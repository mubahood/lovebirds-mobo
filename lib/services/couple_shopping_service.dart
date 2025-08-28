import 'dart:convert';
import 'package:http/http.dart' as http;

class CoupleShoppingService {
  static final CoupleShoppingService _instance =
      CoupleShoppingService._internal();
  factory CoupleShoppingService() => _instance;
  CoupleShoppingService._internal();

  final String baseUrl = 'https://lovebirds-api.com/api'; // Mock base URL

  // Helper method to get auth token (mock for now)
  Future<String> _getToken() async {
    return 'mock_token_123';
  }

  // Helper method to calculate Canadian taxes (mock for now)
  Future<TaxInfo> _calculateCanadianTax(double subtotal) async {
    final hst = subtotal * 0.13; // 13% HST for Ontario
    return TaxInfo(
      hst: hst,
      totalTax: hst,
      subtotal: subtotal,
      total: subtotal + hst,
    );
  }

  // Shopping session management
  Future<ShoppingSession> createShoppingSession(
    String partnerId,
    String sessionType,
  ) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/create-shopping-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'partner_id': partnerId,
          'session_type': sessionType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShoppingSession.fromJson(data['data']);
      } else {
        throw Exception('Failed to create shopping session');
      }
    } catch (e) {
      // Fallback with mock data
      return ShoppingSession(
        sessionId: 'SESSION_${DateTime.now().millisecondsSinceEpoch}',
        partnerId: partnerId,
        sessionType: sessionType,
        status: 'active',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        items: [],
        totalCost: 0.0,
        currency: 'CAD',
      );
    }
  }

  Future<List<ShoppingSession>> getActiveShoppingSessions() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/get-shopping-sessions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((session) => ShoppingSession.fromJson(session))
            .toList();
      } else {
        throw Exception('Failed to get shopping sessions');
      }
    } catch (e) {
      // Return mock active sessions
      return [
        ShoppingSession(
          sessionId: 'SESSION_001',
          partnerId: 'partner_123',
          sessionType: 'date_planning',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          expiresAt: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
          items: [
            ShoppingItem(
              itemId: 'item_001',
              name: 'Romantic Dinner Candles',
              price: 24.99,
              category: 'date_essentials',
              addedBy: 'partner_123',
              addedAt: DateTime.now().subtract(const Duration(minutes: 15)),
            ),
          ],
          totalCost: 24.99,
          currency: 'CAD',
        ),
      ];
    }
  }

  // Collaborative shopping items
  Future<List<DateShoppingItem>> getDateShoppingItems(String category) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/get-date-shopping-items?category=$category'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((item) => DateShoppingItem.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get shopping items');
      }
    } catch (e) {
      // Return comprehensive mock shopping items
      return _getMockShoppingItems(category);
    }
  }

  List<DateShoppingItem> _getMockShoppingItems(String category) {
    final Map<String, List<DateShoppingItem>> mockItems = {
      'date_essentials': [
        DateShoppingItem(
          itemId: 'candles_001',
          name: 'Romantic Dinner Candles (Set of 6)',
          description:
              'Premium soy candles with vanilla scent, perfect for intimate dining',
          price: 29.99,
          originalPrice: 39.99,
          discount: 25,
          category: 'date_essentials',
          subcategory: 'ambiance',
          imageUrl: 'https://example.com/candles.jpg',
          vendor: 'Romantic Essentials Co.',
          rating: 4.8,
          reviewCount: 124,
          inStock: true,
          deliveryTime: '1-2 days',
          idealFor: ['romantic dinner', 'home date', 'anniversary'],
          coupleApprovalRating: 95,
          tags: ['romantic', 'scented', 'long-lasting'],
        ),
        DateShoppingItem(
          itemId: 'playlist_001',
          name: 'Curated Date Night Playlist (Premium)',
          description:
              'Hand-picked romantic songs for the perfect evening ambiance',
          price: 9.99,
          category: 'date_essentials',
          subcategory: 'entertainment',
          imageUrl: 'https://example.com/playlist.jpg',
          vendor: 'LoveTunes',
          rating: 4.9,
          reviewCount: 89,
          inStock: true,
          deliveryTime: 'Instant',
          idealFor: ['any date', 'background music', 'mood setting'],
          coupleApprovalRating: 98,
          tags: ['music', 'instant', 'curated'],
        ),
        DateShoppingItem(
          itemId: 'flowers_001',
          name: 'Fresh Rose Bouquet (12 roses)',
          description:
              'Beautiful red roses delivered fresh for your special someone',
          price: 49.99,
          category: 'date_essentials',
          subcategory: 'flowers',
          imageUrl: 'https://example.com/roses.jpg',
          vendor: 'Toronto Flower Market',
          rating: 4.7,
          reviewCount: 234,
          inStock: true,
          deliveryTime: 'Same day',
          idealFor: ['surprise', 'apology', 'anniversary'],
          coupleApprovalRating: 92,
          tags: ['fresh', 'classic', 'romantic'],
        ),
      ],
      'experience_gifts': [
        DateShoppingItem(
          itemId: 'cooking_001',
          name: 'Virtual Couples Cooking Class',
          description:
              'Learn to cook together with a professional chef via video call',
          price: 89.99,
          category: 'experience_gifts',
          subcategory: 'activities',
          imageUrl: 'https://example.com/cooking.jpg',
          vendor: 'Chef Connect Canada',
          rating: 4.9,
          reviewCount: 156,
          inStock: true,
          deliveryTime: 'Schedule required',
          idealFor: ['learning together', 'fun activity', 'date night'],
          coupleApprovalRating: 96,
          tags: ['interactive', 'educational', 'fun'],
        ),
        DateShoppingItem(
          itemId: 'wine_001',
          name: 'Wine Tasting Kit for Two',
          description:
              'Premium wine selection with tasting notes and cheese pairings',
          price: 119.99,
          category: 'experience_gifts',
          subcategory: 'food_drink',
          imageUrl: 'https://example.com/wine_kit.jpg',
          vendor: 'Canadian Wine Co.',
          rating: 4.6,
          reviewCount: 78,
          inStock: true,
          deliveryTime: '2-3 days',
          idealFor: ['sophisticated dates', 'wine lovers', 'special occasions'],
          coupleApprovalRating: 88,
          tags: ['wine', 'educational', 'premium'],
        ),
      ],
      'fashion_accessories': [
        DateShoppingItem(
          itemId: 'jewelry_001',
          name: 'Matching Promise Rings Set',
          description: 'Beautiful silver rings engraved with love symbols',
          price: 199.99,
          category: 'fashion_accessories',
          subcategory: 'jewelry',
          imageUrl: 'https://example.com/rings.jpg',
          vendor: 'Eternal Jewelry',
          rating: 4.8,
          reviewCount: 67,
          inStock: true,
          deliveryTime: '3-5 days',
          idealFor: ['commitment', 'anniversary', 'milestone'],
          coupleApprovalRating: 94,
          tags: ['matching', 'symbolic', 'quality'],
        ),
        DateShoppingItem(
          itemId: 'perfume_001',
          name: 'Couples Perfume Set',
          description:
              'Complementary his & hers fragrances that blend perfectly together',
          price: 149.99,
          category: 'fashion_accessories',
          subcategory: 'fragrance',
          imageUrl: 'https://example.com/perfume.jpg',
          vendor: 'Scent Stories',
          rating: 4.5,
          reviewCount: 123,
          inStock: true,
          deliveryTime: '1-2 days',
          idealFor: ['special occasions', 'daily wear', 'gifts'],
          coupleApprovalRating: 87,
          tags: ['complementary', 'long-lasting', 'unique'],
        ),
      ],
      'home_date': [
        DateShoppingItem(
          itemId: 'movie_001',
          name: 'Romantic Movie Night Package',
          description:
              'Curated selection of romantic movies with popcorn and treats',
          price: 34.99,
          category: 'home_date',
          subcategory: 'entertainment',
          imageUrl: 'https://example.com/movie_night.jpg',
          vendor: 'Cozy Nights Co.',
          rating: 4.7,
          reviewCount: 189,
          inStock: true,
          deliveryTime: 'Instant download',
          idealFor: ['cozy nights', 'rainy days', 'relaxation'],
          coupleApprovalRating: 91,
          tags: ['movies', 'snacks', 'cozy'],
        ),
        DateShoppingItem(
          itemId: 'game_001',
          name: 'Couples Card Game Collection',
          description: 'Fun and intimate card games designed for couples',
          price: 24.99,
          category: 'home_date',
          subcategory: 'games',
          imageUrl: 'https://example.com/card_games.jpg',
          vendor: 'Relationship Games Inc.',
          rating: 4.9,
          reviewCount: 234,
          inStock: true,
          deliveryTime: '1-2 days',
          idealFor: [
            'getting to know each other',
            'fun conversations',
            'bonding',
          ],
          coupleApprovalRating: 97,
          tags: ['interactive', 'conversation starters', 'bonding'],
        ),
      ],
    };

    return mockItems[category] ?? [];
  }

  // Add item to shared shopping session
  Future<bool> addItemToSession(
    String sessionId,
    String itemId,
    String addedBy,
  ) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/add-item-to-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'item_id': itemId,
          'added_by': addedBy,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return true; // Mock success
    }
  }

  // Partner approval/voting system
  Future<bool> voteOnItem(
    String sessionId,
    String itemId,
    bool approve,
    String reason,
  ) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/vote-on-item'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'item_id': itemId,
          'approve': approve,
          'reason': reason,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return true; // Mock success
    }
  }

  // Get shopping recommendations based on couple preferences
  Future<List<DateShoppingItem>> getPersonalizedRecommendations(
    String partnerId,
  ) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get-personalized-shopping-recommendations?partner_id=$partnerId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((item) => DateShoppingItem.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get recommendations');
      }
    } catch (e) {
      // Return mock personalized recommendations
      return [
        DateShoppingItem(
          itemId: 'rec_001',
          name: 'Date Night Surprise Box',
          description:
              'Curated box of romantic items based on your preferences',
          price: 79.99,
          category: 'recommendations',
          subcategory: 'curated',
          imageUrl: 'https://example.com/surprise_box.jpg',
          vendor: 'LoveBirds Curated',
          rating: 4.9,
          reviewCount: 345,
          inStock: true,
          deliveryTime: '1-2 days',
          idealFor: ['surprise', 'variety', 'convenience'],
          coupleApprovalRating: 98,
          tags: ['curated', 'surprise', 'personalized'],
          personalizedReason:
              'Based on your shared love for cozy nights and Italian cuisine',
        ),
      ];
    }
  }

  // Complete shared purchase
  Future<PurchaseResult> completeCouplesPurchase(
    String sessionId,
    PaymentInfo paymentInfo,
  ) async {
    try {
      final token = await _getToken();

      // Calculate Canadian taxes and final cost
      final taxInfo = await _calculateCanadianTax(paymentInfo.subtotal);
      final finalCost = paymentInfo.subtotal + taxInfo.totalTax;

      final response = await http.post(
        Uri.parse('$baseUrl/complete-couples-purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'payment_info': paymentInfo.toJson(),
          'tax_info': taxInfo.toJson(),
          'final_cost': finalCost,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PurchaseResult.fromJson(data['data']);
      } else {
        throw Exception('Failed to complete purchase');
      }
    } catch (e) {
      // Return mock successful purchase
      final taxInfo = await _calculateCanadianTax(paymentInfo.subtotal);
      return PurchaseResult(
        purchaseId: 'PURCHASE_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        status: 'completed',
        totalCost: paymentInfo.subtotal + taxInfo.totalTax,
        currency: 'CAD',
        taxInfo: taxInfo,
        confirmationNumber:
            'LB${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
        trackingNumbers: ['TRACK001', 'TRACK002'],
        splitPayment: paymentInfo.splitPayment,
      );
    }
  }

  // Get shopping analytics for couples
  Future<CoupleShoppingAnalytics> getShoppingAnalytics(String partnerId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get-couple-shopping-analytics?partner_id=$partnerId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CoupleShoppingAnalytics.fromJson(data['data']);
      } else {
        throw Exception('Failed to get analytics');
      }
    } catch (e) {
      // Return mock analytics
      return CoupleShoppingAnalytics(
        totalPurchases: 12,
        totalSpent: 847.50,
        favoriteCategory: 'date_essentials',
        averagePurchaseValue: 70.63,
        partnerAgreementRate: 92,
        mostPopularItems: [
          'Romantic Dinner Candles',
          'Wine Tasting Kit',
          'Couples Card Games',
        ],
        spendingTrend: 'increasing',
        budgetUtilization: 76,
        recommendationAccuracy: 88,
      );
    }
  }
}

