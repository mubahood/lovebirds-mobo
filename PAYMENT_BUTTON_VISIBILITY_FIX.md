# Payment Button Visibility Fix

## Problem Description
Users reported that after placing an order successfully, the payment initialization button was not showing for pending orders. The issue was that even though orders were unpaid (`stripePaid != "Yes"`), the payment buttons were not visible, blocking the payment flow.

## Root Cause Analysis
The payment button logic in both `MyOrdersScreen.dart` and `OrderDetailsScreen.dart` had a priority issue:

### Original Logic (BROKEN):
```dart
if (order.stripePaid != "Yes" && order.stripeUrl.isNotEmpty) {
    // Show "Pay Now" button
} else if (order.orderState == 0 || order.orderState == 1) {
    // Show "Track Order" button  <-- THIS RUNS FIRST FOR PENDING ORDERS!
} else if (order.stripePaid != "Yes" && order.stripeUrl.isEmpty) {
    // Show "Generate Payment" button  <-- NEVER REACHED FOR PENDING ORDERS!
}
```

**Issue**: For pending orders (`orderState == 0`) that were unpaid and had no payment URL, the second condition (`order.orderState == 0`) would match first and show "Track Order" instead of "Generate Payment".

## Solution Implemented

### New Logic (FIXED):
```dart
// PRIORITY 1: Payment buttons for unpaid orders
if (order.stripePaid != "Yes" && order.stripeUrl.isNotEmpty) {
    // Show "Pay Now" button
} else if (order.stripePaid != "Yes" && order.stripeUrl.isEmpty) {
    // Show "Generate Payment" button
} 
// PRIORITY 2: Track button only for PAID processing orders  
else if (order.stripePaid == "Yes" && (order.orderState == 0 || order.orderState == 1)) {
    // Show "Track Order" button
}
```

## Files Modified
1. `/lib/screens/shop/screens/shop/orders/MyOrdersScreen.dart`
2. `/lib/screens/shop/screens/shop/orders/OrderDetailsScreen.dart`

## Test Results
The updated logic ensures:

| Order State | Stripe Paid | Stripe URL | Button Shown |
|-------------|-------------|------------|-------------|
| Pending (0) | No | Empty | Generate Payment ✅ |
| Pending (0) | No | Exists | Pay Now ✅ |
| Processing (1) | Yes | Any | Track Order ✅ |
| Processing (1) | No | Empty | Generate Payment ✅ |
| Completed (2) | Yes | Any | No Button ✅ |
| Completed (2) | No | Empty | Generate Payment ✅ |

## Key Improvements
1. **Payment Priority**: Payment buttons now have absolute priority over tracking buttons
2. **Unpaid Orders**: ANY unpaid order will show either "Pay Now" or "Generate Payment" 
3. **Pending Orders**: Pending unpaid orders now correctly show payment buttons instead of track buttons
4. **User Experience**: Users can always initiate payment for unpaid orders regardless of order state

## Verification
- Created comprehensive test script that validates all scenarios
- All test cases pass with the new logic
- Payment flow is now unblocked for pending orders

This fix ensures that users can always see and access payment options for any unpaid order, resolving the core issue where payment buttons were not visible for pending orders.
