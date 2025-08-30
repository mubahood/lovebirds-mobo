import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controllers/CartController.dart';
import '../../../../../controllers/MainController.dart';
import '../../../models/CartItem.dart';
import 'ImprovedCartScreen.dart';

/// CART SYSTEM INTEGRATION GUIDE
///
/// This file demonstrates how to integrate the new improved cart system
/// into your existing app with proper state management and modern UI.
///
/// KEY FEATURES:
/// - Reactive cart state management with GetX
/// - Modern UI with proper error handling
/// - Automated tax calculation (13% VAT)
/// - Delivery method selection (pickup/delivery)
/// - Address management for delivery orders
/// - Order validation and submission
/// - Cart persistence with SQLite
///
/// USAGE EXAMPLES:

class CartIntegrationExample extends StatelessWidget {
  const CartIntegrationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart Integration Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Initialize Cart Controller'),
            _buildCodeExample(_getInitializationExample()),
            const SizedBox(height: 24),

            _buildSectionTitle('2. Add Items to Cart'),
            _buildCodeExample(_getAddToCartExample()),
            const SizedBox(height: 24),

            _buildSectionTitle('3. Navigate to Cart Screen'),
            _buildCodeExample(_getNavigationExample()),
            const SizedBox(height: 24),

            _buildSectionTitle('4. Cart State Management'),
            _buildCodeExample(_getStateManagementExample()),
            const SizedBox(height: 24),

            _buildSectionTitle('5. Checkout Process'),
            _buildCodeExample(_getCheckoutExample()),
            const SizedBox(height: 24),

            _buildSectionTitle('Live Demo Buttons'),
            _buildDemoButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCodeExample(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        code,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }

