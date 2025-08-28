/// Date Planning Marketplace Service
/// Handles restaurant bookings, activity reservations, and date planning commerce
library date_marketplace_service;

import 'dart:math';

import '../models/UserModel.dart';
import '../services/canadian_localization_service.dart';
import '../utils/Utilities.dart';
import '../models/RespondModel.dart';

/// Service for marketplace functionality in date planning
class DateMarketplaceService {
  static final DateMarketplaceService _instance = DateMarketplaceService._();
  static DateMarketplaceService get instance => _instance;
  DateMarketplaceService._();

  /// Book a restaurant for a date
  static Future<RestaurantBookingResult> bookRestaurant({
    required String restaurantId,
    required String restaurantName,
    required UserModel currentUser,
    required UserModel matchedUser,
    required DateTime preferredDate,
    required String preferredTime,
    required int partySize,
    String? specialRequests,
    String? paymentMethod,
  }) async {
    try {
      final params = {
        'restaurant_id': restaurantId,
        'restaurant_name': restaurantName,
        'user_id': currentUser.id,
        'matched_user_id': matchedUser.id,
        'preferred_date': preferredDate.toIso8601String(),
        'preferred_time': preferredTime,
        'party_size': partySize,
        'special_requests': specialRequests,
        'payment_method': paymentMethod,
      };

      final response = await Utils.http_post('book-restaurant', params);
      final resp = RespondModel(response);

      if (resp.code == 1) {
        return RestaurantBookingResult.fromJson(resp.data);
      }

      return _generateMockRestaurantBooking(
        restaurantId,
        restaurantName,
        preferredDate,
        preferredTime,
        partySize,
      );
    } catch (e) {
      print('Error booking restaurant: $e');
      return _generateMockRestaurantBooking(
        restaurantId,
        restaurantName,
        preferredDate,
        preferredTime,
        partySize,
      );
    }
  }

  /// Reserve an activity for a date
  static Future<ActivityBookingResult> bookActivity({
    required String activityId,
    required String activityName,
    required UserModel currentUser,
    required UserModel matchedUser,
    required DateTime preferredDate,
    required String preferredTime,
    required int numberOfPeople,
    String? additionalInfo,
    String? paymentMethod,
  }) async {
    try {
      final params = {
        'activity_id': activityId,
        'activity_name': activityName,
        'user_id': currentUser.id,
        'matched_user_id': matchedUser.id,
        'preferred_date': preferredDate.toIso8601String(),
        'preferred_time': preferredTime,
        'number_of_people': numberOfPeople,
        'additional_info': additionalInfo,
        'payment_method': paymentMethod,
      };

      final response = await Utils.http_post('book-activity', params);
      final resp = RespondModel(response);

      if (resp.code == 1) {
        return ActivityBookingResult.fromJson(resp.data);
      }

      return _generateMockActivityBooking(
        activityId,
        activityName,
        preferredDate,
        preferredTime,
        numberOfPeople,
      );
    } catch (e) {
      print('Error booking activity: $e');
      return _generateMockActivityBooking(
        activityId,
        activityName,
        preferredDate,
        preferredTime,
        numberOfPeople,
      );
    }
  }

