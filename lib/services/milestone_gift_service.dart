import '../utils/Utilities.dart';

class MilestoneGiftService {
  static const String baseUrl = 'https://ugandaemr.com/dating-app';

  /// Get personalized gift suggestions based on relationship milestones
  static Future<Map<String, dynamic>> getMilestoneGiftSuggestions({
    required String partnerId,
    String milestoneType = 'general',
    String? relationshipStartDate,
    String budget = 'medium',
    String partnerGender = 'any',
    int partnerAge = 25,
  }) async {
    try {
      final params = {
        'partner_id': partnerId,
        'milestone_type': milestoneType,
        'budget': budget,
        'partner_gender': partnerGender,
        'partner_age': partnerAge.toString(),
      };

      if (relationshipStartDate != null) {
        params['relationship_start_date'] = relationshipStartDate;
      }

      final response = await Utils.http_get(
        'get-milestone-gift-suggestions',
        params,
      );

      if (response.isSuccessful) {
        return {
          'success': true,
          'data': response.data,
          'message': response.message,
        };
      } else {
        return {
          'success': false,
          'error':
              response.message ?? 'Failed to get milestone gift suggestions',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Save a milestone reminder for future gift suggestions
  static Future<Map<String, dynamic>> saveMilestoneReminder({
    required String partnerId,
    required String milestoneType,
    required String milestoneDate,
    int reminderDays = 7,
    List<String> giftPreferences = const [],
  }) async {
    try {
      final response = await Utils.http_post('save-milestone-reminder', {
        'partner_id': partnerId,
        'milestone_type': milestoneType,
        'milestone_date': milestoneDate,
        'reminder_days': reminderDays,
        'gift_preferences': giftPreferences,
      });

      if (response.isSuccessful) {
        return {
          'success': true,
          'data': response.data,
          'message': response.message,
        };
      } else {
        return {
          'success': false,
          'error': response.message ?? 'Failed to save milestone reminder',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get upcoming milestones for the current user and their partner
  static Future<List<MilestoneEvent>> getUpcomingMilestones({
    String? relationshipStartDate,
  }) async {
    List<MilestoneEvent> milestones = [];

    if (relationshipStartDate != null) {
      try {
        final startDate = DateTime.parse(relationshipStartDate);
        final now = DateTime.now();

        // Calculate upcoming milestones
        final oneMonth = startDate.add(const Duration(days: 30));
        final threeMonths = startDate.add(const Duration(days: 90));
        final sixMonths = startDate.add(const Duration(days: 180));
        final oneYear = startDate.add(const Duration(days: 365));

        // Add milestones that haven't passed yet
        if (oneMonth.isAfter(now)) {
          milestones.add(
            MilestoneEvent(
              type: '1_month',
              date: oneMonth,
              title: 'One Month Together',
              description: 'Celebrate your first month of dating',
              daysUntil: oneMonth.difference(now).inDays,
            ),
          );
        }

        if (threeMonths.isAfter(now)) {
          milestones.add(
            MilestoneEvent(
              type: '3_months',
              date: threeMonths,
              title: 'Three Months Strong',
              description: 'Quarter-year milestone celebration',
              daysUntil: threeMonths.difference(now).inDays,
            ),
          );
        }

        if (sixMonths.isAfter(now)) {
          milestones.add(
            MilestoneEvent(
              type: '6_months',
              date: sixMonths,
              title: 'Six Months of Love',
              description: 'Half-year anniversary celebration',
              daysUntil: sixMonths.difference(now).inDays,
            ),
          );
        }

        if (oneYear.isAfter(now)) {
          milestones.add(
            MilestoneEvent(
              type: '1_year',
              date: oneYear,
              title: 'One Year Anniversary',
              description: 'Your first year together milestone',
              daysUntil: oneYear.difference(now).inDays,
            ),
          );
        }
      } catch (e) {
        print('Error calculating milestones: $e');
      }
    }

    // Add annual milestones (Valentine's Day, Christmas)
    final now = DateTime.now();
    final currentYear = now.year;

    // Valentine's Day
    final valentine = DateTime(currentYear, 2, 14);
    final nextValentine =
        valentine.isBefore(now) ? DateTime(currentYear + 1, 2, 14) : valentine;

    milestones.add(
      MilestoneEvent(
        type: 'valentine',
        date: nextValentine,
        title: 'Valentine\'s Day',
        description: 'Celebrate your love this Valentine\'s Day',
        daysUntil: nextValentine.difference(now).inDays,
      ),
    );

    // Christmas
    final christmas = DateTime(currentYear, 12, 25);
    final nextChristmas =
        christmas.isBefore(now) ? DateTime(currentYear + 1, 12, 25) : christmas;

    milestones.add(
      MilestoneEvent(
        type: 'christmas',
        date: nextChristmas,
        title: 'Christmas Together',
        description: 'Holiday celebration for couples',
        daysUntil: nextChristmas.difference(now).inDays,
      ),
    );

    // Sort by date
    milestones.sort((a, b) => a.date.compareTo(b.date));

    return milestones;
  }

  /// Get milestone type suggestions based on relationship duration
  static String suggestMilestoneType(String? relationshipStartDate) {
    if (relationshipStartDate == null) return 'general';

    try {
      final startDate = DateTime.parse(relationshipStartDate);
      final now = DateTime.now();
      final daysTogether = now.difference(startDate).inDays;

      if (daysTogether < 30) {
        return 'first_date';
      } else if (daysTogether < 90) {
        return '1_month';
      } else if (daysTogether < 180) {
        return '3_months';
      } else if (daysTogether < 365) {
        return '6_months';
      } else {
        return '1_year';
      }
    } catch (e) {
      return 'general';
    }
  }

  /// Get budget recommendations based on milestone type
  static Map<String, dynamic> getBudgetRecommendations(String milestoneType) {
    final budgetGuides = {
      'first_date': {
        'recommended': 'low',
        'explanation':
            'Keep it sweet and casual for early relationship milestones',
        'ranges': {'low': '\$25-75 CAD', 'medium': '\$75-200 CAD'},
      },
      '1_month': {
        'recommended': 'low',
        'explanation': 'Thoughtful but not overwhelming for one month together',
        'ranges': {'low': '\$25-75 CAD', 'medium': '\$75-200 CAD'},
      },
      '3_months': {
        'recommended': 'medium',
        'explanation': 'Show growing commitment with meaningful gifts',
        'ranges': {
          'low': '\$25-75 CAD',
          'medium': '\$75-200 CAD',
          'high': '\$200-500 CAD',
        },
      },
      '6_months': {
        'recommended': 'medium',
        'explanation':
            'Celebrate this significant milestone with special gifts',
        'ranges': {
          'medium': '\$75-200 CAD',
          'high': '\$200-500 CAD',
          'luxury': '\$500+ CAD',
        },
      },
      '1_year': {
        'recommended': 'high',
        'explanation': 'Honor your first year with meaningful, lasting gifts',
        'ranges': {
          'medium': '\$75-200 CAD',
          'high': '\$200-500 CAD',
          'luxury': '\$500+ CAD',
        },
      },
      'birthday': {
        'recommended': 'medium',
        'explanation': 'Make their birthday special with thoughtful gifts',
        'ranges': {
          'low': '\$25-75 CAD',
          'medium': '\$75-200 CAD',
          'high': '\$200-500 CAD',
          'luxury': '\$500+ CAD',
        },
      },
      'valentine': {
        'recommended': 'medium',
        'explanation': 'Classic romantic gifts for Valentine\'s Day',
        'ranges': {
          'low': '\$25-75 CAD',
          'medium': '\$75-200 CAD',
          'high': '\$200-500 CAD',
        },
      },
      'christmas': {
        'recommended': 'medium',
        'explanation': 'Festive gifts to celebrate the holidays together',
        'ranges': {
          'low': '\$25-75 CAD',
          'medium': '\$75-200 CAD',
          'high': '\$200-500 CAD',
          'luxury': '\$500+ CAD',
        },
      },
      'general': {
        'recommended': 'low',
        'explanation': 'Sweet surprises to show you care any time',
        'ranges': {'low': '\$25-75 CAD', 'medium': '\$75-200 CAD'},
      },
    };

    return budgetGuides[milestoneType] ?? budgetGuides['general']!;
  }

  /// Create mock milestone data for testing
  static Map<String, dynamic> createMockMilestoneData(String milestoneType) {
    return {
      'milestone_info': {
        'title': 'Test Milestone',
        'subtitle': 'Testing gift suggestions',
        'message': 'Mock data for development',
        'categories': ['flowers', 'sweets', 'jewelry', 'experiences'],
      },
      'recommended_items': [
        {
          'id': 'mock_001',
          'name': 'Test Gift Item',
          'description': 'Mock gift item for testing',
          'price': 75.00,
          'category': 'flowers',
          'image_url': '',
          'milestone_relevance': 'Perfect for testing milestone features',
          'personalization_options': ['Custom message', 'Gift wrapping'],
        },
      ],
      'budget_range': {'min': 25, 'max': 200},
      'relationship_insights': ['This is a test insight for development'],
      'seasonal_suggestions': [],
      'personalization_available': true,
      'delivery_options': {
        'standard': '3-5 business days',
        'express': '1-2 business days',
        'same_day': 'Available in select cities',
      },
      'currency': 'CAD',
      'total_suggestions': 1,
    };
  }
}

/// Data model for milestone events
class MilestoneEvent {
  final String type;
  final DateTime date;
  final String title;
  final String description;
  final int daysUntil;

  MilestoneEvent({
    required this.type,
    required this.date,
    required this.title,
    required this.description,
    required this.daysUntil,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'days_until': daysUntil,
    };
  }

  factory MilestoneEvent.fromJson(Map<String, dynamic> json) {
    return MilestoneEvent(
      type: json['type'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'],
      daysUntil: json['days_until'],
    );
  }
}

/// Data model for milestone gift items
class MilestoneGiftItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final String milestoneRelevance;
  final List<String> personalizationOptions;

  MilestoneGiftItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.milestoneRelevance,
    required this.personalizationOptions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'milestone_relevance': milestoneRelevance,
      'personalization_options': personalizationOptions,
    };
  }

  factory MilestoneGiftItem.fromJson(Map<String, dynamic> json) {
    return MilestoneGiftItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      imageUrl: json['image_url'] ?? '',
      milestoneRelevance: json['milestone_relevance'] ?? '',
      personalizationOptions: List<String>.from(
        json['personalization_options'] ?? [],
      ),
    );
  }
}
