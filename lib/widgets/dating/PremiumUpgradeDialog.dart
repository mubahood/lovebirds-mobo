import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../services/swipe_service.dart';
import '../../utils/CustomTheme.dart';
import '../common/responsive_dialog_wrapper.dart';

class PremiumUpgradeDialog extends StatefulWidget {
  final String triggerReason;
  final SwipeStats? stats;
  final Map<String, dynamic>? customData;

  const PremiumUpgradeDialog({
    Key? key,
    required this.triggerReason,
    this.stats,
    this.customData,
  }) : super(key: key);

  @override
  _PremiumUpgradeDialogState createState() => _PremiumUpgradeDialogState();
}

class _PremiumUpgradeDialogState extends State<PremiumUpgradeDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _pulseController.repeat(reverse: true);
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String get dialogTitle {
    switch (widget.triggerReason) {
      case 'daily_limit':
        return '🚀 Unlimited Swipes Await!';
      case 'match_potential':
        return '💕 Unlock Your Match Potential!';
      case 'profile_boost':
        return '⭐ Boost Your Visibility!';
      case 'super_likes':
        return '✨ Send More Super Likes!';
      case 'analytics_pro':
        return '📊 Advanced Analytics Pro!';
      default:
        return '💎 Upgrade to Premium!';
    }
  }

  String get dialogSubtitle {
    switch (widget.triggerReason) {
      case 'daily_limit':
        return 'You\'ve used ${widget.stats?.likesRemaining ?? 0} likes today. Get unlimited!';
      case 'match_potential':
        return 'Users with premium get 3x more matches on average';
      case 'profile_boost':
        return 'Boost your profile to appear first for 30 minutes';
      case 'super_likes':
        return 'Send up to 5 super likes per day with premium';
      case 'analytics_pro':
        return 'Get detailed insights about your dating performance';
      default:
        return 'Unlock all premium features and find love faster';
    }
  }

  List<String> get benefits {
    switch (widget.triggerReason) {
      case 'daily_limit':
        return [
          'Unlimited daily swipes',
          '5 super likes per day',
          'See who liked you',
          'Rewind last swipes',
          'Profile boost feature',
        ];
      case 'match_potential':
        return [
          '3x more profile visibility',
          'Advanced matching algorithm',
          'See mutual interests',
          'Priority customer support',
          'Read receipts in messages',
        ];
      case 'profile_boost':
        return [
          'Profile boost (2x visibility)',
          'Appear first in discovery',
          'Highlighted in search results',
          'Premium badge on profile',
          'Advanced analytics',
        ];
      case 'super_likes':
        return [
          '5 super likes daily',
          'Custom super like messages',
          'Higher match probability',
          'Stand out from the crowd',
          'Premium super like effects',
        ];
      case 'analytics_pro':
        return [
          'Detailed profile analytics',
          'Match success insights',
          'Optimal activity times',
          'Performance trends',
          'Improvement suggestions',
        ];
      default:
        return [
          'Unlimited swipes',
          'See who likes you',
          'Super likes & boosts',
          'Advanced filters',
          'Premium support',
        ];
    }
  }

  Color get accentColor {
    switch (widget.triggerReason) {
      case 'daily_limit':
        return Colors.red;
      case 'match_potential':
        return Colors.pink;
      case 'profile_boost':
        return Colors.orange;
      case 'super_likes':
        return Colors.blue;
      case 'analytics_pro':
        return Colors.purple;
      default:
        return CustomTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ResponsiveDialogWrapper(
        backgroundColor: CustomTheme.card,
        child: ResponsiveDialogColumn(
          children: [
            _buildHeader(),
            _buildContent(),
            _buildPricingOptions(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ResponsiveDialogPadding(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getHeaderIcon(),
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            FxText.titleLarge(
              dialogTitle,
              color: Colors.white,
              fontWeight: 700,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            FxText.bodyMedium(
              dialogSubtitle,
              color: Colors.white.withValues(alpha: 0.9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getHeaderIcon() {
    switch (widget.triggerReason) {
      case 'daily_limit':
        return Icons.all_inclusive;
      case 'match_potential':
        return Icons.favorite;
      case 'profile_boost':
        return Icons.rocket_launch;
      case 'super_likes':
        return Icons.star;
      case 'analytics_pro':
        return Icons.analytics;
      default:
        return Icons.diamond;
    }
  }

  Widget _buildContent() {
    return ResponsiveDialogPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.bodyLarge(
            'Premium Benefits:',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
          const SizedBox(height: 16),
          ...benefits.map((benefit) => _buildBenefitItem(benefit)),
          if (widget.triggerReason == 'daily_limit' &&
              widget.stats != null) ...[
            const SizedBox(height: 16),
            _buildUsageStats(),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 16, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: FxText.bodyMedium(benefit, color: CustomTheme.color)),
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    if (widget.stats == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.bodyMedium(
            'Your Stats Today:',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodySmall('Likes Used:', color: CustomTheme.color2),
              FxText.bodySmall(
                '${50 - (widget.stats?.likesRemaining ?? 50)} / 50',
                color: accentColor,
                fontWeight: 600,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodySmall('Matches Today:', color: CustomTheme.color2),
              FxText.bodySmall(
                '${widget.stats?.matches ?? 0}',
                color: Colors.green,
                fontWeight: 600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOptions() {
    return ResponsiveDialogPadding(
      horizontal: 24,
      vertical: 0,
      child: Column(
        children: [
          _buildPricingOption(
            '1 Week Trial',
            '\$10 CAD',
            'Perfect for testing premium',
            false,
          ),
          const SizedBox(height: 8),
          _buildPricingOption(
            '1 Month',
            '\$30 CAD',
            'Most Popular Choice',
            true,
          ),
          const SizedBox(height: 8),
          _buildPricingOption(
            '3 Months',
            '\$70 CAD',
            'Best Value - Save \$20',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOption(
    String duration,
    String price,
    String subtitle,
    bool isPopular,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            isPopular
                ? accentColor.withValues(alpha: 0.1)
                : CustomTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: isPopular ? Border.all(color: accentColor, width: 2) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Radio<String>(
          value: duration,
          groupValue: isPopular ? duration : null,
          onChanged: (value) {},
          activeColor: accentColor,
        ),
        title: Row(
          children: [
            FxText.bodyMedium(
              duration,
              color: CustomTheme.color,
              fontWeight: 600,
            ),
            if (isPopular) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FxText.bodySmall(
                  'POPULAR',
                  color: Colors.white,
                  fontWeight: 600,
                ),
              ),
            ],
            const Spacer(),
            FxText.bodyLarge(price, color: accentColor, fontWeight: 700),
          ],
        ),
        subtitle: FxText.bodySmall(subtitle, color: CustomTheme.color2),
      ),
    );
  }

  Widget _buildActionButtons() {
    return ResponsiveDialogPadding(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
              child: FxText.bodyLarge(
                'Start Premium Now',
                color: Colors.white,
                fontWeight: 700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: FxText.bodyMedium('Maybe Later', color: CustomTheme.color2),
          ),
          const SizedBox(height: 8),
          FxText.bodySmall(
            'Cancel anytime • No commitment',
            color: CustomTheme.color2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleUpgrade() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();

    // Log the upgrade trigger for analytics
    print('Premium upgrade triggered: ${widget.triggerReason}');

    // Navigate to subscription screen (to be implemented)
    // Get.to(() => SubscriptionScreen(preSelectedPlan: '1 Month'));

    // For now, show success message
    Get.snackbar(
      'Premium Upgrade',
      'Subscription screen coming soon!',
      backgroundColor: accentColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}

// Static helper methods for showing upgrade dialogs
class PremiumPrompts {
  static void showDailyLimitReached(BuildContext context, SwipeStats stats) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) =>
              PremiumUpgradeDialog(triggerReason: 'daily_limit', stats: stats),
    );
  }

  static void showMatchPotential(BuildContext context, {int matchCount = 0}) {
    showDialog(
      context: context,
      builder:
          (context) => PremiumUpgradeDialog(
            triggerReason: 'match_potential',
            customData: {'matchCount': matchCount},
          ),
    );
  }

  static void showBoostOpportunity(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => PremiumUpgradeDialog(triggerReason: 'profile_boost'),
    );
  }

  static void showSuperLikesUpgrade(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PremiumUpgradeDialog(triggerReason: 'super_likes'),
    );
  }

  static void showAnalyticsPro(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => PremiumUpgradeDialog(triggerReason: 'analytics_pro'),
    );
  }
}
