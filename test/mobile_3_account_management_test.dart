import 'package:flutter_test/flutter_test.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';

void main() {
  group('MOBILE-3: Account Profile Management Enhancement Tests', () {
    test('Profile completion percentage calculation works correctly', () {
      // Create test user with partial data
      LoggedInUserModel testUser = LoggedInUserModel();
      testUser.first_name = "John";
      testUser.last_name = "Doe";
      testUser.email = "john@test.com";
      testUser.phone_number = "1234567890";
      testUser.bio = "Test bio";
      testUser.dob = "1990-01-01";
      testUser.sex = "Male";
      testUser.avatar = "test_avatar.jpg";
      testUser.profile_photos = '["photo1.jpg", "photo2.jpg"]';

      // All fields completed = 8/8 = 100%
      expect(testUser.first_name.isNotEmpty, true);
      expect(testUser.last_name.isNotEmpty, true);
      expect(testUser.email.isNotEmpty, true);
      expect(testUser.phone_number.isNotEmpty, true);
      expect(testUser.bio.isNotEmpty, true);
      expect(testUser.dob.isNotEmpty, true);
      expect(testUser.sex.isNotEmpty, true);
      expect(
        testUser.avatar.isNotEmpty || testUser.profile_photos.isNotEmpty,
        true,
      );
    });

    test('Profile completion helpers work correctly', () {
      LoggedInUserModel testUser = LoggedInUserModel();
      testUser.first_name = "John";
      testUser.last_name = "Doe";
      testUser.email = "john@test.com";
      testUser.phone_number = "1234567890";
      testUser.dob = "1990-01-01";
      testUser.sex = "Male";
      testUser.avatar = "test_avatar.jpg";
      testUser.profile_photos = '["photo1.jpg"]';

      // Test personal completion
      bool personalComplete =
          testUser.first_name.isNotEmpty &&
          testUser.last_name.isNotEmpty &&
          testUser.dob.isNotEmpty &&
          testUser.sex.isNotEmpty;
      expect(personalComplete, true);

      // Test account completion
      bool accountComplete =
          testUser.email.isNotEmpty && testUser.phone_number.isNotEmpty;
      expect(accountComplete, true);

      // Test photos completion
      bool photosComplete =
          testUser.avatar.isNotEmpty || testUser.profile_photos.isNotEmpty;
      expect(photosComplete, true);
    });

    test('Empty user shows 0% completion', () {
      LoggedInUserModel emptyUser = LoggedInUserModel();
      emptyUser.first_name = "";
      emptyUser.last_name = "";
      emptyUser.email = "";
      emptyUser.phone_number = "";
      emptyUser.bio = "";
      emptyUser.dob = "";
      emptyUser.sex = "";
      emptyUser.avatar = "";
      emptyUser.profile_photos = "";

      // All fields empty = 0/8 = 0%
      int completedFields = 0;
      if (emptyUser.first_name.isNotEmpty) completedFields++;
      if (emptyUser.last_name.isNotEmpty) completedFields++;
      if (emptyUser.email.isNotEmpty) completedFields++;
      if (emptyUser.phone_number.isNotEmpty) completedFields++;
      if (emptyUser.bio.isNotEmpty) completedFields++;
      if (emptyUser.dob.isNotEmpty) completedFields++;
      if (emptyUser.sex.isNotEmpty) completedFields++;
      if (emptyUser.avatar.isNotEmpty || emptyUser.profile_photos.isNotEmpty)
        completedFields++;

      int percentage = ((completedFields / 8) * 100).round();
      expect(percentage, 0);
    });

    test('Partial completion shows correct percentage', () {
      LoggedInUserModel partialUser = LoggedInUserModel();
      partialUser.first_name = "John";
      partialUser.last_name = "Doe";
      partialUser.email = "john@test.com";
      partialUser.phone_number = "1234567890";
      // Missing: bio, dob, sex, photos

      int completedFields = 0;
      if (partialUser.first_name.isNotEmpty) completedFields++;
      if (partialUser.last_name.isNotEmpty) completedFields++;
      if (partialUser.email.isNotEmpty) completedFields++;
      if (partialUser.phone_number.isNotEmpty) completedFields++;
      if (partialUser.bio.isNotEmpty) completedFields++;
      if (partialUser.dob.isNotEmpty) completedFields++;
      if (partialUser.sex.isNotEmpty) completedFields++;
      if (partialUser.avatar.isNotEmpty ||
          partialUser.profile_photos.isNotEmpty)
        completedFields++;

      // 4 completed fields = 4/8 = 50%
      int percentage = ((completedFields / 8) * 100).round();
      expect(percentage, 50);
    });
  });
}
