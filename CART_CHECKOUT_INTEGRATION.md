# Cart and Checkout Integration Guide

## Overview
This guide explains how to integrate the new comprehensive cart and checkout system into your existing Lovebirds marketplace.

## Components Created

### 1. ComprehensiveCartWidget
**Location:** `/lib/widgets/marketplace/comprehensive_cart_widget.dart`

**Features:**
- Persistent cart storage using SharedPreferences
- Bulk operations (select all, remove selected, save for later)
- Real-time price calculations with Canadian tax (13% HST)
- Promo code system with validation
- Advanced UI with animations and interactive elements
- Save for later functionality
- Recommendations based on cart items
- Comprehensive order summary

### 2. EnhancedCheckoutProcess
**Location:** `/lib/widgets/marketplace/enhanced_checkout_process.dart`

**Features:**
- 4-step checkout flow (Address → Shipping → Payment → Review)
- Canadian address validation with province dropdown
- Multiple payment methods (Credit Card, PayPal, Apple Pay, Google Pay)
- Guest checkout option
- Terms and conditions acceptance
- Order summary with tax calculations
- Progress indicator and step validation

## Integration Steps

### Step 1: Update Dependencies
Add these dependencies to your `pubspec.yaml` if not already present:

```yaml
dependencies:
  shared_preferences: ^2.2.2
  flutter_feather_icons: ^2.0.0+1
  carousel_slider: ^4.2.1
  flutter_staggered_grid_view: ^0.7.0
```

### Step 2: Import Components
```dart
import 'package:your_app/widgets/marketplace/comprehensive_cart_widget.dart';
import 'package:your_app/widgets/marketplace/enhanced_checkout_process.dart';
```

### Step 3: Replace Existing Cart Implementation

#### In your cart screen:
```dart
class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ComprehensiveCartWidget(
        onCartUpdated: (cartItems) {
          // Handle cart updates (save to backend, update UI, etc.)
          print('Cart updated with ${cartItems.length} items');
        },
        onCheckout: (cartItems) {
          // Navigate to checkout
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnhancedCheckoutProcess(
                cartItems: cartItems,
                onOrderComplete: _handleOrderComplete,
              ),
            ),
          );
        },
        showHeader: true,
      ),
    );
  }

  void _handleOrderComplete(Map<String, dynamic> orderData) {
    // Handle successful order completion
    print('Order completed: ${orderData['order_id']}');
    
    // Navigate to order confirmation screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          orderData: orderData,
        ),
      ),
    );
  }
}
```

### Step 4: Add Cart Items from Product Pages

#### In your product detail page:
```dart
// Add to cart functionality
void _addToCart(Product product, {
  int quantity = 1,
  String? selectedSize,
  String? selectedColor,
}) async {
  final cartItem = CartItem(
    product: product,
    quantity: quantity,
    selectedSize: selectedSize,
    selectedColor: selectedColor,
    price: _getCurrentPrice(product), // Use your existing price logic
  );

  // Load existing cart
  final prefs = await SharedPreferences.getInstance();
  final cartData = prefs.getString('cart_items');
  List<CartItem> cartItems = [];
  
  if (cartData != null) {
    final List<dynamic> cartJson = json.decode(cartData);
    cartItems = cartJson.map((item) => CartItem.fromJson(item)).toList();
  }

  // Check if item already exists
  final existingIndex = cartItems.indexWhere(
    (item) => item.product.id == product.id &&
              item.selectedSize == selectedSize &&
              item.selectedColor == selectedColor,
  );

  if (existingIndex >= 0) {
    // Update quantity
    cartItems[existingIndex].quantity += quantity;
  } else {
    // Add new item
    cartItems.add(cartItem);
  }

  // Save updated cart
  final cartJson = cartItems.map((item) => item.toJson()).toList();
  await prefs.setString('cart_items', json.encode(cartJson));

  // Show confirmation
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Added to cart'),
      action: SnackBarAction(
        label: 'View Cart',
        onPressed: () => Navigator.pushNamed(context, '/cart'),
      ),
    ),
  );
}
```

### Step 5: Add Cart Badge to App Bar

#### Update your app bar to show cart item count:
```dart
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart_items');
    
    if (cartData != null) {
      final List<dynamic> cartJson = json.decode(cartData);
      final cartItems = cartJson.map((item) => CartItem.fromJson(item)).toList();
      setState(() {
        _cartItemCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Lovebirds Marketplace'),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Icon(FeatherIcons.shoppingCart),
              if (_cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: DatingTheme.primaryPink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }
}
```

## Backend Integration Requirements

### 1. Order Management API

You'll need to create API endpoints for:

```php
// API Routes needed
POST /api/orders                    // Create new order
GET /api/orders/{id}               // Get order details
PUT /api/orders/{id}/status        // Update order status
GET /api/user/orders               // Get user's orders
POST /api/orders/{id}/cancel       // Cancel order
POST /api/promo-codes/validate     // Validate promo codes
```

### 2. Order Model (Laravel)

