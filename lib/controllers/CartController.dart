import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../models/LoggedInUserModel.dart';
import '../screens/shop/models/CartItem.dart';
import '../screens/shop/models/OrderOnline.dart';
import '../screens/shop/models/Product.dart';
import '../utils/CustomTheme.dart';
import '../utils/Utilities.dart';

class CartController extends GetxController {
  // Observable cart state
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble deliveryFee = 5000.0.obs;
  final RxDouble taxRate = 0.13.obs; // 13% VAT
  final RxString deliveryMethod = 'delivery'.obs; // 'pickup' or 'delivery'
  final RxString selectedAddress = ''.obs;
  final RxString selectedAddressId = ''.obs;
  final RxBool isLoading = false.obs;

  // Computed properties
  double get tax => subtotal.value * taxRate.value;
  double get actualDeliveryFee => deliveryMethod.value == 'pickup' ? 0.0 : deliveryFee.value;
  double get total => subtotal.value + tax + actualDeliveryFee;
  int get itemCount => cartItems.length;
  bool get isEmpty => cartItems.isEmpty;
  bool get isNotEmpty => cartItems.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
  }

  // Load cart items from local database
  Future<void> loadCartItems() async {
    try {
      isLoading.value = true;
      cartItems.clear();
      subtotal.value = 0.0;

      List<CartItem> items = await CartItem.getItems();
      
      for (CartItem item in items) {
        // Ensure product data is loaded
        if (item.pro.id < 1) {
          await item.getPro();
        }
        
        if (item.pro.id > 0) {
          // Handle dynamic pricing
          if (item.pro.p_type == 'Yes') {
            item.pro.getPrices();
            int qty = Utils.int_parse(item.product_quantity);
            for (var price in item.pro.pricesList) {
              if (qty >= price.min_qty && qty <= price.max_qty) {
                item.product_price_1 = price.price;
                break;
              }
            }
          } else {
            item.product_price_1 = item.pro.price_1;
          }
          
          cartItems.add(item);
          subtotal.value += Utils.double_parse(item.product_quantity) * 
                          Utils.double_parse(item.product_price_1);
        }
      }
    } catch (e) {
      Utils.toast('Error loading cart: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Add product to cart
  Future<bool> addToCart(Product product, {String color = "", String size = ""}) async {
    try {
      // Check if item already exists
      for (CartItem item in cartItems) {
        if (item.product_id == product.id.toString() && 
            item.color == color && 
            item.size == size) {
          showMessage('Item already in cart', isError: false);
          return false;
        }
      }

      CartItem cartItem = CartItem();
      cartItem.id = product.id;
      cartItem.product_id = product.id.toString();
      cartItem.product_name = product.name;
      cartItem.product_price_1 = product.price_1;
      cartItem.product_quantity = '1';
      cartItem.product_feature_photo = product.feature_photo;
      cartItem.color = color;
      cartItem.size = size;
      cartItem.pro = product;

      await cartItem.save();
      await loadCartItems();
      
      showMessage('${product.name} added to cart');
      return true;
    } catch (e) {
      showMessage('Error adding to cart: ${e.toString()}', isError: true);
      return false;
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(productId);
        return;
      }

      // Find and update the item
      CartItem? item = cartItems.firstWhereOrNull(
        (item) => item.product_id == productId
      );
      
      if (item != null) {
        item.product_quantity = quantity.toString();
        await item.save();
        await loadCartItems();
        showMessage('Quantity updated');
      }
    } catch (e) {
      showMessage('Error updating quantity: ${e.toString()}', isError: true);
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      await CartItem.deleteAt("product_id = '$productId'");
      await loadCartItems();
      showMessage('Item removed from cart');
    } catch (e) {
      showMessage('Error removing item: ${e.toString()}', isError: true);
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      await CartItem.deleteAll();
      cartItems.clear();
      subtotal.value = 0.0;
      showMessage('Cart cleared');
    } catch (e) {
      showMessage('Error clearing cart: ${e.toString()}', isError: true);
    }
  }

  // Set delivery method
  void setDeliveryMethod(String method) {
    deliveryMethod.value = method;
    if (method == 'pickup') {
      selectedAddress.value = '';
      selectedAddressId.value = '';
    }
  }

  // Set delivery address
  void setDeliveryAddress(String address, String addressId) {
    selectedAddress.value = address;
    selectedAddressId.value = addressId;
  }

  // Validate order before checkout
  bool validateOrder() {
    if (isEmpty) {
      showMessage('Cart is empty', isError: true);
      return false;
    }

    if (deliveryMethod.value == 'delivery' && selectedAddress.value.isEmpty) {
      showMessage('Please select delivery address', isError: true);
      return false;
    }

    return true;
  }

  // Create order object
  Future<OrderOnline> createOrder() async {
    OrderOnline order = OrderOnline();
    
    // Set delivery information
    order.delivery_method = deliveryMethod.value;
    order.delivery_amount = actualDeliveryFee.toString();
    
    if (deliveryMethod.value == 'delivery' && selectedAddressId.value.isNotEmpty) {
      order.delivery_address_id = selectedAddressId.value;
      order.delivery_address_text = selectedAddress.value;
    }

    // Set order totals
    order.order_total = subtotal.value.toString();
    order.payable_amount = total.toString();

    // Set user information
    LoggedInUserModel user = await LoggedInUserModel.getLoggedInUser();
    if (user.id > 0) {
      order.user = user.id.toString();
      order.mail = user.email;
      order.customer_name = '${user.first_name} ${user.last_name}';
      order.customer_phone_number_1 = user.phone_number;
      order.customer_phone_number_2 = user.phone_number_2;
    }

    return order;
  }

  // Helper method to show messages
  void showMessage(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      backgroundColor: isError 
          ? Colors.red.withOpacity(0.9)
          : CustomTheme.primary.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? FeatherIcons.alertCircle : FeatherIcons.checkCircle,
        color: Colors.white,
      ),
    );
  }

  // Get cart summary for display
  Map<String, dynamic> getCartSummary() {
    return {
      'subtotal': subtotal.value,
      'tax': tax,
      'delivery_fee': actualDeliveryFee,
      'total': total,
      'item_count': itemCount,
      'delivery_method': deliveryMethod.value,
      'selected_address': selectedAddress.value,
    };
  }
}
