import '../../models/UserModel.dart';

/// Service for generating conversation starters and icebreakers
class ConversationStarterService {
  /// Generate conversation starters based on shared interests
  static List<String> generateConversationStarters(
    UserModel currentUser,
    UserModel matchedUser,
  ) {
    final starters = <String>[];

    // Shared interests based conversation starters
    final sharedInterests = _findSharedInterests(currentUser, matchedUser);
    for (final interest in sharedInterests) {
      starters.addAll(_getInterestBasedStarters(interest));
    }

    // Age-based conversation starters
    starters.addAll(_getAgeBasedStarters(currentUser, matchedUser));

    // Location-based conversation starters
    starters.addAll(_getLocationBasedStarters(currentUser, matchedUser));

    // Education/profession based starters
    starters.addAll(_getProfessionBasedStarters(currentUser, matchedUser));

    // Lifestyle based starters
    starters.addAll(_getLifestyleBasedStarters(currentUser, matchedUser));

    // Generic dating conversation starters
    starters.addAll(_getGenericDatingStarters());

    // Shuffle and return top 8-10 unique starters
    starters.shuffle();
    return starters.take(10).toSet().toList();
  }

  /// Generate icebreaker templates based on user compatibility
  static List<IcebreakerTemplate> generateIcebreakerTemplates(
    UserModel currentUser,
    UserModel matchedUser,
    double compatibilityScore,
  ) {
    final templates = <IcebreakerTemplate>[];

    // High compatibility icebreakers
    if (compatibilityScore > 0.8) {
      templates.addAll(
        _getHighCompatibilityIcebreakers(currentUser, matchedUser),
      );
    }

    // Medium compatibility icebreakers
    if (compatibilityScore > 0.6) {
      templates.addAll(
        _getMediumCompatibilityIcebreakers(currentUser, matchedUser),
      );
    }

    // General icebreakers for all compatibility levels
    templates.addAll(_getGeneralIcebreakers(currentUser, matchedUser));

    // Question-based icebreakers
    templates.addAll(_getQuestionBasedIcebreakers());

    // Compliment-based icebreakers
    templates.addAll(_getComplimentBasedIcebreakers(matchedUser));

    // Activity suggestion icebreakers
    templates.addAll(_getActivityBasedIcebreakers(currentUser, matchedUser));

    return templates..shuffle();
  }

  /// Get suggested first messages based on profile analysis
  static List<FirstMessageSuggestion> getFirstMessageSuggestions(
    UserModel currentUser,
    UserModel matchedUser,
  ) {
    final suggestions = <FirstMessageSuggestion>[];

    // Profile photo based suggestions
    suggestions.addAll(_getPhotoBasedSuggestions(matchedUser));

    // Bio based suggestions
    suggestions.addAll(_getBioBasedSuggestions(matchedUser));

    // Interest based suggestions
    suggestions.addAll(_getInterestBasedSuggestions(currentUser, matchedUser));

    // Professional background suggestions
    suggestions.addAll(_getProfessionalSuggestions(matchedUser));

    // Travel and lifestyle suggestions
    suggestions.addAll(_getTravelLifestyleSuggestions(matchedUser));

    return suggestions..shuffle();
  }

  /// Generate date planning conversation topics
  static List<DatePlanningTopic> getDatePlanningTopics(
    UserModel currentUser,
    UserModel matchedUser,
  ) {
    final topics = <DatePlanningTopic>[];

    // Coffee date suggestions
    topics.add(
      DatePlanningTopic(
        category: 'Coffee Date',
        icon: '☕',
        suggestions: [
          "I know this amazing coffee shop with the best lattes in town. Want to check it out together?",
          "Coffee date? I promise I won't judge you for ordering something fancy 😄",
          "There's this cute little café I've been wanting to try. Care to join me?",
        ],
        followUp: "What's your go-to coffee order?",
      ),
    );

    // Activity based on shared interests
    final sharedInterests = _findSharedInterests(currentUser, matchedUser);
    for (final interest in sharedInterests.take(3)) {
      topics.add(_getActivityTopicForInterest(interest));
    }

    // Seasonal date suggestions
    topics.addAll(_getSeasonalDateTopics());

    // Food and dining suggestions
    topics.addAll(_getFoodDateTopics(currentUser, matchedUser));

    // Adventure and outdoor suggestions
    topics.addAll(_getAdventureTopics(currentUser, matchedUser));

    return topics;
  }

  // Private helper methods

  static List<String> _findSharedInterests(UserModel user1, UserModel user2) {
    // This would analyze profiles to find shared interests
    // For now, returning sample interests based on common dating app interests
    final allInterests = [
      'travel',
      'fitness',
      'music',
      'food',
      'movies',
      'books',
      'art',
      'photography',
      'hiking',
      'cooking',
      'dancing',
      'sports',
      'gaming',
    ];

    // In a real implementation, this would parse user profiles/interests
    return allInterests.take(3).toList()..shuffle();
  }

