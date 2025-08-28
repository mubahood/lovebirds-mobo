import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/subscription/subscription_selection_screen.dart';
import '../utils/CustomTheme.dart';
import '../config/debug_config.dart';

class PaywallMiddleware {
  static bool _isSubscriptionActive = false;
  static DateTime? _lastSubscriptionCheck;
  static const Duration _checkInterval = Duration(hours: 1);

  /// Check if user has active subscription
  static bool get isSubscribed => _isSubscriptionActive;

  /// Initialize subscription status on app start
  static Future<void> initialize() async {
    await _checkSubscriptionStatus();
  }

  /// Force subscription check
  static Future<bool> checkSubscriptionStatus() async {
    return await _checkSubscriptionStatus();
  }

  /// Enforce subscription paywall
  static Future<bool> enforcePaywall({
    String? triggerReason,
    bool allowBypass = false,
  }) async {
    // Check debug bypass first
    if (DebugConfig.bypassSubscription || allowBypass) {
      print('🔓 Paywall bypassed for testing');
      return true;
    }

    // Check if subscription verification is needed
    if (_needsSubscriptionCheck()) {
      await _checkSubscriptionStatus();
    }

    // If subscribed, allow access
    if (_isSubscriptionActive) {
      return true;
    }

    // If not subscribed, show paywall
    _showPaywallScreen(triggerReason);
    return false;
  }

  /// Show subscription selection screen
  static void _showPaywallScreen(String? reason) {
    // Use SchedulerBinding to delay navigation after current build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.to(
        () => SubscriptionSelectionScreen(triggerReason: reason),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
      );
    });
  }

  /// Check if we need to verify subscription status
  static bool _needsSubscriptionCheck() {
    if (_lastSubscriptionCheck == null) return true;
    return DateTime.now().difference(_lastSubscriptionCheck!) > _checkInterval;
  }

  /// Internal method to check subscription with backend
  static Future<bool> _checkSubscriptionStatus() async {
    try {
      _lastSubscriptionCheck = DateTime.now();

      // TODO: Replace with actual API call to check subscription
      // For now, simulate the API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock subscription check - in real implementation:
      // 1. Call backend API to verify subscription
      // 2. Check Stripe/Apple/Google subscription status
      // 3. Validate subscription expiry date
      // 4. Update local subscription state

      // TEMPORARY: Always return false to enforce paywall
      // Change this to true for testing without paywall
      _isSubscriptionActive = false;

      return _isSubscriptionActive;
    } catch (e) {
      print('Subscription check failed: $e');
      // On error, assume not subscribed for security
      _isSubscriptionActive = false;
      return false;
    }
  }

  /// Update subscription status (call after successful payment)
  static void updateSubscriptionStatus(bool isActive) {
    _isSubscriptionActive = isActive;
    _lastSubscriptionCheck = DateTime.now();
  }

  /// Show upgrade prompt for specific features
  static void showUpgradePrompt({
    required String feature,
    String? description,
  }) {
    Get.dialog(
      PaywallUpgradeDialog(feature: feature, description: description),
      barrierDismissible: true,
    );
  }
}

/// Upgrade prompt dialog for specific features
class PaywallUpgradeDialog extends StatelessWidget {
  final String feature;
  final String? description;

  const PaywallUpgradeDialog({
    Key? key,
    required this.feature,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: CustomTheme.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomTheme.primary, Colors.pink],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Premium Feature',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            // Feature description
            Text(
              description ?? 'Unlock $feature with Lovebirds Premium',
              style: TextStyle(color: Colors.grey[300], fontSize: 16),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            // Benefits list
            _buildBenefit(Icons.all_inclusive, 'Unlimited swipes & matches'),
            _buildBenefit(Icons.star, '5 super likes per day'),
            _buildBenefit(Icons.visibility, 'See who likes you'),
            _buildBenefit(Icons.trending_up, 'Profile boost feature'),

            const SizedBox(height: 25),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[600]!),
                      ),
                    ),
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.to(
                        () => SubscriptionSelectionScreen(
                          triggerReason: 'upgrade_prompt',
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Get Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: CustomTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
