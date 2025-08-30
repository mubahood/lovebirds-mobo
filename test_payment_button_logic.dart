#!/usr/bin/env dart
// Payment Button Logic Test Script
// This script tests the payment button visibility logic for different order scenarios

void main() {
  print('=== PAYMENT BUTTON LOGIC TEST ===\n');

  // Test scenarios with different order states
  List<TestOrder> testOrders = [
    TestOrder(
      id: 1,
      description: 'Pending order, not paid, no payment URL',
      orderState: 0,
      stripePaid: 'No',
      stripeUrl: '',
    ),
    TestOrder(
      id: 2,
      description: 'Pending order, not paid, has payment URL',
      orderState: 0,
      stripePaid: 'No',
      stripeUrl: 'https://buy.stripe.com/test_12345',
    ),
    TestOrder(
      id: 3,
      description: 'Processing order, paid, has payment URL',
      orderState: 1,
      stripePaid: 'Yes',
      stripeUrl: 'https://buy.stripe.com/test_67890',
    ),
    TestOrder(
      id: 4,
      description: 'Processing order, not paid, no payment URL',
      orderState: 1,
      stripePaid: 'No',
      stripeUrl: '',
    ),
    TestOrder(
      id: 5,
      description: 'Completed order, paid',
      orderState: 2,
      stripePaid: 'Yes',
      stripeUrl: 'https://buy.stripe.com/test_completed',
    ),
    TestOrder(
      id: 6,
      description: 'Completed order, somehow not paid',
      orderState: 2,
      stripePaid: 'No',
      stripeUrl: '',
    ),
  ];

  for (TestOrder order in testOrders) {
    print('📦 Order #${order.id}: ${order.description}');
    print(
      '   State: ${order.orderState}, Paid: ${order.stripePaid}, URL: ${order.stripeUrl.isEmpty ? "(empty)" : "(exists)"}',
    );

    String buttonResult = getButtonLogic(order);
    print('   🔲 Button: $buttonResult');

    bool isCorrect = validateButtonLogic(order, buttonResult);
    print('   ${isCorrect ? "✅ CORRECT" : "❌ ISSUE"}\n');
  }

  print('=== SUMMARY ===');
  print('The updated logic prioritizes payment buttons:');
  print('1. PRIORITY 1: Pay Now (when URL exists and not paid)');
  print('2. PRIORITY 2: Generate Payment (when not paid and no URL)');
  print('3. PRIORITY 3: Track Order (when paid and processing)');
  print('\nThis ensures payment buttons always show for unpaid orders!');
}

class TestOrder {
  final int id;
  final String description;
  final int orderState;
  final String stripePaid;
  final String stripeUrl;

  TestOrder({
    required this.id,
    required this.description,
    required this.orderState,
    required this.stripePaid,
    required this.stripeUrl,
  });
}

String getButtonLogic(TestOrder order) {
  // Updated logic from MyOrdersScreen.dart
  if (order.stripePaid != "Yes" && order.stripeUrl.isNotEmpty) {
    return "Pay Now";
  } else if (order.stripePaid != "Yes" && order.stripeUrl.isEmpty) {
    return "Generate Payment";
  } else if (order.stripePaid == "Yes" &&
      (order.orderState == 0 || order.orderState == 1)) {
    return "Track Order";
  } else {
    return "No Button";
  }
}

bool validateButtonLogic(TestOrder order, String buttonResult) {
  // An unpaid order should ALWAYS have a payment button
  if (order.stripePaid != "Yes") {
    return buttonResult == "Pay Now" || buttonResult == "Generate Payment";
  }

  // A paid processing order should have Track button
  if (order.stripePaid == "Yes" &&
      (order.orderState == 0 || order.orderState == 1)) {
    return buttonResult == "Track Order";
  }

  // Completed paid orders might not need any button
  return true;
}