  static List<String> _getInterestBasedStarters(String interest) {
    final starters = <String, List<String>>{
      'travel': [
        "I see you love traveling! What's the most beautiful place you've ever been to?",
        "Travel buddy alert! 🌍 Where's next on your bucket list?",
        "I'm always planning my next adventure. Any hidden gems you'd recommend?",
      ],
      'fitness': [
        "Fitness enthusiast here too! What's your favorite way to stay active?",
        "I love that you're into fitness! Gym partner or outdoor workouts?",
        "We could definitely motivate each other at the gym! What's your go-to workout?",
      ],
      'music': [
        "Music lover! 🎵 What's the last concert that absolutely blew your mind?",
        "I see we both love music! What's been on repeat for you lately?",
        "Musical souls unite! Any artists I absolutely need to discover?",
      ],
      'food': [
        "Fellow foodie! 🍽️ What's the best meal you've had recently?",
        "I love that you're into food! Any restaurants you keep going back to?",
        "Food adventure buddy? I'm always looking for new places to try!",
      ],
    };

    return starters[interest] ?? [];
  }

  static List<String> _getAgeBasedStarters(UserModel user1, UserModel user2) {
    final age1 = _calculateAge(user1.dob);
    final age2 = _calculateAge(user2.dob);
    final ageDiff = (age1 - age2).abs();

    if (ageDiff <= 2) {
      return [
        "We're practically the same age! I bet we grew up with similar experiences 😊",
        "Same generation crew! What's something from our childhood you miss the most?",
      ];
    } else if (ageDiff <= 5) {
      return [
        "I love meeting people from different perspectives! What's something your generation taught you?",
        "Age is just a number, but I'm curious - what's the best life advice you've learned so far?",
      ];
    }

    return [];
  }

  static List<String> _getLocationBasedStarters(
    UserModel user1,
    UserModel user2,
  ) {
    // In a real implementation, this would calculate distance and city matching
    return [
      "Local connection! 📍 What's your favorite hidden spot in the city?",
      "Neighbor alert! What's the best thing about living here?",
      "Fellow city dweller! Any local recommendations for someone who loves exploring?",
    ];
  }

  static List<String> _getProfessionBasedStarters(
    UserModel user1,
    UserModel user2,
  ) {
    return [
      "I'd love to hear about your work! What's the most interesting part of your job?",
      "Career-driven and attractive? Tell me what you're passionate about professionally!",
      "Work-life balance is so important. How do you unwind after a busy day?",
    ];
  }

  static List<String> _getLifestyleBasedStarters(
    UserModel user1,
    UserModel user2,
  ) {
    return [
      "I'm curious about your lifestyle! Are you more of an adventure seeker or a cozy night in person?",
      "What does your perfect weekend look like?",
      "Morning person or night owl? I need to know if our energy levels will match! 😄",
    ];
  }

  static List<String> _getGenericDatingStarters() {
    return [
      "Your smile caught my attention! What's something that never fails to make you smile?",
      "I'm impressed by your profile! What's something you're genuinely excited about these days?",
      "Hey there! What's been the highlight of your week so far?",
      "I had to reach out! What's something you're passionate about that most people don't know?",
      "Your energy seems amazing! What's something that gets you excited?",
      "I'm curious about the person behind this great profile! What makes you, you?",
    ];
  }

  static List<IcebreakerTemplate> _getHighCompatibilityIcebreakers(
    UserModel user1,
    UserModel user2,
  ) {
    return [
      IcebreakerTemplate(
        category: 'High Compatibility',
        template:
            "We seem incredibly compatible! {shared_interest} is clearly something we both love. {question}",
        variables: ['shared_interest', 'question'],
        examples: [
          "We seem incredibly compatible! Travel is clearly something we both love. What's your dream destination?",
          "We seem incredibly compatible! Fitness is clearly something we both love. Want to be workout partners?",
        ],
      ),
      IcebreakerTemplate(
        category: 'High Compatibility',
        template:
            "I have a feeling we're going to get along great! {compliment} {follow_up}",
        variables: ['compliment', 'follow_up'],
        examples: [
          "I have a feeling we're going to get along great! Your adventurous spirit is infectious. Where should we explore first?",
          "I have a feeling we're going to get along great! Your sense of humor already has me smiling. Coffee soon?",
        ],
      ),
    ];
  }