```php
// app/Models/Order.php
class Order extends Model
{
    protected $fillable = [
        'user_id',
        'order_id',
        'status',
        'items',
        'shipping_address',
        'billing_address',
        'shipping_method',
        'payment_method',
        'payment_status',
        'subtotal',
        'shipping_cost',
        'tax_amount',
        'discount_amount',
        'total_amount',
        'notes',
        'tracking_number',
    ];

    protected $casts = [
        'items' => 'array',
        'shipping_address' => 'array',
        'billing_address' => 'array',
    ];
}
```

### 3. Migration for Orders Table

```php
// database/migrations/create_orders_table.php
Schema::create('orders', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->nullable()->constrained();
    $table->string('order_id')->unique();
    $table->enum('status', ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled']);
    $table->json('items');
    $table->json('shipping_address');
    $table->json('billing_address')->nullable();
    $table->string('shipping_method');
    $table->string('payment_method');
    $table->enum('payment_status', ['pending', 'paid', 'failed', 'refunded']);
    $table->decimal('subtotal', 10, 2);
    $table->decimal('shipping_cost', 10, 2);
    $table->decimal('tax_amount', 10, 2);
    $table->decimal('discount_amount', 10, 2)->default(0);
    $table->decimal('total_amount', 10, 2);
    $table->text('notes')->nullable();
    $table->string('tracking_number')->nullable();
    $table->timestamps();
});
```

## Payment Integration

### 1. Stripe Setup (for Credit Card payments)

Add to your `pubspec.yaml`:
```yaml
dependencies:
  stripe_payment: ^1.0.8
```

### 2. Payment Processing

```dart
// lib/services/payment_service.dart
class PaymentService {
  static Future<bool> processPayment({
    required double amount,
    required String paymentMethod,
    required Map<String, dynamic> paymentData,
  }) async {
    switch (paymentMethod) {
      case 'card':
        return await _processCardPayment(amount, paymentData);
      case 'paypal':
        return await _processPayPalPayment(amount, paymentData);
      case 'apple_pay':
        return await _processApplePayPayment(amount, paymentData);
      case 'google_pay':
        return await _processGooglePayPayment(amount, paymentData);
      default:
        throw Exception('Unsupported payment method');
    }
  }

  static Future<bool> _processCardPayment(double amount, Map<String, dynamic> data) async {
    // Implement Stripe payment processing
    // This is a placeholder - implement actual Stripe integration
    await Future.delayed(Duration(seconds: 2)); // Simulate processing
    return true; // Return success/failure based on actual payment result
  }

  // Implement other payment methods...
}
```

## Testing the Integration

### 1. Cart Functionality Testing

```dart
// Test cart operations
void testCartOperations() async {
  // Create test product
  final testProduct = Product();
  testProduct.id = 1;
  testProduct.name = 'Test Product';
  testProduct.price_1 = '29.99';

  // Test adding to cart
  final cartItem = CartItem(
    product: testProduct,
    quantity: 2,
    price: 29.99,
  );

  // Test cart persistence
  final prefs = await SharedPreferences.getInstance();
  final cartData = [cartItem.toJson()];
  await prefs.setString('cart_items', json.encode(cartData));

  // Verify cart data
  final savedData = prefs.getString('cart_items');
  assert(savedData != null);
  print('Cart test passed');
}
```

### 2. Checkout Flow Testing

```dart
// Test checkout process
void testCheckoutFlow() {
  final testCartItems = [
    CartItem(
      product: Product()..id = 1..name = 'Test Product',
      quantity: 1,
      price: 29.99,
    ),
  ];

  // Navigate to checkout
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EnhancedCheckoutProcess(
        cartItems: testCartItems,
        onOrderComplete: (orderData) {
          print('Test order completed: ${orderData['order_id']}');
        },
      ),
    ),
  );
}
```

## Troubleshooting

### Common Issues

1. **Cart items not persisting:**
   - Check SharedPreferences permissions
   - Verify JSON serialization/deserialization

2. **Checkout validation failing:**
   - Ensure all required fields are validated
   - Check province dropdown values match Canadian provinces

3. **Payment processing errors:**
   - Verify payment gateway API keys
   - Check network connectivity
   - Validate payment data format

### Debug Mode

Enable debug logging by adding this to your cart widget:

```dart
void _debugCartState() {
  print('Cart Items: ${_cartItems.length}');
  print('Saved Items: ${_savedForLater.length}');
  print('Subtotal: \$${_calculateSubtotal().toStringAsFixed(2)}');
}
```

## Next Steps

1. **Implement backend API endpoints** for order management
2. **Set up payment gateway** (Stripe/PayPal) integration
3. **Add order tracking** functionality
4. **Implement push notifications** for order updates
5. **Add email confirmations** for orders
6. **Create admin panel** for order management

## Support

For implementation support or questions about integrating these components:
- Check existing cart service: `/lib/services/enhanced_cart_service.dart`
- Review product model: `/lib/screens/shop/models/Product.dart`
- Examine current marketplace implementation in `/lib/screens/shop/`

This comprehensive cart and checkout system provides a foundation for a complete e-commerce experience while maintaining consistency with your existing Lovebirds design theme.
