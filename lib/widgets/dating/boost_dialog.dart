import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/services/BoostService.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';
import 'package:lovebirds_app/utils/Utilities.dart';
import '../../screens/subscription/subscription_selection_screen.dart';
import '../common/responsive_dialog_wrapper.dart';

class BoostDialog extends StatefulWidget {
  final Map<String, dynamic>? boostStatus;
  final Map<String, dynamic>? subscriptionStatus;
  final VoidCallback? onBoostActivated;

  const BoostDialog({
    Key? key,
    this.boostStatus,
    this.subscriptionStatus,
    this.onBoostActivated,
  }) : super(key: key);

  @override
  _BoostDialogState createState() => _BoostDialogState();
}

class _BoostDialogState extends State<BoostDialog>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _showPurchaseOption = false;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkPurchaseOption();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _sparkleController.repeat();
  }

  void _checkPurchaseOption() {
    final availableBoosts = widget.boostStatus?['available_boosts'] ?? {};
    final boostType = availableBoosts['type'] ?? 'credits';
    final boostCount = availableBoosts['count'] ?? 0;

    _showPurchaseOption = boostType != 'unlimited' && boostCount == 0;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  Future<void> _activateBoost() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.lightImpact();

      final result = await BoostService.boostProfile();

      if (result.code == 1) {
        Utils.toast(
          'Boost activated! Your profile is now 3x more visible!',
          color: Colors.green,
        );

        // Success animation
        HapticFeedback.mediumImpact();

        if (widget.onBoostActivated != null) {
          widget.onBoostActivated!();
        }

        Navigator.of(context).pop(true);
      } else {
        // If user needs to purchase, redirect to subscription page
        if (result.message.contains('need a premium subscription') ||
            result.message.contains('boost credits')) {
          Navigator.of(context).pop();
          Get.to(() => const SubscriptionSelectionScreen());
          return;
        }

        Utils.toast(result.message);
        setState(() {
          _showPurchaseOption = true;
        });
      }
    } catch (e) {
      Utils.toast('Failed to activate boost. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildBoostIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  CustomTheme.primary,
                  CustomTheme.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: CustomTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.rocket_launch, size: 40, color: Colors.white),
                AnimatedBuilder(
                  animation: _sparkleAnimation,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: CustomPaint(
                        painter: SparklesPainter(_sparkleAnimation.value),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoostButton() {
    final buttonState = BoostService.getBoostButtonState(widget.boostStatus);
    final isEnabled = buttonState['enabled'] as bool;
    final buttonText = buttonState['text'] as String;
    final buttonColor = buttonState['color'] as String;
    final subtitle = buttonState['subtitle'] as String?;

    Color getButtonColor() {
      switch (buttonColor) {
        case 'success':
          return Colors.green;
        case 'premium':
          return Colors.purple;
        case 'purchase':
          return Colors.orange;
        case 'disabled':
          return Colors.grey;
        default:
          return CustomTheme.primary;
      }
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading || !isEnabled ? null : _activateBoost,
            style: ElevatedButton.styleFrom(
              backgroundColor: getButtonColor(),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isEnabled ? 4 : 0,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: CustomTheme.color2),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildPurchaseOption() {
    if (!_showPurchaseOption) return const SizedBox.shrink();

    final pricing = BoostService.getBoostPricing();
    final singleBoost = pricing['single_boost'];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Boost Package',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CustomTheme.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      singleBoost['description'],
                      style: TextStyle(fontSize: 14, color: CustomTheme.color2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${singleBoost['duration_minutes']} minutes • ${singleBoost['visibility_multiplier']}x visibility',
                      style: TextStyle(fontSize: 12, color: CustomTheme.color2),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  singleBoost['formatted_price'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Implement in-app purchase
                Utils.toast('In-app purchase coming soon!');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Purchase Boost',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPromo() {
    final isPremium = widget.subscriptionStatus?['is_premium'] ?? false;
    if (isPremium) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.diamond, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Premium Benefits',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Get unlimited boosts + 5 super likes daily + see who liked you',
            style: TextStyle(fontSize: 14, color: CustomTheme.color2),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to subscription page
                Get.to(() => const SubscriptionSelectionScreen());
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: const BorderSide(color: Colors.purple),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentlyBoosted = widget.boostStatus?['is_boosted'] ?? false;

    return ResponsiveDialogWrapper(
      backgroundColor: CustomTheme.card,
      child: ResponsiveDialogColumn(
        children: [
          ResponsiveDialogPadding(
            child: Column(
              children: [
                _buildBoostIcon(),
                const SizedBox(height: 24),
                Text(
                  isCurrentlyBoosted ? 'Boost Active!' : 'Boost Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isCurrentlyBoosted
                      ? 'Your profile is currently getting 3x more visibility!'
                      : 'Get 3x more profile visibility for 30 minutes and increase your chances of finding matches!',
                  style: TextStyle(
                    fontSize: 16,
                    color: CustomTheme.color2,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildBoostButton(),
                _buildPurchaseOption(),
                _buildPremiumPromo(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: CustomTheme.color2, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SparklesPainter extends CustomPainter {
  final double animationValue;

  SparklesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0 + animationValue * 360) * 3.14159 / 180;
      final sparkleRadius = radius * 0.7;
      final sparkleX = center.dx + sparkleRadius * math.cos(angle);
      final sparkleY = center.dy + sparkleRadius * math.sin(angle);

      final sparkleSize = 2.0 + math.sin(animationValue * 6.28 + i) * 1.0;

      canvas.drawCircle(Offset(sparkleX, sparkleY), sparkleSize, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