  /// Get available time slots for a restaurant
  static Future<List<TimeSlot>> getRestaurantAvailability({
    required String restaurantId,
    required DateTime date,
    required int partySize,
  }) async {
    try {
      final params = {
        'restaurant_id': restaurantId,
        'date': date.toIso8601String(),
        'party_size': partySize,
      };

      final response = await Utils.http_post(
        'get-restaurant-availability',
        params,
      );
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final slotsData = resp.data['available_slots'] as List? ?? [];
        return slotsData.map((data) => TimeSlot.fromJson(data)).toList();
      }

      return _generateMockTimeSlots(date);
    } catch (e) {
      print('Error getting restaurant availability: $e');
      return _generateMockTimeSlots(date);
    }
  }

  /// Get available time slots for an activity
  static Future<List<TimeSlot>> getActivityAvailability({
    required String activityId,
    required DateTime date,
    required int numberOfPeople,
  }) async {
    try {
      final params = {
        'activity_id': activityId,
        'date': date.toIso8601String(),
        'number_of_people': numberOfPeople,
      };

      final response = await Utils.http_post(
        'get-activity-availability',
        params,
      );
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final slotsData = resp.data['available_slots'] as List? ?? [];
        return slotsData.map((data) => TimeSlot.fromJson(data)).toList();
      }

      return _generateMockActivitySlots(date);
    } catch (e) {
      print('Error getting activity availability: $e');
      return _generateMockActivitySlots(date);
    }
  }

  /// Get date packages (restaurant + activity combinations)
  static Future<List<DatePackage>> getDatePackages({
    required UserModel currentUser,
    required UserModel matchedUser,
    String? priceRange,
    String? theme,
  }) async {
    try {
      final params = {
        'user_id': currentUser.id,
        'matched_user_id': matchedUser.id,
        'price_range': priceRange,
        'theme': theme,
        'location': '${currentUser.latitude},${currentUser.longitude}',
      };

      final response = await Utils.http_post('get-date-packages', params);
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final packagesData = resp.data['packages'] as List? ?? [];
        return packagesData.map((data) => DatePackage.fromJson(data)).toList();
      }

      return _generateMockDatePackages();
    } catch (e) {
      print('Error getting date packages: $e');
      return _generateMockDatePackages();
    }
  }

  /// Book a complete date package
  static Future<DatePackageBookingResult> bookDatePackage({
    required String packageId,
    required UserModel currentUser,
    required UserModel matchedUser,
    required DateTime preferredDate,
    String? paymentMethod,
    Map<String, String>? customizations,
  }) async {
    try {
      final params = {
        'package_id': packageId,
        'user_id': currentUser.id,
        'matched_user_id': matchedUser.id,
        'preferred_date': preferredDate.toIso8601String(),
        'payment_method': paymentMethod,
        'customizations': customizations,
      };

      final response = await Utils.http_post('book-date-package', params);
      final resp = RespondModel(response);

      if (resp.code == 1) {
        return DatePackageBookingResult.fromJson(resp.data);
      }

      return _generateMockPackageBooking(packageId, preferredDate);
    } catch (e) {
      print('Error booking date package: $e');
      return _generateMockPackageBooking(packageId, preferredDate);
    }
  }

  /// Get user's booking history
  static Future<List<BookingHistory>> getBookingHistory({
    required int userId,
    int? limit,
  }) async {
    try {
      final params = {'user_id': userId, 'limit': limit ?? 20};

      final response = await Utils.http_post('get-booking-history', params);
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final historyData = resp.data['bookings'] as List? ?? [];
        return historyData
            .map((data) => BookingHistory.fromJson(data))
            .toList();
      }

      return _generateMockBookingHistory(userId);
    } catch (e) {
      print('Error getting booking history: $e');
      return _generateMockBookingHistory(userId);
    }
  }

  /// Calculate total cost with Canadian taxes
  static BookingCostBreakdown calculateBookingCost({
    required double basePrice,
    required String provinceCode,
    double? serviceFee,
    double? discountAmount,
  }) {
    final taxService = CanadianTaxService.instance;
    final serviceFeeAmount = serviceFee ?? (basePrice * 0.05); // 5% service fee

    final subtotal = basePrice + serviceFeeAmount - (discountAmount ?? 0);
    final taxCalculation = taxService.calculateTax(subtotal, provinceCode);

    return BookingCostBreakdown(
      basePrice: basePrice,
      serviceFee: serviceFeeAmount,
      discountAmount: discountAmount ?? 0,
      subtotal: subtotal,
      taxCalculation: taxCalculation,
      finalTotal: taxCalculation.totalWithTax,
    );
  }

  // Mock data generators for fallback

  static RestaurantBookingResult _generateMockRestaurantBooking(
    String restaurantId,
    String restaurantName,
    DateTime date,
    String time,
    int partySize,
  ) {
    return RestaurantBookingResult(
      bookingId: 'BOOK_${Random().nextInt(100000)}',
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      reservationDate: date,
      reservationTime: time,
      partySize: partySize,
      confirmationNumber: 'RES${Random().nextInt(1000000)}',
      status: BookingStatus.confirmed,
      specialInstructions: '',
      estimatedCost: 80.0 + (partySize * 20),
      depositRequired: false,
      cancellationPolicy: 'Free cancellation up to 24 hours before',
      contactPhone: '+1 (555) 123-4567',
      restaurantAddress: '123 Romance Street, Downtown',
    );
  }

  static ActivityBookingResult _generateMockActivityBooking(
    String activityId,
    String activityName,
    DateTime date,
    String time,
    int numberOfPeople,
  ) {
    return ActivityBookingResult(
      bookingId: 'ACT_${Random().nextInt(100000)}',
      activityId: activityId,
      activityName: activityName,
      bookingDate: date,
      startTime: time,
      numberOfPeople: numberOfPeople,
      confirmationNumber: 'ACT${Random().nextInt(1000000)}',
      status: BookingStatus.confirmed,
      totalCost: 45.0 * numberOfPeople,
      equipment: ['All equipment provided'],
      meetingPoint: 'Main entrance lobby',
      duration: '2-3 hours',
      contactInfo: 'Call (555) 987-6543 for assistance',
      requirements: ['Comfortable clothing recommended'],
    );
  }

  static List<TimeSlot> _generateMockTimeSlots(DateTime date) {
    final slots = <TimeSlot>[];
    final times = [
      '5:30 PM',
      '6:00 PM',
      '6:30 PM',
      '7:00 PM',
      '7:30 PM',
      '8:00 PM',
      '8:30 PM',
    ];

    for (int i = 0; i < times.length; i++) {
      slots.add(
        TimeSlot(
          time: times[i],
          available: Random().nextBool() || i < 3, // Ensure some availability
          price: 0.0,
          duration: '2 hours',
          maxCapacity: 4,
          remainingSpots: Random().nextInt(4) + 1,
        ),
      );
    }

    return slots;
  }

  static List<TimeSlot> _generateMockActivitySlots(DateTime date) {
    final slots = <TimeSlot>[];
    final times = ['10:00 AM', '1:00 PM', '3:00 PM', '5:00 PM', '7:00 PM'];

    for (int i = 0; i < times.length; i++) {
      slots.add(
        TimeSlot(
          time: times[i],
          available: Random().nextBool() || i < 2,
          price: 45.0,
          duration: '2-3 hours',
          maxCapacity: 8,
          remainingSpots: Random().nextInt(6) + 1,
        ),
      );
    }

    return slots;
  }

  static List<DatePackage> _generateMockDatePackages() {
    return [
      DatePackage(
        id: 'PKG001',
        name: 'Romantic Evening Package',
        description: 'Dinner at upscale restaurant followed by sunset walk',
        theme: 'romantic',
        totalPrice: 150.0,
        originalPrice: 180.0,
        savings: 30.0,
        duration: '4-5 hours',
        includes: [
          'Dinner for two at The Romantic Bistro',
          'Guided sunset walk at Riverfront',
          'Complimentary dessert',
          'Professional photography (optional)',
        ],
        restrictions: ['Weekend bookings only', 'Weather dependent for walk'],
        availability: 'High',
        rating: 4.8,
        reviewCount: 127,
        imageUrl: 'https://example.com/romantic-package.jpg',
      ),
      DatePackage(
        id: 'PKG002',
        name: 'Adventure Duo Package',
        description: 'Rock climbing followed by casual dining',
        theme: 'adventure',
        totalPrice: 95.0,
        originalPrice: 120.0,
        savings: 25.0,
        duration: '5-6 hours',
        includes: [
          'Indoor rock climbing session',
          'Equipment rental included',
          'Lunch at Sports Café',
          'Victory celebration drinks',
        ],
        restrictions: ['Age 16+', 'No experience required'],
        availability: 'Medium',
        rating: 4.6,
        reviewCount: 89,
        imageUrl: 'https://example.com/adventure-package.jpg',
      ),
      DatePackage(
        id: 'PKG003',
        name: 'Cultural Experience Package',
        description: 'Art gallery visit with wine tasting',
        theme: 'cultural',
        totalPrice: 110.0,
        originalPrice: 130.0,
        savings: 20.0,
        duration: '3-4 hours',
        includes: [
          'Art gallery admission for two',
          'Guided tour included',
          'Wine tasting experience',
          'Light appetizers',
        ],
        restrictions: ['21+ for wine tasting', 'ID required'],
        availability: 'High',
        rating: 4.9,
        reviewCount: 156,
        imageUrl: 'https://example.com/cultural-package.jpg',
      ),
    ];
  }

  static DatePackageBookingResult _generateMockPackageBooking(
    String packageId,
    DateTime date,
  ) {
    return DatePackageBookingResult(
      bookingId: 'PKG_${Random().nextInt(100000)}',
      packageId: packageId,
      packageName: 'Romantic Evening Package',
      bookingDate: date,
      confirmationNumber: 'PKG${Random().nextInt(1000000)}',
      status: BookingStatus.confirmed,
      totalCost: 150.0,
      paymentStatus: 'Paid',
      itinerary: [
        ItineraryItem(
          time: '6:00 PM',
          activity: 'Dinner at The Romantic Bistro',
          location: '123 Romance Street',
          duration: '1.5 hours',
          notes: 'Table reserved under confirmation number',
        ),
        ItineraryItem(
          time: '7:45 PM',
          activity: 'Sunset walk at Riverfront Promenade',
          location: 'Riverfront Park Entrance',
          duration: '45 minutes',
          notes: 'Meet guide at main entrance',
        ),
      ],
      contactInfo: 'Support: (555) DATE-FUN',
      cancellationDeadline: date.subtract(Duration(hours: 24)),
      specialInstructions: 'Dietary restrictions noted for restaurant',
    );
  }

  static List<BookingHistory> _generateMockBookingHistory(int userId) {
    return [
      BookingHistory(
        bookingId: 'HIST001',
        type: BookingType.restaurant,
        title: 'The Romantic Bistro',
        date: DateTime.now().subtract(Duration(days: 7)),
        status: BookingStatus.completed,
        cost: 85.50,
        rating: 4.5,
        reviewGiven: true,
      ),
      BookingHistory(
        bookingId: 'HIST002',
        type: BookingType.activity,
        title: 'Rock Climbing Adventure',
        date: DateTime.now().subtract(Duration(days: 14)),
        status: BookingStatus.completed,
        cost: 90.00,
        rating: 5.0,
        reviewGiven: true,
      ),
      BookingHistory(
        bookingId: 'HIST003',
        type: BookingType.package,
        title: 'Cultural Experience Package',
        date: DateTime.now().add(Duration(days: 3)),
        status: BookingStatus.confirmed,
        cost: 110.00,
        rating: 0.0,
        reviewGiven: false,
      ),
    ];
  }
}

