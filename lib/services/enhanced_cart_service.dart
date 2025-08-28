import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Product.dart';

class EnhancedCartService {
  static final EnhancedCartService _instance = EnhancedCartService._internal();
  factory EnhancedCartService() => _instance;
  EnhancedCartService._internal();

  static const String _cartKey = 'enhanced_cart_items';
  static const String _wishlistKey = 'wishlist_items';
  static const String _favoritesKey = 'favorite_items';

  // Cart management
  ValueNotifier<List<EnhancedCartItem>> cartItems = ValueNotifier([]);
  ValueNotifier<List<Product>> wishlistItems = ValueNotifier([]);
  ValueNotifier<List<Product>> favoriteItems = ValueNotifier([]);

  // Initialize the service
  Future<void> initialize() async {
    await _loadCartFromStorage();
    await _loadWishlistFromStorage();
    await _loadFavoritesFromStorage();
  }

  // Cart operations
  Future<void> addToCart({
    required Product product,
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
    Map<String, dynamic>? customOptions,
  }) async {
    final existingIndex = cartItems.value.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (existingIndex != -1) {
      // Update existing item quantity
      final updatedItems = List<EnhancedCartItem>.from(cartItems.value);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
      cartItems.value = updatedItems;
    } else {
      // Add new item
      final newItem = EnhancedCartItem(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: quantity,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
        customOptions: customOptions ?? {},
        addedAt: DateTime.now(),
      );
      cartItems.value = [...cartItems.value, newItem];
    }

    await _saveCartToStorage();
  }

  Future<void> removeFromCart(String itemId) async {
    cartItems.value =
        cartItems.value.where((item) => item.id != itemId).toList();
    await _saveCartToStorage();
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(itemId);
      return;
    }

    final updatedItems =
        cartItems.value.map((item) {
          if (item.id == itemId) {
            return item.copyWith(quantity: newQuantity);
          }
          return item;
        }).toList();

