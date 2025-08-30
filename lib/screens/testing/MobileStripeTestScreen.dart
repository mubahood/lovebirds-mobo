import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/RespondModel.dart';
import '../../utils/Utilities.dart';
import '../../models/LoggedInUserModel.dart';

/// Mobile Stripe Integration Test Screen
/// Tests the complete payment flow from mobile app
class MobileStripeTestScreen extends StatefulWidget {
  const MobileStripeTestScreen({Key? key}) : super(key: key);

  @override
  _MobileStripeTestScreenState createState() => _MobileStripeTestScreenState();
}

class _MobileStripeTestScreenState extends State<MobileStripeTestScreen> {
  final List<TestResult> testResults = [];
  bool isRunningTests = false;
  String? testOrderId;
  String? paymentUrl;
  LoggedInUserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    currentUser = await LoggedInUserModel.getLoggedInUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Stripe Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildControls(),
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
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔥 Mobile Stripe Integration Test',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tests the complete payment flow: Order creation → Payment link → Browser payment',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (currentUser != null) ...[
            const SizedBox(height: 8),
            Text(
              '👤 User: ${currentUser!.first_name} ${currentUser!.last_name}',
              style: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isRunningTests ? null : _runCompleteTest,
            icon:
                isRunningTests
                    ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Icon(Icons.play_arrow),
            label: Text(isRunningTests ? 'Testing...' : 'Run Complete Test'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            setState(() {
              testResults.clear();
              testOrderId = null;
              paymentUrl = null;
            });
          },
          child: Text('Clear'),
        ),
        if (paymentUrl != null) ...[
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _openPaymentUrl(paymentUrl!),
            icon: Icon(Icons.open_in_browser, size: 16),
            label: Text('Pay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResults() {
    if (testResults.isEmpty && !isRunningTests) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Ready to test Stripe integration',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'This will create a real order and payment link',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (testResults.isNotEmpty) _buildSummary(),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: testResults.length + (isRunningTests ? 1 : 0),
            itemBuilder: (context, index) {
              if (isRunningTests && index == testResults.length) {
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text('Running test...'),
                    subtitle: Text('Please wait'),
                  ),
                );
              }
              return _buildTestCard(testResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestCard(TestResult result) {
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
    final passed = testResults.where((r) => r.passed).length;
    final total = testResults.length;
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
            'Success',
            '$rate%',
            rate >= 80 ? Colors.green : Colors.orange,
          ),
          if (testOrderId != null)
            _buildStat('Order', testOrderId!.substring(0, 4), Colors.blue),
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

  Future<void> _runCompleteTest() async {
    setState(() {
      isRunningTests = true;
      testResults.clear();
      testOrderId = null;
      paymentUrl = null;
    });

    // Test 1: User Authentication
    await _testUserAuth();
    await _delay();

    // Test 2: Create Order
    await _testCreateOrder();
    await _delay();

    // Test 3: Generate Payment Link
    if (testOrderId != null) {
      await _testGeneratePaymentLink();
      await _delay();
    }

    // Test 4: Validate Payment URL
    if (paymentUrl != null) {
      await _testValidatePaymentUrl();
      await _delay();
    }

    // Test 5: Test Order Retrieval
    await _testOrderRetrieval();
    await _delay();

    setState(() {
      isRunningTests = false;
    });

    // Show result
    final passed = testResults.where((r) => r.passed).length;
    final total = testResults.length;
    final rate = (passed / total * 100).round();

    Get.snackbar(
      'Test Complete',
      '$passed/$total tests passed ($rate% success)',
      backgroundColor: rate >= 80 ? Colors.green : Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _testUserAuth() async {
    if (currentUser == null) {
      currentUser = await LoggedInUserModel.getLoggedInUser();
    }

    testResults.add(
      TestResult(
        name: 'User Authentication',
        description: 'Check if user is logged in',
        passed: currentUser != null && currentUser!.id > 0,
        details:
            currentUser != null
                ? 'User ID: ${currentUser!.id}'
                : 'No user logged in',
      ),
    );
    setState(() {});
  }

  Future<void> _testCreateOrder() async {
    try {
      if (currentUser == null) {
        testResults.add(
          TestResult(
            name: 'Create Order',
            description: 'Create test order with sample products',
            passed: false,
            details: 'No user logged in',
          ),
        );
        setState(() {});
        return;
      }

      Map<String, dynamic> orderData = {
        'user': currentUser!.id,
        'customer_name': '${currentUser!.first_name} ${currentUser!.last_name}',
        'customer_phone_number_1': currentUser!.phone_number,
        'customer_address':
            currentUser!.address.isNotEmpty
                ? currentUser!.address
                : '123 Test Street',
        'amount': '67.48',
        'order_total': '67.48',
        'total_amount': '6748', // In cents
        'order_state': 0,
        'delivery_district': 'Test District',
        'items': [
          {
            'product_id': 1,
            'quantity': 2,
            'price': 25.99,
            'name': 'Mobile Test Product',
          },
        ],
      };

      RespondModel r = RespondModel(
        await Utils.http_post('create-order', orderData),
      );

      bool success = r.code == 1;
      String details = r.message;

      if (success && r.data != null) {
        if (r.data is Map && r.data['order'] != null) {
          var order = r.data['order'];
          testOrderId = order['id']?.toString();
          details =
              testOrderId != null
                  ? 'Order created: $testOrderId'
                  : 'Order created successfully';
        }
      }

      testResults.add(
        TestResult(
          name: 'Create Order',
          description: 'Create test order with sample products',
          passed: success,
          details: details,
        ),
      );
    } catch (e) {
      testResults.add(
        TestResult(
          name: 'Create Order',
          description: 'Create test order with sample products',
          passed: false,
          details: 'Error: ${e.toString()}',
        ),
      );
    }
    setState(() {});
  }

  Future<void> _testGeneratePaymentLink() async {
    try {
      Map<String, dynamic> paymentData = {
        'order_id': testOrderId,
        'logged_in_user_id': currentUser?.id ?? 1,
      };

      RespondModel r = RespondModel(
        await Utils.http_post('generate-payment-link', paymentData),
      );

      bool success = r.code == 1;
      String details = r.message;

      if (success && r.data != null) {
        if (r.data is Map && r.data['payment_url'] != null) {
          paymentUrl = r.data['payment_url'].toString();
          details = 'Payment link generated successfully';
        }
      }

      testResults.add(
        TestResult(
          name: 'Generate Payment Link',
          description: 'Create Stripe payment link',
          passed: success,
          details: details,
        ),
      );
    } catch (e) {
      testResults.add(
        TestResult(
          name: 'Generate Payment Link',
          description: 'Create Stripe payment link',
          passed: false,
          details: 'Error: ${e.toString()}',
        ),
      );
    }
    setState(() {});
  }

  Future<void> _testValidatePaymentUrl() async {
    bool isValid =
        paymentUrl != null &&
        paymentUrl!.isNotEmpty &&
        paymentUrl!.contains('stripe.com') &&
        paymentUrl!.startsWith('https://');

    testResults.add(
      TestResult(
        name: 'Validate Payment URL',
        description: 'Check payment URL is valid Stripe link',
        passed: isValid,
        details:
            isValid
                ? 'Valid Stripe HTTPS URL'
                : 'Invalid or missing payment URL',
      ),
    );
    setState(() {});
  }

  Future<void> _testOrderRetrieval() async {
    try {
      RespondModel r = RespondModel(await Utils.http_post('my-orders', {}));

      bool success = r.code == 1;
      String details = r.message;

      if (success &&
          r.data != null &&
          r.data is Map &&
          r.data['orders'] != null) {
        List orders = r.data['orders'];
        details = 'Found ${orders.length} orders';

        if (testOrderId != null) {
          bool found = orders.any(
            (order) => order['id'].toString() == testOrderId,
          );
          if (found) {
            details += ' (including test order)';
          }
        }
      }

      testResults.add(
        TestResult(
          name: 'Retrieve Orders',
          description: 'Fetch user order history',
          passed: success,
          details: details,
        ),
      );
    } catch (e) {
      testResults.add(
        TestResult(
          name: 'Retrieve Orders',
          description: 'Fetch user order history',
          passed: false,
          details: 'Error: ${e.toString()}',
        ),
      );
    }
    setState(() {});
  }

  Future<void> _openPaymentUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

        Get.snackbar(
          'Payment Page Opened',
          'Use test card: 4242 4242 4242 4242',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 8),
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

  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 800));
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
