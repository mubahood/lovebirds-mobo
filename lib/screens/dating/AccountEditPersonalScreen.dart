// lib/screens/account/AccountEditPersonalScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';

import '../../../models/LoggedInUserModel.dart';
import '../../../models/RespondModel.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';

class AccountEditPersonalScreen extends StatefulWidget {
  final LoggedInUserModel user;

  const AccountEditPersonalScreen({Key? key, required this.user})
    : super(key: key);

  @override
  _AccountEditPersonalScreenState createState() =>
      _AccountEditPersonalScreenState();
}

class _AccountEditPersonalScreenState extends State<AccountEditPersonalScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late LoggedInUserModel _item;
  bool _isSaving = false;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _item = widget.user;
  }

  InputDecoration _dec(String label, [IconData? icon]) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: CustomTheme.card,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    prefixIcon:
        icon != null ? Icon(icon, color: CustomTheme.primaryDark) : null,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: CustomTheme.card),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: CustomTheme.primary),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      Utils.toast('Please fix the errors', color: Colors.redAccent);
      return;
    }
    setState(() {
      _isSaving = true;
      _error = "";
    });

    final v = _formKey.currentState!.value;

    // update model
    _item
      ..sex = v['sex'] as String
      ..dob = (v['dob'] as DateTime).toIso8601String()
      ..sexual_orientation = v['sexual_orientation'] as String
      ..height_cm = (v['height_cm'] as double).toStringAsFixed(0)
      ..body_type = v['body_type'] as String
      ..religion = v['religion'] as String
      ..smoking_habit = v['smoking_habit'] as String
      ..drinking_habit = v['drinking_habit'] as String
      ..pet_preference = v['pet_preference'] as String
      ..political_views = v['political_views'] as String
      ..education_level = v['education_level'] as String
      ..occupation = v['occupation'] as String
      ..looking_for = v['looking_for'] as String
      ..interested_in = v['interested_in'] as String
      ..age_range_min = (v['age_range'] as RangeValues).start.toInt().toString()
      ..age_range_max = (v['age_range'] as RangeValues).end.toInt().toString()
      ..max_distance_km = (v['max_distance'] as double).toStringAsFixed(0)
      ..bio = v['bio'] as String
      ..tagline = v['tagline'] as String;

    final data = _item.toJson();
    final resp = RespondModel(await Utils.http_post('User', data));
    setState(() => _isSaving = false);

    if (resp.code != 1) {
      setState(() => _error = resp.message);
      Utils.toast('Failed to save', color: Colors.redAccent);
      return;
    }

    // save updated user locally
    LoggedInUserModel updated = LoggedInUserModel.fromJson(resp.data);
    await updated.save();

    Utils.toast('Personal info updated!', color: Colors.green);
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomTheme.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: FxText.titleMedium(
          'Edit Personal Info',
          color: CustomTheme.accent,
          fontWeight: 700,
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(CustomTheme.accent),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: FxText.bodyLarge(
                'SAVE',
                color: CustomTheme.accent,
                fontWeight: 800,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(12),
                    child: FxText.bodySmall(_error, color: Colors.redAccent),
                  ),

                // Sex
                FormBuilderChoiceChips<String>(
                  name: 'sex',
                  initialValue: _item.sex,
                  decoration: _dec('Gender'),
                  options: const [
                    FormBuilderChipOption(value: 'male', child: Text('Male')),
                    FormBuilderChipOption(
                      value: 'female',
                      child: Text('Female'),
                    ),
                    FormBuilderChipOption(value: 'other', child: Text('Other')),
                  ],
                  selectedColor: CustomTheme.primary,
                ),
                const SizedBox(height: 16),

                // Date of Birth
                FormBuilderDateTimePicker(
                  name: 'dob',
                  initialValue:
                      _item.dob.isNotEmpty ? DateTime.parse(_item.dob) : null,
                  decoration: _dec('Date of Birth', Icons.calendar_today),
                  inputType: InputType.date,
                  lastDate: DateTime.now(),
                ),
                const SizedBox(height: 16),

                // Sexual Orientation
                FormBuilderDropdown<String>(
                  name: 'sexual_orientation',
                  initialValue: _item.sexual_orientation,
                  decoration: _dec('Sexual Orientation'),
                  items:
                      ['Straight', 'Gay', 'Bisexual', 'Other']
                          .map(
                            (o) => DropdownMenuItem(
                              value: o.toLowerCase(),
                              child: Text(o),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),

                // Height slider
                Text(
                  'Height (cm)',
                  style: FxTextStyle.bodyMedium(color: CustomTheme.color2),
                ),
                FormBuilderSlider(
                  name: 'height_cm',
                  initialValue: double.tryParse(_item.height_cm) ?? 170,
                  min: 100,
                  max: 220,
                  divisions: 24,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
                const SizedBox(height: 16),

                // Body type
                FormBuilderDropdown<String>(
                  name: 'body_type',
                  initialValue: _item.body_type,
                  decoration: _dec('Body Type'),
                  items:
                      ['Slim', 'Average', 'Athletic', 'Curvy', 'Other']
                          .map(
                            (b) => DropdownMenuItem(
                              value: b.toLowerCase(),
                              child: Text(b),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),

                // Religion
                FormBuilderTextField(
                  name: 'religion',
                  initialValue: _item.religion,
                  decoration: _dec('Religion'),
                ),
                const SizedBox(height: 16),

                // Smoking & Drinking
                FormBuilderDropdown<String>(
                  name: 'smoking_habit',
                  initialValue: _item.smoking_habit,
                  decoration: _dec('Smoking Habit'),
                  items:
                      ['No', 'Occasionally', 'Regular']
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.toLowerCase(),
                              child: Text(s),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown<String>(
                  name: 'drinking_habit',
                  initialValue: _item.drinking_habit,
                  decoration: _dec('Drinking Habit'),
                  items:
                      ['No', 'Occasionally', 'Regular']
                          .map(
                            (d) => DropdownMenuItem(
                              value: d.toLowerCase(),
                              child: Text(d),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),

                // Pet Preference
                FormBuilderDropdown<String>(
                  name: 'pet_preference',
                  initialValue: _item.pet_preference,
                  decoration: _dec('Pet Preference'),
                  items:
                      ['No pets', 'Dogs', 'Cats', 'Other']
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.toLowerCase(),
                              child: Text(p),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),

                // Political Views
                FormBuilderDropdown<String>(
                  name: 'political_views',
                  initialValue: _item.political_views,
                  decoration: _dec('Political Views'),
                  items:
                      ['Left', 'Center', 'Right', 'Other']
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.toLowerCase(),
                              child: Text(p),
                            ),
                          )
                          .toList(),
                ),

                const SizedBox(height: 16),

                // Education level & Occupation
                FormBuilderTextField(
                  name: 'education_level',
                  initialValue: _item.education_level,
                  decoration: _dec('Education Level'),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'occupation',
                  initialValue: _item.occupation,
                  decoration: _dec('Occupation'),
                ),
                const SizedBox(height: 16),

                // Looking for & Interested In
                FormBuilderDropdown<String>(
                  name: 'looking_for',
                  initialValue: _item.looking_for,
                  decoration: _dec('Looking For'),
                  items:
                      ['Friendship', 'Dating', 'Relationship']
                          .map(
                            (o) => DropdownMenuItem(
                              value: o.toLowerCase(),
                              child: Text(o),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown<String>(
                  name: 'interested_in',
                  initialValue: _item.interested_in,
                  decoration: _dec('Interested In'),
                  items:
                      ['Male', 'Female', 'Both', 'Other']
                          .map(
                            (o) => DropdownMenuItem(
                              value: o.toLowerCase(),
                              child: Text(o),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),

                // Age range & Max distance
                Text(
                  'Age Range',
                  style: FxTextStyle.bodyMedium(color: CustomTheme.color2),
                ),
                FormBuilderRangeSlider(
                  name: 'age_range',
                  initialValue: RangeValues(
                    double.tryParse(_item.age_range_min) ?? 18,
                    double.tryParse(_item.age_range_max) ?? 35,
                  ),
                  min: 18,
                  max: 100,
                  divisions: 82,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
                const SizedBox(height: 16),
                Text(
                  'Max Distance (km)',
                  style: FxTextStyle.bodyMedium(color: CustomTheme.color2),
                ),
                FormBuilderSlider(
                  name: 'max_distance',
                  initialValue: double.tryParse(_item.max_distance_km) ?? 50,
                  min: 1,
                  max: 500,
                  divisions: 499,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
                const SizedBox(height: 16),

                // Bio & Tagline
                FormBuilderTextField(
                  name: 'tagline',
                  initialValue: _item.tagline,
                  decoration: _dec('Tagline'),
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'bio',
                  initialValue: _item.bio,
                  decoration: _dec('Bio'),
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