    cartItems.value = updatedItems;
    await _saveCartToStorage();
  }

  Future<void> clearCart() async {
    cartItems.value = [];
    await _saveCartToStorage();
  }

  // Wishlist operations
  Future<void> addToWishlist(Product product) async {
    if (!wishlistItems.value.any((item) => item.id == product.id)) {
      wishlistItems.value = [...wishlistItems.value, product];
      await _saveWishlistToStorage();
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    wishlistItems.value =
        wishlistItems.value.where((item) => item.id != productId).toList();
    await _saveWishlistToStorage();
  }

  bool isInWishlist(int productId) {
    return wishlistItems.value.any((item) => item.id == productId);
  }

  // Favorites operations
  Future<void> addToFavorites(Product product) async {
    if (!favoriteItems.value.any((item) => item.id == product.id)) {
      favoriteItems.value = [...favoriteItems.value, product];
      await _saveFavoritesToStorage();
    }
  }

  Future<void> removeFromFavorites(int productId) async {
    favoriteItems.value =
        favoriteItems.value.where((item) => item.id != productId).toList();
    await _saveFavoritesToStorage();
  }

  bool isInFavorites(int productId) {
    return favoriteItems.value.any((item) => item.id == productId);
  }

  // Move wishlist item to cart
  Future<void> moveWishlistItemToCart(int productId) async {
    final product = wishlistItems.value.firstWhere(
      (item) => item.id == productId,
    );

    await addToCart(product: product);
    await removeFromWishlist(productId);
  }

  // Getters
  int get totalItems =>
      cartItems.value.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => cartItems.value.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  double get tax => subtotal * 0.13; // 13% HST for Ontario

  double get total => subtotal + tax;

  List<String> get availableSizes => [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '2XL',
    '3XL',
    'US 6',
    'US 7',
    'US 8',
    'US 9',
    'US 10',
    'US 11',
    'US 12',
    'One Size',
  ];

  List<String> get availableColors => [
    'Black',
    'White',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Purple',
    'Pink',
    'Orange',
    'Brown',
    'Grey',
    'Navy',
    'Beige',
    'Maroon',
    'Turquoise',
  ];

  // Storage operations
  Future<void> _saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = cartItems.value.map((item) => item.toJson()).toList();
    await prefs.setString(_cartKey, jsonEncode(cartJson));
  }

  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);

      if (cartString != null) {
        final cartJson = jsonDecode(cartString) as List;
        cartItems.value =
            cartJson.map((item) => EnhancedCartItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
      cartItems.value = [];
    }
  }

  Future<void> _saveWishlistToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson =
        wishlistItems.value.map((item) => item.toJson()).toList();
    await prefs.setString(_wishlistKey, jsonEncode(wishlistJson));
  }

  Future<void> _loadWishlistFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistString = prefs.getString(_wishlistKey);

      if (wishlistString != null) {
        final wishlistJson = jsonDecode(wishlistString) as List;
        wishlistItems.value =
            wishlistJson.map((item) => Product.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading wishlist from storage: $e');
      wishlistItems.value = [];
    }
  }

  Future<void> _saveFavoritesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson =
        favoriteItems.value.map((item) => item.toJson()).toList();
    await prefs.setString(_favoritesKey, jsonEncode(favoritesJson));
  }

  Future<void> _loadFavoritesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString(_favoritesKey);

      if (favoritesString != null) {
        final favoritesJson = jsonDecode(favoritesString) as List;
        favoriteItems.value =
            favoritesJson.map((item) => Product.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading favorites from storage: $e');
      favoriteItems.value = [];
    }
  }

  // Contact seller functionality
  Future<ContactSellerResponse> contactSeller({
    required int productId,
    required String message,
    required ContactReason reason,
  }) async {
    // Mock implementation - in real app, this would call an API
    await Future.delayed(Duration(seconds: 1));

    return ContactSellerResponse(
      success: true,
      message:
          'Your message has been sent to the seller. They will respond within 24 hours.',
      conversationId: 'conv_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // Buy now functionality
  Future<BuyNowResponse> buyNow({
    required Product product,
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
    Map<String, dynamic>? customOptions,
  }) async {
    // Mock implementation - in real app, this would process immediate purchase
    await Future.delayed(Duration(seconds: 2));

    return BuyNowResponse(
      success: true,
      orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
      paymentUrl: 'https://payment.lovebirds.com/pay/order_123',
      estimatedDelivery: DateTime.now().add(Duration(days: 7)),
    );
  }
}

// Enhanced cart item model
class EnhancedCartItem {
  final String id;
  final Product product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final Map<String, dynamic> customOptions;
  final DateTime addedAt;

  EnhancedCartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    required this.customOptions,
    required this.addedAt,
  });

  double get itemTotal => product.price * quantity;

  EnhancedCartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    Map<String, dynamic>? customOptions,
    DateTime? addedAt,
  }) {
    return EnhancedCartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      customOptions: customOptions ?? this.customOptions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'selected_size': selectedSize,
      'selected_color': selectedColor,
      'custom_options': customOptions,
      'added_at': addedAt.toIso8601String(),
    };
  }

  factory EnhancedCartItem.fromJson(Map<String, dynamic> json) {
    return EnhancedCartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      selectedSize: json['selected_size'],
      selectedColor: json['selected_color'],
      customOptions: Map<String, dynamic>.from(json['custom_options'] ?? {}),
      addedAt: DateTime.parse(json['added_at']),
    );
  }
}

// Supporting classes
enum ContactReason {
  productQuestion,
  shippingInquiry,
  returnRequest,
  customization,
  bulkOrder,
  other,
}

extension ContactReasonExtension on ContactReason {
  String get displayName {
    switch (this) {
      case ContactReason.productQuestion:
        return 'Product Question';
      case ContactReason.shippingInquiry:
        return 'Shipping Inquiry';
      case ContactReason.returnRequest:
        return 'Return Request';
      case ContactReason.customization:
        return 'Customization';
      case ContactReason.bulkOrder:
        return 'Bulk Order';
      case ContactReason.other:
        return 'Other';
    }
  }
}

class ContactSellerResponse {
  final bool success;
  final String message;
  final String? conversationId;

  ContactSellerResponse({
    required this.success,
    required this.message,
    this.conversationId,
  });
}

class BuyNowResponse {
  final bool success;
  final String? orderId;
  final String? paymentUrl;
  final DateTime? estimatedDelivery;
  final String? errorMessage;

  BuyNowResponse({
    required this.success,
    this.orderId,
    this.paymentUrl,
    this.estimatedDelivery,
    this.errorMessage,
  });
}
