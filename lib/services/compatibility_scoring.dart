import 'dart:math';
import '../models/UserModel.dart';

/// Advanced compatibility scoring algorithm for intelligent match recommendations
class CompatibilityScoring {
  static CompatibilityScoring? _instance;
  static CompatibilityScoring get instance =>
      _instance ??= CompatibilityScoring._();
  CompatibilityScoring._();

  /// Calculate comprehensive compatibility score between two users
  /// Returns a score from 0.0 to 100.0
  double calculateCompatibilityScore(UserModel user1, UserModel user2) {
    double totalScore = 0.0;
    int factors = 0;

    // 1. Age Compatibility (Weight: 15%)
    final ageScore = _calculateAgeCompatibility(user1, user2);
    if (ageScore != null) {
      totalScore += ageScore * 0.15;
      factors++;
    }

    // 2. Location Proximity (Weight: 20%)
    final locationScore = _calculateLocationCompatibility(user1, user2);
    if (locationScore != null) {
      totalScore += locationScore * 0.20;
      factors++;
    }

    // 3. Lifestyle Compatibility (Weight: 25%)
    final lifestyleScore = _calculateLifestyleCompatibility(user1, user2);
    if (lifestyleScore != null) {
      totalScore += lifestyleScore * 0.25;
      factors++;
    }

    // 4. Relationship Goals Alignment (Weight: 20%)
    final goalScore = _calculateRelationshipGoalCompatibility(user1, user2);
    if (goalScore != null) {
      totalScore += goalScore * 0.20;
      factors++;
    }

    // 5. Education & Career Compatibility (Weight: 15%)
    final educationScore = _calculateEducationCompatibility(user1, user2);
    if (educationScore != null) {
      totalScore += educationScore * 0.15;
      factors++;
    }

    // 6. Physical/Preference Compatibility (Weight: 5%)
    final physicalScore = _calculatePhysicalCompatibility(user1, user2);
    if (physicalScore != null) {
      totalScore += physicalScore * 0.05;
      factors++;
    }

    // Return normalized score
    return factors > 0 ? (totalScore / factors) * 100 : 0.0;
  }