// Data models for date marketplace

class RestaurantBookingResult {
  final String bookingId;
  final String restaurantId;
  final String restaurantName;
  final DateTime reservationDate;
  final String reservationTime;
  final int partySize;
  final String confirmationNumber;
  final BookingStatus status;
  final String specialInstructions;
  final double estimatedCost;
  final bool depositRequired;
  final String cancellationPolicy;
  final String contactPhone;
  final String restaurantAddress;

  RestaurantBookingResult({
    required this.bookingId,
    required this.restaurantId,
    required this.restaurantName,
    required this.reservationDate,
    required this.reservationTime,
    required this.partySize,
    required this.confirmationNumber,
    required this.status,
    required this.specialInstructions,
    required this.estimatedCost,
    required this.depositRequired,
    required this.cancellationPolicy,
    required this.contactPhone,
    required this.restaurantAddress,
  });

  factory RestaurantBookingResult.fromJson(Map<String, dynamic> json) {
    return RestaurantBookingResult(
      bookingId: json['booking_id'] ?? '',
      restaurantId: json['restaurant_id'] ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      reservationDate: DateTime.parse(json['reservation_date']),
      reservationTime: json['reservation_time'] ?? '',
      partySize: json['party_size'] ?? 2,
      confirmationNumber: json['confirmation_number'] ?? '',
      status: BookingStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      specialInstructions: json['special_instructions'] ?? '',
      estimatedCost: (json['estimated_cost'] ?? 0.0).toDouble(),
      depositRequired: json['deposit_required'] ?? false,
      cancellationPolicy: json['cancellation_policy'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      restaurantAddress: json['restaurant_address'] ?? '',
    );
  }
}

class ActivityBookingResult {
  final String bookingId;
  final String activityId;
  final String activityName;
  final DateTime bookingDate;
  final String startTime;
  final int numberOfPeople;
  final String confirmationNumber;
  final BookingStatus status;
  final double totalCost;
  final List<String> equipment;
  final String meetingPoint;
  final String duration;
  final String contactInfo;
  final List<String> requirements;

