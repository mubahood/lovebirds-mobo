import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../utils/AppConfig.dart';
import '../utils/Utilities.dart';
import 'RespondModel.dart';

class UserModel {
  static const String endPoint = "users-list";
  static const String tableName = "admin_users_2";

  bool isVerified = false;
  bool isOnline = false;

  // --- Fields matching your table ---
  int id = 0;
  String username = "";
  String password = "";
  String name = "";
  String avatar = "";
  String remember_token = "";
  String created_at = "";
  String updated_at = "";
  String company_id = "";
  String first_name = "";
  String last_name = "";
  String phone_number = "";
  String phone_number_2 = "";
  String address = "";
  String sex = "";
  String dob = "";
  String status = "";
  String email = "";
  String secret_code = "";
  String profile_photos = "";
  String bio = "";
  String tagline = "";
  String phone_country_name = "";
  String phone_country_code = "";
  String phone_country_international = "";
  String sexual_orientation = "";
  String height_cm = "";
  String body_type = "";
  String country = "";
  String state = "";
  String city = "";
  String latitude = "";
  String longitude = "";
  String last_online_at = "";
  String online_status = "";
  String looking_for = "";
  String interested_in = "";
  String age_range_min = "";
  String age_range_max = "";
  String max_distance_km = "";
  String smoking_habit = "";
  String drinking_habit = "";
  String pet_preference = "";
  String religion = "";
  String political_views = "";
  String languages_spoken = "";
  String education_level = "";
  String occupation = "";
  String email_verified = "";
  String phone_verified = "";
  String verification_code = "";
  String failed_login_attempts = "";
  String last_password_change = "";
  String subscription_tier = "";
  String subscription_expires = "";
  String credits_balance = "";
  String profile_views = "";
  String likes_received = "";
  String matches_count = "";
  String completed_profile_pct = "";

  // Distance property for location-based features
  double distance = 0.0;

  UserModel();

  /// Construct from API or local DB row
  static UserModel fromJson(dynamic m) {
    final u = UserModel();
    if (m == null) return u;

    u.id = Utils.int_parse(m['id']);
    u.username = Utils.to_str(m['username'], '');
    u.password = Utils.to_str(m['password'], '');
    u.name = Utils.to_str(m['name'], '');
    u.avatar = Utils.to_str(m['avatar'], '');
    u.remember_token = Utils.to_str(m['remember_token'], '');
    u.created_at = Utils.to_str(m['created_at'], '');
    u.updated_at = Utils.to_str(m['updated_at'], '');
    u.company_id = Utils.to_str(m['company_id'], '');
    u.first_name = Utils.to_str(m['first_name'], '');
    u.last_name = Utils.to_str(m['last_name'], '');
    u.phone_number = Utils.to_str(m['phone_number'], '');
    u.phone_number_2 = Utils.to_str(m['phone_number_2'], '');
    u.address = Utils.to_str(m['address'], '');
    u.sex = Utils.to_str(m['sex'], '');
    u.dob = Utils.to_str(m['dob'], '');
    u.status = Utils.to_str(m['status'], '');
    u.email = Utils.to_str(m['email'], '');
    u.secret_code = Utils.to_str(m['secret_code'], '');
    u.profile_photos = Utils.to_str(m['profile_photos'], '');
    u.bio = Utils.to_str(m['bio'], '');
    u.tagline = Utils.to_str(m['tagline'], '');
    u.phone_country_name = Utils.to_str(m['phone_country_name'], '');
    u.phone_country_code = Utils.to_str(m['phone_country_code'], '');
    u.phone_country_international = Utils.to_str(
      m['phone_country_international'],
      '',
    );
    u.sexual_orientation = Utils.to_str(m['sexual_orientation'], '');
    u.height_cm = Utils.to_str(m['height_cm'], '');
    u.body_type = Utils.to_str(m['body_type'], '');
    u.country = Utils.to_str(m['country'], '');
    u.state = Utils.to_str(m['state'], '');
    u.city = Utils.to_str(m['city'], '');
    u.latitude = Utils.to_str(m['latitude'], '');
    u.longitude = Utils.to_str(m['longitude'], '');
    u.last_online_at = Utils.to_str(m['last_online_at'], '');
    u.online_status = Utils.to_str(m['online_status'], '');
    u.looking_for = Utils.to_str(m['looking_for'], '');
    u.interested_in = Utils.to_str(m['interested_in'], '');
    u.age_range_min = Utils.to_str(m['age_range_min'], '');
    u.age_range_max = Utils.to_str(m['age_range_max'], '');
    u.max_distance_km = Utils.to_str(m['max_distance_km'], '');
    u.smoking_habit = Utils.to_str(m['smoking_habit'], '');
    u.drinking_habit = Utils.to_str(m['drinking_habit'], '');
    u.pet_preference = Utils.to_str(m['pet_preference'], '');
    u.religion = Utils.to_str(m['religion'], '');
    u.political_views = Utils.to_str(m['political_views'], '');
    u.languages_spoken = Utils.to_str(m['languages_spoken'], '');
    u.education_level = Utils.to_str(m['education_level'], '');
    u.occupation = Utils.to_str(m['occupation'], '');
    u.email_verified = Utils.to_str(m['email_verified'], '');
    u.phone_verified = Utils.to_str(m['phone_verified'], '');
    u.verification_code = Utils.to_str(m['verification_code'], '');
    u.failed_login_attempts = Utils.to_str(m['failed_login_attempts'], '');
    u.last_password_change = Utils.to_str(m['last_password_change'], '');
    u.subscription_tier = Utils.to_str(m['subscription_tier'], '');
    u.subscription_expires = Utils.to_str(m['subscription_expires'], '');
    u.credits_balance = Utils.to_str(m['credits_balance'], '');
    u.profile_views = Utils.to_str(m['profile_views'], '');
    u.likes_received = Utils.to_str(m['likes_received'], '');
    u.matches_count = Utils.to_str(m['matches_count'], '');
    u.completed_profile_pct = Utils.to_str(m['completed_profile_pct'], '');

    // Parse distance if provided (for location-based features)
    if (m['distance'] != null) {
      try {
        u.distance = double.parse(m['distance'].toString());
      } catch (e) {
        u.distance = 0.0;
      }
    }

    u.isOnline = false;
    if (u.online_status.toLowerCase() == 'online') {
      u.isOnline = true;
    }

    return u;
  }

