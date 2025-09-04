import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart' as gt;
import 'package:image_picker/image_picker.dart';

import '../../models/LoggedInUserModel.dart';
import '../../models/RespondModel.dart';
import '../../src/features/app_introduction/view/onboarding_screens.dart';
import '../../screens/shop/screens/shop/full_app/full_app.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/Utilities.dart';

class ProfileSetupWizardScreen extends StatefulWidget {
  final LoggedInUserModel user;
  final bool isEditing;

  const ProfileSetupWizardScreen({
    Key? key,
    required this.user,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<ProfileSetupWizardScreen> createState() =>
      _ProfileSetupWizardScreenState();
}

class _ProfileSetupWizardScreenState extends State<ProfileSetupWizardScreen> {
  // Form keys with unique stable identity
  late final List<GlobalKey<FormBuilderState>> _formKeys;

  int _currentStep = 0;
  bool _isSaving = false;
  String _error = "";
  File? _pickedImage;
  late LoggedInUserModel _user; // Step titles for progress indicator
  final List<String> _stepTitles = [
    'Basic Info',
    'Photos',
    'Physical',
    'Lifestyle',
    'Goals',
    'Interests',
    'Preferences',
  ];

  // Enhanced safe dropdown value validation with comprehensive logging
  String? _safeDropdownValue(String? currentValue, List<String> validOptions) {
    if (currentValue == null || currentValue.isEmpty) {
      debugPrint('📝 Dropdown: Empty/null value provided, returning null');
      return null;
    }

    final isValid = validOptions.contains(currentValue);
    if (!isValid) {
      debugPrint(
        '⚠️  Dropdown: Invalid value "$currentValue" not in options: ${validOptions.join(", ")}',
      );
      debugPrint('🔧 Dropdown: Setting to null to prevent crashes');
      return null;
    }

    debugPrint('✅ Dropdown: Valid value "$currentValue" found in options');
    return currentValue;
  }

  // Safe integer dropdown value validation
  int? _safeIntDropdownValue(String? currentValue, List<int> validOptions) {
    if (currentValue == null || currentValue.isEmpty) {
      debugPrint('📝 Int Dropdown: Empty/null value provided, returning null');
      return null;
    }

    final intValue = int.tryParse(currentValue);
    if (intValue == null) {
      debugPrint(
        '⚠️  Int Dropdown: Cannot parse "$currentValue" to int, returning null',
      );
      return null;
    }

    final isValid = validOptions.contains(intValue);
    if (!isValid) {
      debugPrint(
        '⚠️  Int Dropdown: Invalid value $intValue not in options: ${validOptions.join(", ")}',
      );
      debugPrint('🔧 Int Dropdown: Setting to null to prevent crashes');
      return null;
    }

    debugPrint('✅ Int Dropdown: Valid value $intValue found in options');
    return intValue;
  }

  // Custom age range validator
  String? _validateAgeRange(dynamic value) {
    if (value == null) return 'Age range is required';

    final formValues = _formKeys[4].currentState?.value;
    if (formValues != null) {
      final minAge = formValues['age_range_min'];
      final maxAge = formValues['age_range_max'];

      if (minAge != null && maxAge != null && minAge >= maxAge) {
        return 'Min age must be less than max age';
      }
    }
    return null;
  }

  // Predefined dropdown options for consistency
  final List<String> _bodyTypes = [
    'Slim',
    'Average',
    'Athletic',
    'Curvy',
    'Plus Size',
  ];
  final List<String> _educationLevels = [
    'High School',
    'Associate Degree',
    'Bachelor Degree',
    'Master Degree',
    'PhD',
    'Trade School',
    'Other',
  ];
  final List<String> _religions = [
    'Christianity',
    'Islam',
    'Hinduism',
    'Buddhism',
    'Judaism',
    'Atheism',
    'Agnostic',
    'Spiritual',
    'Other',
    'Prefer not to say',
  ];
  final List<String> _smokingHabits = [
    'Never',
    'Rarely',
    'Sometimes',
    'Regularly',
  ];
  final List<String> _drinkingHabits = [
    'Never',
    'Rarely',
    'Socially',
    'Regularly',
  ];
  final List<String> _petPreferences = [
    'Love pets',
    'Like pets',
    'Allergic to pets',
    'No pets',
    'Prefer not to say',
  ];
  final List<String> _politicalViews = [
    'Liberal',
    'Moderate',
    'Conservative',
    'Other',
    'Prefer not to say',
  ];
  final List<String> _familyPlans = [
    'Want children',
    'Have children',
    'Don\'t want children',
    'Open to children',
    'Prefer not to say',
  ];
  final List<String> _sexualOrientations = [
    'Straight',
    'Gay',
    'Lesbian',
    'Bisexual',
    'Pansexual',
    'Asexual',
    'Other',
  ];
  final List<String> _lookingFor = [
    'Long-term relationship',
    'Short-term relationship',
    'Friendship',
    'Casual dating',
    'Not sure',
  ];
  final List<String> _interestedIn = ['Men', 'Women', 'Everyone'];

  // Enhanced language options with flags/emojis for better UX
  final List<Map<String, String>> _languageOptions = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italian', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Portuguese', 'flag': '🇵🇹'},
    {'code': 'ru', 'name': 'Russian', 'flag': '🇷🇺'},
    {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': 'Korean', 'flag': '🇰🇷'},
    {'code': 'ar', 'name': 'Arabic', 'flag': '🇸🇦'},
    {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳'},
    {'code': 'sw', 'name': 'Swahili', 'flag': '🇰🇪'},
    {'code': 'am', 'name': 'Amharic', 'flag': '🇪🇹'},
    {'code': 'wo', 'name': 'Wolof', 'flag': '🇸🇳'},
    {'code': 'yo', 'name': 'Yoruba', 'flag': '🇳🇬'},
    {'code': 'ig', 'name': 'Igbo', 'flag': '🇳🇬'},
    {'code': 'ha', 'name': 'Hausa', 'flag': '🇳🇬'},
    {'code': 'zu', 'name': 'Zulu', 'flag': '🇿🇦'},
    {'code': 'xh', 'name': 'Xhosa', 'flag': '🇿🇦'},
  ];

  @override
  @override
  void initState() {
    super.initState();
    _formKeys = List.generate(7, (index) => GlobalKey<FormBuilderState>());

    // Initialize with passed user data first, then load fresh data
    _user = LoggedInUserModel.fromJson(widget.user.toJson());

    // Load fresh data from storage in the background
    _initializeUserData();
  }

  // Initialize user data by fetching fresh data from local storage
  Future<void> _initializeUserData() async {
    try {
      debugPrint('🔄 Fetching fresh user data from local storage...');

      // Get the latest user data from local storage
      LoggedInUserModel freshUser = await LoggedInUserModel.getLoggedInUser();

      if (freshUser.id > 0) {
        debugPrint(
          '✅ Fresh user data loaded from storage with ID: ${freshUser.id}',
        );

        // Update the widget.user with fresh data from storage
        widget.user.id = freshUser.id;
        widget.user.first_name = freshUser.first_name;
        widget.user.last_name = freshUser.last_name;
        widget.user.email = freshUser.email;
        widget.user.username = freshUser.username;
        widget.user.name = freshUser.name;
        widget.user.avatar = freshUser.avatar;
        // Note: token is managed separately in SharedPreferences now
        widget.user.dob = freshUser.dob;
        widget.user.sex = freshUser.sex;
        widget.user.phone_number = freshUser.phone_number;
        widget.user.bio = freshUser.bio;
        widget.user.city = freshUser.city;
        widget.user.state = freshUser.state;
        widget.user.country = freshUser.country;
        widget.user.height_cm = freshUser.height_cm;
        widget.user.body_type = freshUser.body_type;
        widget.user.smoking_habit = freshUser.smoking_habit;
        widget.user.drinking_habit = freshUser.drinking_habit;
        widget.user.sexual_orientation = freshUser.sexual_orientation;
        widget.user.occupation = freshUser.occupation;
        widget.user.education_level = freshUser.education_level;
        widget.user.religion = freshUser.religion;
        widget.user.looking_for = freshUser.looking_for;
        widget.user.interested_in = freshUser.interested_in;
        widget.user.age_range_min = freshUser.age_range_min;
        widget.user.age_range_max = freshUser.age_range_max;
        widget.user.languages_spoken = freshUser.languages_spoken;
        widget.user.family_plans = freshUser.family_plans;
        widget.user.max_distance_km = freshUser.max_distance_km;
        widget.user.pet_preference = freshUser.pet_preference;
        widget.user.political_views = freshUser.political_views;
        widget.user.interests_json = freshUser.interests_json;

        // Update internal working copy with fresh data
        _user = LoggedInUserModel.fromJson(widget.user.toJson());

        // Trigger UI update to reflect the fresh data
        if (mounted) {
          setState(() {
            debugPrint('🔄 UI updated with fresh user data');
          });
        }
      } else {
        debugPrint(
          '⚠️ No valid user found in local storage, using passed user data',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading fresh user data: ${e.toString()}');
      Utils.toast(
        'Failed to load latest profile data',
        color: Colors.orange.shade700,
      );
    }
  }

  @override
  void dispose() {
    // No PageController to dispose
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      if (_validateCurrentStep()) {
        if (mounted) {
          setState(() {
            _currentStep++;
          });
        }
      }
    } else {
      _saveProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      if (mounted) {
        setState(() {
          _currentStep--;
        });
      }
    }
  }

  bool _validateCurrentStep() {
    final currentFormKey = _formKeys[_currentStep];
    if (currentFormKey.currentState != null) {
      return currentFormKey.currentState!.validate();
    }
    return true;
  }

  void _saveCurrentStep() {
    final currentFormKey = _formKeys[_currentStep];
    if (currentFormKey.currentState != null) {
      currentFormKey.currentState!.save();
      final values = currentFormKey.currentState!.value;

      // Update user model with current step values
      _updateUserFromFormValues(values);
    }
  }

  void _updateUserFromFormValues(Map<String, dynamic> values) {
    values.forEach((key, value) {
      if (value != null) {
        switch (key) {
          case 'first_name':
            _user.first_name = value.toString();
            break;
          case 'last_name':
            _user.last_name = value.toString();
            break;
          case 'email':
            _user.email = value.toString();
            break;
          case 'dob':
            _user.dob =
                value is DateTime
                    ? value.toIso8601String().split('T')[0]
                    : value.toString();
            break;
          case 'sex':
            _user.sex = value.toString();
            break;
          case 'phone_number':
            _user.phone_number = value.toString();
            break;
          case 'city':
            _user.city = value.toString();
            break;
          case 'height_cm':
            _user.height_cm = value.toString();
            break;
          case 'body_type':
            _user.body_type = value.toString();
            break;
          case 'smoking_habit':
            _user.smoking_habit = value.toString();
            break;
          case 'drinking_habit':
            _user.drinking_habit = value.toString();
            break;
          case 'sexual_orientation':
            _user.sexual_orientation = value.toString();
            break;
          case 'bio':
            _user.bio = value.toString();
            break;
          case 'occupation':
            _user.occupation = value.toString();
            break;
          case 'education_level':
            _user.education_level = value.toString();
            break;
          case 'religion':
            _user.religion = value.toString();
            break;
          case 'looking_for':
            _user.looking_for = value.toString();
            break;
          case 'interested_in':
            _user.interested_in = value.toString();
            break;
          case 'age_range_min':
            _user.age_range_min = value.toString();
            break;
          case 'age_range_max':
            _user.age_range_max = value.toString();
            break;
          case 'languages_spoken':
            _user.languages_spoken = value.toString();
            break;
          case 'family_plans':
            _user.family_plans = value.toString();
            break;
          case 'political_views':
            _user.political_views = value.toString();
            break;
          case 'pet_preference':
            _user.pet_preference = value.toString();
            break;
          case 'max_distance_km':
            _user.max_distance_km = value.toString();
            break;
          case 'interests':
            // Store as JSON array string for future flexibility
            if (value is String) {
              // If already comma separated convert to JSON array
              final parts =
                  value
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
              _user.interests_json =
                  parts.isEmpty ? '[]' : '["' + parts.join('","') + '"]';
            } else if (value is List) {
              _user.interests_json =
                  '["' + value.map((e) => e.toString()).join('","') + '"]';
            }
            break;
          case 'languages_spoken_structured':
            if (value is List && value.isNotEmpty) {
              _user.languages_spoken = value.join(', ');
            }
            break;
          case 'languages_custom':
            if (value != null && value.toString().isNotEmpty) {
              final customLangs =
                  value
                      .toString()
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
              final existingLangs =
                  _user.languages_spoken
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toSet();
              existingLangs.addAll(customLangs);
              _user.languages_spoken = existingLangs.join(', ');
            }
            break;
        }
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Utils.toast('Error picking image: $e', color: Colors.red.shade700);
    }
  }

  // Safely update user object with server response data
  void _updateUserWithServerResponse(LoggedInUserModel serverUser) {
    // Core profile fields
    widget.user.id = serverUser.id;
    widget.user.first_name = serverUser.first_name;
    widget.user.last_name = serverUser.last_name;
    widget.user.email = serverUser.email;
    widget.user.username = serverUser.username;
    widget.user.name = serverUser.name;
    widget.user.avatar = serverUser.avatar;
    // Note: token is managed separately in SharedPreferences - don't update from server response
    widget.user.created_at = serverUser.created_at;
    widget.user.updated_at = serverUser.updated_at;

    // Personal details
    widget.user.dob = serverUser.dob;
    widget.user.sex = serverUser.sex;
    widget.user.phone_number = serverUser.phone_number;
    widget.user.phone_number_2 = serverUser.phone_number_2;
    widget.user.address = serverUser.address;
    widget.user.bio = serverUser.bio;
    widget.user.tagline = serverUser.tagline;

    // Location
    widget.user.city = serverUser.city;
    widget.user.state = serverUser.state;
    widget.user.country = serverUser.country;
    widget.user.latitude = serverUser.latitude;
    widget.user.longitude = serverUser.longitude;

    // Physical attributes
    widget.user.height_cm = serverUser.height_cm;
    widget.user.body_type = serverUser.body_type;

    // Lifestyle
    widget.user.smoking_habit = serverUser.smoking_habit;
    widget.user.drinking_habit = serverUser.drinking_habit;
    widget.user.sexual_orientation = serverUser.sexual_orientation;
    widget.user.occupation = serverUser.occupation;
    widget.user.education_level = serverUser.education_level;
    widget.user.religion = serverUser.religion;

    // Dating preferences
    widget.user.looking_for = serverUser.looking_for;
    widget.user.interested_in = serverUser.interested_in;
    widget.user.age_range_min = serverUser.age_range_min;
    widget.user.age_range_max = serverUser.age_range_max;
    widget.user.languages_spoken = serverUser.languages_spoken;
    widget.user.family_plans = serverUser.family_plans;
    widget.user.max_distance_km = serverUser.max_distance_km;
    widget.user.pet_preference = serverUser.pet_preference;
    widget.user.political_views = serverUser.political_views;
    widget.user.interests_json = serverUser.interests_json;

    // Status and verification fields
    widget.user.status = serverUser.status;
    widget.user.isVerified = serverUser.isVerified;
    widget.user.isOnline = serverUser.isOnline;
    widget.user.last_online_at = serverUser.last_online_at;
    widget.user.online_status = serverUser.online_status;

    // Profile completeness and engagement
    widget.user.completed_profile_pct = serverUser.completed_profile_pct;
    widget.user.profile_views = serverUser.profile_views;
    widget.user.likes_received = serverUser.likes_received;
    widget.user.matches_count = serverUser.matches_count;

    // Update internal user copy as well
    _user = LoggedInUserModel.fromJson(widget.user.toJson());

    debugPrint(
      '✅ Local user data updated successfully with ID: ${widget.user.id}',
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _error = "";
    });

    try {
      // Save current step data
      _saveCurrentStep();

      // Prepare form data for saving
      var data = _user.toJson();

      // Add image handling if needed
      if (_pickedImage != null) {
        if (_pickedImage!.path.length > 3) {
          data['avatar'] = await MultipartFile.fromFile(
            _pickedImage!.path,
            filename: _pickedImage!.path,
          );
        }
      }

      // Normalize newly added structured fields before send
      if (_user.interests_json.isNotEmpty) {
        data['interests_json'] = _user.interests_json;
      }
      if (_user.family_plans.isNotEmpty)
        data['family_plans'] = _user.family_plans;
      if (_user.max_distance_km.isNotEmpty)
        data['max_distance_km'] = _user.max_distance_km;
      if (_user.pet_preference.isNotEmpty)
        data['pet_preference'] = _user.pet_preference;

      final resp = RespondModel(
        await Utils.http_post('profile-wizard-save', data),
      );
      setState(() {
        _isSaving = false;
      });

      if (resp.code != 1) {
        setState(() {
          _error =
              resp.message.isNotEmpty
                  ? resp.message
                  : 'Failed to save profile. Please try again.';
          _isSaving = false;
        });
        Utils.toast('Error: ${resp.message}', color: Colors.red.shade700);
        return;
      }

      // Check if response contains valid updated profile data
      if (resp.data == null || resp.data is! Map<String, dynamic>) {
        setState(() {
          _error = 'Invalid response from server. Please try again.';
          _isSaving = false;
        });
        Utils.toast('Failed to save profile', color: Colors.red.shade700);
        return;
      }

      LoggedInUserModel updatedUser = LoggedInUserModel.fromJson(resp.data);
      if (updatedUser.id < 1) {
        setState(() {
          _error = 'Invalid user ID from server. Please try again.';
          _isSaving = false;
        });
        Utils.toast('Failed to save profile', color: Colors.red.shade700);
        return;
      }

      try {
        updatedUser.save();
      } catch (e) {
        Utils.toast(
          'Failed to save profile locally: ${e.toString()}',
          color: Colors.orange.shade700,
        );
        return;
      }

      _updateUserWithServerResponse(updatedUser);

      // Save the updated user data to local storage
      bool saveSuccess = await widget.user.save();
      if (!saveSuccess) {
        Utils.toast(
          'Profile saved on server but failed to save locally. Please restart the app.',
          color: Colors.orange.shade700,
        );
      }

      // Clear any previous errors on success
      setState(() {
        _error = "";
        _isSaving = false;
      });

      Utils.toast(resp.message, color: Colors.green.shade700);

      debugPrint('🎉 Profile update completed successfully');
      debugPrint('📊 Updated user ID: ${widget.user.id}');
      debugPrint('📧 Email: ${widget.user.email}');
      debugPrint('👤 Name: ${widget.user.first_name} ${widget.user.last_name}');

      // Add a delay to show the success message and let the UI update
      await Future.delayed(Duration(milliseconds: 800));

      // Return the updated user data so the calling screen can refresh
      // Navigator.pop(context, widget.user);
      gt.Get.offAll(() => const OnBoardingScreen());
    } catch (e) {
      setState(() {
        _error = 'Network error: ${e.toString()}';
        _isSaving = false;
      });
      Utils.toast(
        'Failed to save profile. Please check your connection and try again.',
        color: Colors.red.shade700,
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: CustomTheme.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CustomTheme.color2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CustomTheme.primary, width: 2),
      ),
      filled: true,
      fillColor: CustomTheme.card,
      labelStyle: TextStyle(color: CustomTheme.color),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _stepTitles.length,
            backgroundColor: CustomTheme.color2,
            valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
          ),
          SizedBox(height: 12),

          // Step indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_stepTitles.length, (index) {
              bool isActive = index <= _currentStep;
              bool isCurrent = index == _currentStep;

              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isActive ? CustomTheme.primary : CustomTheme.color2,
                      border:
                          isCurrent
                              ? Border.all(color: CustomTheme.accent, width: 2)
                              : null,
                    ),
                    child: Icon(
                      isActive ? Icons.check : Icons.circle,
                      color: isActive ? CustomTheme.accent : CustomTheme.color,
                      size: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _stepTitles[index],
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isActive ? CustomTheme.primary : CustomTheme.color2,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 8),

          // Step counter
          FxText.bodySmall(
            'Step ${_currentStep + 1} of ${_stepTitles.length}',
            color: CustomTheme.color,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        title: FxText.titleLarge(
          widget.isEditing ? 'Edit Profile' : 'Set Up Your Profile',
          color: CustomTheme.accent,
        ),
        centerTitle: true,
        backgroundColor: CustomTheme.background,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomTheme.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),

          if (_error.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Expanded(child: FxText.bodyMedium(_error, color: Colors.red)),
                  IconButton(
                    onPressed: () => setState(() => _error = ""),
                    icon: Icon(Icons.close, color: Colors.red, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Container(
              key: ValueKey('pageview_container'),
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildBasicInfoStep(),
                  _buildPhotosStep(),
                  _buildPhysicalAttributesStep(),
                  _buildLifestyleStep(),
                  _buildRelationshipGoalsStep(),
                  _buildInterestsStep(),
                  _buildPreferencesStep(),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: FxButton(
                      onPressed: _isSaving ? null : _previousStep,
                      backgroundColor: CustomTheme.color2,
                      child: FxText.titleMedium(
                        'Previous',
                        color: CustomTheme.color,
                        fontWeight: 600,
                      ),
                    ),
                  ),

                if (_currentStep > 0) SizedBox(width: 12),

                Expanded(
                  flex: _currentStep == 0 ? 1 : 1,
                  child: FxButton(
                    onPressed: _isSaving ? null : _nextStep,
                    backgroundColor: CustomTheme.primary,
                    child:
                        _isSaving
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: CustomTheme.accent,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                FxText.titleMedium(
                                  'Saving...',
                                  color: CustomTheme.accent,
                                  fontWeight: 600,
                                ),
                              ],
                            )
                            : FxText.titleMedium(
                              _currentStep == _stepTitles.length - 1
                                  ? 'Complete Profile'
                                  : 'Next',
                              color: CustomTheme.accent,
                              fontWeight: 600,
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: FormBuilder(
        key: _formKeys[0],
        onChanged: () => _saveCurrentStep(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxText.titleLarge(
              'Basic Information',
              color: CustomTheme.accent,
              fontWeight: 700,
            ),
            SizedBox(height: 8),
            FxText.bodyMedium(
              'Let\'s start with the basics. This information helps others get to know you.',
              color: CustomTheme.color,
            ),
            SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'first_name',
                    initialValue: _user.first_name,
                    decoration: _inputDecoration('First Name', Icons.person),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(2),
                    ]),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'last_name',
                    initialValue: _user.last_name,
                    decoration: _inputDecoration('Last Name', Icons.person),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(2),
                    ]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            FormBuilderTextField(
              name: 'email',
              initialValue: _user.email,
              decoration: _inputDecoration('Email', Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
            ),
            SizedBox(height: 16),

            FormBuilderDateTimePicker(
              name: 'dob',
              initialValue: DateTime.tryParse(
                _user.dob.isNotEmpty ? _user.dob : '2000-01-01',
              ),
              decoration: _inputDecoration('Date of Birth', Icons.cake),
              inputType: InputType.date,
              lastDate: DateTime.now().subtract(
                Duration(days: 18 * 365),
              ), // Must be 18+
              firstDate: DateTime(1940),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            SizedBox(height: 16),

            FxText.bodyLarge(
              'Gender',
              color: CustomTheme.accent,
              fontWeight: 600,
            ),
            SizedBox(height: 8),
            FormBuilderRadioGroup<String>(
              name: 'sex',
              initialValue: _user.sex.isNotEmpty ? _user.sex : null,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: FormBuilderValidators.required(),
              options:
                  ['Male', 'Female', 'Non-binary', 'Other']
                      .map(
                        (gender) => FormBuilderFieldOption(
                          value: gender,
                          child: Text(
                            gender,
                            style: TextStyle(color: CustomTheme.color),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 16),

            FormBuilderTextField(
              name: 'phone_number',
              initialValue: _user.phone_number,
              decoration: _inputDecoration('Phone Number', Icons.phone),
              keyboardType: TextInputType.phone,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            SizedBox(height: 16),

            FormBuilderTextField(
              name: 'city',
              initialValue: _user.city,
              decoration: _inputDecoration('City', Icons.location_city),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleLarge(
            'Add Your Photos',
            color: CustomTheme.accent,
            fontWeight: 700,
          ),
          SizedBox(height: 8),
          FxText.bodyMedium(
            'Great photos help you make a strong first impression. Add at least one photo to continue.',
            color: CustomTheme.color,
          ),
          SizedBox(height: 24),

          // Main profile photo
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomTheme.card,
                      border: Border.all(color: CustomTheme.primary, width: 3),
                    ),
                    child: ClipOval(
                      child:
                          _pickedImage != null
                              ? Image.file(_pickedImage!, fit: BoxFit.cover)
                              : _user.avatar.isNotEmpty
                              ? Image.network(
                                Utils.getImageUrl(_user.avatar),
                                fit: BoxFit.cover,
                              )
                              : Icon(
                                Icons.add_a_photo,
                                size: 60,
                                color: CustomTheme.color2,
                              ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CustomTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 24,
                      color: CustomTheme.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Photo tips
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CustomTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CustomTheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: CustomTheme.primary, size: 20),
                    SizedBox(width: 8),
                    FxText.bodyLarge(
                      'Photo Tips',
                      color: CustomTheme.primary,
                      fontWeight: 600,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                FxText.bodySmall(
                  '• Use recent photos that clearly show your face\n'
                  '• Natural lighting works best\n'
                  '• Smile and show your personality\n'
                  '• Avoid group photos as your main picture',
                  color: CustomTheme.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalAttributesStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: FormBuilder(
        key: _formKeys[2],
        onChanged: () => _saveCurrentStep(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxText.titleLarge(
              'Physical Attributes',
              color: CustomTheme.accent,
              fontWeight: 700,
            ),
            SizedBox(height: 8),
            FxText.bodyMedium(
              'Share some physical details to help others get a better picture of you.',
              color: CustomTheme.color,
            ),
            SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'height_cm',
                    initialValue: _user.height_cm,
                    decoration: _inputDecoration('Height (cm)', Icons.height),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.min(100),
                      FormBuilderValidators.max(250),
                    ]),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FormBuilderDropdown<String>(
                    name: 'body_type',
                    initialValue: _safeDropdownValue(
                      _user.body_type,
                      _bodyTypes,
                    ),
                    decoration: _inputDecoration(
                      'Body Type',
                      Icons.accessibility,
                    ),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.required(),
                    items:
                        _bodyTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: TextStyle(color: CustomTheme.color),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            FxText.bodyLarge(
              'Sexual Orientation',
              color: CustomTheme.accent,
              fontWeight: 600,
            ),
            SizedBox(height: 8),
            FormBuilderRadioGroup<String>(
              name: 'sexual_orientation',
              initialValue: _safeDropdownValue(
                _user.sexual_orientation,
                _sexualOrientations,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: FormBuilderValidators.required(),
              options:
                  _sexualOrientations
                      .map(
                        (orientation) => FormBuilderFieldOption(
                          value: orientation,
                          child: Text(
                            orientation,
                            style: TextStyle(color: CustomTheme.color),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: FormBuilder(
        key: _formKeys[3],
        onChanged: () => _saveCurrentStep(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxText.titleLarge(
              'Lifestyle Preferences',
              color: CustomTheme.accent,
              fontWeight: 700,
            ),
            SizedBox(height: 8),
            FxText.bodyMedium(
              'Tell us about your lifestyle choices and preferences.',
              color: CustomTheme.color,
            ),
            SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: FormBuilderDropdown<String>(
                    name: 'smoking_habit',
                    initialValue: _safeDropdownValue(
                      _user.smoking_habit,
                      _smokingHabits,
                    ),
                    decoration: _inputDecoration(
                      'Smoking',
                      Icons.smoking_rooms,
                    ),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.required(),
                    items:
                        _smokingHabits
                            .map(
                              (habit) => DropdownMenuItem(
                                value: habit,
                                child: Text(
                                  habit,
                                  style: TextStyle(color: CustomTheme.color),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FormBuilderDropdown<String>(
                    name: 'drinking_habit',
                    initialValue: _safeDropdownValue(
                      _user.drinking_habit,
                      _drinkingHabits,
                    ),
                    decoration: _inputDecoration('Drinking', Icons.local_bar),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.required(),
                    items:
                        _drinkingHabits
                            .map(
                              (habit) => DropdownMenuItem(
                                value: habit,
                                child: Text(
                                  habit,
                                  style: TextStyle(color: CustomTheme.color),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Add pet preference field
            FormBuilderDropdown<String>(
              name: 'pet_preference',
              initialValue: _safeDropdownValue(
                _user.pet_preference,
                _petPreferences,
              ),
              decoration: _inputDecoration('Pet Preference', Icons.pets),
              dropdownColor: CustomTheme.card,
              items:
                  _petPreferences
                      .map(
                        (pref) => DropdownMenuItem(
                          value: pref,
                          child: Text(
                            pref,
                            style: TextStyle(color: CustomTheme.color),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'occupation',
                    initialValue: _user.occupation,
                    decoration: _inputDecoration('Occupation', Icons.work),
                    validator: FormBuilderValidators.required(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FormBuilderDropdown<String>(
                    name: 'education_level',
                    initialValue: _safeDropdownValue(
                      _user.education_level,
                      _educationLevels,
                    ),
                    decoration: _inputDecoration('Education', Icons.school),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.required(),
                    items:
                        _educationLevels
                            .map(
                              (level) => DropdownMenuItem(
                                value: level,
                                child: Text(
                                  level,
                                  style: TextStyle(color: CustomTheme.color),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            FormBuilderDropdown<String>(
              name: 'religion',
              initialValue: _safeDropdownValue(_user.religion, _religions),
              decoration: _inputDecoration(
                'Religion/Spirituality',
                Icons.favorite,
              ),
              dropdownColor: CustomTheme.card,
              items:
                  _religions
                      .map(
                        (religion) => DropdownMenuItem(
                          value: religion,
                          child: Text(
                            religion,
                            style: TextStyle(color: CustomTheme.color),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 16),

            // Enhanced Language Selection with Multi-Select
            FxText.bodyLarge(
              'Languages Spoken',
              color: CustomTheme.accent,
              fontWeight: 600,
            ),
            SizedBox(height: 8),
            FxText.bodySmall(
              'Select all languages you can communicate in',
              color: CustomTheme.color.withValues(alpha: 0.7),
            ),
            SizedBox(height: 12),

            FormBuilderCheckboxGroup<String>(
              name: 'languages_spoken_structured',
              initialValue:
                  _user.languages_spoken
                      .split(',')
                      .map((lang) => lang.trim())
                      .where((lang) => lang.isNotEmpty)
                      .where(
                        (lang) =>
                            _languageOptions.any((opt) => opt['name'] == lang),
                      )
                      .toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: CustomTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: CustomTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CustomTheme.primary, width: 2),
                ),
                filled: true,
                fillColor: CustomTheme.card,
                contentPadding: EdgeInsets.all(16),
              ),
              options:
                  _languageOptions
                      .map(
                        (lang) => FormBuilderFieldOption(
                          value: lang['name']!,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  lang['flag']!,
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    lang['name']!,
                                    style: TextStyle(
                                      color: CustomTheme.color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
              checkColor: CustomTheme.accent,
              activeColor: CustomTheme.primary,
              controlAffinity: ControlAffinity.leading,
              wrapSpacing: 8,
              wrapRunSpacing: 4,
              separator: SizedBox(height: 8),
            ),

            SizedBox(height: 16),

            // Fallback text field for custom languages not in the list
            FormBuilderTextField(
              name: 'languages_custom',
              decoration: InputDecoration(
                labelText: 'Other Languages (comma-separated)',
                hintText: 'e.g., Mandarin, Swahili, Tamil',
                prefixIcon: Icon(Icons.translate, color: CustomTheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: CustomTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: CustomTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CustomTheme.primary, width: 2),
                ),
                filled: true,
                fillColor: CustomTheme.card,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                labelStyle: TextStyle(
                  color: CustomTheme.color.withValues(alpha: 0.7),
                ),
                hintStyle: TextStyle(
                  color: CustomTheme.color.withValues(alpha: 0.5),
                ),
              ),
              style: TextStyle(color: CustomTheme.color),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipGoalsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: FormBuilder(
        key: _formKeys[4],
        onChanged: () => _saveCurrentStep(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxText.titleLarge(
              'Relationship Goals',
              color: CustomTheme.accent,
              fontWeight: 700,
            ),
            SizedBox(height: 8),
            FxText.bodyMedium(
              'Let others know what you\'re looking for and your relationship preferences.',
              color: CustomTheme.color,
            ),
            SizedBox(height: 24),

            FormBuilderDropdown<String>(
              name: 'looking_for',
              initialValue: _safeDropdownValue(_user.looking_for, _lookingFor),
              decoration: _inputDecoration('Looking For', Icons.search_rounded),
              dropdownColor: CustomTheme.card,
              validator: FormBuilderValidators.required(),
              items:
                  _lookingFor
                      .map(
                        (goal) => DropdownMenuItem(
                          value: goal,
                          child: Text(
                            goal,
                            style: TextStyle(color: CustomTheme.color),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 16),

            FormBuilderDropdown<String>(
              name: 'interested_in',
              initialValue: _safeDropdownValue(
                _user.interested_in,
                _interestedIn,
              ),
              decoration: _inputDecoration('Interested In', Icons.people),
              dropdownColor: CustomTheme.card,
              validator: FormBuilderValidators.required(),
              items:
                  _interestedIn
                      .map(
                        (interest) => DropdownMenuItem(
                          value: interest,
                          child: Text(
                            interest,
                            style: TextStyle(color: CustomTheme.color),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 16),

            // Add family plans field
            FormBuilderDropdown<String>(
              name: 'family_plans',
              initialValue: _safeDropdownValue(
                _user.family_plans,
                _familyPlans,
              ),
              decoration: _inputDecoration(
                'Family Plans',
                Icons.family_restroom,
              ),
              dropdownColor: CustomTheme.card,
              items:
                  _familyPlans
                      .map(
                        (plan) => DropdownMenuItem(
                          value: plan,
                          child: Text(
                            plan,
                            style: TextStyle(color: CustomTheme.color),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 16),

            FxText.bodyLarge(
              'Age Range Preference',
              color: CustomTheme.accent,
              fontWeight: 600,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FormBuilderDropdown<int>(
                    name: 'age_range_min',
                    initialValue: _safeIntDropdownValue(
                      _user.age_range_min,
                      List.generate(63, (i) => i + 18), // 18-80 age range
                    ),
                    decoration: _inputDecoration(
                      'Min Age',
                      Icons.calendar_today,
                    ),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      _validateAgeRange,
                    ]),
                    items:
                        List.generate(35, (index) => 18 + index)
                            .map(
                              (age) => DropdownMenuItem(
                                value: age,
                                child: Text(
                                  '$age',
                                  style: TextStyle(color: CustomTheme.color),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FormBuilderDropdown<int>(
                    name: 'age_range_max',
                    initialValue: _safeIntDropdownValue(
                      _user.age_range_max,
                      List.generate(63, (i) => i + 18), // 18-80 age range
                    ),
                    decoration: _inputDecoration(
                      'Max Age',
                      Icons.calendar_today,
                    ),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      _validateAgeRange,
                    ]),
                    items:
                        List.generate(35, (index) => 25 + index)
                            .map(
                              (age) => DropdownMenuItem(
                                value: age,
                                child: Text(
                                  '$age',
                                  style: TextStyle(color: CustomTheme.color),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: FormBuilder(
        key: _formKeys[5],
        onChanged: () => _saveCurrentStep(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxText.titleLarge(
              'About You',
              color: CustomTheme.accent,
              fontWeight: 700,
            ),
            SizedBox(height: 8),
            FxText.bodyMedium(
              'Tell us more about yourself! This helps others connect with you.',
              color: CustomTheme.color,
            ),
            SizedBox(height: 24),

            FormBuilderTextField(
              name: 'bio',
              initialValue: _user.bio,
              decoration: _inputDecoration(
                'About Me',
                Icons.edit_note,
              ).copyWith(
                hintText:
                    'Tell others about yourself, your interests, and what makes you unique...',
              ),
              minLines: 4,
              maxLines: 6,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(50),
              ]),
            ),
            SizedBox(height: 24),

            // Interests section
            FxText.bodyLarge(
              'Your Interests & Hobbies',
              color: CustomTheme.accent,
              fontWeight: 600,
            ),
            SizedBox(height: 8),
            FxText.bodySmall(
              'Select up to 10 interests that describe you best:',
              color: CustomTheme.color,
            ),
            SizedBox(height: 12),

            // Interest tags
            Builder(
              builder: (context) {
                final List<String> availableInterests = [
                  'Travel',
                  'Photography',
                  'Music',
                  'Movies',
                  'Reading',
                  'Cooking',
                  'Fitness',
                  'Hiking',
                  'Swimming',
                  'Dancing',
                  'Art',
                  'Gaming',
                  'Sports',
                  'Yoga',
                  'Shopping',
                  'Fashion',
                  'Technology',
                  'Science',
                  'Nature',
                  'Animals',
                  'Volunteering',
                  'Writing',
                  'Meditation',
                  'Wine Tasting',
                  'Coffee',
                  'Concerts',
                  'Museums',
                  'Theater',
                  'Comedy',
                  'Karaoke',
                  'Board Games',
                  'Puzzles',
                  'Gardening',
                ];

                List<String> selectedInterests =
                    _user.tagline.isNotEmpty
                        ? _user.tagline
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList()
                        : [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          availableInterests.map((interest) {
                            final isSelected = selectedInterests.contains(
                              interest,
                            );
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedInterests.remove(interest);
                                  } else if (selectedInterests.length < 10) {
                                    selectedInterests.add(interest);
                                  } else {
                                    Utils.toast(
                                      'You can select up to 10 interests',
                                      color: Colors.orange,
                                    );
                                    return;
                                  }
                                  _user.tagline = selectedInterests.join(', ');
                                  _formKeys[5].currentState?.patchValue({
                                    'interests': _user.tagline,
                                  });
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? CustomTheme.primary
                                          : CustomTheme.card,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? CustomTheme.primary
                                            : CustomTheme.color2,
                                    width: 1,
                                  ),
                                ),
                                child: FxText.bodySmall(
                                  interest,
                                  color:
                                      isSelected
                                          ? CustomTheme.accent
                                          : CustomTheme.color,
                                  fontWeight: isSelected ? 600 : 400,
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    // Hidden field to store selected interests
                    SizedBox(height: 8),
                    FormBuilderTextField(
                      name: 'interests',
                      initialValue: _user.tagline,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(height: 0, color: Colors.transparent),
                      readOnly: true,
                      maxLines: 1,
                    ),

                    // Selected interests display
                    if (selectedInterests.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CustomTheme.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: CustomTheme.color2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FxText.bodySmall(
                              'Selected Interests (${selectedInterests.length}/10):',
                              color: CustomTheme.color,
                              fontWeight: 600,
                            ),
                            SizedBox(height: 4),
                            FxText.bodySmall(
                              selectedInterests.join(', '),
                              color: CustomTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            SizedBox(height: 16),

            // Profile completion tip
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: CustomTheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      FxText.bodyLarge(
                        'You\'re Almost Done!',
                        color: CustomTheme.primary,
                        fontWeight: 600,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  FxText.bodySmall(
                    'Complete profiles with interests get 3x more meaningful matches. You\'re doing great!',
                    color: CustomTheme.color,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: FormBuilder(
        key: _formKeys[6],
        onChanged: () => _saveCurrentStep(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxText.titleLarge(
              'Dating Preferences',
              color: CustomTheme.primary,
              fontWeight: 700,
            ),
            SizedBox(height: 8),
            FxText.bodyMedium(
              'Help us find your perfect match by setting your preferences.',
              color: CustomTheme.color2,
            ),
            SizedBox(height: 24),

            // Max Distance
            FxText.bodyLarge(
              'Maximum Distance (km)',
              color: CustomTheme.accent,
              fontWeight: 600,
            ),
            SizedBox(height: 8),
            FormBuilderSlider(
              name: 'max_distance_km',
              min: 1,
              max: 100,
              divisions: 99,
              initialValue: double.tryParse(_user.max_distance_km) ?? 25.0,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              valueTransformer: (value) => value?.round().toString(),
              displayValues: DisplayValues.current,
              activeColor: CustomTheme.primary,
              inactiveColor: CustomTheme.color2,
            ),
            SizedBox(height: 24),

            // Political Views
            FormBuilderDropdown<String>(
              name: 'political_views',
              initialValue: _safeDropdownValue(
                _user.political_views,
                _politicalViews,
              ),
              decoration: _inputDecoration(
                'Political Views',
                Icons.how_to_vote,
              ),
              dropdownColor: CustomTheme.card,
              items:
                  _politicalViews
                      .map(
                        (view) => DropdownMenuItem(
                          value: view,
                          child: Text(
                            view,
                            style: TextStyle(color: CustomTheme.color),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 16),

            // Enhanced Bio Section
            FxText.bodyLarge(
              'About You',
              color: CustomTheme.accent,
              fontWeight: 600,
            ),
            SizedBox(height: 8),
            FormBuilderTextField(
              name: 'bio',
              initialValue: _user.bio,
              decoration: _inputDecoration(
                'Tell us about yourself...',
                Icons.edit,
              ),
              maxLines: 4,
              maxLength: 500,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.minLength(
                  20,
                  errorText: 'Bio should be at least 20 characters',
                ),
              ]),
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 24),

            // Profile completeness tip
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: CustomTheme.primary, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: FxText.bodySmall(
                      'Complete profiles with detailed preferences get 5x more quality matches!',
                      color: CustomTheme.primary,
                      fontWeight: 500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
