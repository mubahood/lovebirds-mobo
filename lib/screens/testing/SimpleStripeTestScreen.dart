import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/RespondModel.dart';
import '../../utils/Utilities.dart';
import '../../models/LoggedInUserModel.dart';

/// Simple Stripe Integration Test for Mobile
class SimpleStripeTestScreen extends StatefulWidget {
  const SimpleStripeTestScreen({Key? key}) : super(key: key);

  @override
  _SimpleStripeTestScreenState createState() => _SimpleStripeTestScreenState();
}

class _SimpleStripeTestScreenState extends State<SimpleStripeTestScreen> {
  final List<TestResult> results = [];
  bool isRunning = false;
  String? orderId;
  String? paymentUrl;
  LoggedInUserModel? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    user = await LoggedInUserModel.getLoggedInUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildButtons(),
            const SizedBox(height: 20),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🧪 Simple Stripe Test',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tests: Create Order → Generate Payment Link → Open Payment',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (user != null) ...[
            const SizedBox(height: 8),
            Text(
              '👤 ${user!.first_name} ${user!.last_name}',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isRunning ? null : _runTest,
                icon:
                    isRunning
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Icon(Icons.play_arrow),
                label: Text(isRunning ? 'Testing...' : 'Run Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  results.clear();
                  orderId = null;
                  paymentUrl = null;
                });
              },
              child: Text('Clear'),
            ),
          ],
        ),
        if (paymentUrl != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openPayment(paymentUrl!),
              icon: Icon(Icons.payment),
              label: Text('Open Payment Page'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResults() {
    if (results.isEmpty && !isRunning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Ready to Test',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            Text(
              'This will test the complete payment flow',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (results.isNotEmpty) _buildSummary(),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: results.length + (isRunning ? 1 : 0),
            itemBuilder: (context, index) {
              if (isRunning && index == results.length) {
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text('Running test...'),
                  ),
                );
              }
              return _buildResultCard(results[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(TestResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          result.passed ? Icons.check_circle : Icons.error,
          color: result.passed ? Colors.green : Colors.red,
        ),
        title: Text(
          result.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.description),
            if (result.details.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                result.details,
                style: TextStyle(
                  fontSize: 12,
                  color: result.passed ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final passed = results.where((r) => r.passed).length;
    final total = results.length;
    final rate = total > 0 ? (passed / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Passed', passed.toString(), Colors.green),
          _buildStat('Failed', (total - passed).toString(), Colors.red),
          _buildStat(
            'Rate',
            '$rate%',
            rate >= 80 ? Colors.green : Colors.orange,
          ),
          if (orderId != null)
            _buildStat(
              'Order',
              orderId!.length > 4 ? orderId!.substring(0, 4) : orderId!,
              Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Future<void> _runTest() async {
    setState(() {
      isRunning = true;
      results.clear();
      orderId = null;
      paymentUrl = null;
    });

    await _testUser();
    await Future.delayed(const Duration(milliseconds: 500));

    await _testCreateOrder();
    await Future.delayed(const Duration(milliseconds: 500));

    if (orderId != null) {
      await _testGeneratePaymentLink();
      await Future.delayed(const Duration(milliseconds: 500));

      if (paymentUrl != null) {
        await _testPaymentUrl();
      }
    }

    setState(() {
      isRunning = false;
    });

    final passed = results.where((r) => r.passed).length;
    final total = results.length;
    final rate = (passed / total * 100).round();

    Get.snackbar(
      'Test Complete',
      '$passed/$total tests passed ($rate%)',
      backgroundColor: rate >= 75 ? Colors.green : Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _testUser() async {
    if (user == null) {
      user = await LoggedInUserModel.getLoggedInUser();
    }

    results.add(
      TestResult(
        name: 'User Check',
        description: 'Verify user is logged in',
        passed: user != null && user!.id > 0,
        details: user != null ? 'User ID: ${user!.id}' : 'No user logged in',
      ),
    );
    setState(() {});
  }

  Future<void> _testCreateOrder() async {
    try {
      if (user == null) {
        results.add(
          TestResult(
            name: 'Create Order',
            description: 'Create test order',
            passed: false,
            details: 'No user available',
          ),
        );
        setState(() {});
        return;
      }

      final orderData = {
        'user': user!.id,
        'customer_name': '${user!.first_name} ${user!.last_name}',
        'customer_phone_number_1':
            user!.phone_number.isNotEmpty ? user!.phone_number : '+1234567890',
        'customer_address': '123 Test Street',
        'amount': '29.99',
        'order_total': '29.99',
        'total_amount': '2999', // cents
        'description': 'Mobile test order',
      };

      final response = RespondModel(
        await Utils.http_post('orders-create', orderData),
      );

      bool success = response.code == 1;
      String details = response.message;

      if (success && response.data != null) {
        if (response.data is Map && response.data['order'] != null) {
          orderId = response.data['order']['id']?.toString();
          if (orderId != null) {
            details = 'Order created: $orderId';
          }
        }
      }

      results.add(
        TestResult(
          name: 'Create Order',
          description: 'Create test order',
          passed: success,
          details: details,
        ),
      );
    } catch (e) {
      results.add(
        TestResult(
          name: 'Create Order',
          description: 'Create test order',
          passed: false,
          details: 'Error: ${e.toString()}',
        ),
      );
    }
    setState(() {});
  }

  Future<void> _testGeneratePaymentLink() async {
    try {
      final paymentData = {
        'order_id': orderId,
        'logged_in_user_id': user?.id ?? 1,
      };

      final response = RespondModel(
        await Utils.http_post('generate-payment-link', paymentData),
      );

      bool success = response.code == 1;
      String details = response.message;

      if (success && response.data != null) {
        if (response.data is Map && response.data['payment_url'] != null) {
          paymentUrl = response.data['payment_url'].toString();
          details = 'Payment link generated';
        }
      }

      results.add(
        TestResult(
          name: 'Payment Link',
          description: 'Generate Stripe payment link',
          passed: success,
          details: details,
        ),
      );
    } catch (e) {
      results.add(
        TestResult(
          name: 'Payment Link',
          description: 'Generate Stripe payment link',
          passed: false,
          details: 'Error: ${e.toString()}',
        ),
      );
    }
    setState(() {});
  }

  Future<void> _testPaymentUrl() async {
    bool valid =
        paymentUrl != null &&
        paymentUrl!.isNotEmpty &&
        paymentUrl!.contains('stripe.com') &&
        paymentUrl!.startsWith('https://');

    results.add(
      TestResult(
        name: 'Payment URL',
        description: 'Validate payment URL',
        passed: valid,
        details: valid ? 'Valid Stripe HTTPS URL' : 'Invalid URL format',
      ),
    );
    setState(() {});
  }

  Future<void> _openPayment(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

        Get.snackbar(
          'Payment Opened',
          'Test card: 4242 4242 4242 4242\nAny future date, any CVC',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 10),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Cannot open payment URL',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class TestResult {
  final String name;
  final String description;
  final bool passed;
  final String details;

  TestResult({
    required this.name,
    required this.description,
    required this.passed,
    required this.details,
  });
}
