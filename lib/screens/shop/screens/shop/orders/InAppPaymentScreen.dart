import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/Utilities.dart';
import '../../../../../../models/RespondModel.dart';
import '../../../models/Order.dart';

class InAppPaymentScreen extends StatefulWidget {
  final Order order;

  const InAppPaymentScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<InAppPaymentScreen> createState() => _InAppPaymentScreenState();
}

class _InAppPaymentScreenState extends State<InAppPaymentScreen> {
  bool isGeneratingPayment = false;
  String? paymentUrl;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _generatePaymentLink();
  }

  Future<void> _generatePaymentLink() async {
    setState(() {
      isGeneratingPayment = true;
      errorMessage = null;
    });

    try {
      RespondModel resp = RespondModel(
        await Utils.http_post('generate-payment-link', {
          'order_id': widget.order.id.toString(),
        }),
      );

      if (resp.code == 1) {
        final url = resp.data?['payment_url'];
        if (url != null && url.isNotEmpty) {
          setState(() {
            paymentUrl = url;
            isGeneratingPayment = false;
          });
        } else {
          throw Exception('No payment URL received');
        }
      } else {
        throw Exception(resp.message.isEmpty ? 'Failed to generate payment link' : resp.message);
      }
    } catch (e) {
      setState(() {
        isGeneratingPayment = false;
        errorMessage = 'Error generating payment: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Payment - Order #${widget.order.id}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CustomTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isGeneratingPayment) {
      return _buildLoadingScreen();
    }
    
    if (errorMessage != null) {
      return _buildErrorScreen();
    }
    
    if (paymentUrl == null) {
      return _buildNoUrlScreen();
    }
    
    return _buildPaymentScreen();
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Generating Payment Link...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Setting up secure payment for Order #${widget.order.id}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.alertCircle,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Setup Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _generatePaymentLink,
              icon: const Icon(FeatherIcons.rotateCcw),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUrlScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.creditCard,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Payment URL Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to generate payment link for this order.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentScreen() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.primary.withOpacity(0.1), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Payment Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CustomTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FeatherIcons.creditCard,
                    size: 48,
                    color: CustomTheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  "Complete Your Payment",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Order info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order ID:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '#${widget.order.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '\$${widget.order.totalAmount}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CustomTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Payment instructions
                const Text(
                  "You will be redirected to our secure payment page. Complete your payment safely with Stripe.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Payment buttons
                Column(
                  children: [
                    // Primary payment button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () => _openPaymentPage(),
                        icon: const Icon(FeatherIcons.creditCard, size: 20),
                        label: const Text(
                          "Pay Now",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Secondary button - external browser
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomTheme.primary,
                          side: BorderSide(color: CustomTheme.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _openInExternalBrowser(),
                        icon: const Icon(FeatherIcons.externalLink, size: 18),
                        label: const Text(
                          "Open in Browser",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Security notice
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FeatherIcons.shield,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Secured by Stripe",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
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

  void _openPaymentPage() async {
    if (paymentUrl != null) {
      try {
        final Uri uri = Uri.parse(paymentUrl!);
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
        
        if (launched) {
          Utils.toast('Payment page opened');
          // Check payment status after some time
          _schedulePaymentStatusCheck();
        } else {
          Utils.toast('Could not open payment page', color: Colors.red);
        }
      } catch (e) {
        Utils.toast('Error opening payment page', color: Colors.red);
        debugPrint('Payment launch error: $e');
      }
    }
  }

  void _openInExternalBrowser() async {
    if (paymentUrl != null) {
      try {
        final Uri uri = Uri.parse(paymentUrl!);
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          Utils.toast('Payment page opened in external browser');
          _schedulePaymentStatusCheck();
        } else {
          Utils.toast('Could not open external browser', color: Colors.red);
        }
      } catch (e) {
        Utils.toast('Error opening external browser', color: Colors.red);
        debugPrint('External launch error: $e');
      }
    }
  }

  void _schedulePaymentStatusCheck() {
    // Schedule payment status check after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _checkPaymentStatus();
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    try {
      RespondModel resp = RespondModel(
        await Utils.http_get('order-details', {
          'order_id': widget.order.id.toString(),
        }),
      );

      if (resp.code == 1) {
        final order = Order.fromJson(resp.data);
        if (order.stripePaid == "Yes") {
          _showPaymentSuccessDialog();
        }
      }
    } catch (e) {
      debugPrint('Payment status check error: $e');
    }
  }

  void _showPaymentSuccessDialog() {
    Get.defaultDialog(
      title: 'Payment Successful!',
      titleStyle: TextStyle(
        color: Colors.green[700], 
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          Icon(
            FeatherIcons.checkCircle,
            size: 64,
            color: Colors.green[600],
          ),
          const SizedBox(height: 16),
          const Text(
            'Your payment has been processed successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Order #${widget.order.id}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      textConfirm: 'Done',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green[600],
      onConfirm: () {
        Get.back(); // Close dialog
        Get.back(); // Return to previous screen
      },
    );
  }
}
