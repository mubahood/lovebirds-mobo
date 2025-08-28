import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../../services/compatibility_scoring.dart';
import '../../models/UserModel.dart';
import '../../utils/dating_theme.dart';

class CompatibilityScoreWidget extends StatelessWidget {
  final UserModel user1;
  final UserModel user2;
  final bool showDetails;

  const CompatibilityScoreWidget({
    Key? key,
    required this.user1,
    required this.user2,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final score = CompatibilityScoring.instance.calculateCompatibilityScore(
      user1,
      user2,
    );
    final level = CompatibilityScoring.instance.getCompatibilityLevel(score);
    final insights = CompatibilityScoring.instance.getCompatibilityInsights(
      user1,
      user2,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: DatingTheme.heartGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DatingTheme.primaryPink.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildScoreHeader(score, level),
          if (showDetails) ...[
            _buildCompatibilityBreakdown(),
            _buildInsights(insights),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreHeader(double score, String level) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Circular progress indicator with score
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                ),
              ),
              Column(
                children: [
                  FxText.headlineMedium(
                    '${score.round()}%',
                    color: Colors.white,
                    fontWeight: 800,
                  ),
                  FxText.bodySmall(
                    'Match',
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: 500,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          FxText.titleLarge(
            level,
            color: Colors.white,
            fontWeight: 600,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            _getScoreDescription(score),
            color: Colors.white.withValues(alpha: 0.9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityBreakdown() {
    final breakdown = CompatibilityScoring.instance.getCompatibilityBreakdown(
      user1,
      user2,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(
            'Compatibility Breakdown',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 16),
          ...breakdown.entries
              .map((entry) => _buildBreakdownItem(entry.key, entry.value))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String category, double score) {
    final displayScore = score.clamp(0.0, 100.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyMedium(
                _getCategoryDisplayName(category),
                color: Colors.white,
                fontWeight: 500,
              ),
              FxText.bodyMedium(
                '${displayScore.round()}%',
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: 600,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: displayScore / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getScoreColor(displayScore),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(List<String> insights) {
    if (insights.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: DatingTheme.accentGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              FxText.titleMedium(
                'Compatibility Insights',
                color: Colors.white,
                fontWeight: 600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights
              .map(
                (insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: BoxDecoration(
                          color: DatingTheme.accentGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: FxText.bodyMedium(
                          insight,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFFFF9800); // Orange
    if (score >= 40) return const Color(0xFFFFC107); // Yellow
    return const Color(0xFFF44336); // Red
  }

  String _getScoreDescription(double score) {
    if (score >= 85) return 'You two are incredibly compatible!';
    if (score >= 75) return 'You have excellent compatibility';
    if (score >= 65) return 'You have good compatibility potential';
    if (score >= 50) return 'You have moderate compatibility';
    if (score >= 35) return 'You may face some challenges';
    return 'You may not be the best match';
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'age':
        return 'Age Compatibility';
      case 'location':
        return 'Location';
      case 'lifestyle':
        return 'Lifestyle';
      case 'goals':
        return 'Relationship Goals';
      case 'education':
        return 'Education & Career';
      case 'physical':
        return 'Physical Preferences';
      default:
        return category.toUpperCase();
    }
  }
}

/// Compact compatibility score widget for cards
class CompactCompatibilityWidget extends StatelessWidget {
  final UserModel user1;
  final UserModel user2;
  final double size;

  const CompactCompatibilityWidget({
    Key? key,
    required this.user1,
    required this.user2,
    this.size = 32,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final score = CompatibilityScoring.instance.calculateCompatibilityScore(
      user1,
      user2,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor(score),
            _getScoreColor(score).withValues(alpha: 0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(score).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: FxText.bodySmall(
          '${score.round()}%',
          color: Colors.white,
          fontWeight: 700,
          fontSize: size * 0.3,
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    if (score >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }
}

/// Animated compatibility reveal widget
class CompatibilityRevealWidget extends StatefulWidget {
  final UserModel user1;
  final UserModel user2;
  final VoidCallback? onComplete;

  const CompatibilityRevealWidget({
    Key? key,
    required this.user1,
    required this.user2,
    this.onComplete,
  }) : super(key: key);

  @override
  _CompatibilityRevealWidgetState createState() =>
      _CompatibilityRevealWidgetState();
}

class _CompatibilityRevealWidgetState extends State<CompatibilityRevealWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = CompatibilityScoring.instance.calculateCompatibilityScore(
      widget.user1,
      widget.user2,
    );
    final level = CompatibilityScoring.instance.getCompatibilityLevel(score);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated compatibility circle
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: (score / 100) * _progressAnimation.value,
                        strokeWidth: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(score),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        FxText.displaySmall(
                          '${(score * _progressAnimation.value).round()}%',
                          color: Colors.white,
                          fontWeight: 800,
                        ),
                        FxText.bodyMedium(
                          'Compatible',
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: 500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Animated result text
              Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    FxText.headlineSmall(
                      level,
                      color: Colors.white,
                      fontWeight: 600,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FxText.bodyLarge(
                      _getScoreDescription(score),
                      color: Colors.white.withValues(alpha: 0.9),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    if (score >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  String _getScoreDescription(double score) {
    if (score >= 85) return 'You two are incredibly compatible!';
    if (score >= 75) return 'You have excellent compatibility';
    if (score >= 65) return 'You have good compatibility potential';
    if (score >= 50) return 'You have moderate compatibility';
    if (score >= 35) return 'You may face some challenges';
    return 'You may not be the best match';
  }
}