  Widget _buildDemoButtons() {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Initialize Cart Controller Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _initializeCartController,
            child: const Text('Initialize Cart Controller'),
          ),
        ),
        const SizedBox(height: 12),

        // View Cart Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _navigateToCart,
            child: const Text('Open Improved Cart Screen'),
          ),
        ),
        const SizedBox(height: 12),

        // Add Sample Item Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _addSampleItem,
            child: const Text('Add Sample Item to Cart'),
          ),
        ),
        const SizedBox(height: 12),

        // Clear Cart Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _clearCart,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Cart'),
          ),
        ),
      ],
    );
  }

  String _getInitializationExample() {
    return '''
// Initialize the cart controller in your main app or screen
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MyHomePage(),
      // Initialize controllers
      initialBinding: BindingsBuilder(() {
        Get.put(CartController());
        Get.put(MainController());
      }),
    );
  }
}

// Or initialize when needed
final CartController cartController = Get.put(CartController());
''';
  }

  String _getAddToCartExample() {
    return '''
// Add item to cart from product screen
void addToCart(Product product, int quantity) async {
  final CartController cartController = Get.find<CartController>();
  
  // Create cart item with proper field assignments
  CartItem cartItem = CartItem();
  cartItem.product_id = product.id.toString();
  cartItem.product_name = product.name;
  cartItem.product_price_1 = product.price.toString();
  cartItem.product_quantity = quantity.toString();
  cartItem.product_feature_photo = product.feature_photo;
  cartItem.color = ""; // Set if product has color variants
  cartItem.size = ""; // Set if product has size variants
  
  // Save to database and update UI
  await cartItem.save();
  await cartController.loadCartItems();
  
  // Show feedback
  Get.snackbar(
    'Added to Cart',
    '\${product.name} added successfully',
    backgroundColor: Colors.green,
  );
}
''';
  }

  String _getNavigationExample() {
    return '''
// Navigate to improved cart screen
void openCartScreen() {
  Get.to(() => const ImprovedCartScreen());
}

// Or as a bottom sheet
void openCartBottomSheet() {
  Get.bottomSheet(
    const ImprovedCartScreen(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
''';
  }

  String _getStateManagementExample() {
    return '''
// Listen to cart changes in your UI
class CartBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    
    return Obx(() => Badge(
      count: cartController.itemCount.value,
      child: IconButton(
        icon: Icon(Icons.shopping_cart),
        onPressed: () => Get.to(() => ImprovedCartScreen()),
      ),
    ));
  }
}

// Access cart totals reactively
Widget buildCartSummary() {
  final CartController cartController = Get.find<CartController>();
  
  return Obx(() => Column(
    children: [
      Text('Items: \${cartController.itemCount}'),
      Text('Subtotal: UGX \${cartController.subtotal}'),
      Text('Tax: UGX \${cartController.tax}'),
      Text('Total: UGX \${cartController.total}'),
    ],
  ));
}
''';
  }

  String _getCheckoutExample() {
    return '''
// Navigate to checkout with proper order setup
void proceedToCheckout() async {
  final CartController cartController = Get.find<CartController>();
  
  // Validate cart
  if (cartController.isEmpty) {
    Get.snackbar('Cart Empty', 'Please add items to cart');
    return;
  }
  
  // Create order object
  OrderOnline order = OrderOnline();
  order.delivery_method = cartController.deliveryMethod.value;
  order.order_total = cartController.subtotal.value.toString();
  order.payable_amount = cartController.total.toString();
  order.delivery_amount = cartController.actualDeliveryFee.toString();
  
  // Set delivery details
  if (cartController.deliveryMethod.value == 'delivery') {
    order.delivery_address_id = cartController.selectedAddressId;
    order.delivery_address_text = cartController.selectedAddress;
  }
  
  // Navigate to checkout
  Get.to(() => ImprovedCheckoutScreen(order));
}
''';
  }

  // Demo button handlers
  void _initializeCartController() {
    try {
      Get.put(CartController());
      Get.put(MainController());
      Get.snackbar(
        'Success',
        'Cart controller initialized successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _navigateToCart() {
    try {
      // Ensure controller exists
      if (!Get.isRegistered<CartController>()) {
        Get.put(CartController());
      }

      Get.to(() => const ImprovedCartScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open cart: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _addSampleItem() async {
    try {
      // Ensure controller exists
      if (!Get.isRegistered<CartController>()) {
        Get.put(CartController());
      }

      final CartController cartController = Get.find<CartController>();

      // Create a sample cart item with proper field assignments
      CartItem sampleItem = CartItem();
      sampleItem.product_id = "999"; // Sample product ID
      sampleItem.product_name = "Sample Product";
      sampleItem.product_price_1 = "25000";
      sampleItem.product_quantity = "1";
      sampleItem.product_feature_photo = "";
      sampleItem.color = "";
      sampleItem.size = "";

      // Save and reload
      await sampleItem.save();
      await cartController.loadCartItems();

      Get.snackbar(
        'Success',
        'Sample item added to cart',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add item: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _clearCart() async {
    try {
      // Clear all cart items
      await CartItem.deleteAll();

      // Reload cart if controller exists
      if (Get.isRegistered<CartController>()) {
        final CartController cartController = Get.find<CartController>();
        await cartController.loadCartItems();
      }

      Get.snackbar(
        'Success',
        'Cart cleared successfully',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear cart: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

/// INTEGRATION CHECKLIST:
/// 
/// □ 1. Add CartController to your app initialization
/// □ 2. Update product screens to use new addToCart method
/// □ 3. Replace old cart screens with ImprovedCartScreen
/// □ 4. Replace old checkout with ImprovedCheckoutScreen  
/// □ 5. Update cart badge/icon to use reactive state
/// □ 6. Test cart persistence across app restarts
/// □ 7. Test delivery method selection and address handling
/// □ 8. Test tax calculation and order submission
/// □ 9. Test error handling for empty carts and failed orders
/// □ 10. Verify UI consistency with your app theme

/// IMPORTANT NOTES:
/// 
/// 1. DEPENDENCIES: Make sure all imports are available in your project
/// 2. DATABASE: CartItem uses SQLite - ensure database is initialized
/// 3. API: Order submission requires working API endpoint 'orders-create'
/// 4. THEME: Uses CustomTheme - adapt colors to match your design
/// 5. VALIDATION: Add additional validation as needed for your business logic
/// 6. TESTING: Test thoroughly on different devices and screen sizes
/// 
/// SUPPORT:
/// If you encounter any issues during integration, check:
/// - Import paths are correct for your project structure
/// - Database permissions and initialization
/// - API endpoints and network connectivity  
/// - GetX controller registration and dependency injection
/// - Theme colors and styling compatibility
