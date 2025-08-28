import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/AppConfig.dart';
import '../utils/Utilities.dart';

class LoggedInUserModel {
  static String tableName = "logged_in_user_6";
  int id = 0;

  bool isVerified = false;
  bool isOnline = false;

  String username = "";
  String password = "";
  String name = "";
  String avatar = "";
  String token = "";
  String created_at = "";
  String updated_at = "";
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

  // Legal and Agreement Fields
  String terms_of_service_accepted =
      ""; // "Yes" or "No" - EULA/Terms acceptance
  String privacy_policy_accepted =
      ""; // "Yes" or "No" - Privacy policy acceptance
  String community_guidelines_accepted =
      ""; // "Yes" or "No" - Community guidelines
  String marketing_emails_consent = ""; // "Yes" or "No" - Marketing emails
  String data_processing_consent = ""; // "Yes" or "No" - Data processing
  String content_moderation_consent =
      ""; // "Yes" or "No" - Content moderation agreement
  String terms_accepted_date = ""; // Date when terms were accepted
  String privacy_accepted_date = ""; // Date when privacy policy was accepted
  String guidelines_accepted_date = ""; // Date when guidelines were accepted

  // Additional User Settings
  String notification_preferences = ""; // "Yes" or "No" - General notifications
  String push_notifications = ""; // "Yes" or "No" - Push notifications
  String email_notifications = ""; // "Yes" or "No" - Email notifications
  String profile_visibility =
      ""; // "Public", "Private", "Friends" - Profile visibility
  String content_filtering = ""; // "On" or "Off" - Content filtering
  String safe_mode = ""; // "On" or "Off" - Safe browsing mode
  String location_sharing = ""; // "Yes" or "No" - Location sharing
  String analytics_consent = ""; // "Yes" or "No" - Analytics tracking
  String crash_reporting = ""; // "Yes" or "No" - Crash reporting

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'name': name,
    'avatar': avatar,
    'created_at': created_at,
    'updated_at': updated_at,
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
    // Legal and Agreement Fields
    'terms_of_service_accepted': terms_of_service_accepted,
    'privacy_policy_accepted': privacy_policy_accepted,
    'community_guidelines_accepted': community_guidelines_accepted,
    'marketing_emails_consent': marketing_emails_consent,
    'data_processing_consent': data_processing_consent,
    'content_moderation_consent': content_moderation_consent,
    'terms_accepted_date': terms_accepted_date,
    'privacy_accepted_date': privacy_accepted_date,
    'guidelines_accepted_date': guidelines_accepted_date,
    // Additional User Settings
    'notification_preferences': notification_preferences,
    'push_notifications': push_notifications,
    'email_notifications': email_notifications,
    'profile_visibility': profile_visibility,
    'content_filtering': content_filtering,
    'safe_mode': safe_mode,
    'location_sharing': location_sharing,
    'analytics_consent': analytics_consent,
    'crash_reporting': crash_reporting,
  };

  /// Initialize the local table if needed
  static Future<bool> initTable() async {
    final db = await Utils.getDb();
    if (!db.isOpen) return false;
    final sql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY,
      username TEXT,
      token TEXT,
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
      phone_number_1 TEXT,
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
      completed_profile_pct TEXT,
      terms_of_service_accepted TEXT,
      privacy_policy_accepted TEXT,
      community_guidelines_accepted TEXT,
      marketing_emails_consent TEXT,
      data_processing_consent TEXT,
      content_moderation_consent TEXT,
      terms_accepted_date TEXT,
      privacy_accepted_date TEXT,
      guidelines_accepted_date TEXT,
      notification_preferences TEXT,
      push_notifications TEXT,
      email_notifications TEXT,
      profile_visibility TEXT,
      content_filtering TEXT,
      safe_mode TEXT,
      location_sharing TEXT,
      analytics_consent TEXT,
      crash_reporting TEXT
    )
    ''';
    await db.execute(sql);
    return true;
  }

  String s(dynamic m) {
    return Utils.to_str(m, '');
  }

  static deleteAllItems() async {}

  List<String> permissions = [];

  static Future<LoggedInUserModel> getLoggedInUser() async {
    LoggedInUserModel item = LoggedInUserModel();

    if (!await initTable()) {
      Utils.toast('Failed to create user storage.');
      return item;
    }

    Database db = await openDatabase(AppConfig.DATABASE_PATH);
    if (!db.isOpen) {
      return item;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      LoggedInUserModel.tableName,
    );

    List.generate(maps.length, (i) {
      item = LoggedInUserModel.fromJson(maps[i]);
    });

    return item;
  }

  static LoggedInUserModel fromJson(dynamic m) {
    final u = LoggedInUserModel();
    if (m == null) return u;

    u.id = Utils.int_parse(m['id']);
    u.username = Utils.to_str(m['username'], '');
    u.password = Utils.to_str(m['password'], '');
    u.name = Utils.to_str(m['name'], '');
    u.avatar = Utils.to_str(m['avatar'], '');
    u.created_at = Utils.to_str(m['created_at'], '');
    u.updated_at = Utils.to_str(m['updated_at'], '');
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

    u.terms_of_service_accepted = Utils.to_str(
      m['terms_of_service_accepted'],
      '',
    );
    u.privacy_policy_accepted = Utils.to_str(m['privacy_policy_accepted'], '');
    u.community_guidelines_accepted = Utils.to_str(
      m['community_guidelines_accepted'],
      '',
    );
    u.marketing_emails_consent = Utils.to_str(
      m['marketing_emails_consent'],
      '',
    );
    u.data_processing_consent = Utils.to_str(m['data_processing_consent'], '');
    u.content_moderation_consent = Utils.to_str(
      m['content_moderation_consent'],
      '',
    );
    u.terms_accepted_date = Utils.to_str(m['terms_accepted_date'], '');
    u.privacy_accepted_date = Utils.to_str(m['privacy_accepted_date'], '');
    u.guidelines_accepted_date = Utils.to_str(
      m['guidelines_accepted_date'],
      '',
    );
    u.notification_preferences = Utils.to_str(
      m['notification_preferences'],
      '',
    );
    u.push_notifications = Utils.to_str(m['push_notifications'], '');
    u.email_notifications = Utils.to_str(m['email_notifications'], '');
    u.profile_visibility = Utils.to_str(m['profile_visibility'], '');
    u.content_filtering = Utils.to_str(m['content_filtering'], '');
    u.safe_mode = Utils.to_str(m['safe_mode'], '');
    u.location_sharing = Utils.to_str(m['location_sharing'], '');
    u.analytics_consent = Utils.to_str(m['analytics_consent'], '');
    u.crash_reporting = Utils.to_str(m['crash_reporting'], '');
    u.token = Utils.to_str(m['token'], '');

    u.isOnline = false;
    if (u.online_status.toLowerCase() == 'online') {
      u.isOnline = true;
    }

    return u;
  }

  static Future<String> get_token() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic localToken = prefs.getString('token');
    if (localToken == null || localToken.toString().length < 6) {
      LoggedInUserModel lu = await LoggedInUserModel.getLoggedInUser();
      localToken = lu.token;
      await prefs.setString('token', localToken);
    }

    return localToken;
  }

  Future<bool> save() async {
    bool isSuccess = false;
    if (!(await initTable())) {
      return false;
    }
    Database db = await openDatabase(AppConfig.DATABASE_PATH);
    if (!db.isOpen) {
      return false;
    }

    try {
      await db.insert(
        LoggedInUserModel.tableName,
        toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      isSuccess = true;
    } catch (e) {
      Utils.log(" !!!==> Failed because ${e.toString()}");
      isSuccess = false;
    }

    return isSuccess;
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
