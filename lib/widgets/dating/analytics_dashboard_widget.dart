import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import '../../utils/CustomTheme.dart';
import '../../services/swipe_service.dart';

class AnalyticsDashboardWidget extends StatefulWidget {
  final SwipeStats stats;
  final VoidCallback? onUpgradePressed;

  const AnalyticsDashboardWidget({
    Key? key,
    required this.stats,
    this.onUpgradePressed,
  }) : super(key: key);

  @override
  _AnalyticsDashboardWidgetState createState() =>
      _AnalyticsDashboardWidgetState();
}

class _AnalyticsDashboardWidgetState extends State<AnalyticsDashboardWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Start animations
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  double get matchRate {
    final totalSwipes = widget.stats.likesGiven + widget.stats.passesGiven;
    if (totalSwipes == 0) return 0.0;
    return (widget.stats.matches / totalSwipes * 100).clamp(0.0, 100.0);
  }

  double get likeSuccessRate {
    if (widget.stats.likesGiven == 0) return 0.0;
    return (widget.stats.matches / widget.stats.likesGiven * 100).clamp(
      0.0,
      100.0,
    );
  }

  double get profilePopularity {
    final totalActivity = widget.stats.likesReceived + widget.stats.matches;
    if (totalActivity == 0) return 0.0;
    return (totalActivity / 100 * 100).clamp(
      0.0,
      100.0,
    ); // Normalize to percentage
  }

  void _triggerHapticFeedback() {
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomTheme.card, CustomTheme.cardDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildMatchRateSection(),
                  const SizedBox(height: 20),
                  _buildStatsGrid(),
                  const SizedBox(height: 20),
                  _buildPerformanceIndicators(),
                  if (_shouldShowUpgradePrompt()) ...[
                    const SizedBox(height: 20),
                    _buildUpgradePrompt(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CustomTheme.primary,
                CustomTheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.trending_up, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FxText.titleMedium(
                'Your Dating Analytics',
                color: CustomTheme.color,
                fontWeight: 700,
              ),
              const SizedBox(height: 4),
              FxText.bodySmall(
                'Track your success and improve your game',
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchRateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomTheme.primary.withValues(alpha: 0.1),
            CustomTheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.titleMedium(
                'Match Success Rate',
                color: CustomTheme.color,
                fontWeight: 600,
              ),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return FxText.titleLarge(
                    '${(matchRate * _progressAnimation.value).toInt()}%',
                    color: CustomTheme.primary,
                    fontWeight: 700,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(matchRate / 100, CustomTheme.primary),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodySmall(
                '${widget.stats.matches} matches',
                color: Colors.grey[600],
              ),
              FxText.bodySmall(
                '${widget.stats.likesGiven + widget.stats.passesGiven} total swipes',
                color: Colors.grey[600],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          icon: Icons.favorite,
          title: 'Like Success',
          value: '${likeSuccessRate.toInt()}%',
          subtitle:
              '${widget.stats.matches}/${widget.stats.likesGiven} likes matched',
          color: Colors.pink,
        ),
        _buildStatCard(
          icon: Icons.visibility,
          title: 'Profile Views',
          value: '${widget.stats.likesReceived}',
          subtitle: 'People who liked you',
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.star,
          title: 'Super Likes',
          value: '${widget.stats.superLikesGiven}',
          subtitle: 'Premium gestures sent',
          color: Colors.amber,
        ),
        _buildStatCard(
          icon: Icons.trending_up,
          title: 'Popularity',
          value: '${profilePopularity.toInt()}%',
          subtitle: 'Based on activity',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: FxText.bodyMedium(
                  title,
                  color: CustomTheme.color,
                  fontWeight: 600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FxText.titleLarge(value, color: color, fontWeight: 700),
          const SizedBox(height: 4),
          FxText.bodySmall(subtitle, color: Colors.grey[600], maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.titleMedium(
          'Performance Indicators',
          color: CustomTheme.color,
          fontWeight: 600,
        ),
        const SizedBox(height: 16),
        _buildIndicatorRow(
          'Engagement Rate',
          likeSuccessRate / 100,
          Colors.green,
          '${widget.stats.matches} matches from ${widget.stats.likesGiven} likes',
        ),
        const SizedBox(height: 12),
        _buildIndicatorRow(
          'Profile Attractiveness',
          profilePopularity / 100,
          Colors.purple,
          '${widget.stats.likesReceived} people liked your profile',
        ),
        const SizedBox(height: 12),
        _buildIndicatorRow(
          'Activity Level',
          ((widget.stats.likesGiven + widget.stats.passesGiven) / 100).clamp(
            0.0,
            1.0,
          ),
          Colors.orange,
          '${widget.stats.likesGiven + widget.stats.passesGiven} total interactions',
        ),
      ],
    );
  }

  Widget _buildIndicatorRow(
    String title,
    double progress,
    Color color,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FxText.bodyMedium(title, color: CustomTheme.color, fontWeight: 500),
            FxText.bodyMedium(
              '${(progress * 100).toInt()}%',
              color: color,
              fontWeight: 600,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildProgressBar(progress, color),
        const SizedBox(height: 4),
        FxText.bodySmall(subtitle, color: Colors.grey[600]),
      ],
    );
  }

  Widget _buildProgressBar(double progress, Color color) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: (progress * _progressAnimation.value).clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _shouldShowUpgradePrompt() {
    // Show upgrade prompt if user is active but has low remaining limits
    return widget.stats.likesRemaining < 10 ||
        widget.stats.superLikesRemaining == 0 ||
        matchRate < 5.0; // Low match rate suggests they need premium features
  }

  Widget _buildUpgradePrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.primary.withValues(alpha: 0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomTheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, color: CustomTheme.primary, size: 24),
              const SizedBox(width: 8),
              FxText.titleMedium(
                'Boost Your Success!',
                color: CustomTheme.primary,
                fontWeight: 700,
              ),
            ],
          ),
          const SizedBox(height: 12),
          FxText.bodyMedium(
            'Upgrade to Premium for unlimited likes, super likes, and advanced analytics to improve your match rate!',
            color: CustomTheme.color,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _triggerHapticFeedback();
                widget.onUpgradePressed?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
              ),
              child: FxText.bodyMedium(
                'Upgrade Now',
                color: Colors.white,
                fontWeight: 600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