// Data models for couple shopping
class ShoppingSession {
  final String sessionId;
  final String partnerId;
  final String sessionType;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<ShoppingItem> items;
  final double totalCost;
  final String currency;

  ShoppingSession({
    required this.sessionId,
    required this.partnerId,
    required this.sessionType,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.items,
    required this.totalCost,
    required this.currency,
  });

  factory ShoppingSession.fromJson(Map<String, dynamic> json) {
    return ShoppingSession(
      sessionId: json['session_id'],
      partnerId: json['partner_id'],
      sessionType: json['session_type'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      items:
          (json['items'] as List?)
              ?.map((item) => ShoppingItem.fromJson(item))
              .toList() ??
          [],
      totalCost: (json['total_cost'] as num).toDouble(),
      currency: json['currency'],
    );
  }
}

class ShoppingItem {
  final String itemId;
  final String name;
  final double price;
  final String category;
  final String addedBy;
  final DateTime addedAt;
  final bool? partnerApproved;
  final String? partnerNotes;

  ShoppingItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.category,
    required this.addedBy,
    required this.addedAt,
    this.partnerApproved,
    this.partnerNotes,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      itemId: json['item_id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      addedBy: json['added_by'],
      addedAt: DateTime.parse(json['added_at']),
      partnerApproved: json['partner_approved'],
      partnerNotes: json['partner_notes'],
    );
  }
}

