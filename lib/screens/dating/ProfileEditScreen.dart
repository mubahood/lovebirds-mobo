import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/LoggedInUserModel.dart';
import '../../models/RespondModel.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/Utilities.dart';
import 'ProfileSetupWizardScreen.dart';

class ProfileEditScreen extends StatefulWidget {
  LoggedInUserModel user;

  ProfileEditScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late LoggedInUserModel _user;
  File? _pickedImage;
  bool _isSaving = false;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  void _openProfileWizard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProfileSetupWizardScreen(user: _user, isEditing: true),
      ),
    );

    if (result != null && result is LoggedInUserModel) {
      setState(() {
        _user = result;
        widget.user = result;
      });
      Utils.toast('Profile updated via wizard!', color: Colors.green.shade700);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: CustomTheme.card,
      prefixIcon: Icon(icon, color: CustomTheme.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CustomTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 24, bottom: 16),
      child: FxText.titleLarge(
        title,
        color: CustomTheme.accent,
        fontWeight: 800,
        letterSpacing: 0.8,
      ),
    );
  }

  Future<void> _saveProfile() async {
    final form = _formKey.currentState!;
    if (!form.saveAndValidate()) {
      Utils.toast('Please fix form errors', color: Colors.red);
      return;
    }

    final formValue = form.value;

    // Required fields validation
    final requiredFields = {
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'sex': 'Gender',
      'email': 'Email',
      'bio': 'Bio',
      'body_type': 'Body Type',
      'occupation': 'Occupation',
    };

    for (final entry in requiredFields.entries) {
      if ((formValue[entry.key] ?? '').toString().isEmpty) {
        Utils.toast('${entry.value} is required', color: Colors.red);
        return;
      }
    }

    //if country is not selected
    if (_user.country.isEmpty) {
      Utils.toast('Country is required', color: Colors.red);
      return;
    }

    // Date of Birth validation
    try {
      DateTime? dob = DateTime.tryParse(formValue['dob']?.toString() ?? '');
      if (dob == null) {
        Utils.toast('Invalid date format', color: Colors.red);
        return;
      }
      final minAgeDate = DateTime.now().subtract(Duration(days: 14 * 365));

      if (dob.isAfter(minAgeDate)) {
        Utils.toast('Must be at least 14 years old', color: Colors.red);
        return;
      }
    } catch (e) {
      Utils.toast(
        'Invalid date format (YYYY-MM-DD required) ${e.toString()}',
        color: Colors.red,
      );
      return;
    }

    // Phone number validation
    final phone = (formValue['phone_number'] ?? '').toString();
    if (!phone.startsWith('+')) {
      Utils.toast(
        'Phone number must start with country code (e.g. +1)',
        color: Colors.red,
      );
      return;
    }

    // Collect all data
    try {
      _user
        ..first_name = formValue['first_name'] ?? ''
        ..last_name = formValue['last_name'] ?? ''
        ..sex = formValue['sex'] ?? ''
        ..email = formValue['email'] ?? ''
        ..bio = formValue['bio'] ?? ''
        ..body_type = formValue['body_type'] ?? ''
        ..occupation = formValue['occupation'] ?? ''
        ..dob = formValue['dob']?.toIso8601String().split('T').first ?? ''
        ..phone_number = formValue['phone_number'] ?? ''
        ..phone_number_2 = formValue['phone_number_2'] ?? ''
        ..address = formValue['address'] ?? ''
        ..city = formValue['city'] ?? ''
        ..sexual_orientation = formValue['sexual_orientation'] ?? ''
        ..height_cm = formValue['height_cm']?.toString() ?? ''
        ..smoking_habit = formValue['smoking_habit'] ?? ''
        ..drinking_habit = formValue['drinking_habit'] ?? ''
        ..religion = formValue['religion'] ?? ''
        ..political_views = formValue['political_views'] ?? ''
        ..languages_spoken = formValue['languages_spoken'] ?? ''
        ..education_level = formValue['education_level'] ?? ''
        ..looking_for = formValue['looking_for'] ?? ''
        ..interested_in = formValue['interested_in'] ?? ''
        ..age_range_min = formValue['age_range_min']?.toString() ?? '18'
        ..age_range_max = formValue['age_range_max']?.toString() ?? '35'
        ..max_distance_km = formValue['max_distance_km']?.toString() ?? '50';
    } catch (e) {}

    // Add image handling if needed
    if (_pickedImage != null) {
      // Implement your image upload logic here
    }

    Map<String, dynamic> data = _user.toJson();

    if (_pickedImage != null) {
      if (_pickedImage!.path.length > 3) {
        data['temp_file_field'] = 'avatar';
        data['photo'] = await MultipartFile.fromFile(
          _pickedImage!.path,
          filename: _pickedImage!.path,
        );
      }
    }
    _error = '';
    setState(() {});

    // TODO: upload avatar if picked

    Utils.showLoader(false);
    final resp = RespondModel(await Utils.http_post('User', data));
    Utils.hideLoader();

    setState(() => _isSaving = false);
    if (resp.code != 1) {
      setState(() => _error = resp.message);
      Utils.toast('Failed to save', color: Colors.red.shade700);
      return;
    }

    LoggedInUserModel newUser = LoggedInUserModel.fromJson(resp.data);
    if (newUser.id < 1) {
      Utils.toast('Failed to save', color: Colors.red.shade700);
      return;
    }

    print(newUser.toJson().toString());

    widget.user = newUser;
    await widget.user.save();

    Utils.toast('Updated account successfully.', color: Colors.green.shade700);
    Navigator.pop(context, _user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        title: FxText.titleLarge('Edit Profile', color: CustomTheme.accent),
        centerTitle: true,
        backgroundColor: CustomTheme.background,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomTheme.accent),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.auto_fix_high, color: CustomTheme.primary),
            onPressed: () => _openProfileWizard(),
            tooltip: 'Setup Wizard',
          ),
          _isSaving
              ? Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: CustomTheme.primary),
              )
              : TextButton(
                onPressed: _saveProfile,
                child: FxText.bodyLarge(
                  'SAVE',
                  color: CustomTheme.primary,
                  fontWeight: 800,
                ),
              ),
        ],
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              if (_error.isNotEmpty)
                FxContainer(
                  color: Colors.red.withValues(alpha: 0.1),
                  padding: EdgeInsets.all(12),
                  child: FxText.bodySmall(_error, color: Colors.red),
                ),

              // Avatar Section
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: CustomTheme.card,
                      backgroundImage:
                          _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : NetworkImage(Utils.getImageUrl(_user.avatar))
                                  as ImageProvider,
                      child:
                          _pickedImage == null && _user.avatar.isEmpty
                              ? Icon(
                                Icons.person,
                                size: 60,
                                color: CustomTheme.color,
                              )
                              : null,
                    ),
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CustomTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 20,
                        color: CustomTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Personal Information
              _buildSectionHeader('Personal Information'),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'first_name',
                      initialValue: _user.first_name,
                      decoration: _inputDecoration('First Name', Icons.person),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'last_name',
                      initialValue: _user.last_name,
                      decoration: _inputDecoration('Last Name', Icons.person),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
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
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'dob',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                initialValue: DateTime.tryParse(_user.dob),
                decoration: _inputDecoration('Date of Birth', Icons.cake),
                inputType: InputType.date,
                lastDate: DateTime.now(),
                firstDate: DateTime(1960),
              ),
              SizedBox(height: 16),
              FormBuilderRadioGroup<String>(
                name: 'sex',
                initialValue: _user.sex,
                decoration: _inputDecoration(
                  'Gender ${_user.sex}',
                  Icons.person_outline,
                ),
                options:
                    ['Male', 'Female', 'Other']
                        .map(
                          (e) =>
                              FormBuilderFieldOption(value: e, child: Text(e)),
                        )
                        .toList(),
              ),

              // Contact Information
              _buildSectionHeader('Contact Information'),
              FormBuilderTextField(
                name: 'phone_number',
                initialValue: _user.phone_number,
                decoration: _inputDecoration('Phone Number', Icons.phone),
                keyboardType: TextInputType.phone,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FxContainer(
                      padding: const EdgeInsets.symmetric(
                        vertical: 1,
                        horizontal: 0,
                      ),
                      border: Border.all(color: CustomTheme.color2, width: 1),
                      bordered: true,
                      margin: const EdgeInsets.only(right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CountryCodePicker(
                            onChanged: (code) {
                              _user.country = code.name!;
                              _user.phone_country_international = code.code!;
                              setState(() {});

                              /*_item.phone_country_code = code.dialCode!;
                              _item.phone_country_international =
                              code.code!;
                              _formKey.currentState!.patchValue({
                                "phone_number":
                                _item.phone_country_code.toString(),
                              });*/
                            },
                            headerText: "Select Country",
                            showFlag: true,
                            showFlagDialog: true,
                            showFlagMain: true,
                            showDropDownButton: true,
                            padding: EdgeInsets.zero,
                            dialogBackgroundColor: Colors.black,
                            backgroundColor: Colors.black,
                            barrierColor: CustomTheme.background.withOpacity(
                              0.5,
                            ),
                            boxDecoration: BoxDecoration(
                              color: CustomTheme.card,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                            initialSelection: _user.phone_country_international,
                            favorite: ['+256', 'UG'],
                            // optional. Shows only country name and flag
                            showCountryOnly: false,
                            // optional. Shows only country name and flag when popup is closed.
                            showOnlyCountryWhenClosed: false,
                            // optional. aligns the flag and the Text left
                            alignLeft: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'city',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      initialValue: _user.city,
                      decoration: _inputDecoration('City', Icons.location_city),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              FormBuilderTextField(
                name: 'address',
                initialValue: _user.address,
                decoration: _inputDecoration('Address', Icons.home),
                keyboardType: TextInputType.streetAddress,
              ),

              // Lifestyle Preferences
              _buildSectionHeader('Lifestyle Preferences'),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderDropdown<String>(
                      name: 'smoking_habit',
                      initialValue:
                          [
                                'Never',
                                'Occasionally',
                                'Regular',
                              ].contains(_user.smoking_habit)
                              ? _user.smoking_habit
                              : null,
                      decoration: _inputDecoration(
                        'Smoking',
                        Icons.smoking_rooms,
                      ),
                      dropdownColor: CustomTheme.card,
                      items:
                          ['Never', 'Occasionally', 'Regular']
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.toString(),
                                  child: Text(e),
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
                          [
                                'Never',
                                'Socially',
                                'Regular',
                              ].contains(_user.drinking_habit)
                              ? _user.drinking_habit
                              : null,
                      dropdownColor: CustomTheme.card,
                      decoration: _inputDecoration('Drinking', Icons.local_bar),
                      items:
                          ['Never', 'Socially', 'Regular']
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.toString(),
                                  child: Text(e),
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
                      name: 'height_cm',
                      initialValue: _user.height_cm,
                      decoration: _inputDecoration('Height (cm)', Icons.height),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderDropdown<String>(
                      name: 'body_type',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      initialValue:
                          [
                                'Slim',
                                'Average',
                                'Athletic',
                                'Curvy',
                              ].contains(_user.body_type)
                              ? _user.body_type
                              : null,
                      dropdownColor: CustomTheme.card,
                      decoration: _inputDecoration(
                        'Body Type',
                        Icons.health_and_safety,
                      ),
                      items:
                          ['Slim', 'Average', 'Athletic', 'Curvy']
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.toString(),
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              FormBuilderRadioGroup<String>(
                name: 'sexual_orientation',
                initialValue: _user.sexual_orientation,
                decoration: _inputDecoration(
                  'Sexual Orientation',
                  Icons.favorite,
                ),
                options:
                    ['Straight', 'Homosexual', 'Bisexual', 'Asexual', 'Other']
                        .map(
                          (e) =>
                              FormBuilderFieldOption(value: e, child: Text(e)),
                        )
                        .toList(),
              ),
              SizedBox(height: 16),
              FormBuilderTextField(
                name: 'bio',
                initialValue: _user.bio,
                minLines: 3,
                maxLines: 5,
                enableSuggestions: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  'About Me (Bio)',
                  Icons.description,
                ),
              ),

              // Additional Details
              _buildSectionHeader('Additional Details'),
              FormBuilderTextField(
                name: 'occupation',
                initialValue: _user.occupation,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                decoration: _inputDecoration('Occupation', Icons.work),
              ),
              SizedBox(height: 16),
              FormBuilderDropdown<String>(
                name: 'education_level',
                initialValue:
                    [
                          'None',
                          'High School',
                          'Associate Degree',
                          'Bachelor Degree',
                          'Master Degree',
                          'PhD',
                          'Postdoctoral',
                        ].contains(_user.education_level.toString())
                        ? _user.education_level.toString()
                        : null,
                dropdownColor: CustomTheme.card,
                decoration: _inputDecoration('Education Level', Icons.school),
                items:
                    [
                          'None',
                          'High School',
                          'Associate Degree',
                          'Bachelor Degree',
                          'Master Degree',
                          'PhD',
                          'Postdoctoral',
                        ]
                        .map(
                          (level) => DropdownMenuItem(
                            value: level.toString(),
                            child: Text(level),
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 16),
              FormBuilderTextField(
                name: 'languages_spoken',
                initialValue: _user.languages_spoken,
                decoration: _inputDecoration(
                  'Languages Spoken',
                  Icons.language,
                ),
              ),
              SizedBox(height: 16),
              FormBuilderDropdown<String>(
                name: 'religion',
                initialValue:
                    [
                          'Christianity',
                          'Islam',
                          'Hinduism',
                          'Buddhism',
                          'Judaism',
                          'Atheism',
                          'Agnostic',
                          'Spiritual',
                          'Sikhism',
                          'Other',
                        ].contains(_user.religion)
                        ? _user.religion
                        : null,
                decoration: _inputDecoration('Religion', Icons.people),
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
                          'Sikhism',
                          'Other',
                        ]
                        .map(
                          (religion) => DropdownMenuItem(
                            value: religion,
                            child: Text(religion),
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 16),
              FormBuilderTextField(
                name: 'political_views',
                initialValue: _user.political_views,
                decoration: _inputDecoration('Political Views', Icons.gavel),
              ),

              // Preferences
              _buildSectionHeader('Relationship Preferences'),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderDropdown<String>(
                      name: 'looking_for',
                      initialValue:
                          [
                                'Relationship',
                                'Connect',
                                'Friendship',
                                'Casual',
                              ].contains(_user.looking_for.toString())
                              ? _user.looking_for.toString()
                              : null,
                      dropdownColor: CustomTheme.card,
                      decoration: _inputDecoration('Looking For', Icons.search),
                      items:
                          [
                                'Relationship',
                                'Connect',
                                'Friendship',
                                'Casual',
                                'Marriage',
                              ]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.toString(),
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderDropdown<String>(
                      name: 'interested_in',
                      initialValue:
                          [
                                'Men',
                                'Women',
                                'Both',
                                'Non-binary',
                              ].contains(_user.interested_in.toString())
                              ? _user.interested_in.toString()
                              : null,
                      dropdownColor: CustomTheme.card,
                      decoration: _inputDecoration(
                        'Interested In',
                        Icons.people,
                      ),
                      items:
                          ['Men', 'Women', 'Both', 'Non-binary', 'Other']
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.toString(),
                                  child: Text(e),
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
                    child: FormBuilderDropdown<int>(
                      name: 'age_range_min',
                      initialValue:
                          [
                                18,
                                20,
                                25,
                                30,
                              ].contains(int.tryParse(_user.age_range_min))
                              ? int.parse(_user.age_range_min)
                              : null,
                      dropdownColor: CustomTheme.card,
                      decoration: _inputDecoration('Min Age', Icons.numbers),
                      items:
                          [18, 20, 25, 30, 35]
                              .map(
                                (age) => DropdownMenuItem(
                                  value: age,
                                  child: Text('$age'),
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
                          [
                                25,
                                30,
                                35,
                                40,
                                50,
                              ].contains(int.tryParse(_user.age_range_max))
                              ? int.parse(_user.age_range_max)
                              : null,
                      dropdownColor: CustomTheme.card,
                      decoration: _inputDecoration('Max Age', Icons.numbers),
                      items:
                          [25, 30, 35, 40, 45, 50]
                              .map(
                                (age) => DropdownMenuItem(
                                  value: age,
                                  child: Text('$age'),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              FxButton.block(
                onPressed: _saveProfile,
                backgroundColor: CustomTheme.primary,
                child: FxText.titleMedium(
                  'Save Profile',
                  color: CustomTheme.accent,
                  fontWeight: 800,
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
