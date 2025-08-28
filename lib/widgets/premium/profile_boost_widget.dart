import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../utils/CustomTheme.dart';
import '../../utils/PremiumFeaturesManager.dart';
import '../../utils/SubscriptionManager.dart';

class ProfileBoostWidget extends StatefulWidget {
  final VoidCallback? onBoostActivated;

  const ProfileBoostWidget({Key? key, this.onBoostActivated}) : super(key: key);

  @override
  _ProfileBoostWidgetState createState() => _ProfileBoostWidgetState();
}

class _ProfileBoostWidgetState extends State<ProfileBoostWidget>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _canUseBoost = false;
  int _remainingBoosts = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );
    _pulseController.repeat(reverse: true);
    _checkBoostAvailability();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _checkBoostAvailability() async {
    try {
      final canUse = await PremiumFeaturesManager.canUseBoost();
      final remaining = await PremiumFeaturesManager.getRemainingBoosts();

      setState(() {
        _canUseBoost = canUse;
        _remainingBoosts = remaining;
      });
    } catch (e) {
      print('Error checking boost availability: $e');
    }
  }

  Future<void> _activateBoost() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await PremiumFeaturesManager.activateBoost();

      if (result.success) {
        _showSuccessDialog(result);
        _checkBoostAvailability(); // Refresh status
        widget.onBoostActivated?.call();

        // Track usage
        await PremiumFeaturesManager.trackFeatureUsage('profile_boost');
      } else if (result.requiresUpgrade) {
        PremiumFeaturesManager.showFeatureUpgradePrompt(
          context,
          'Profile Boost',
        );
      } else {
        _showErrorSnackbar(result.message);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to activate boost: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(BoostResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomTheme.primary, CustomTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  SizedBox(height: 20),

                  FxText.titleLarge(
                    'Boost Activated!',
                    color: Colors.white,
                    fontWeight: 700,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12),

                  FxText.bodyMedium(
                    'Your profile will be shown to 2x more people for the next 30 minutes.',
                    color: Colors.white.withValues(alpha: 0.9),
                    textAlign: TextAlign.center,
                  ),

                  if (result.viewsIncrease != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FxText.bodyMedium(
                        'Expected: +${result.viewsIncrease} profile views',
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: FxText.bodyMedium(
                            'Continue Swiping',
                            color: Colors.white,
                            fontWeight: 600,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigate to matches to see results
                            Get.snackbar(
                              'Tip',
                              'Check your matches in 30 minutes to see the boost results!',
                              backgroundColor: Colors.green.withValues(alpha: 0.9),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: FxText.bodyMedium(
                            'View Matches',
                            color: CustomTheme.primary,
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

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Boost Error',
      message,
      backgroundColor: Colors.red.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.8),
            Colors.deepOrange.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap:
              _canUseBoost && !_isLoading
                  ? _activateBoost
                  : () => _showNotAvailableInfo(),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder:
                          (context, child) => Transform.scale(
                            scale: _canUseBoost ? _pulseAnimation.value : 1.0,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                    ),

                    SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              FxText.titleMedium(
                                'Profile Boost',
                                color: Colors.white,
                                fontWeight: 700,
                              ),
                              if (_remainingBoosts > 0) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FxText.bodySmall(
                                    '$_remainingBoosts left',
                                    color: Colors.white,
                                    fontWeight: 600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4),
                          FxText.bodySmall(
                            _canUseBoost
                                ? '2x profile visibility for 30 minutes'
                                : 'Premium feature - upgrade to unlock',
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                    ),

                    if (_isLoading)
                      Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    else
                      Icon(
                        _canUseBoost ? Icons.play_arrow : Icons.lock,
                        color: Colors.white,
                        size: 24,
                      ),
                  ],
                ),

                SizedBox(height: 16),

                // Benefits row
                Row(
                  children: [
                    Expanded(
                      child: _buildBenefitItem(Icons.visibility, 'More Views'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildBenefitItem(Icons.favorite, 'More Likes'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildBenefitItem(Icons.people, 'More Matches'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(height: 4),
        FxText.bodySmall(
          label,
          color: Colors.white.withValues(alpha: 0.9),
          textAlign: TextAlign.center,
          fontWeight: 500,
        ),
      ],
    );
  }

  void _showNotAvailableInfo() async {
    final hasSubscription = await SubscriptionManager.hasActiveSubscription();

    if (!hasSubscription) {
      PremiumFeaturesManager.showFeatureUpgradePrompt(context, 'Profile Boost');
    } else {
      Get.snackbar(
        'Boost Not Available',
        'You\'ve used all your boosts for today. More will be available tomorrow!',
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