class DateShoppingItem {
  final String itemId;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int? discount;
  final String category;
  final String subcategory;
  final String imageUrl;
  final String vendor;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final String deliveryTime;
  final List<String> idealFor;
  final int coupleApprovalRating;
  final List<String> tags;
  final String? personalizedReason;

  DateShoppingItem({
    required this.itemId,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discount,
    required this.category,
    required this.subcategory,
    required this.imageUrl,
    required this.vendor,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.deliveryTime,
    required this.idealFor,
    required this.coupleApprovalRating,
    required this.tags,
    this.personalizedReason,
  });

  factory DateShoppingItem.fromJson(Map<String, dynamic> json) {
    return DateShoppingItem(
      itemId: json['item_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      discount: json['discount'],
      category: json['category'],
      subcategory: json['subcategory'],
      imageUrl: json['image_url'],
      vendor: json['vendor'],
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'],
      inStock: json['in_stock'],
      deliveryTime: json['delivery_time'],
      idealFor: List<String>.from(json['ideal_for']),
      coupleApprovalRating: json['couple_approval_rating'],
      tags: List<String>.from(json['tags']),
      personalizedReason: json['personalized_reason'],
    );
  }
}

class PaymentInfo {
  final double subtotal;
  final bool splitPayment;
  final String paymentMethod;
  final String? partnerPaymentMethod;

