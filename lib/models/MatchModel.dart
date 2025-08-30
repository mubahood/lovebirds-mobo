class MatchModel {
  int id;
  UserModel user;
  String matchedAt;
  double compatibilityScore;
  String conversationStarter;
  int unreadCount;
  String lastMessageAt;
  bool isNewMatch;

  MatchModel({
    required this.id,
    required this.user,
    required this.matchedAt,
    required this.compatibilityScore,
    this.conversationStarter = '',
    this.unreadCount = 0,
    this.lastMessageAt = '',
    this.isNewMatch = false,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] ?? 0,
      user: UserModel.fromJson(json['user'] ?? {}),
      matchedAt: json['matched_at'] ?? DateTime.now().toIso8601String(),
      compatibilityScore: (json['compatibility_score'] ?? 0.0).toDouble(),
      conversationStarter: json['conversation_starter'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      lastMessageAt: json['last_message_at'] ?? '',
      isNewMatch: json['is_new_match'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'matched_at': matchedAt,
      'compatibility_score': compatibilityScore,
      'conversation_starter': conversationStarter,
      'unread_count': unreadCount,
      'last_message_at': lastMessageAt,
      'is_new_match': isNewMatch,
    };
  }
}

class MatchesResponse {
  List<MatchModel> matches;
  Map<String, int> filterCounts;
  bool hasMore;
  int currentPage;
  int totalPages;

  MatchesResponse({
    required this.matches,
    required this.filterCounts,
    required this.hasMore,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  factory MatchesResponse.fromJson(Map<String, dynamic> json) {
    final matchesData = json['matches'] ?? [];
    final matches = (matchesData as List)
        .map((match) => MatchModel.fromJson(match))
        .toList();

    final filterCounts = Map<String, int>.from(json['filter_counts'] ?? {
      'all': 0,
      'new': 0,
      'recent': 0,
      'unread': 0,
    });

    return MatchesResponse(
      matches: matches,
      filterCounts: filterCounts,
      hasMore: json['has_more'] ?? false,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