  static List<IcebreakerTemplate> _getMediumCompatibilityIcebreakers(
    UserModel user1,
    UserModel user2,
  ) {
    return [
      IcebreakerTemplate(
        category: 'Medium Compatibility',
        template: "I'd love to get to know you better! {interest_question}",
        variables: ['interest_question'],
        examples: [
          "I'd love to get to know you better! What's something you're passionate about?",
          "I'd love to get to know you better! What's been making you happy lately?",
        ],
      ),
    ];
  }

  static List<IcebreakerTemplate> _getGeneralIcebreakers(
    UserModel user1,
    UserModel user2,
  ) {
    return [
      IcebreakerTemplate(
        category: 'General',
        template: "Hey {name}! {opener} {question}",
        variables: ['name', 'opener', 'question'],
        examples: [
          "Hey Sarah! Your profile caught my eye. What's been the best part of your day?",
          "Hey Alex! I love your energy in your photos. What makes you genuinely happy?",
        ],
      ),
    ];
  }

  static List<IcebreakerTemplate> _getQuestionBasedIcebreakers() {
    return [
      IcebreakerTemplate(
        category: 'Questions',
        template:
            "Quick question: {fun_question} (asking for a friend... just kidding, asking for me! 😄)",
        variables: ['fun_question'],
        examples: [
          "Quick question: Coffee or tea? (asking for a friend... just kidding, asking for me! 😄)",
          "Quick question: Beach vacation or mountain adventure? (asking for a friend... just kidding, asking for me! 😄)",
        ],
      ),
    ];
  }

  static List<IcebreakerTemplate> _getComplimentBasedIcebreakers(
    UserModel user,
  ) {
    return [
      IcebreakerTemplate(
        category: 'Compliments',
        template: "{genuine_compliment} {follow_up_question}",
        variables: ['genuine_compliment', 'follow_up_question'],
        examples: [
          "Your smile is absolutely radiant! What's something that always makes you smile like that?",
          "I love your sense of style! Do you have a fashion inspiration or is it all you?",
        ],
      ),
    ];
  }

  static List<IcebreakerTemplate> _getActivityBasedIcebreakers(
    UserModel user1,
    UserModel user2,
  ) {
    return [
      IcebreakerTemplate(
        category: 'Activities',
        template: "I have an idea! {activity_suggestion} Are you in?",
        variables: ['activity_suggestion'],
        examples: [
          "I have an idea! There's this amazing coffee shop I've been wanting to try. Are you in?",
          "I have an idea! Weekend farmers market adventure followed by brunch. Are you in?",
        ],
      ),
    ];
  }

  static List<FirstMessageSuggestion> _getPhotoBasedSuggestions(
    UserModel user,
  ) {
    return [
      FirstMessageSuggestion(
        category: 'Photo-based',
        message: "I love your photos! That smile is contagious 😊",
        reasoning: "Compliments their photos in a genuine way",
        confidence: 0.8,
      ),
      FirstMessageSuggestion(
        category: 'Photo-based',
        message:
            "Your travel photos are amazing! Where was that beautiful shot taken?",
        reasoning: "Shows interest in their experiences",
        confidence: 0.7,
      ),
    ];
  }

  static List<FirstMessageSuggestion> _getBioBasedSuggestions(UserModel user) {
    return [
      FirstMessageSuggestion(
        category: 'Bio-based',
        message:
            "Your bio made me smile! You seem like someone with great stories to tell.",
        reasoning: "Acknowledges their personality",
        confidence: 0.75,
      ),
    ];
  }

  static List<FirstMessageSuggestion> _getInterestBasedSuggestions(
    UserModel user1,
    UserModel user2,
  ) {
    return [
      FirstMessageSuggestion(
        category: 'Shared Interests',
        message: "Fellow [interest] enthusiast! What got you into it?",
        reasoning: "Builds connection through shared interests",
        confidence: 0.9,
      ),
    ];
  }

  static List<FirstMessageSuggestion> _getProfessionalSuggestions(
    UserModel user,
  ) {
    return [
      FirstMessageSuggestion(
        category: 'Professional',
        message:
            "I'd love to hear about your work! What's the most exciting part?",
        reasoning: "Shows interest in their career and ambitions",
        confidence: 0.6,
      ),
    ];
  }

  static List<FirstMessageSuggestion> _getTravelLifestyleSuggestions(
    UserModel user,
  ) {
    return [
      FirstMessageSuggestion(
        category: 'Lifestyle',
        message:
            "What's been the highlight of your week? You seem like you live life to the fullest!",
        reasoning: "Positive and open-ended conversation starter",
        confidence: 0.7,
      ),
    ];
  }

