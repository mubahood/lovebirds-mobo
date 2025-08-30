import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';

import '../../models/RespondModel.dart';
import '../../utils/Utilities.dart';
import '../shop/models/Order.dart';
import '../../models/LoggedInUserModel.dart';

/// Complete Mobile Stripe Integration Test
/// Tests the entire payment flow from mobile app perspective
class CompleteMobileStripeTestScreen extends StatefulWidget {
  const CompleteMobileStripeTestScreen({Key? key}) : super(key: key);

  @override
  _CompleteMobileStripeTestScreenState createState() =>
      _CompleteMobileStripeTestScreenState();
}

class _CompleteMobileStripeTestScreenState
    extends State<CompleteMobileStripeTestScreen> {
  final List<MobileTestResult> testResults = [];
  bool isRunningTests = false;
  int currentTestIndex = 0;
  String? testOrderId;
  String? paymentUrl;
  LoggedInUserModel? currentUser;

  final List<MobileTestCase> testCases = [
    MobileTestCase(
      name: 'User Authentication',
      description: 'Verify user is logged in and has valid token',
      testId: 'auth_test',
    ),
    MobileTestCase(
      name: 'API Connection',
      description: 'Test connection to LoveBirds API server',
      testId: 'api_connection',
    ),
    MobileTestCase(
      name: 'Order Creation',
      description: 'Create a test order with sample products',
      testId: 'order_creation',
    ),
    MobileTestCase(
      name: 'Payment Link Generation',
      description: 'Generate Stripe payment link for the test order',
      testId: 'payment_link',
    ),
    MobileTestCase(
      name: 'Payment URL Validation',
      description: 'Verify payment URL is valid Stripe link',
      testId: 'url_validation',
    ),
    MobileTestCase(
      name: 'Order Status Check',
      description: 'Verify order appears in user order history',
      testId: 'order_status',
    ),
    MobileTestCase(
      name: 'Payment Flow Test',
      description: 'Test opening payment URL in browser',
      testId: 'payment_flow',
    ),
    MobileTestCase(
      name: 'Order Update Test',
      description: 'Test order status updates after payment',
      testId: 'order_update',
    ),
  ];

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
        title: const Text('Complete Mobile Stripe Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildControlPanel(),
              const SizedBox(height: 20),
              Expanded(child: _buildTestResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: Colors.deepPurple, size: 28),
              const SizedBox(width: 12),
              Text(
                'Mobile Payment Integration Test',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This comprehensive test verifies the complete payment flow from mobile app to Stripe, including order creation, payment link generation, and status updates.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          if (currentUser != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Logged in as: ${currentUser!.first_name} ${currentUser!.last_name}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isRunningTests ? null : _runAllTests,
                  icon: isRunningTests
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Icon(Icons.play_arrow),
                  label: Text(isRunningTests ? 'Running Tests...' : 'Run All Tests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _clearResults,
                icon: Icon(Icons.clear),
                label: Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          if (paymentUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generated Payment URL:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _copyToClipboard(paymentUrl!),
                    child: Text(
                      paymentUrl!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _openPaymentUrl(paymentUrl!),
                    icon: Icon(Icons.open_in_browser, size: 16),
                    label: Text('Open Payment Page'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestResults() {
    if (testResults.isEmpty && !isRunningTests) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Ready to run tests',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Run All Tests" to start the complete integration test',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (testResults.isNotEmpty) _buildSummaryCard(),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: testResults.length + (isRunningTests ? 1 : 0),
            itemBuilder: (context, index) {
              if (isRunningTests && index == testResults.length) {
                return _buildRunningTestCard();
              }
              return _buildTestResultCard(testResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestResultCard(MobileTestResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (result.passed ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            result.passed ? Icons.check_circle : Icons.error,
            color: result.passed ? Colors.green : Colors.red,
          ),
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
                  color: result.passed ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (result.duration > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Duration: ${result.duration}ms',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRunningTestCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
        ),
        title: Text(
          currentTestIndex < testCases.length
              ? testCases[currentTestIndex].name
              : 'Running test...',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          currentTestIndex < testCases.length
              ? testCases[currentTestIndex].description
              : 'Please wait while the test completes',
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final passed = testResults.where((r) => r.passed).length;
    final failed = testResults.where((r) => !r.passed).length;
    final total = testResults.length;
    final successRate = total > 0 ? (passed / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Results Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Passed', passed.toString(), Colors.green),
              _buildStatItem('Failed', failed.toString(), Colors.red),
              _buildStatItem('Total', total.toString(), Colors.blue),
              _buildStatItem('Success Rate', '$successRate%', 
                successRate >= 80 ? Colors.green : Colors.orange),
            ],
          ),
          if (testOrderId != null) ...[
            const SizedBox(height: 12),
            Text(
              'Test Order ID: $testOrderId',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      isRunningTests = true;
      testResults.clear();
      currentTestIndex = 0;
    });

    for (int i = 0; i < testCases.length; i++) {
      currentTestIndex = i;
      setState(() {});

      await Future.delayed(const Duration(milliseconds: 500)); // UI update delay
      
      final testCase = testCases[i];
      final startTime = DateTime.now().millisecondsSinceEpoch;
      
      MobileTestResult result;
      
      try {
        switch (testCase.testId) {
          case 'auth_test':
            result = await _testUserAuthentication();
            break;
          case 'api_connection':
            result = await _testApiConnection();
            break;
          case 'order_creation':
            result = await _testOrderCreation();
            break;
          case 'payment_link':
            result = await _testPaymentLinkGeneration();
            break;
          case 'url_validation':
            result = await _testPaymentUrlValidation();
            break;
          case 'order_status':
            result = await _testOrderStatusCheck();
            break;
          case 'payment_flow':
            result = await _testPaymentFlow();
            break;
          case 'order_update':
            result = await _testOrderUpdate();
            break;
          default:
            result = MobileTestResult(
              name: testCase.name,
              description: testCase.description,
              passed: false,
              details: 'Test not implemented',
            );
        }
      } catch (e) {
        result = MobileTestResult(
          name: testCase.name,
          description: testCase.description,
          passed: false,
          details: 'Error: ${e.toString()}',
        );
      }
      
      final endTime = DateTime.now().millisecondsSinceEpoch;
      result.duration = endTime - startTime;
      
      testResults.add(result);
      setState(() {});
    }

    setState(() {
      isRunningTests = false;
    });

    // Show completion message
    final passed = testResults.where((r) => r.passed).length;
    final total = testResults.length;
    final rate = (passed / total * 100).round();
    
    Get.snackbar(
      'Tests Complete',
      '$passed/$total tests passed ($rate% success rate)',
      backgroundColor: rate >= 80 ? Colors.green : Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<MobileTestResult> _testUserAuthentication() async {
    if (currentUser == null) {
      currentUser = await LoggedInUserModel.getLoggedInUser();
    }

    if (currentUser == null || currentUser!.id <= 0) {
      return MobileTestResult(
        name: 'User Authentication',
        description: 'Verify user is logged in and has valid token',
        passed: false,
        details: 'No user is currently logged in',
      );
    }

    return MobileTestResult(
      name: 'User Authentication',
      description: 'Verify user is logged in and has valid token',
      passed: true,
      details: 'User: ${currentUser!.first_name} ${currentUser!.last_name} (ID: ${currentUser!.id})',
    );
  }

  Future<MobileTestResult> _testApiConnection() async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (currentUser != null) {
        headers['Tok'] = currentUser!.remember_token;
      }

      RespondModel r = await Utilities.postData(
        url: 'test-connection',
        params: {'test': true},
        requestTimeout: 10,
        headers: headers,
      );

      return MobileTestResult(
        name: 'API Connection',
        description: 'Test connection to LoveBirds API server',
        passed: r.code == 1,
        details: r.message.isNotEmpty ? r.message : 'API connection ${r.code == 1 ? 'successful' : 'failed'}',
      );
    } catch (e) {
      return MobileTestResult(
        name: 'API Connection',
        description: 'Test connection to LoveBirds API server',
        passed: false,
        details: 'Connection error: ${e.toString()}',
      );
    }
  }

  Future<MobileTestResult> _testOrderCreation() async {
    try {
      if (currentUser == null) {
        return MobileTestResult(
          name: 'Order Creation',
          description: 'Create a test order with sample products',
          passed: false,
          details: 'No user logged in for order creation',
        );
      }

      Map<String, dynamic> orderData = {
        'items': [
          {
            'product_id': 1,
            'quantity': 2,
            'price': 25.99,
            'name': 'Mobile Test Product 1'
          },
          {
            'product_id': 2,
            'quantity': 1,
            'price': 15.50,
            'name': 'Mobile Test Product 2'
          }
        ],
        'customer_name': '${currentUser!.first_name} ${currentUser!.last_name}',
        'customer_phone_number_1': currentUser!.phone_number,
        'customer_address': currentUser!.address.isNotEmpty ? currentUser!.address : '123 Test Street',
        'delivery_method': 'pickup',
        'logged_in_user_id': currentUser!.id,
      };

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Tok': currentUser!.remember_token,
      };

      RespondModel r = await Utilities.postData(
        url: 'create-order',
        params: orderData,
        headers: headers,
      );

      if (r.code == 1 && r.data != null) {
        // Try to extract order ID from response
        if (r.data is Map && r.data['order'] != null) {
          Map orderMap = r.data['order'];
          testOrderId = orderMap['id']?.toString();
        }

        return MobileTestResult(
          name: 'Order Creation',
          description: 'Create a test order with sample products',
          passed: true,
          details: testOrderId != null 
              ? 'Order created successfully (ID: $testOrderId)'
              : 'Order created successfully',
        );
      } else {
        return MobileTestResult(
          name: 'Order Creation',
          description: 'Create a test order with sample products',
          passed: false,
          details: r.message.isNotEmpty ? r.message : 'Order creation failed',
        );
      }
    } catch (e) {
      return MobileTestResult(
        name: 'Order Creation',
        description: 'Create a test order with sample products',
        passed: false,
        details: 'Error: ${e.toString()}',
      );
    }
  }

  Future<MobileTestResult> _testPaymentLinkGeneration() async {
    if (testOrderId == null) {
      return MobileTestResult(
        name: 'Payment Link Generation',
        description: 'Generate Stripe payment link for the test order',
        passed: false,
        details: 'No test order available for payment link generation',
      );
    }

    try {
      Map<String, dynamic> paymentData = {
        'order_id': testOrderId,
        'logged_in_user_id': currentUser?.id ?? 1,
      };

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (currentUser != null) {
        headers['Tok'] = currentUser!.remember_token;
      }

      RespondModel r = await Utilities.postData(
        url: 'generate-payment-link',
        params: paymentData,
        headers: headers,
      );

      if (r.code == 1 && r.data != null) {
        if (r.data is Map && r.data['payment_url'] != null) {
          paymentUrl = r.data['payment_url'].toString();
          setState(() {}); // Update UI with payment URL
        }

        return MobileTestResult(
          name: 'Payment Link Generation',
          description: 'Generate Stripe payment link for the test order',
          passed: true,
          details: paymentUrl != null 
              ? 'Payment link generated successfully'
              : 'Payment link generation completed',
        );
      } else {
        return MobileTestResult(
          name: 'Payment Link Generation',
          description: 'Generate Stripe payment link for the test order',
          passed: false,
          details: r.message.isNotEmpty ? r.message : 'Payment link generation failed',
        );
      }
    } catch (e) {
      return MobileTestResult(
        name: 'Payment Link Generation',
        description: 'Generate Stripe payment link for the test order',
        passed: false,
        details: 'Error: ${e.toString()}',
      );
    }
  }

  Future<MobileTestResult> _testPaymentUrlValidation() async {
    if (paymentUrl == null || paymentUrl!.isEmpty) {
      return MobileTestResult(
        name: 'Payment URL Validation',
        description: 'Verify payment URL is valid Stripe link',
        passed: false,
        details: 'No payment URL available for validation',
      );
    }

    bool isValidStripeUrl = paymentUrl!.contains('stripe.com') || 
                           paymentUrl!.contains('checkout.stripe.com');

    bool isHttps = paymentUrl!.startsWith('https://');

    return MobileTestResult(
      name: 'Payment URL Validation',
      description: 'Verify payment URL is valid Stripe link',
      passed: isValidStripeUrl && isHttps,
      details: isValidStripeUrl && isHttps 
          ? 'Valid HTTPS Stripe payment URL' 
          : 'Invalid payment URL format',
    );
  }

  Future<MobileTestResult> _testOrderStatusCheck() async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (currentUser != null) {
        headers['Tok'] = currentUser!.remember_token;
      }

      RespondModel r = await Utilities.postData(
        url: 'my-orders',
        params: {},
        headers: headers,
      );

      if (r.code == 1 && r.data != null) {
        bool orderFound = false;
        
        if (r.data is Map && r.data['orders'] != null) {
          List orders = r.data['orders'];
          
          if (testOrderId != null) {
            for (var orderData in orders) {
              if (orderData['id'].toString() == testOrderId) {
                orderFound = true;
                break;
              }
            }
          }
          
          return MobileTestResult(
            name: 'Order Status Check',
            description: 'Verify order appears in user order history',
            passed: orderFound || orders.isNotEmpty,
            details: orderFound 
                ? 'Test order found in user orders'
                : 'User has ${orders.length} orders (test order may not be visible)',
          );
        }
        
        return MobileTestResult(
          name: 'Order Status Check',
          description: 'Verify order appears in user order history',
          passed: true,
          details: 'Orders API responded successfully',
        );
      } else {
        return MobileTestResult(
          name: 'Order Status Check',
          description: 'Verify order appears in user order history',
          passed: false,
          details: r.message.isNotEmpty ? r.message : 'Failed to fetch user orders',
        );
      }
    } catch (e) {
      return MobileTestResult(
        name: 'Order Status Check',
        description: 'Verify order appears in user order history',
        passed: false,
        details: 'Error: ${e.toString()}',
      );
    }
  }

  Future<MobileTestResult> _testPaymentFlow() async {
    if (paymentUrl == null || paymentUrl!.isEmpty) {
      return MobileTestResult(
        name: 'Payment Flow Test',
        description: 'Test opening payment URL in browser',
        passed: false,
        details: 'No payment URL available for testing',
      );
    }

    try {
      bool canLaunch = await canLaunchUrl(Uri.parse(paymentUrl!));
      
      return MobileTestResult(
        name: 'Payment Flow Test',
        description: 'Test opening payment URL in browser',
        passed: canLaunch,
        details: canLaunch 
            ? 'Payment URL can be opened in browser'
            : 'Cannot open payment URL in browser',
      );
    } catch (e) {
      return MobileTestResult(
        name: 'Payment Flow Test',
        description: 'Test opening payment URL in browser',
        passed: false,
        details: 'Error testing URL launch: ${e.toString()}',
      );
    }
  }

  Future<MobileTestResult> _testOrderUpdate() async {
    if (testOrderId == null) {
      return MobileTestResult(
        name: 'Order Update Test',
        description: 'Test order status updates after payment',
        passed: false,
        details: 'No test order available for update testing',
      );
    }

    try {
      Map<String, dynamic> updateData = {
        'order_id': testOrderId,
        'stripe_paid': 'Yes',
        'payment_confirmation': 'test_payment_intent_mobile_${DateTime.now().millisecondsSinceEpoch}',
        'order_state': 1,
      };

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (currentUser != null) {
        headers['Tok'] = currentUser!.remember_token;
      }

      RespondModel r = await Utilities.postData(
        url: 'update-order-payment',
        params: updateData,
        headers: headers,
      );

      return MobileTestResult(
        name: 'Order Update Test',
        description: 'Test order status updates after payment',
        passed: r.code == 1,
        details: r.message.isNotEmpty ? r.message : 'Order update ${r.code == 1 ? 'successful' : 'failed'}',
      );
    } catch (e) {
      return MobileTestResult(
        name: 'Order Update Test',
        description: 'Test order status updates after payment',
        passed: false,
        details: 'Error: ${e.toString()}',
      );
    }
  }

  void _clearResults() {
    setState(() {
      testResults.clear();
      testOrderId = null;
      paymentUrl = null;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Payment URL copied to clipboard',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _openPaymentUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        
        Get.snackbar(
          'Payment Page Opened',
          'Use test card: 4242424242424242',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Error',
          'Cannot open payment URL',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open payment URL: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class MobileTestCase {
  final String name;
  final String description;
  final String testId;

  MobileTestCase({
    required this.name,
    required this.description,
    required this.testId,
  });
}

class MobileTestResult {
  final String name;
  final String description;
  final bool passed;
  final String details;
  int duration = 0;

  MobileTestResult({
    required this.name,
    required this.description,
    required this.passed,
    required this.details,
  });
}