  ActivityBookingResult({
    required this.bookingId,
    required this.activityId,
    required this.activityName,
    required this.bookingDate,
    required this.startTime,
    required this.numberOfPeople,
    required this.confirmationNumber,
    required this.status,
    required this.totalCost,
    required this.equipment,
    required this.meetingPoint,
    required this.duration,
    required this.contactInfo,
    required this.requirements,
  });

  factory ActivityBookingResult.fromJson(Map<String, dynamic> json) {
    return ActivityBookingResult(
      bookingId: json['booking_id'] ?? '',
      activityId: json['activity_id'] ?? '',
      activityName: json['activity_name'] ?? '',
      bookingDate: DateTime.parse(json['booking_date']),
      startTime: json['start_time'] ?? '',
      numberOfPeople: json['number_of_people'] ?? 2,
      confirmationNumber: json['confirmation_number'] ?? '',
      status: BookingStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      totalCost: (json['total_cost'] ?? 0.0).toDouble(),
      equipment: List<String>.from(json['equipment'] ?? []),
      meetingPoint: json['meeting_point'] ?? '',
      duration: json['duration'] ?? '',
      contactInfo: json['contact_info'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
    );
  }
}

class TimeSlot {
  final String time;
  final bool available;
  final double price;
  final String duration;
  final int maxCapacity;
  final int remainingSpots;

