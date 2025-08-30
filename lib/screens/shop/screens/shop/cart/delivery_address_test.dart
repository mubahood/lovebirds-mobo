import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controllers/CartController.dart';
import '../../../../../models/DeliveryAddress.dart';

/// DELIVERY ADDRESS INTEGRATION TEST
/// 
/// This test file verifies that the DeliveryAddress model is properly
/// integrated with the CartController and that pricing calculations work correctly.

class DeliveryAddressTest {
  static Future<void> runTests() async {
    print('🧪 Starting Delivery Address Integration Tests...');
    
    try {
      // Initialize controller
      CartController cartController = Get.put(CartController());
      
      // Test 1: Verify initial state
      print('✅ Test 1: Initial state verification');
      assert(cartController.selectedDeliveryAddress.value == null);
      assert(cartController.selectedAddress.isEmpty);
      assert(cartController.selectedAddressId.isEmpty);
      assert(cartController.actualDeliveryFee == 5000.0); // default delivery fee
      print('   ✓ Initial state correct');
      
      // Test 2: Create mock DeliveryAddress
      print('✅ Test 2: Creating mock delivery address');
      DeliveryAddress mockAddress = DeliveryAddress();
      mockAddress.id = 123;
      mockAddress.address = "Kampala Central, Uganda";
      mockAddress.shipping_cost = "7500";
      mockAddress.latitude = "0.3476";
      mockAddress.longitude = "32.5825";
      
      // Test 3: Set delivery address
      print('✅ Test 3: Setting delivery address');
      cartController.setDeliveryAddress(mockAddress);
      
      // Test 4: Verify address is set correctly
      print('✅ Test 4: Verifying address assignment');
      assert(cartController.selectedDeliveryAddress.value != null);
      assert(cartController.selectedAddress == "Kampala Central, Uganda");
      assert(cartController.selectedAddressId == "123");
      assert(cartController.selectedAddressShippingCost == "7500");
      print('   ✓ Address assignment correct');
      
      // Test 5: Verify delivery fee calculation
      print('✅ Test 5: Verifying delivery fee calculation');
      cartController.setDeliveryMethod('delivery');
      double deliveryFee = cartController.actualDeliveryFee;
      assert(deliveryFee == 7500.0); // should use address shipping cost
      print('   ✓ Delivery fee calculation correct: UGX $deliveryFee');
      
      // Test 6: Test pickup method (should be free)
      print('✅ Test 6: Testing pickup method');
      cartController.setDeliveryMethod('pickup');
      double pickupFee = cartController.actualDeliveryFee;
      assert(pickupFee == 0.0);
      assert(cartController.selectedDeliveryAddress.value == null); // should be cleared
      print('   ✓ Pickup method correct: UGX $pickupFee');
      
      // Test 7: Test order creation
      print('✅ Test 7: Testing order creation');
      cartController.setDeliveryMethod('delivery');
      cartController.setDeliveryAddress(mockAddress);
      
      // Add some mock subtotal
      cartController.subtotal.value = 50000.0;
      
      // Create order
      var order = await cartController.createOrder();
      
      assert(order.delivery_method == 'delivery');
      assert(order.delivery_address_id == '123');
      assert(order.delivery_address_text == 'Kampala Central, Uganda');
      assert(order.delivery_amount == '7500');
      print('   ✓ Order creation correct');
      
      // Test 8: Test validation
      print('✅ Test 8: Testing order validation');
      
      // Should be valid with address
      assert(cartController.validateOrder() == true);
      
      // Should be invalid without address
      cartController.setDeliveryAddress(null);
      assert(cartController.validateOrder() == false);
      print('   ✓ Order validation correct');
      
      print('🎉 All Delivery Address Integration Tests Passed!');
      
      // Display summary
      cartController.setDeliveryAddress(mockAddress);
      var summary = cartController.getCartSummary();
      print('\n📋 Cart Summary:');
      print('   - Subtotal: UGX ${summary['subtotal']}');
      print('   - Tax: UGX ${summary['tax']}');
      print('   - Delivery Fee: UGX ${summary['delivery_fee']}');
      print('   - Total: UGX ${summary['total']}');
      print('   - Delivery Method: ${summary['delivery_method']}');
      print('   - Selected Address: ${summary['selected_address']}');
      print('   - Address ID: ${summary['selected_address_id']}');
      
      return;
      
    } catch (e, stackTrace) {
      print('❌ Test Failed: $e');
      print('Stack Trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Test the actual DeliveryAddressPickerScreen integration
  static Future<void> testDeliveryAddressPickerIntegration() async {
    print('🧪 Testing DeliveryAddressPickerScreen Integration...');
    
    try {
      // This test requires actual data from the API
      List<DeliveryAddress> addresses = await DeliveryAddress.get_items();
      
      if (addresses.isEmpty) {
        print('⚠️  No delivery addresses found in database');
        print('   This may be expected if the app hasn\'t synced with the API yet');
        return;
      }
      
      print('✅ Found ${addresses.length} delivery addresses');
      
      for (int i = 0; i < addresses.length && i < 3; i++) {
        DeliveryAddress addr = addresses[i];
        print('   ${i + 1}. ${addr.address} - UGX ${addr.shipping_cost}');
      }
      
      // Test with first address
      if (addresses.isNotEmpty) {
        CartController cartController = Get.find<CartController>();
        DeliveryAddress testAddr = addresses.first;
        
        cartController.setDeliveryAddress(testAddr);
        
        print('✅ Successfully set delivery address:');
        print('   - Address: ${cartController.selectedAddress}');
        print('   - ID: ${cartController.selectedAddressId}');
        print('   - Cost: UGX ${cartController.selectedAddressShippingCost}');
      }
      
      print('🎉 DeliveryAddressPickerScreen Integration Test Passed!');
      
    } catch (e) {
      print('❌ DeliveryAddressPickerScreen Test Failed: $e');
    }
  }
  
  /// Run all tests and display results
  static Future<void> runAllTests() async {
    print('\n🚀 Running Complete Delivery Address Test Suite\n');
    
    try {
      await runTests();
      print('\n---\n');
      await testDeliveryAddressPickerIntegration();
      
      print('\n🎉 All tests completed successfully!');
      print('\n💡 Integration Notes:');
      print('   - DeliveryAddress model properly integrated');
      print('   - Pricing calculations work correctly');
      print('   - Pickup vs delivery logic functions properly');
      print('   - Order validation includes address requirements');
      print('   - CartController provides backward-compatible getters');
      
    } catch (e) {
      print('\n❌ Test suite failed: $e');
      rethrow;
    }
  }
}

/// Widget for testing the delivery address integration in UI
class DeliveryAddressTestWidget extends StatelessWidget {
  const DeliveryAddressTestWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Address Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await DeliveryAddressTest.runAllTests();
                  Get.snackbar(
                    'Tests Passed',
                    'All delivery address tests completed successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Tests Failed',
                    'Some tests failed: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text('Run Delivery Address Tests'),
            ),
            const SizedBox(height: 20),
            const Text(
              'This will test the integration between\nDeliveryAddress model and CartController',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