  /// Calculate age from date of birth
  int? _calculateAge(String dob) {
    if (dob.isEmpty) return null;
    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  /// Calculate age compatibility based on reasonable age ranges
  double? _calculateAgeCompatibility(UserModel user1, UserModel user2) {
    final age1 = _calculateAge(user1.dob);
    final age2 = _calculateAge(user2.dob);

    if (age1 == null || age2 == null) return null;

    final ageDifference = (age1 - age2).abs();

    // Ideal age differences by age group
    double maxIdealDifference;
    final averageAge = (age1 + age2) / 2;

    if (averageAge <= 25) {
      maxIdealDifference = 3.0; // Young adults: 3 years
    } else if (averageAge <= 35) {
      maxIdealDifference = 5.0; // Adults: 5 years
    } else if (averageAge <= 45) {
      maxIdealDifference = 7.0; // Mature adults: 7 years
    } else {
      maxIdealDifference = 10.0; // Older adults: 10 years
    }

    // Calculate score: perfect match at 0 difference, declining linearly
    if (ageDifference <= maxIdealDifference) {
      return 1.0 - (ageDifference / maxIdealDifference);
    } else {
      // Steep decline for large age gaps
      return max(0.0, 0.3 - ((ageDifference - maxIdealDifference) * 0.05));
    }
  }

  /// Calculate location compatibility based on distance
  double? _calculateLocationCompatibility(UserModel user1, UserModel user2) {
    final distance1 = user1.distance;

    // Distance-based scoring (assuming distance is in km)
    if (distance1 <= 5) return 1.0; // Perfect: Within 5km
    if (distance1 <= 15) return 0.9; // Excellent: Within 15km
    if (distance1 <= 30) return 0.8; // Good: Within 30km
    if (distance1 <= 50) return 0.6; // Fair: Within 50km
    if (distance1 <= 100) return 0.4; // Moderate: Within 100km
    return 0.2; // Long distance
  }

  /// Calculate lifestyle compatibility (smoking, drinking, fitness, etc.)
  double? _calculateLifestyleCompatibility(UserModel user1, UserModel user2) {
    double totalScore = 0.0;
    int factors = 0;

    // Smoking compatibility
    final smokingScore = _compareLifestyleChoice(
      user1.smoking_habit,
      user2.smoking_habit,
      perfectMatches: ['never', 'never'],
      goodMatches: ['occasionally', 'occasionally'],
      neutralMatches: ['socially', 'socially'],
    );
    if (smokingScore != null) {
      totalScore += smokingScore;
      factors++;
    }

    // Drinking compatibility
    final drinkingScore = _compareLifestyleChoice(
      user1.drinking_habit,
      user2.drinking_habit,
      perfectMatches: ['socially', 'socially'],
      goodMatches: ['occasionally', 'occasionally'],
      neutralMatches: ['regularly', 'regularly'],
    );
    if (drinkingScore != null) {
      totalScore += drinkingScore;
      factors++;
    }

    // Religion compatibility
    final religionScore = _compareLifestyleChoice(
      user1.religion,
      user2.religion,
      perfectMatches: ['christian', 'christian'],
      goodMatches: ['spiritual', 'spiritual'],
      neutralMatches: ['none', 'none'],
    );
    if (religionScore != null) {
      totalScore += religionScore;
      factors++;
    }

    return factors > 0 ? totalScore / factors : null;
  }

  /// Helper method to compare lifestyle choices
  double? _compareLifestyleChoice(
    String choice1,
    String choice2, {
    required List<String> perfectMatches,
    required List<String> goodMatches,
    required List<String> neutralMatches,
  }) {
    if (choice1.isEmpty || choice2.isEmpty) return null;

    // Perfect match
    if (choice1.toLowerCase() == choice2.toLowerCase()) {
      if (perfectMatches.contains(choice1.toLowerCase())) return 1.0;
      if (goodMatches.contains(choice1.toLowerCase())) return 0.9;
      if (neutralMatches.contains(choice1.toLowerCase())) return 0.7;
      return 0.6; // Same but not ideal
    }

    // Compatible but different
    if ((perfectMatches.contains(choice1.toLowerCase()) &&
            goodMatches.contains(choice2.toLowerCase())) ||
        (goodMatches.contains(choice1.toLowerCase()) &&
            perfectMatches.contains(choice2.toLowerCase()))) {
      return 0.8;
    }

    if ((goodMatches.contains(choice1.toLowerCase()) &&
            neutralMatches.contains(choice2.toLowerCase())) ||
        (neutralMatches.contains(choice1.toLowerCase()) &&
            goodMatches.contains(choice2.toLowerCase()))) {
      return 0.6;
    }

    // Major lifestyle conflicts
    if ((choice1.toLowerCase() == 'never' &&
            choice2.toLowerCase() == 'regularly') ||
        (choice1.toLowerCase() == 'regularly' &&
            choice2.toLowerCase() == 'never')) {
      return 0.2;
    }

    return 0.4; // Moderate incompatibility
  }

  /// Calculate relationship goals compatibility
  double? _calculateRelationshipGoalCompatibility(
    UserModel user1,
    UserModel user2,
  ) {
    final goal1 = user1.looking_for.toLowerCase();
    final goal2 = user2.looking_for.toLowerCase();

    if (goal1.isEmpty || goal2.isEmpty) return null;

    // Perfect matches
    if (goal1 == goal2) {
      if (goal1 == 'marriage' || goal1 == 'long_term') return 1.0;
      if (goal1 == 'dating' || goal1 == 'friends') return 0.9;
      return 0.8; // Other exact matches
    }

    // Compatible goals
    final compatiblePairs = {
      'marriage': ['long_term'],
      'long_term': ['marriage', 'dating'],
      'dating': ['long_term', 'friends'],
      'friends': ['dating'],
    };

    if (compatiblePairs[goal1]?.contains(goal2) == true) {
      return 0.7;
    }

    // Major incompatibilities
    if ((goal1 == 'casual' && goal2 == 'marriage') ||
        (goal1 == 'marriage' && goal2 == 'casual')) {
      return 0.1;
    }

    return 0.4; // Moderate incompatibility
  }

  /// Calculate education and career compatibility
  double? _calculateEducationCompatibility(UserModel user1, UserModel user2) {
    final education1 = user1.education_level;
    final education2 = user2.education_level;
    final career1 = user1.occupation;
    final career2 = user2.occupation;

    double totalScore = 0.0;
    int factors = 0;

    // Education level compatibility
    if (education1.isNotEmpty && education2.isNotEmpty) {
      final educationScore = _calculateEducationLevelScore(
        education1,
        education2,
      );
      totalScore += educationScore;
      factors++;
    }

    // Career field compatibility
    if (career1.isNotEmpty && career2.isNotEmpty) {
      final careerScore = _calculateCareerCompatibility(career1, career2);
      totalScore += careerScore;
      factors++;
    }

    return factors > 0 ? totalScore / factors : null;
  }

  /// Calculate education level compatibility
  double _calculateEducationLevelScore(String education1, String education2) {
    final educationLevels = {
      'high_school': 1,
      'some_college': 2,
      'bachelors': 3,
      'masters': 4,
      'doctorate': 5,
    };

    final level1 = educationLevels[education1.toLowerCase()] ?? 0;
    final level2 = educationLevels[education2.toLowerCase()] ?? 0;

    if (level1 == 0 || level2 == 0) return 0.5;

    final difference = (level1 - level2).abs();

    if (difference == 0) return 1.0; // Same level
    if (difference == 1) return 0.9; // One level difference
    if (difference == 2) return 0.7; // Two levels difference
    return 0.5; // Large education gap
  }

  /// Calculate career field compatibility
  double _calculateCareerCompatibility(String career1, String career2) {
    // Career field groupings for compatibility
    final careerGroups = {
      'creative': ['artist', 'designer', 'writer', 'musician', 'photographer'],
      'tech': ['engineer', 'developer', 'analyst', 'scientist'],
      'business': ['manager', 'consultant', 'entrepreneur', 'sales'],
      'healthcare': ['doctor', 'nurse', 'therapist', 'pharmacist'],
      'education': ['teacher', 'professor', 'researcher'],
      'service': ['server', 'retail', 'hospitality'],
    };

    String? group1, group2;

    for (final group in careerGroups.keys) {
      if (careerGroups[group]!.contains(career1.toLowerCase())) group1 = group;
      if (careerGroups[group]!.contains(career2.toLowerCase())) group2 = group;
    }

    if (career1.toLowerCase() == career2.toLowerCase()) return 1.0;
    if (group1 == group2 && group1 != null) return 0.8;

    // Compatible career combinations
    final compatibleGroups = {
      'creative': ['business', 'tech'],
      'tech': ['business', 'creative'],
      'business': ['tech', 'creative'],
      'healthcare': ['education'],
      'education': ['healthcare'],
    };

    if (group1 != null && group2 != null) {
      if (compatibleGroups[group1]?.contains(group2) == true) return 0.6;
    }

    return 0.4; // Different career fields
  }

  /// Calculate physical/preference compatibility
  double? _calculatePhysicalCompatibility(UserModel user1, UserModel user2) {
    double totalScore = 0.0;
    int factors = 0;

    // Height compatibility (if height data available)
    if (user1.height_cm.isNotEmpty && user2.height_cm.isNotEmpty) {
      try {
        final height1 = double.parse(user1.height_cm);
        final height2 = double.parse(user2.height_cm);
        final heightDiff = (height1 - height2).abs();

        // Most people prefer height differences within 15cm
        double heightScore;
        if (heightDiff <= 5)
          heightScore = 1.0;
        else if (heightDiff <= 10)
          heightScore = 0.9;
        else if (heightDiff <= 15)
          heightScore = 0.8;
        else if (heightDiff <= 20)
          heightScore = 0.6;
        else
          heightScore = 0.4;

        totalScore += heightScore;
        factors++;
      } catch (e) {
        // Invalid height data
      }
    }

    // Body type compatibility
    if (user1.body_type.isNotEmpty && user2.body_type.isNotEmpty) {
      final bodyScore =
          user1.body_type.toLowerCase() == user2.body_type.toLowerCase()
              ? 0.8
              : 0.6;
      totalScore += bodyScore;
      factors++;
    }

    return factors > 0 ? totalScore / factors : null;
  }

  /// Get compatibility breakdown for detailed analysis
  Map<String, double> getCompatibilityBreakdown(
    UserModel user1,
    UserModel user2,
  ) {
    return {
      'age': (_calculateAgeCompatibility(user1, user2) ?? 0.0) * 100,
      'location': (_calculateLocationCompatibility(user1, user2) ?? 0.0) * 100,
      'lifestyle':
          (_calculateLifestyleCompatibility(user1, user2) ?? 0.0) * 100,
      'goals':
          (_calculateRelationshipGoalCompatibility(user1, user2) ?? 0.0) * 100,
      'education':
          (_calculateEducationCompatibility(user1, user2) ?? 0.0) * 100,
      'physical': (_calculatePhysicalCompatibility(user1, user2) ?? 0.0) * 100,
    };
  }

  /// Get compatibility level description
  String getCompatibilityLevel(double score) {
    if (score >= 85) return 'Exceptional Match';
    if (score >= 75) return 'Great Match';
    if (score >= 65) return 'Good Match';
    if (score >= 50) return 'Fair Match';
    if (score >= 35) return 'Low Compatibility';
    return 'Poor Match';
  }

  /// Get personalized compatibility insights
  List<String> getCompatibilityInsights(UserModel user1, UserModel user2) {
    final breakdown = getCompatibilityBreakdown(user1, user2);
    final insights = <String>[];

    // Analyze each factor
    breakdown.forEach((factor, score) {
      if (score >= 80) {
        insights.add(_getPositiveInsight(factor));
      } else if (score <= 30) {
        insights.add(_getNegativeInsight(factor));
      }
    });

    if (insights.isEmpty) {
      insights.add('You have moderate compatibility in most areas');
    }

    return insights;
  }

  String _getPositiveInsight(String factor) {
    switch (factor) {
      case 'age':
        return 'You\'re in a similar life stage';
      case 'location':
        return 'You live close to each other';
      case 'lifestyle':
        return 'You have compatible lifestyles';
      case 'goals':
        return 'You want similar things in a relationship';
      case 'education':
        return 'You have compatible educational backgrounds';
      case 'physical':
        return 'You have compatible physical preferences';
      default:
        return 'You have great compatibility in this area';
    }
  }

  String _getNegativeInsight(String factor) {
    switch (factor) {
      case 'age':
        return 'There\'s a significant age difference';
      case 'location':
        return 'You live quite far apart';
      case 'lifestyle':
        return 'Your lifestyles may not align well';
      case 'goals':
        return 'You may want different things from a relationship';
      case 'education':
        return 'You have different educational backgrounds';
      case 'physical':
        return 'Your physical preferences may differ';
      default:
        return 'This area may need some consideration';
    }
  }
}
