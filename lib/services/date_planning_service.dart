import '../models/UserModel.dart';
import '../utils/Utilities.dart';
import '../models/RespondModel.dart';

/// Service for generating restaurant and date activity suggestions
class DatePlanningService {
  static final DatePlanningService _instance = DatePlanningService._();
  static DatePlanningService get instance => _instance;
  DatePlanningService._();

  /// Get restaurant suggestions for a date
  static Future<List<RestaurantSuggestion>> getRestaurantSuggestions({
    required UserModel currentUser,
    required UserModel matchedUser,
    String? cuisine,
    String? priceRange,
    double? maxDistance,
  }) async {
    try {
      final params = {
        'lat': currentUser.latitude,
        'lng': currentUser.longitude,
        'cuisine': cuisine,
        'price_range': priceRange,
        'max_distance': maxDistance ?? 10.0,
        'for_date': true,
      };

      final response = await Utils.http_post(
        'get-restaurant-suggestions',
        params,
      );
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final restaurantsData = resp.data['restaurants'] as List? ?? [];
        return restaurantsData
            .map((data) => RestaurantSuggestion.fromJson(data))
            .toList();
      }

      // Fallback to mock data if API not available
      return _getMockRestaurantSuggestions(currentUser, matchedUser);
    } catch (e) {
      print('Error getting restaurant suggestions: $e');
      return _getMockRestaurantSuggestions(currentUser, matchedUser);
    }
  }

  /// Get date activity suggestions based on shared interests
  static Future<List<DateActivitySuggestion>> getDateActivitySuggestions({
    required UserModel currentUser,
    required UserModel matchedUser,
    String? category,
    bool indoorOnly = false,
  }) async {
    try {
      final params = {
        'lat': currentUser.latitude,
        'lng': currentUser.longitude,
        'category': category,
        'indoor_only': indoorOnly,
        'user_interests': _extractUserInterests(currentUser),
        'match_interests': _extractUserInterests(matchedUser),
      };

      final response = await Utils.http_post('get-date-activities', params);
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final activitiesData = resp.data['activities'] as List? ?? [];
        return activitiesData
            .map((data) => DateActivitySuggestion.fromJson(data))
            .toList();
      }

      // Fallback to generated suggestions
      return _generateDateActivitySuggestions(
        currentUser,
        matchedUser,
        category,
      );
    } catch (e) {
      print('Error getting date activity suggestions: $e');
      return _generateDateActivitySuggestions(
        currentUser,
        matchedUser,
        category,
      );
    }
  }

  /// Get popular date spots in the area
  static Future<List<DateSpotSuggestion>> getPopularDateSpots({
    required UserModel currentUser,
    double? maxDistance,
    String? timeOfDay,
  }) async {
    try {
      final params = {
        'lat': currentUser.latitude,
        'lng': currentUser.longitude,
        'max_distance': maxDistance ?? 15.0,
        'time_of_day': timeOfDay ?? 'evening',
      };

      final response = await Utils.http_post('get-popular-date-spots', params);
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final spotsData = resp.data['spots'] as List? ?? [];
        return spotsData
            .map((data) => DateSpotSuggestion.fromJson(data))
            .toList();
      }

      return _getMockDateSpots(currentUser);
    } catch (e) {
      print('Error getting date spots: $e');
      return _getMockDateSpots(currentUser);
    }
  }

  /// Generate personalized date ideas based on compatibility and preferences
  static List<PersonalizedDateIdea> generatePersonalizedDateIdeas({
    required UserModel currentUser,
    required UserModel matchedUser,
    required double compatibilityScore,
  }) {
    final ideas = <PersonalizedDateIdea>[];

    // Coffee/casual ideas for new matches or lower compatibility
    if (compatibilityScore < 0.7) {
      ideas.addAll(_getCasualDateIdeas());
    }

    // More adventurous ideas for high compatibility
    if (compatibilityScore > 0.8) {
      ideas.addAll(_getAdventurousDateIdeas());
    }

    // Activity-based ideas from shared interests
    ideas.addAll(_getInterestBasedDateIdeas(currentUser, matchedUser));

    // Seasonal date ideas
    ideas.addAll(_getSeasonalDateIdeas());

    // Location-specific ideas
    ideas.addAll(_getLocationBasedDateIdeas(currentUser));

    return ideas..shuffle();
  }

  /// Save a planned date for later reference
  static Future<bool> savePlannedDate({
    required int matchUserId,
    required String title,
    required String description,
    required DateTime plannedDate,
    String? location,
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      final params = {
        'match_user_id': matchUserId,
        'title': title,
        'description': description,
        'planned_date': plannedDate.toIso8601String(),
        'location': location,
        'details': additionalDetails,
      };

      final response = await Utils.http_post('save-planned-date', params);
      final resp = RespondModel(response);

      return resp.code == 1;
    } catch (e) {
      print('Error saving planned date: $e');
      return false;
    }
  }

  // Private helper methods

  static List<String> _extractUserInterests(UserModel user) {
    // This would extract interests from user profile
    // For now, return some default interests based on profile data
    final interests = <String>[];

    if (user.occupation.toLowerCase().contains('fitness') ||
        user.occupation.toLowerCase().contains('trainer')) {
      interests.add('fitness');
    }

    if (user.education_level.toLowerCase().contains('university')) {
      interests.add('culture');
      interests.add('museums');
    }

    return interests;
  }

  static List<RestaurantSuggestion> _getMockRestaurantSuggestions(
    UserModel currentUser,
    UserModel matchedUser,
  ) {
    return [
      RestaurantSuggestion(
        id: '1',
        name: 'The Romantic Bistro',
        cuisine: 'French',
        priceRange: '\$\$\$',
        rating: 4.7,
        distance: 2.3,
        address: '123 Romance Street',
        imageUrl: 'https://example.com/bistro.jpg',
        description: 'Intimate French bistro perfect for date nights',
        specialties: ['Wine selection', 'Candlelit dining'],
        reasonForSuggestion: 'Highly rated for romantic dinners',
      ),
      RestaurantSuggestion(
        id: '2',
        name: 'Café Luna',
        cuisine: 'Italian',
        priceRange: '\$\$',
        rating: 4.5,
        distance: 1.8,
        address: '456 Coffee Lane',
        imageUrl: 'https://example.com/cafe.jpg',
        description: 'Cozy Italian café with great coffee and pastries',
        specialties: ['Espresso', 'Fresh pastries'],
        reasonForSuggestion: 'Perfect for a casual coffee date',
      ),
    ];
  }

  static List<DateActivitySuggestion> _generateDateActivitySuggestions(
    UserModel currentUser,
    UserModel matchedUser,
    String? category,
  ) {
    final activities = <DateActivitySuggestion>[
      DateActivitySuggestion(
        id: '1',
        title: 'Art Gallery Walk',
        category: 'Culture',
        description:
            'Explore local art galleries and discuss your favorite pieces',
        duration: '2-3 hours',
        priceRange: '\$',
        isIndoor: true,
        compatibilityScore: 0.8,
        whyPerfectMatch:
            'Great for intellectual conversations and discovering shared tastes',
      ),
      DateActivitySuggestion(
        id: '2',
        title: 'Hiking Adventure',
        category: 'Outdoor',
        description: 'Scenic hike with beautiful views and fresh air',
        duration: '3-4 hours',
        priceRange: 'Free',
        isIndoor: false,
        compatibilityScore: 0.9,
        whyPerfectMatch: 'Perfect for active couples who love nature',
      ),
      DateActivitySuggestion(
        id: '3',
        title: 'Cooking Class',
        category: 'Interactive',
        description: 'Learn to cook a new dish together in a fun environment',
        duration: '2 hours',
        priceRange: '\$\$',
        isIndoor: true,
        compatibilityScore: 0.85,
        whyPerfectMatch: 'Great for couples who enjoy learning together',
      ),
    ];

    if (category != null) {
      return activities
          .where((a) => a.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    return activities;
  }

  static List<DateSpotSuggestion> _getMockDateSpots(UserModel currentUser) {
    return [
      DateSpotSuggestion(
        id: '1',
        name: 'Sunset Lookout Point',
        category: 'Scenic',
        description:
            'Beautiful viewpoint perfect for watching sunsets together',
        distance: 5.2,
        rating: 4.8,
        imageUrl: 'https://example.com/sunset.jpg',
        bestTimeToVisit: 'Evening',
        whyRomantic:
            'Stunning views and peaceful atmosphere create perfect romantic moments',
      ),
      DateSpotSuggestion(
        id: '2',
        name: 'Downtown Night Market',
        category: 'Entertainment',
        description:
            'Vibrant market with food vendors, live music, and local crafts',
        distance: 3.1,
        rating: 4.6,
        imageUrl: 'https://example.com/market.jpg',
        bestTimeToVisit: 'Evening',
        whyRomantic:
            'Explore together while enjoying street food and live entertainment',
      ),
    ];
  }

  static List<PersonalizedDateIdea> _getCasualDateIdeas() {
    return [
      PersonalizedDateIdea(
        title: 'Coffee & Walk',
        description:
            'Start with coffee and take a leisurely walk through a nice neighborhood',
        category: 'Casual',
        estimatedCost: '\$',
        duration: '1-2 hours',
        icon: '☕',
        personalizedReason:
            'Perfect for getting to know each other in a relaxed setting',
      ),
      PersonalizedDateIdea(
        title: 'Bookstore Browse',
        description:
            'Explore a bookstore together and share your favorite book recommendations',
        category: 'Casual',
        estimatedCost: '\$',
        duration: '1-2 hours',
        icon: '📚',
        personalizedReason:
            'Great way to learn about each other\'s interests and intellect',
      ),
    ];
  }

  static List<PersonalizedDateIdea> _getAdventurousDateIdeas() {
    return [
      PersonalizedDateIdea(
        title: 'Weekend Getaway',
        description: 'Plan a short trip to a nearby city or natural area',
        category: 'Adventure',
        estimatedCost: '\$\$\$',
        duration: '1-2 days',
        icon: '🏔️',
        personalizedReason:
            'Your high compatibility suggests you\'re ready for bigger adventures together',
      ),
      PersonalizedDateIdea(
        title: 'Concert or Show',
        description: 'Attend a live music event or theater performance',
        category: 'Entertainment',
        estimatedCost: '\$\$',
        duration: '3-4 hours',
        icon: '🎵',
        personalizedReason:
            'Shared experiences like this create lasting memories',
      ),
    ];
  }

  static List<PersonalizedDateIdea> _getInterestBasedDateIdeas(
    UserModel currentUser,
    UserModel matchedUser,
  ) {
    final ideas = <PersonalizedDateIdea>[];
    final interests = _extractUserInterests(currentUser);

    if (interests.contains('fitness')) {
      ideas.add(
        PersonalizedDateIdea(
          title: 'Rock Climbing',
          description: 'Try indoor rock climbing or bouldering together',
          category: 'Active',
          estimatedCost: '\$\$',
          duration: '2-3 hours',
          icon: '🧗‍♀️',
          personalizedReason:
              'Perfect match for your shared love of fitness activities',
        ),
      );
    }

    if (interests.contains('culture')) {
      ideas.add(
        PersonalizedDateIdea(
          title: 'Museum & Lunch',
          description: 'Visit a museum followed by lunch at a nearby café',
          category: 'Cultural',
          estimatedCost: '\$\$',
          duration: '3-4 hours',
          icon: '🏛️',
          personalizedReason:
              'Your educational backgrounds suggest you\'ll enjoy cultural experiences',
        ),
      );
    }

    return ideas;
  }

  static List<PersonalizedDateIdea> _getSeasonalDateIdeas() {
    final month = DateTime.now().month;

    if (month >= 12 || month <= 2) {
      // Winter
      return [
        PersonalizedDateIdea(
          title: 'Ice Skating & Hot Chocolate',
          description:
              'Go ice skating followed by warming up with hot chocolate',
          category: 'Seasonal',
          estimatedCost: '\$\$',
          duration: '2-3 hours',
          icon: '⛸️',
          personalizedReason: 'Perfect winter activity for couples',
        ),
      ];
    } else if (month >= 6 && month <= 8) {
      // Summer
      return [
        PersonalizedDateIdea(
          title: 'Beach Picnic',
          description: 'Pack a picnic and spend the day at the beach',
          category: 'Seasonal',
          estimatedCost: '\$',
          duration: '4-6 hours',
          icon: '🏖️',
          personalizedReason: 'Summer is perfect for outdoor romantic dates',
        ),
      ];
    }

    return [];
  }

  static List<PersonalizedDateIdea> _getLocationBasedDateIdeas(
    UserModel currentUser,
  ) {
    // Generate ideas based on user's location/city
    return [
      PersonalizedDateIdea(
        title: 'Local Food Tour',
        description: 'Explore the best local food spots in your area',
        category: 'Food',
        estimatedCost: '\$\$',
        duration: '3-4 hours',
        icon: '🍽️',
        personalizedReason:
            'Discover your city together while trying amazing local cuisine',
      ),
    ];
  }
}

// Data models for date planning

class RestaurantSuggestion {
  final String id;
  final String name;
  final String cuisine;
  final String priceRange;
  final double rating;
  final double distance;
  final String address;
  final String imageUrl;
  final String description;
  final List<String> specialties;
  final String reasonForSuggestion;

  RestaurantSuggestion({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.priceRange,
    required this.rating,
    required this.distance,
    required this.address,
    required this.imageUrl,
    required this.description,
    required this.specialties,
    required this.reasonForSuggestion,
  });

  factory RestaurantSuggestion.fromJson(Map<String, dynamic> json) {
    return RestaurantSuggestion(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      cuisine: json['cuisine'] ?? '',
      priceRange: json['price_range'] ?? '\$\$',
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      specialties: List<String>.from(json['specialties'] ?? []),
      reasonForSuggestion: json['reason_for_suggestion'] ?? '',
    );
  }
}

class DateActivitySuggestion {
  final String id;
  final String title;
  final String category;
  final String description;
  final String duration;
  final String priceRange;
  final bool isIndoor;
  final double compatibilityScore;
  final String whyPerfectMatch;

  DateActivitySuggestion({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.duration,
    required this.priceRange,
    required this.isIndoor,
    required this.compatibilityScore,
    required this.whyPerfectMatch,
  });

  factory DateActivitySuggestion.fromJson(Map<String, dynamic> json) {
    return DateActivitySuggestion(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      priceRange: json['price_range'] ?? '\$',
      isIndoor: json['is_indoor'] == true,
      compatibilityScore: (json['compatibility_score'] ?? 0.0).toDouble(),
      whyPerfectMatch: json['why_perfect_match'] ?? '',
    );
  }
}

class DateSpotSuggestion {
  final String id;
  final String name;
  final String category;
  final String description;
  final double distance;
  final double rating;
  final String imageUrl;
  final String bestTimeToVisit;
  final String whyRomantic;

  DateSpotSuggestion({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.distance,
    required this.rating,
    required this.imageUrl,
    required this.bestTimeToVisit,
    required this.whyRomantic,
  });

  factory DateSpotSuggestion.fromJson(Map<String, dynamic> json) {
    return DateSpotSuggestion(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      distance: (json['distance'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'] ?? '',
      bestTimeToVisit: json['best_time_to_visit'] ?? '',
      whyRomantic: json['why_romantic'] ?? '',
    );
  }
}

class PersonalizedDateIdea {
  final String title;
  final String description;
  final String category;
  final String estimatedCost;
  final String duration;
  final String icon;
  final String personalizedReason;

  PersonalizedDateIdea({
    required this.title,
    required this.description,
    required this.category,
    required this.estimatedCost,
    required this.duration,
    required this.icon,
    required this.personalizedReason,
  });
}