  // Profile photos helper methods
  List<String> getProfilePhotos() {
    if (profile_photos.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(profile_photos);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  List<String> getProfilePhotoUrls() {
    final photos = getProfilePhotos();
    return photos.map((photo) {
      if (photo.startsWith('http')) {
        return photo;
      }
      return '${AppConfig.BASE_URL}/storage/$photo';
    }).toList();
  }

  String getPrimaryPhotoUrl() {
    final photos = getProfilePhotoUrls();
    if (photos.isNotEmpty) {
      return photos.first;
    }

    // Fallback to avatar
    if (avatar.isNotEmpty) {
      if (avatar.startsWith('http')) {
        return avatar;
      }
      return '${AppConfig.BASE_URL}/storage/$avatar';
    }

    // Final fallback
    return '${AppConfig.BASE_URL}/storage/images/1.jpg';
  }

  int getPhotoCount() {
    return getProfilePhotos().length;
  }

  bool hasMultiplePhotos() {
    return getPhotoCount() > 1;
  }

  /// Get first name or fallback to name
  String getFirstName() {
    if (first_name.isNotEmpty) {
      return first_name;
    }
    if (name.isNotEmpty) {
      // If name contains spaces, return first word
      final nameParts = name.split(' ');
      return nameParts.first;
    }
    return 'User';
  }

  /// Serialize for DB insert/update
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'name': name,
    'avatar': avatar,
    'remember_token': remember_token,
    'created_at': created_at,
    'updated_at': updated_at,
    'company_id': company_id,
    'first_name': first_name,
    'last_name': last_name,
    'phone_number': phone_number,
    'phone_number_2': phone_number_2,
    'address': address,
    'sex': sex,
    'dob': dob,
    'status': status,
    'email': email,
    'secret_code': secret_code,
    'profile_photos': profile_photos,
    'bio': bio,
    'tagline': tagline,
    'phone_country_name': phone_country_name,
    'phone_country_code': phone_country_code,
    'phone_country_international': phone_country_international,
    'sexual_orientation': sexual_orientation,
    'height_cm': height_cm,
    'body_type': body_type,
    'country': country,
    'state': state,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'last_online_at': last_online_at,
    'online_status': online_status,
    'looking_for': looking_for,
    'interested_in': interested_in,
    'age_range_min': age_range_min,
    'age_range_max': age_range_max,
    'max_distance_km': max_distance_km,
    'smoking_habit': smoking_habit,
    'drinking_habit': drinking_habit,
    'pet_preference': pet_preference,
    'religion': religion,
    'political_views': political_views,
    'languages_spoken': languages_spoken,
    'education_level': education_level,
    'occupation': occupation,
    'email_verified': email_verified,
    'phone_verified': phone_verified,
    'verification_code': verification_code,
    'failed_login_attempts': failed_login_attempts,
    'last_password_change': last_password_change,
    'subscription_tier': subscription_tier,
    'subscription_expires': subscription_expires,
    'credits_balance': credits_balance,
    'profile_views': profile_views,
    'likes_received': likes_received,
    'matches_count': matches_count,
    'completed_profile_pct': completed_profile_pct,
    'distance': distance,
  };

  /// Initialize the local table if needed
  static Future<bool> initTable() async {
    final db = await Utils.getDb();
    if (!db.isOpen) return false;
    final sql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY,
      username TEXT,
      password TEXT,
      name TEXT,
      avatar TEXT,
      remember_token TEXT,
      created_at TEXT,
      updated_at TEXT,
      company_id TEXT,
      first_name TEXT,
      last_name TEXT,
      phone_number TEXT,
      phone_number_2 TEXT,
      address TEXT,
      sex TEXT,
      dob TEXT,
      status TEXT,
      email TEXT,
      secret_code TEXT,
      profile_photos TEXT,
      bio TEXT,
      tagline TEXT,
      phone_country_name TEXT,
      phone_country_code TEXT,
      phone_country_international TEXT,
      sexual_orientation TEXT,
      height_cm TEXT,
      body_type TEXT,
      country TEXT,
      state TEXT,
      city TEXT,
      latitude TEXT,
      longitude TEXT,
      last_online_at TEXT,
      online_status TEXT,
      looking_for TEXT,
      interested_in TEXT,
      age_range_min TEXT,
      age_range_max TEXT,
      max_distance_km TEXT,
      smoking_habit TEXT,
      drinking_habit TEXT,
      pet_preference TEXT,
      religion TEXT,
      political_views TEXT,
      languages_spoken TEXT,
      education_level TEXT,
      occupation TEXT,
      email_verified TEXT,
      phone_verified TEXT,
      verification_code TEXT,
      failed_login_attempts TEXT,
      last_password_change TEXT,
      subscription_tier TEXT,
      subscription_expires TEXT,
      credits_balance TEXT,
      profile_views TEXT,
      likes_received TEXT,
      matches_count TEXT,
      completed_profile_pct TEXT
    )
    ''';
    await db.execute(sql);
    return true;
  }

  /// Delete all local records
  static Future<void> deleteAll() async {
    if (!await initTable()) return;
    final db = await Utils.getDb();
    if (db.isOpen) await db.delete(tableName);
  }

  /// Upsert locally
  Future<void> save() async {
    final db = await Utils.getDb();
    if (!db.isOpen) return;
    await initTable();
    await db.insert(
      tableName,
      toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch one page from local
  static Future<List<UserModel>> getLocalPage({
    String where = '1',
    int page = 1,
    int perPage = 20,
  }) async {
    final list = <UserModel>[];
    if (!await initTable()) return list;
    final db = await Utils.getDb();
    if (!db.isOpen) return list;
    final offset = (page - 1) * perPage;
    final maps = await db.query(
      tableName,
      where: where,
      orderBy: 'id DESC',
      limit: perPage,
      offset: offset,
    );
    for (var m in maps) {
      list.add(UserModel.fromJson(m));
    }
    return list;
  }

  /// Public API: page, with optional background refresh
  static Future<List<UserModel>> getItems({
    String where = '1',
    int page = 1,
    int perPage = 20,
    String? lastUpdate,
    bool onlineOnly = false,
    bool verifiedOnly = false,
  }) async {
    var clause = where;
    if (onlineOnly) clause += " AND online_status='1'";
    if (verifiedOnly) clause += " AND email_verified='1'";
    var local = await getLocalPage(where: clause, page: page, perPage: perPage);
    if (local.isEmpty) {
      await _fetchOnlinePage(
        page: page,
        perPage: perPage,
        lastUpdate: lastUpdate,
      );
      local = await getLocalPage(where: clause, page: page, perPage: perPage);
    } else {
      _fetchOnlinePage(page: page, perPage: perPage, lastUpdate: lastUpdate);
    }
    return local;
  }

  /// Fetch & merge one page from server
  static Future<void> _fetchOnlinePage({
    required int page,
    required int perPage,
    String? lastUpdate,
  }) async {
    final params = {
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (lastUpdate != null) 'last_update_date': lastUpdate,
    };
    final resp = RespondModel(await Utils.http_get(endPoint, params));

    if (resp.code != 1 ||
        resp.data == null ||
        resp.data is! Map<String, dynamic>)
      return;
    final pageMap = resp.data as Map<String, dynamic>;
    if (pageMap['data'] is! List) return;
    final items = pageMap['data'] as List<dynamic>;

    final db = await Utils.getDb();
    if (!db.isOpen) return;

    if (page == 1 && lastUpdate == null) {
      await deleteAll();
    }

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var raw in items) {
        final u = UserModel.fromJson(raw);
        batch.insert(
          tableName,
          u.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(continueOnError: true);
    });
  }

  // Computed properties for profile screen compatibility
  String get age {
    if (dob.isNotEmpty) {
      try {
        final birthDate = DateTime.parse(dob);
        final now = DateTime.now();
        int age = now.year - birthDate.year;
        if (now.month < birthDate.month ||
            (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
        return age.toString();
      } catch (e) {
        return 'Unknown';
      }
    }
    return 'Unknown';
  }

  String get location {
    List<String> locationParts = [];
    if (city.isNotEmpty) locationParts.add(city);
    if (state.isNotEmpty) locationParts.add(state);
    if (country.isNotEmpty) locationParts.add(country);
    return locationParts.isEmpty ? 'Not specified' : locationParts.join(', ');
  }

  String get interests {
    List<String> interestList = [];
    if (interested_in.isNotEmpty)
      interestList.add('Looking for: $interested_in');
    if (languages_spoken.isNotEmpty)
      interestList.add('Languages: $languages_spoken');
    if (occupation.isNotEmpty) interestList.add('Occupation: $occupation');
    return interestList.isEmpty ? 'Not specified' : interestList.join(', ');
  }
}

// Match model for dating matches
class MatchModel {
  int id = 0;
  int userId = 0;
  int matchedUserId = 0;
  String status = "";
  String matchType = "";
  String matchedAt = "";
  String lastMessageAt = "";
  int messagesCount = 0;
  String conversationStarter = "";
  String matchReason = "";
  double compatibilityScore = 0.0;
  String isConversationStarted = "";
  String unMatchedAt = "";
  int unMatchedBy = 0;
  String unMatchReason = "";
  UserModel user = UserModel();
  UserModel matchedUser = UserModel();

  // Computed properties for backward compatibility
  bool get hasMessage => messagesCount > 0;
  bool get isSuperLike => matchType == 'super_like';

  bool get isNew => status == 'new';

  MatchModel();

  MatchModel.fromJson(Map<String, dynamic> json) {
    id = Utils.int_parse(json['id']);
    userId = Utils.int_parse(json['user_id']);
    matchedUserId = Utils.int_parse(json['matched_user_id']);
    status = Utils.to_str(json['status'], '');
    matchType = Utils.to_str(json['match_type'], '');
    matchedAt = Utils.to_str(json['matched_at'], '');
    lastMessageAt = Utils.to_str(json['last_message_at'], '');
    messagesCount = Utils.int_parse(json['messages_count']);
    conversationStarter = Utils.to_str(json['conversation_starter'], '');
    matchReason = Utils.to_str(json['match_reason'], '');
    compatibilityScore =
        (json['compatibility_score'] is num)
            ? (json['compatibility_score'] as num).toDouble()
            : 0.0;
    isConversationStarted = Utils.to_str(json['is_conversation_started'], '');
    unMatchedAt = Utils.to_str(json['unmatched_at'], '');
    unMatchedBy = Utils.int_parse(json['unmatched_by']);
    unMatchReason = Utils.to_str(json['unmatch_reason'], '');

    if (json['user'] != null) {
      user = UserModel.fromJson(json['user']);
    }
    if (json['matched_user'] != null) {
      matchedUser = UserModel.fromJson(json['matched_user']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'matched_user_id': matchedUserId,
      'status': status,
      'match_type': matchType,
      'matched_at': matchedAt,
      'last_message_at': lastMessageAt,
      'messages_count': messagesCount,
      'conversation_starter': conversationStarter,
      'match_reason': matchReason,
      'compatibility_score': compatibilityScore,
      'is_conversation_started': isConversationStarted,
      'unmatched_at': unMatchedAt,
      'unmatched_by': unMatchedBy,
      'unmatch_reason': unMatchReason,
      'user': user.toJson(),
      'matched_user': matchedUser.toJson(),
    };
  }
}

// Response model for filtered matches
class FilteredMatchResponse {
  List<MatchModel> matches = [];
  Map<String, int> filterCounts = {};
  bool hasMore = false;

  FilteredMatchResponse({
    required this.matches,
    required this.filterCounts,
    required this.hasMore,
  });
}
