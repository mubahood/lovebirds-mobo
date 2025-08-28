import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SharedWishlistService {
  static final SharedWishlistService _instance =
      SharedWishlistService._internal();
  factory SharedWishlistService() => _instance;
  SharedWishlistService._internal();

  final String baseUrl = 'https://lovebirds-api.com/api'; // Mock base URL

  // Helper method to get auth token (mock for now)
  Future<String> _getToken() async {
    return 'mock_token_123';
  }

  // Create a new shared wishlist
  Future<SharedWishlist> createSharedWishlist({
    required String partnerId,
    required String name,
    String? description,
    bool isPrivate = false,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/shared-wishlists'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'partner_id': partnerId,
          'name': name,
          'description': description,
          'is_private': isPrivate,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SharedWishlist.fromJson(data['data']);
      } else {
        throw Exception('Failed to create shared wishlist');
      }
    } catch (e) {
      // Mock successful response for demo
      return SharedWishlist(
        id: 'wl_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description ?? '',
        ownerId: 'current_user_id',
        partnerId: partnerId,
        isPrivate: isPrivate,
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Get shared wishlists for current user
  Future<List<SharedWishlist>> getSharedWishlists() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/shared-wishlists'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((item) => SharedWishlist.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load shared wishlists');
      }
    } catch (e) {
      // Mock response for demo
      return [
        SharedWishlist(
          id: 'wl_1',
          name: 'Our Dream Home',
          description: 'Items for our future together',
          ownerId: 'current_user_id',
          partnerId: 'partner_123',
          isPrivate: false,
          items: _getMockWishlistItems(),
          createdAt: DateTime.now().subtract(Duration(days: 7)),
          updatedAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        SharedWishlist(
          id: 'wl_2',
          name: 'Date Night Ideas',
          description: 'Fun activities and restaurants to try',
          ownerId: 'partner_123',
          partnerId: 'current_user_id',
          isPrivate: true,
          items: _getMockDateNightItems(),
          createdAt: DateTime.now().subtract(Duration(days: 3)),
          updatedAt: DateTime.now().subtract(Duration(minutes: 30)),
        ),
      ];
    }
  }

  // Add item to shared wishlist
  Future<WishlistItem> addItemToWishlist({
    required String wishlistId,
    required String productId,
    required String productName,
    required double price,
    String? imageUrl,
    String? notes,
    int priority = 1,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/shared-wishlists/$wishlistId/items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'product_name': productName,
          'price': price,
          'image_url': imageUrl,
          'notes': notes,
          'priority': priority,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WishlistItem.fromJson(data['data']);
      } else {
        throw Exception('Failed to add item to wishlist');
      }
    } catch (e) {
      // Mock successful response for demo
      return WishlistItem(
        id: 'wi_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        productName: productName,
        price: price,
        imageUrl: imageUrl,
        notes: notes,
        priority: priority,
        addedBy: 'current_user_id',
        isPurchased: false,
        createdAt: DateTime.now(),
      );
    }
  }

  // Remove item from wishlist
  Future<bool> removeItemFromWishlist(String wishlistId, String itemId) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/shared-wishlists/$wishlistId/items/$itemId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      // Mock successful response for demo
      return true;
    }
  }

  // Mark item as purchased
  Future<bool> markItemAsPurchased({
    required String wishlistId,
    required String itemId,
    String? purchasedBy,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.patch(
        Uri.parse(
          '$baseUrl/shared-wishlists/$wishlistId/items/$itemId/purchase',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'purchased_by': purchasedBy}),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Mock successful response for demo
      return true;
    }
  }

  // Update wishlist item priority
  Future<bool> updateItemPriority({
    required String wishlistId,
    required String itemId,
    required int priority,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.patch(
        Uri.parse(
          '$baseUrl/shared-wishlists/$wishlistId/items/$itemId/priority',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'priority': priority}),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Mock successful response for demo
      return true;
    }
  }

  // Get wishlist sharing analytics
  Future<WishlistAnalytics> getWishlistAnalytics(String wishlistId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/shared-wishlists/$wishlistId/analytics'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WishlistAnalytics.fromJson(data['data']);
      } else {
        throw Exception('Failed to load wishlist analytics');
      }
    } catch (e) {
      // Mock response for demo
      return WishlistAnalytics(
        totalItems: 12,
        purchasedItems: 3,
        totalValue: 850.99,
        purchasedValue: 120.99,
        averageItemPrice: 70.92,
        topCategory: 'Home & Garden',
        collaborationScore: 8.5,
        lastActivity: DateTime.now().subtract(Duration(hours: 2)),
      );
    }
  }

  // Mock data generators
  List<WishlistItem> _getMockWishlistItems() {
    return [
      WishlistItem(
        id: 'wi_1',
        productId: 'prod_1',
        productName: 'Cozy Living Room Sofa',
        price: 899.99,
        imageUrl: 'https://example.com/sofa.jpg',
        notes: 'Perfect for movie nights together',
        priority: 3,
        addedBy: 'current_user_id',
        isPurchased: false,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      WishlistItem(
        id: 'wi_2',
        productId: 'prod_2',
        productName: 'Dining Table Set',
        price: 649.99,
        imageUrl: 'https://example.com/dining.jpg',
        notes: 'For romantic dinners at home',
        priority: 2,
        addedBy: 'partner_123',
        isPurchased: true,
        purchasedBy: 'current_user_id',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
      WishlistItem(
        id: 'wi_3',
        productId: 'prod_3',
        productName: 'Kitchen Appliance Set',
        price: 299.99,
        imageUrl: 'https://example.com/kitchen.jpg',
        notes: 'To cook together',
        priority: 1,
        addedBy: 'current_user_id',
        isPurchased: false,
        createdAt: DateTime.now().subtract(Duration(hours: 6)),
      ),
    ];
  }

  List<WishlistItem> _getMockDateNightItems() {
    return [
      WishlistItem(
        id: 'wi_4',
        productId: 'exp_1',
        productName: 'Wine Tasting Experience',
        price: 150.00,
        imageUrl: 'https://example.com/wine.jpg',
        notes: 'For our anniversary',
        priority: 3,
        addedBy: 'partner_123',
        isPurchased: false,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      WishlistItem(
        id: 'wi_5',
        productId: 'rest_1',
        productName: 'Fine Dining Reservation',
        price: 200.00,
        imageUrl: 'https://example.com/restaurant.jpg',
        notes: 'That fancy place downtown',
        priority: 2,
        addedBy: 'current_user_id',
        isPurchased: false,
        createdAt: DateTime.now().subtract(Duration(hours: 12)),
      ),
    ];
  }
}

// Data models for shared wishlist
class SharedWishlist {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String partnerId;
  final bool isPrivate;
  final List<WishlistItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  SharedWishlist({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.partnerId,
    required this.isPrivate,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SharedWishlist.fromJson(Map<String, dynamic> json) {
    return SharedWishlist(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      ownerId: json['owner_id'],
      partnerId: json['partner_id'],
      isPrivate: json['is_private'] ?? false,
      items:
          (json['items'] as List?)
              ?.map((item) => WishlistItem.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'partner_id': partnerId,
      'is_private': isPrivate,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get totalValue => items.fold(0.0, (sum, item) => sum + item.price);
  double get purchasedValue => items
      .where((item) => item.isPurchased)
      .fold(0.0, (sum, item) => sum + item.price);
  int get totalItems => items.length;
  int get purchasedItems => items.where((item) => item.isPurchased).length;
  double get completionPercentage =>
      totalItems > 0 ? (purchasedItems / totalItems) * 100 : 0;
}

class WishlistItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final String? imageUrl;
  final String? notes;
  final int priority; // 1 = Low, 2 = Medium, 3 = High
  final String addedBy;
  final bool isPurchased;
  final String? purchasedBy;
  final DateTime createdAt;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    this.imageUrl,
    this.notes,
    required this.priority,
    required this.addedBy,
    required this.isPurchased,
    this.purchasedBy,
    required this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      notes: json['notes'],
      priority: json['priority'],
      addedBy: json['added_by'],
      isPurchased: json['is_purchased'] ?? false,
      purchasedBy: json['purchased_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'image_url': imageUrl,
      'notes': notes,
      'priority': priority,
      'added_by': addedBy,
      'is_purchased': isPurchased,
      'purchased_by': purchasedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get priorityText {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class WishlistAnalytics {
  final int totalItems;
  final int purchasedItems;
  final double totalValue;
  final double purchasedValue;
  final double averageItemPrice;
  final String topCategory;
  final double
  collaborationScore; // 0-10 score based on both partners' participation
  final DateTime lastActivity;

  WishlistAnalytics({
    required this.totalItems,
    required this.purchasedItems,
    required this.totalValue,
    required this.purchasedValue,
    required this.averageItemPrice,
    required this.topCategory,
    required this.collaborationScore,
    required this.lastActivity,
  });

  factory WishlistAnalytics.fromJson(Map<String, dynamic> json) {
    return WishlistAnalytics(
      totalItems: json['total_items'],
      purchasedItems: json['purchased_items'],
      totalValue: json['total_value'].toDouble(),
      purchasedValue: json['purchased_value'].toDouble(),
      averageItemPrice: json['average_item_price'].toDouble(),
      topCategory: json['top_category'],
      collaborationScore: json['collaboration_score'].toDouble(),
      lastActivity: DateTime.parse(json['last_activity']),
    );
  }

  double get completionPercentage =>
      totalItems > 0 ? (purchasedItems / totalItems) * 100 : 0;

  double get budgetUsedPercentage =>
      totalValue > 0 ? (purchasedValue / totalValue) * 100 : 0;
}