  static DatePlanningTopic _getActivityTopicForInterest(String interest) {
    final topicMap = <String, DatePlanningTopic>{
      'travel': DatePlanningTopic(
        category: 'Travel Exploration',
        icon: '✈️',
        suggestions: [
          "I know this place that feels like a mini-vacation right here in the city. Want to explore it together?",
          "Day trip adventure? I have some ideas for places that'll feel like we traveled without the jet lag!",
        ],
        followUp: "What's your ideal day trip destination?",
      ),
      'fitness': DatePlanningTopic(
        category: 'Active Date',
        icon: '🏃‍♀️',
        suggestions: [
          "Active date idea: hiking trail followed by smoothie rewards?",
          "Want to try that new climbing gym together? I promise to catch you if you fall 😄",
        ],
        followUp: "What's your favorite way to stay active?",
      ),
      'food': DatePlanningTopic(
        category: 'Culinary Adventure',
        icon: '🍽️',
        suggestions: [
          "Food adventure! I know this place that does fusion cuisine like nowhere else. Game?",
          "Cooking date idea: we pick ingredients at the farmers market and create something amazing together!",
        ],
        followUp: "What type of cuisine makes you happiest?",
      ),
    };

    return topicMap[interest] ??
        DatePlanningTopic(
          category: 'General Activity',
          icon: '🎯',
          suggestions: [
            "Want to try something new together? I'm always up for an adventure!",
          ],
          followUp: "What's something you've always wanted to try?",
        );
  }

  static List<DatePlanningTopic> _getSeasonalDateTopics() {
    final month = DateTime.now().month;

    if (month >= 12 || month <= 2) {
      // Winter
      return [
        DatePlanningTopic(
          category: 'Winter Activities',
          icon: '❄️',
          suggestions: [
            "Ice skating followed by hot chocolate? Perfect winter date combo!",
            "Cozy indoor market exploring, then warm soup somewhere with a fireplace?",
          ],
          followUp: "Winter person or counting down to spring?",
        ),
      ];
    } else if (month >= 3 && month <= 5) {
      // Spring
      return [
        DatePlanningTopic(
          category: 'Spring Activities',
          icon: '🌸',
          suggestions: [
            "Cherry blossom hunting and picnic? Spring is calling!",
            "Garden center adventure followed by planting something together?",
          ],
          followUp: "What's your favorite thing about spring?",
        ),
      ];
    } else if (month >= 6 && month <= 8) {
      // Summer
      return [
        DatePlanningTopic(
          category: 'Summer Activities',
          icon: '☀️',
          suggestions: [
            "Beach day or lake adventure? Summer vibes are calling!",
            "Outdoor concert in the park with a picnic basket?",
          ],
          followUp: "Perfect summer day - what does it look like to you?",
        ),
      ];
    } else {
      // Fall
      return [
        DatePlanningTopic(
          category: 'Fall Activities',
          icon: '🍂',
          suggestions: [
            "Apple picking and cider tasting? Peak fall romance!",
            "Cozy bookstore browsing followed by warm drinks?",
          ],
          followUp: "Fall person? What's your favorite autumn activity?",
        ),
      ];
    }
  }

  static List<DatePlanningTopic> _getFoodDateTopics(
    UserModel user1,
    UserModel user2,
  ) {
    return [
      DatePlanningTopic(
        category: 'Foodie Adventure',
        icon: '🌮',
        suggestions: [
          "Food truck tour of the city? I know the best route!",
          "Brunch and then dessert somewhere completely different? Full foodie experience!",
        ],
        followUp: "Sweet tooth or savory person?",
      ),
    ];
  }

  static List<DatePlanningTopic> _getAdventureTopics(
    UserModel user1,
    UserModel user2,
  ) {
    return [
      DatePlanningTopic(
        category: 'Adventure Date',
        icon: '🎢',
        suggestions: [
          "Mini golf championship followed by victory pizza?",
          "Mystery activity date - I plan, you trust. Deal?",
        ],
        followUp: "Spontaneous adventures or planned perfection?",
      ),
    ];
  }

  static int _calculateAge(String? dob) {
    if (dob == null) return 25; // Default age if not provided

    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;

      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age;
    } catch (e) {
      return 25; // Default age if parsing fails
    }
  }
}

/// Data models for conversation features

class IcebreakerTemplate {
  final String category;
  final String template;
  final List<String> variables;
  final List<String> examples;

  IcebreakerTemplate({
    required this.category,
    required this.template,
    required this.variables,
    required this.examples,
  });
}

class FirstMessageSuggestion {
  final String category;
  final String message;
  final String reasoning;
  final double confidence;

  FirstMessageSuggestion({
    required this.category,
    required this.message,
    required this.reasoning,
    required this.confidence,
  });
}

class DatePlanningTopic {
  final String category;
  final String icon;
  final List<String> suggestions;
  final String followUp;

  DatePlanningTopic({
    required this.category,
    required this.icon,
    required this.suggestions,
    required this.followUp,
  });
}
