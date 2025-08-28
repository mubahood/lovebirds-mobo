import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/features/legal/views/privacy_policy_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/legal/views/terms_of_service_screen.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/Utilities.dart';

class SubscriptionSelectionScreen extends StatefulWidget {
  final String? triggerReason; // 'paywall', 'upgrade_prompt', 'settings'

  const SubscriptionSelectionScreen({Key? key, this.triggerReason})
    : super(key: key);

  @override
  State<SubscriptionSelectionScreen> createState() =>
      _SubscriptionSelectionScreenState();
}

class _SubscriptionSelectionScreenState
    extends State<SubscriptionSelectionScreen>
    with TickerProviderStateMixin {
  int selectedPlanIndex = 1; // Default to monthly (most popular)
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;
  bool _isLoading = false;

  // Canadian pricing with promotional benefits
  final List<Map<String, dynamic>> subscriptionPlans = [
    {
      'id': 'weekly',
      'title': 'Weekly Trial',
      'price': '\$10',
      'period': '/week',
      'originalPrice': null,
      'savings': null,
      'badge': 'TRY IT',
      'color': Colors.blue,
      'features': [
        'Unlimited swipes',
        '5 super likes/day',
        'See who likes you',
        'Profile boost',
      ],
      'description': 'Perfect for trying premium features',
    },
    {
      'id': 'monthly',
      'title': 'Monthly Premium',
      'price': '\$30',
      'period': '/month',
      'originalPrice': '\$40',
      'savings': 'Save \$10',
      'badge': 'MOST POPULAR',
      'color': CustomTheme.primary,
      'features': [
        'Everything in Weekly',
        'Unlimited rewinds',
        'Read receipts',
        'Priority support',
        'Advanced filters',
      ],
      'description': 'Best value for serious dating',
    },
    {
      'id': 'quarterly',
      'title': '3 Month Premium',
      'price': '\$70',
      'period': '/3 months',
      'originalPrice': '\$90',
      'savings': 'Save \$20 + 1 FREE month',
      'badge': 'BEST VALUE',
      'color': Colors.green,
      'features': [
        'Everything in Monthly',
        'Profile insights',
        'Date planning tools',
        'Relationship coaching',
        'VIP customer service',
      ],
      'description': 'Ultimate dating experience with coaching',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
  }

  void _startAnimations() {
    _backgroundController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          // Clamp animation values to prevent overflow
          final clampedValue = _backgroundAnimation.value.clamp(0.0, 1.0);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CustomTheme.primary.withValues(alpha: 0.1 * clampedValue),
                  Colors.pink.withValues(alpha: 0.15 * clampedValue),
                  Colors.purple.withValues(alpha: 0.1 * clampedValue),
                  Colors.black,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildSubscriptionCards()),
                  _buildFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Close button and title
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: Colors.white, size: 28),
              ),
              Spacer(),
              if (widget.triggerReason != 'paywall')
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 0),

          // Premium badge with animation
          AnimatedBuilder(
            animation: _cardAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _cardAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [CustomTheme.primary, Colors.pink],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'LOVEBIRDS PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 5),

          // Main title
          Text(
            'Find Your Perfect Match',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 0),

          // Subtitle based on trigger reason
          Text(
            _getSubtitleText(),
            style: TextStyle(color: Colors.grey[300], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getSubtitleText() {
    switch (widget.triggerReason) {
      case 'paywall':
        return 'Premium membership required to access Lovebirds Dating';
      case 'upgrade_prompt':
        return 'Unlock premium features and find love faster';
      default:
        return 'Premium features for serious dating';
    }
  }

  Widget _buildSubscriptionCards() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        // Clamp opacity value to prevent animation overflow
        final clampedOpacity = _cardAnimation.value.clamp(0.0, 1.0);
        final clampedTransform = (1 - _cardAnimation.value).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 50 * clampedTransform),
          child: Opacity(
            opacity: clampedOpacity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Plans grid
                  Expanded(
                    child: ListView.builder(
                      itemCount: subscriptionPlans.length,
                      itemBuilder: (context, index) {
                        final plan = subscriptionPlans[index];
                        final isSelected = selectedPlanIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPlanIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              gradient:
                                  isSelected
                                      ? LinearGradient(
                                        colors: [
                                          plan['color'].withValues(alpha: 0.2),
                                          plan['color'].withValues(alpha: 0.1),
                                        ],
                                      )
                                      : null,
                              color: isSelected ? null : Colors.grey[900],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? plan['color']
                                        : Colors.grey[700]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color: plan['color'].withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ]
                                      : null,
                            ),
                            child: _buildPlanCard(plan, isSelected),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge and title
          Row(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: plan['color'],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  plan['badge'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Spacer(),

              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? plan['color'] : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? plan['color'] : Colors.grey[600]!,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Title and price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (plan['savings'] != null)
                    Text(
                      plan['savings'],
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              Spacer(),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (plan['originalPrice'] != null)
                    Text(
                      plan['originalPrice'],
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan['price'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        plan['period'],
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Description
          Text(
            plan['description'],
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),

          const SizedBox(height: 15),

          // Features list
          ...plan['features'].map<Widget>((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: plan['color'], size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final selectedPlan = subscriptionPlans[selectedPlanIndex];

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
      child: Column(
        children: [
          // Subscribe button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedPlan['color'],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        'Start Premium - ${selectedPlan['price']}${selectedPlan['period']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),

          const SizedBox(height: 5),

          // Terms and conditions
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                'By subscribing, you agree to our ',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const TermsOfServiceScreen());
                },
                child: Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: CustomTheme.primary,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' and ',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const PrivacyPolicyScreen());
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: CustomTheme.primary,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe() async {
    setState(() {
      _isLoading = true;
    });

    final selectedPlan = subscriptionPlans[selectedPlanIndex];

    try {
      // Step 1: Create Stripe payment session via our backend
      final paymentResponse = await _createStripePaymentSession(
        selectedPlan['id'],
      );

      if (paymentResponse == null || paymentResponse['payment_url'] == null) {
        throw Exception('Failed to create payment session');
      }

      // Step 2: Open payment URL in in-app browser
      final paymentSuccess = await _openPaymentUrlInBrowser(
        paymentResponse['payment_url'],
        paymentResponse['payment_id'],
      );

      if (paymentSuccess) {
        // Step 3: Verify payment completion with backend
        await _verifyPaymentCompletion(paymentResponse['payment_id']);

        // Show success message
        Get.snackbar(
          'Welcome to Premium! 🎉',
          'Your ${selectedPlan['title']} subscription is now active!',
          backgroundColor: CustomTheme.primary,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          icon: Icon(Icons.favorite, color: Colors.white),
        );

        // Navigate back to main app
        Get.back();
      } else {
        throw Exception('Payment was cancelled or failed');
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Payment Failed',
        'Unable to process subscription: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        icon: Icon(Icons.error, color: Colors.white),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Create Stripe payment session via backend API
  Future<Map<String, dynamic>?> _createStripePaymentSession(
    String planId,
  ) async {
    try {
      final response = await Utils.http_post(
        'api/create_subscription_payment',
        {'plan': planId},
      );

      if (response != null && response.code == 1) {
        return {
          'payment_url': response.data['payment_url'],
          'payment_id': response.data['payment_id'],
        };
      } else {
        throw Exception(
          response?.message ?? 'Failed to create payment session',
        );
      }
    } catch (e) {
      print('Error creating payment session: $e');
      return null;
    }
  }

  // Open payment URL in in-app browser and monitor completion
  Future<bool> _openPaymentUrlInBrowser(
    String paymentUrl,
    String paymentId,
  ) async {
    try {
      // Launch the Stripe payment URL in external browser
      // In production, you might want to use an in-app browser
      final Uri url = Uri.parse(paymentUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);

        // Show a dialog to let user confirm payment completion
        final result = await Get.dialog<bool>(
          AlertDialog(
            title: Text('Complete Your Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please complete your payment in the browser.'),
                SizedBox(height: 16),
                Text(
                  'Once payment is complete, return here and tap "Payment Complete"',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: Text('Payment Complete'),
              ),
            ],
          ),
          barrierDismissible: false,
        );

        return result ?? false;
      } else {
        throw Exception('Could not launch payment URL');
      }
    } catch (e) {
      print('Error opening payment URL: $e');
      return false;
    }
  }

  // Verify payment completion with backend
  Future<void> _verifyPaymentCompletion(String paymentId) async {
    try {
      final response = await Utils.http_post('check_subscription_payment', {
        'payment_id': paymentId,
      });

      if (response != null && response.code == 1) {
        // Payment verified successfully
        Utils.toast('Subscription activated successfully!');
      } else {
        throw Exception(response?.message ?? 'Payment verification failed');
      }
    } catch (e) {
      print('Error verifying payment: $e');
      throw Exception('Failed to verify payment completion');
    }
  }
}
