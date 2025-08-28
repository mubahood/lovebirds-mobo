import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../../utils/dating_theme.dart';

/// Optimized compact swipe progress indicator - replaces the bulky white overlay
/// Provides essential swipe information in a minimalist, non-intrusive design
class CompactSwipeIndicator extends StatefulWidget {
  final int likesRemaining;
  final int superLikesRemaining;
  final bool isLoading;
  final VoidCallback onUpgradePressed;
  final bool showDetailed;

  // Daily limits for free users
  static const int maxDailyLikes = 50;
  static const int maxDailySuperLikes = 3;

  const CompactSwipeIndicator({
    Key? key,
    required this.likesRemaining,
    required this.superLikesRemaining,
    required this.isLoading,
    required this.onUpgradePressed,
    this.showDetailed = false,
  }) : super(key: key);

  @override
  State<CompactSwipeIndicator> createState() => _CompactSwipeIndicatorState();
}

class _CompactSwipeIndicatorState extends State<CompactSwipeIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.1),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    // Start pulsing if limits are low
    if (_shouldShowWarning()) {
      _pulseController.repeat(reverse: true);
    }
  }

  bool _shouldShowWarning() {
    final likesProgress =
        widget.likesRemaining / CompactSwipeIndicator.maxDailyLikes;
    return likesProgress <= 0.2 || widget.likesRemaining <= 5;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showDetailed) {
      return _buildDetailedPanel();
    }
    return _buildCompactFloatingBadge();
  }

  Widget _buildCompactFloatingBadge() {
    final likesProgress =
        1.0 - (widget.likesRemaining / CompactSwipeIndicator.maxDailyLikes);
    final isLowOnLikes = widget.likesRemaining <= 5;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      right: 16,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isLowOnLikes ? _pulseAnimation.value : 1.0,
            child: SlideTransition(
              position: _slideAnimation,
              child: GestureDetector(
                onTap: _toggleExpanded,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      _isExpanded
                          ? const EdgeInsets.all(12)
                          : const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                  decoration: BoxDecoration(
                    gradient: _getGradientForStatus(),
                    borderRadius: BorderRadius.circular(_isExpanded ? 16 : 20),
                    boxShadow: [
                      BoxShadow(
                        color: DatingTheme.primaryPink.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child:
                      _isExpanded
                          ? _buildExpandedContent()
                          : _buildCompactContent(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(FeatherIcons.heart, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(
          '${widget.likesRemaining}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        if (widget.isLoading) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpandedContent() {
    final likesProgress =
        1.0 - (widget.likesRemaining / CompactSwipeIndicator.maxDailyLikes);
    final superLikesProgress =
        1.0 -
        (widget.superLikesRemaining / CompactSwipeIndicator.maxDailySuperLikes);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FeatherIcons.activity, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              'Daily Progress',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Likes progress
        _buildMiniProgressBar(
          icon: FeatherIcons.heart,
          label: 'Likes',
          remaining: widget.likesRemaining,
          total: CompactSwipeIndicator.maxDailyLikes,
          progress: likesProgress,
        ),

        const SizedBox(height: 6),

        // Super likes progress
        _buildMiniProgressBar(
          icon: FeatherIcons.star,
          label: 'Super',
          remaining: widget.superLikesRemaining,
          total: CompactSwipeIndicator.maxDailySuperLikes,
          progress: superLikesProgress,
        ),

        // Upgrade button if needed
        if (widget.likesRemaining <= 5) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: widget.onUpgradePressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Get More',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMiniProgressBar({
    required IconData icon,
    required String label,
    required int remaining,
    required int total,
    required double progress,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 12),
        const SizedBox(width: 4),
        Text(
          '$remaining',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DatingTheme.primaryPink.withValues(alpha: 0.1),
            DatingTheme.primaryPink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DatingTheme.primaryPink.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FeatherIcons.activity,
                color: DatingTheme.primaryPink,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Today\'s Activity',
                  style: TextStyle(
                    color: DatingTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Icon(
                  _isExpanded
                      ? FeatherIcons.chevronUp
                      : FeatherIcons.chevronDown,
                  color: DatingTheme.primaryPink,
                  size: 16,
                ),
              ),
            ],
          ),

          if (_isExpanded) ...[
            const SizedBox(height: 12),
            _buildDetailedProgressBar(
              icon: FeatherIcons.heart,
              label: 'Likes Remaining',
              remaining: widget.likesRemaining,
              total: CompactSwipeIndicator.maxDailyLikes,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            _buildDetailedProgressBar(
              icon: FeatherIcons.star,
              label: 'Super Likes',
              remaining: widget.superLikesRemaining,
              total: CompactSwipeIndicator.maxDailySuperLikes,
              color: Colors.amber,
            ),

            if (widget.likesRemaining <= 10) ...[
              const SizedBox(height: 12),
              _buildUpgradePrompt(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedProgressBar({
    required IconData icon,
    required String label,
    required int remaining,
    required int total,
    required Color color,
  }) {
    final progress = 1.0 - (remaining / total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DatingTheme.primaryText,
              ),
            ),
            const Spacer(),
            Text(
              '$remaining/$total',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildUpgradePrompt() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DatingTheme.primaryPink.withValues(alpha: 0.1),
            DatingTheme.primaryPink.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(FeatherIcons.zap, color: DatingTheme.primaryPink, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Running low on likes?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: DatingTheme.primaryPink,
                  ),
                ),
                Text(
                  'Upgrade for unlimited swipes',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onUpgradePressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DatingTheme.primaryPink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Upgrade',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getGradientForStatus() {
    if (widget.likesRemaining <= 0) {
      return LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]);
    } else if (widget.likesRemaining <= 5) {
      return LinearGradient(
        colors: [Colors.orange.shade400, Colors.orange.shade600],
      );
    } else if (widget.likesRemaining <= 15) {
      return LinearGradient(
        colors: [Colors.amber.shade400, Colors.amber.shade600],
      );
    }
    return LinearGradient(
      colors: [
        DatingTheme.primaryPink,
        DatingTheme.primaryPink.withValues(alpha: 0.8),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
