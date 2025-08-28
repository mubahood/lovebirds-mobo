import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/swipe_service.dart';
import '../../utils/CustomTheme.dart';
import '../../widgets/common/responsive_dialog_wrapper.dart';
import '../../widgets/dating/ProfileStatsWidget.dart';
import '../../widgets/dating/analytics_dashboard_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  SwipeStats? stats;
  List<ActivityItem> recentActivity = [];
  bool isLoading = true;
  String errorMessage = '';

  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAnalytics();
  }

  void _setupAnimations() {
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      await _refreshController.forward();
      _refreshController.reset();
    }

    try {
      final results = await Future.wait([
        SwipeService.getSwipeStats(),
        SwipeService.getRecentActivity(days: 7),
      ]);
      setState(() {
        stats = results[0] as SwipeStats?;
        recentActivity = results[1] as List<ActivityItem>;
        isLoading = false;
      });
      if (stats == null) {
        errorMessage = 'No analytics data available.';
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load analytics: ${e.toString()}';
      });
    }
  }

  void _showUpgradeDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => ResponsiveDialogWrapper(
        backgroundColor: CustomTheme.card,
        child: ResponsiveDialogPadding(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.analytics, color: CustomTheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FxText.titleMedium(
                      'Analytics Pro',
                      color: Colors.white,
                      fontWeight: 700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              FxText.bodyMedium(
                'Unlock advanced insights to optimize your profile and maximize matches!',
                textAlign: TextAlign.center,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),

              // Feature list
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomTheme.primary.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildUpgradeFeature(
                      Icons.bar_chart,
                      'Detailed Match Analytics',
                      CustomTheme.primary,
                    ),
                    _buildUpgradeFeature(
                      Icons.trending_up,
                      'Success Rate Tracking',
                      CustomTheme.successGreen,
                    ),
                    _buildUpgradeFeature(
                      Icons.insights,
                      'Profile Optimization Tips',
                      CustomTheme.accentGold,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[600]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: FxText.bodyMedium(
                        'Maybe Later',
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: navigate to upgrade
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeFeature(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          FxText.bodyMedium(label, color: Colors.white),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.card,
        elevation: 0,
        title: FxText.titleMedium(
          'Dating Analytics',
          color: Colors.white,
          fontWeight: 700,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          AnimatedBuilder(
            animation: _refreshAnimation,
            builder: (_, __) => Transform.rotate(
              angle: _refreshAnimation.value * 2 * 3.14159,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed:
                isLoading ? null : () => _loadAnalytics(refresh: true),
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
      body: isLoading && stats == null
          ? _buildLoadingState()
          : errorMessage.isNotEmpty
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _shimmerBox(height: 200, radius: 20),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _shimmerBox(height: 120, radius: 16)),
          const SizedBox(width: 12),
          Expanded(child: _shimmerBox(height: 120, radius: 16)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _shimmerBox(height: 120, radius: 16)),
          const SizedBox(width: 12),
          Expanded(child: _shimmerBox(height: 120, radius: 16)),
        ]),
        const SizedBox(height: 16),
        _shimmerBox(height: 150, radius: 16),
      ],
    );
  }

  Widget _shimmerBox({required double height, required double radius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: CustomTheme.card,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined,
                size: 80, color: CustomTheme.errorRed),
            const SizedBox(height: 20),
            FxText.titleMedium(
              'Analytics Unavailable',
              color: CustomTheme.color,
              fontWeight: 600,
            ),
            const SizedBox(height: 8),
            FxText.bodyMedium(errorMessage,
                color: CustomTheme.colorSecondary, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadAnalytics(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: FxText.bodyMedium('Retry',
                  color: Colors.white, fontWeight: 600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (stats == null) return _buildErrorState();

    return RefreshIndicator(
      onRefresh: () => _loadAnalytics(refresh: true),
      color: CustomTheme.primary,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          AnalyticsDashboardWidget(
            stats: stats!,
            onUpgradePressed: _showUpgradeDialog,
          ),
          const ProfileStatsWidget(),
          _buildRecentActivitySection(),
          if (_hasEnoughDataForWeeklySummary()) _buildWeeklySummarySection(),
          _buildTipsSection(),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.history, color: CustomTheme.primary, size: 24),
            const SizedBox(width: 12),
            FxText.titleMedium('Recent Activity',
                color: CustomTheme.color, fontWeight: 700),
          ]),
          const SizedBox(height: 16),
          if (recentActivity.isEmpty)
            _buildEmptyActivity()
          else
            ...recentActivity
                .take(5)
                .map((a) => _buildActivityItem(a))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Column(
      children: [
        Icon(Icons.timeline, size: 48, color: Colors.grey[600]),
        const SizedBox(height: 12),
        FxText.bodyMedium('No recent activity',
            color: Colors.grey[500]),
        const SizedBox(height: 4),
        FxText.bodySmall(
          'Start swiping to see activity here',
          color: Colors.grey[500],
        ),
      ],
    );
  }

  Widget _buildActivityItem(ActivityItem a) {
    IconData icon;
    Color color;
    String desc;
    switch (a.type) {
      case 'like_received':
        icon = Icons.favorite;
        color = Colors.pink;
        desc = '${a.user.first_name} liked you';
        break;
      case 'super_like_received':
        icon = Icons.star;
        color = CustomTheme.accentGold;
        desc = '${a.user.first_name} super liked you';
        break;
      case 'match':
        icon = Icons.favorite;
        color = CustomTheme.successGreen;
        desc = 'You matched with ${a.user.first_name}';
        break;
      default:
        icon = Icons.notifications;
        color = CustomTheme.primary;
        desc = 'New activity';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FxText.bodyMedium(desc, color: CustomTheme.color, fontWeight: 500),
              FxText.bodySmall(a.timeAgo, color: Colors.grey[500]),
            ],
          ),
        ),
      ]),
    );
  }

  bool _hasEnoughDataForWeeklySummary() {
    if (stats == null) return false;
    return (stats!.likesGiven + stats!.passesGiven) > 10;
  }

  Widget _buildWeeklySummarySection() {
    final total = stats!.likesGiven + stats!.passesGiven;
    final avg = (total / 7).round();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.calendar_today, color: CustomTheme.accentGold, size: 24),
          const SizedBox(width: 12),
          FxText.titleMedium('Weekly Summary',
              color: CustomTheme.color, fontWeight: 700),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: _buildSummaryCard(
              'Daily Average',
              '$avg swipes',
              Icons.swipe,
              CustomTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Best Day',
              _getBestDayMetric(),
              Icons.trending_up,
              CustomTheme.successGreen,
            ),
          ),
        ]),
      ]),
    );
  }

  String _getBestDayMetric() {
    if (stats!.matches > 0) return '${stats!.matches} matches';
    if (stats!.likesReceived > 0) return '${stats!.likesReceived} likes';
    return 'Keep swiping!';
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        FxText.bodySmall(title, color: Colors.grey[500]),
        FxText.bodyMedium(value, color: color, fontWeight: 600),
      ]),
    );
  }

  Widget _buildTipsSection() {
    final tips = _generatePersonalizedTips();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomTheme.primary.withOpacity(0.1),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CustomTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.lightbulb_outline,
              color: CustomTheme.primary, size: 24),
          const SizedBox(width: 12),
          FxText.titleMedium('Success Tips',
              color: CustomTheme.primary, fontWeight: 700),
        ]),
        const SizedBox(height: 16),
        ...tips.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Icon(Icons.arrow_right,
                color: CustomTheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: FxText.bodyMedium(t, color: CustomTheme.color),
            ),
          ]),
        )),
      ]),
    );
  }

  List<String> _generatePersonalizedTips() {
    final List<String> tips = [];
    if (stats!.matches == 0) {
      tips.add('Add more photos to increase your match rate');
    }
    if (stats!.likesGiven > 0 &&
        stats!.matches / stats!.likesGiven < 0.1) {
      tips.add('Be selective with likes to improve match quality');
    }
    if (stats!.superLikesGiven == 0) {
      tips.add('Try using Super Likes on profiles you love');
    }
    if (tips.isEmpty) {
      tips.add('Great job! Keep being authentic.');
    }
    return tips;
  }
}
