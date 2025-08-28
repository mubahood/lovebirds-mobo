import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutx/flutx.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/LoggedInUserModel.dart';
import '../../models/RespondModel.dart';
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
  final PageController _pageController = PageController();
  final List<GlobalKey<FormBuilderState>> _formKeys = List.generate(
    6,
    (index) => GlobalKey<FormBuilderState>(),
  );

  int _currentStep = 0;
  bool _isSaving = false;
  String _error = "";
  File? _pickedImage;
  late LoggedInUserModel _user;

  // Step titles for progress indicator
  final List<String> _stepTitles = [
    'Basic Info',
    'Photos',
    'Physical',
    'Lifestyle',
    'Goals',
    'Interests',
  ];

  @override
  void initState() {
    super.initState();
    _user = LoggedInUserModel.fromJson(widget.user.toJson());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _saveProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
            _user.political_views =
                value.toString(); // Repurpose this field for family plans
            break;
          case 'interests':
            _user.tagline =
                value.toString(); // Repurpose this field for interests tags
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

      final resp = RespondModel(await Utils.http_post('User', data));

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

      LoggedInUserModel newUser = LoggedInUserModel.fromJson(resp.data);
      if (newUser.id < 1) {
        setState(() {
          _error = 'Invalid response from server. Please try again.';
          _isSaving = false;
        });
        Utils.toast('Failed to save profile', color: Colors.red.shade700);
        return;
      }

      // Update the widget's user object
      widget.user.id = newUser.id;
      widget.user.first_name = newUser.first_name;
      widget.user.last_name = newUser.last_name;
      widget.user.email = newUser.email;
      widget.user.dob = newUser.dob;
      widget.user.sex = newUser.sex;
      widget.user.phone_number = newUser.phone_number;
      widget.user.city = newUser.city;
      widget.user.height_cm = newUser.height_cm;
      widget.user.body_type = newUser.body_type;
      widget.user.smoking_habit = newUser.smoking_habit;
      widget.user.drinking_habit = newUser.drinking_habit;
      widget.user.sexual_orientation = newUser.sexual_orientation;
      widget.user.bio = newUser.bio;
      widget.user.occupation = newUser.occupation;
      widget.user.education_level = newUser.education_level;
      widget.user.religion = newUser.religion;
      widget.user.looking_for = newUser.looking_for;
      widget.user.interested_in = newUser.interested_in;
      widget.user.age_range_min = newUser.age_range_min;
      widget.user.age_range_max = newUser.age_range_max;
      widget.user.languages_spoken = newUser.languages_spoken;
      widget.user.avatar = newUser.avatar;

      await widget.user.save();

      // Clear any previous errors on success
      setState(() {
        _error = "";
        _isSaving = false;
      });

      Utils.toast(
        'Profile ${widget.isEditing ? 'updated' : 'created'} successfully!',
        color: Colors.green.shade700,
      );

      // Add a small delay to show the success message before navigating
      await Future.delayed(Duration(milliseconds: 500));

      Navigator.pop(context, _user);
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
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // Prevent manual swiping
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBasicInfoStep(),
                _buildPhotosStep(),
                _buildPhysicalAttributesStep(),
                _buildLifestyleStep(),
                _buildRelationshipGoalsStep(),
                _buildInterestsStep(),
              ],
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
                    initialValue:
                        _user.body_type.isNotEmpty ? _user.body_type : null,
                    decoration: _inputDecoration(
                      'Body Type',
                      Icons.accessibility,
                    ),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.required(),
                    items:
                        ['Slim', 'Average', 'Athletic', 'Curvy', 'Plus Size']
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
              initialValue:
                  _user.sexual_orientation.isNotEmpty
                      ? _user.sexual_orientation
                      : null,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: FormBuilderValidators.required(),
              options:
                  [
                        'Straight',
                        'Gay',
                        'Lesbian',
                        'Bisexual',
                        'Pansexual',
                        'Asexual',
                        'Other',
                      ]
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
                    initialValue:
                        _user.smoking_habit.isNotEmpty
                            ? _user.smoking_habit
                            : null,
                    decoration: _inputDecoration(
                      'Smoking',
                      Icons.smoking_rooms,
                    ),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.required(),
                    items:
                        ['Never', 'Occasionally', 'Regular', 'Trying to Quit']
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
                    initialValue:
                        _user.drinking_habit.isNotEmpty
                            ? _user.drinking_habit
                            : null,
                    decoration: _inputDecoration('Drinking', Icons.local_bar),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.required(),
                    items:
                        ['Never', 'Socially', 'Regular', 'Frequently']
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
                    initialValue:
                        _user.education_level.isNotEmpty
                            ? _user.education_level
                            : null,
                    decoration: _inputDecoration('Education', Icons.school),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.required(),
                    items:
                        [
                              'High School',
                              'Associate Degree',
                              'Bachelor Degree',
                              'Master Degree',
                              'PhD',
                              'Trade School',
                              'Other',
                            ]
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
              initialValue: _user.religion.isNotEmpty ? _user.religion : null,
              decoration: _inputDecoration(
                'Religion/Spirituality',
                Icons.favorite,
              ),
              dropdownColor: CustomTheme.card,
              items:
                  [
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
                      ]
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

            FormBuilderTextField(
              name: 'languages_spoken',
              initialValue: _user.languages_spoken,
              decoration: _inputDecoration('Languages Spoken', Icons.language),
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
              initialValue:
                  _user.looking_for.isNotEmpty ? _user.looking_for : null,
              decoration: _inputDecoration('Looking For', Icons.search_rounded),
              dropdownColor: CustomTheme.card,
              validator: FormBuilderValidators.required(),
              items:
                  [
                        'Casual Dating',
                        'Serious Relationship',
                        'Marriage',
                        'Friendship',
                        'Connect & See',
                        'Something Casual',
                        'Long-term Partner',
                      ]
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
              initialValue:
                  _user.interested_in.isNotEmpty ? _user.interested_in : null,
              decoration: _inputDecoration('Interested In', Icons.people),
              dropdownColor: CustomTheme.card,
              validator: FormBuilderValidators.required(),
              items:
                  ['Men', 'Women', 'Everyone', 'Non-binary']
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
                    initialValue:
                        _user.age_range_min.isNotEmpty
                            ? int.tryParse(_user.age_range_min)
                            : null,
                    decoration: _inputDecoration(
                      'Min Age',
                      Icons.calendar_today,
                    ),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.required(),
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
                    initialValue:
                        _user.age_range_max.isNotEmpty
                            ? int.tryParse(_user.age_range_max)
                            : null,
                    decoration: _inputDecoration(
                      'Max Age',
                      Icons.calendar_today,
                    ),
                    dropdownColor: CustomTheme.card,
                    validator: FormBuilderValidators.required(),
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

            FormBuilderDropdown<String>(
              name: 'family_plans',
              initialValue:
                  _user.political_views.isNotEmpty
                      ? _user.political_views
                      : null,
              decoration: _inputDecoration(
                'Family Plans',
                Icons.family_restroom,
              ),
              dropdownColor: CustomTheme.card,
              validator: FormBuilderValidators.required(),
              items:
                  [
                        'Want kids someday',
                        'Want kids soon',
                        'Have kids & want more',
                        'Have kids & done',
                        'Don\'t want kids',
                        'Not sure yet',
                        'Open to discussion',
                      ]
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
          ],
        ),
      ),
    );
  }
}
