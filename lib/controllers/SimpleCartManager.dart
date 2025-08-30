import 'package:get/get.dart';
import '../screens/shop/models/CartItem.dart';
import '../utils/Utilities.dart';

class SimpleCartManager extends GetxController {
  // Single source of truth for cart items
  final RxList<CartItem> _cartItems = <CartItem>[].obs;
  
  // Getters
  List<CartItem> get cartItems => _cartItems.toList();
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;
  int get itemCount => _cartItems.length;
  
  // Calculations
  double get subtotal {
    double total = 0.0;
    for (CartItem item in _cartItems) {
      double price = Utils.double_parse(item.product_price_1);
      int quantity = Utils.int_parse(item.product_quantity);
      total += (price * quantity);
    }
    return total;
  }
  
  double get tax => subtotal * 0.13; // 13% VAT
  
  double deliveryFee(String method) {
    return method.toLowerCase() == 'pickup' ? 0.0 : 5000.0;
  }
  
  double totalAmount(String deliveryMethod) {
    return subtotal + tax + deliveryFee(deliveryMethod);
  }
  
  // Load cart items
  Future<void> loadCartItems() async {
    try {
      List<CartItem> items = await CartItem.getLocalData();
      _cartItems.assignAll(items);
      print('SimpleCartManager: Loaded ${items.length} items');
      for (var item in items) {
        print('Item: ${item.product_name}, Price: ${item.product_price_1}, Qty: ${item.product_quantity}');
      }
    } catch (e) {
      print('SimpleCartManager Error loading items: $e');
      _cartItems.clear();
    }
  }
  
  // Add item to cart
  Future<void> addItem(CartItem item) async {
    try {
      await item.save();
      await loadCartItems(); // Reload to get updated list
    } catch (e) {
      print('SimpleCartManager Error adding item: $e');
    }
  }
  
  // Remove item from cart
  Future<void> removeItem(CartItem item) async {
    try {
      await item.delete();
      await loadCartItems(); // Reload to get updated list
    } catch (e) {
      print('SimpleCartManager Error removing item: $e');
    }
  }
  
  // Update item quantity
  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    try {
      item.product_quantity = newQuantity.toString();
      await item.save();
      await loadCartItems(); // Reload to get updated list
    } catch (e) {
      print('SimpleCartManager Error updating quantity: $e');
    }
  }
  
  // Clear cart
  Future<void> clearCart() async {
    try {
      for (CartItem item in _cartItems) {
        await item.delete();
      }
      _cartItems.clear();
    } catch (e) {
      print('SimpleCartManager Error clearing cart: $e');
    }
  }
}