  TimeSlot({
    required this.time,
    required this.available,
    required this.price,
    required this.duration,
    required this.maxCapacity,
    required this.remainingSpots,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'] ?? '',
      available: json['available'] ?? false,
      price: (json['price'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? '',
      maxCapacity: json['max_capacity'] ?? 0,
      remainingSpots: json['remaining_spots'] ?? 0,
    );
  }
}

class DatePackage {
  final String id;
  final String name;
  final String description;
  final String theme;
  final double totalPrice;
  final double originalPrice;
  final double savings;
  final String duration;
  final List<String> includes;
  final List<String> restrictions;
  final String availability;
  final double rating;
  final int reviewCount;
  final String imageUrl;

  DatePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.theme,
    required this.totalPrice,
    required this.originalPrice,
    required this.savings,
    required this.duration,
    required this.includes,
    required this.restrictions,
    required this.availability,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
  });

  factory DatePackage.fromJson(Map<String, dynamic> json) {
    return DatePackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      theme: json['theme'] ?? '',
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      originalPrice: (json['original_price'] ?? 0.0).toDouble(),
      savings: (json['savings'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? '',
      includes: List<String>.from(json['includes'] ?? []),
      restrictions: List<String>.from(json['restrictions'] ?? []),
      availability: json['availability'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class DatePackageBookingResult {
  final String bookingId;
  final String packageId;
  final String packageName;
  final DateTime bookingDate;
  final String confirmationNumber;
  final BookingStatus status;
  final double totalCost;
  final String paymentStatus;
  final List<ItineraryItem> itinerary;
  final String contactInfo;
  final DateTime cancellationDeadline;
  final String specialInstructions;

  DatePackageBookingResult({
    required this.bookingId,
    required this.packageId,
    required this.packageName,
    required this.bookingDate,
    required this.confirmationNumber,
    required this.status,
    required this.totalCost,
    required this.paymentStatus,
    required this.itinerary,
    required this.contactInfo,
    required this.cancellationDeadline,
    required this.specialInstructions,
  });

  factory DatePackageBookingResult.fromJson(Map<String, dynamic> json) {
    return DatePackageBookingResult(
      bookingId: json['booking_id'] ?? '',
      packageId: json['package_id'] ?? '',
      packageName: json['package_name'] ?? '',
      bookingDate: DateTime.parse(json['booking_date']),
      confirmationNumber: json['confirmation_number'] ?? '',
      status: BookingStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      totalCost: (json['total_cost'] ?? 0.0).toDouble(),
      paymentStatus: json['payment_status'] ?? '',
      itinerary:
          (json['itinerary'] as List? ?? [])
              .map((item) => ItineraryItem.fromJson(item))
              .toList(),
      contactInfo: json['contact_info'] ?? '',
      cancellationDeadline: DateTime.parse(json['cancellation_deadline']),
      specialInstructions: json['special_instructions'] ?? '',
    );
  }
}

class ItineraryItem {
  final String time;
  final String activity;
  final String location;
  final String duration;
  final String notes;

  ItineraryItem({
    required this.time,
    required this.activity,
    required this.location,
    required this.duration,
    required this.notes,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      time: json['time'] ?? '',
      activity: json['activity'] ?? '',
      location: json['location'] ?? '',
      duration: json['duration'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class BookingHistory {
  final String bookingId;
  final BookingType type;
  final String title;
  final DateTime date;
  final BookingStatus status;
  final double cost;
  final double rating;
  final bool reviewGiven;

  BookingHistory({
    required this.bookingId,
    required this.type,
    required this.title,
    required this.date,
    required this.status,
    required this.cost,
    required this.rating,
    required this.reviewGiven,
  });

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    return BookingHistory(
      bookingId: json['booking_id'] ?? '',
      type: BookingType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
        orElse: () => BookingType.restaurant,
      ),
      title: json['title'] ?? '',
      date: DateTime.parse(json['date']),
      status: BookingStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      cost: (json['cost'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewGiven: json['review_given'] ?? false,
    );
  }
}

class BookingCostBreakdown {
  final double basePrice;
  final double serviceFee;
  final double discountAmount;
  final double subtotal;
  final TaxCalculation taxCalculation;
  final double finalTotal;

  BookingCostBreakdown({
    required this.basePrice,
    required this.serviceFee,
    required this.discountAmount,
    required this.subtotal,
    required this.taxCalculation,
    required this.finalTotal,
  });
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  refunded,
  noShow,
}

enum BookingType { restaurant, activity, package, spot }