  PaymentInfo({
    required this.subtotal,
    required this.splitPayment,
    required this.paymentMethod,
    this.partnerPaymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'split_payment': splitPayment,
      'payment_method': paymentMethod,
      'partner_payment_method': partnerPaymentMethod,
    };
  }
}

class PurchaseResult {
  final String purchaseId;
  final String sessionId;
  final String status;
  final double totalCost;
  final String currency;
  final dynamic taxInfo;
  final String confirmationNumber;
  final DateTime estimatedDelivery;
  final List<String> trackingNumbers;
  final bool splitPayment;

  PurchaseResult({
    required this.purchaseId,
    required this.sessionId,
    required this.status,
    required this.totalCost,
    required this.currency,
    required this.taxInfo,
    required this.confirmationNumber,
    required this.estimatedDelivery,
    required this.trackingNumbers,
    required this.splitPayment,
  });

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    return PurchaseResult(
      purchaseId: json['purchase_id'],
      sessionId: json['session_id'],
      status: json['status'],
      totalCost: (json['total_cost'] as num).toDouble(),
      currency: json['currency'],
      taxInfo: json['tax_info'],
      confirmationNumber: json['confirmation_number'],
      estimatedDelivery: DateTime.parse(json['estimated_delivery']),
      trackingNumbers: List<String>.from(json['tracking_numbers']),
      splitPayment: json['split_payment'],
    );
  }
}

class CoupleShoppingAnalytics {
  final int totalPurchases;
  final double totalSpent;
  final String favoriteCategory;
  final double averagePurchaseValue;
  final int partnerAgreementRate;
  final List<String> mostPopularItems;
  final String spendingTrend;
  final int budgetUtilization;
  final int recommendationAccuracy;

  CoupleShoppingAnalytics({
    required this.totalPurchases,
    required this.totalSpent,
    required this.favoriteCategory,
    required this.averagePurchaseValue,
    required this.partnerAgreementRate,
    required this.mostPopularItems,
    required this.spendingTrend,
    required this.budgetUtilization,
    required this.recommendationAccuracy,
  });

  factory CoupleShoppingAnalytics.fromJson(Map<String, dynamic> json) {
    return CoupleShoppingAnalytics(
      totalPurchases: json['total_purchases'],
      totalSpent: (json['total_spent'] as num).toDouble(),
      favoriteCategory: json['favorite_category'],
      averagePurchaseValue: (json['average_purchase_value'] as num).toDouble(),
      partnerAgreementRate: json['partner_agreement_rate'],
      mostPopularItems: List<String>.from(json['most_popular_items']),
      spendingTrend: json['spending_trend'],
      budgetUtilization: json['budget_utilization'],
      recommendationAccuracy: json['recommendation_accuracy'],
    );
  }
}

// Tax information class
class TaxInfo {
  final double hst;
  final double totalTax;
  final double subtotal;
  final double total;

  TaxInfo({
    required this.hst,
    required this.totalTax,
    required this.subtotal,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'hst': hst,
      'total_tax': totalTax,
      'subtotal': subtotal,
      'total': total,
    };
  }

  factory TaxInfo.fromJson(Map<String, dynamic> json) {
    return TaxInfo(
      hst: (json['hst'] as num).toDouble(),
      totalTax: (json['total_tax'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}
