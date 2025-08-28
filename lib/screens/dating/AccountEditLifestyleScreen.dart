// lib/screens/account/AccountEditLifestyleScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';
import 'package:lovebirds_app/models/RespondModel.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';
import 'package:lovebirds_app/utils/Utilities.dart';

class AccountEditLifestyleScreen extends StatefulWidget {
  final LoggedInUserModel user;

  const AccountEditLifestyleScreen({Key? key, required this.user})
    : super(key: key);

  @override
  _AccountEditLifestyleScreenState createState() =>
      _AccountEditLifestyleScreenState();
}

class _AccountEditLifestyleScreenState
    extends State<AccountEditLifestyleScreen> {
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
    prefixIcon: icon != null ? Icon(icon, color: CustomTheme.primary) : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: CustomTheme.card),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: CustomTheme.primaryDark),
    ),
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      Utils.toast('Please fix errors first', color: Colors.redAccent);
      return;
    }
    setState(() {
      _isSaving = true;
      _error = "";
    });

    final v = _formKey.currentState!.value;

    // map only lifestyle & preference fields
    _item
      ..smoking_habit = v['smoking_habit'] as String
      ..drinking_habit = v['drinking_habit'] as String
      ..pet_preference = v['pet_preference'] as String
      ..religion = v['religion'] as String
      ..political_views = v['political_views'] as String
      ..languages_spoken = (v['languages_spoken'] as List).join(', ')
      ..education_level = v['education_level'] as String
      ..occupation = v['occupation'] as String
      ..looking_for = v['looking_for'] as String
      ..interested_in = v['interested_in'] as String
      ..age_range_min = (v['age_range'] as RangeValues).start.toInt().toString()
      ..age_range_max = (v['age_range'] as RangeValues).end.toInt().toString()
      ..max_distance_km = (v['max_distance'] as double).toStringAsFixed(0);

    final resp = RespondModel(await Utils.http_post('User', _item.toJson()));

    setState(() => _isSaving = false);

    if (resp.code != 1) {
      setState(() => _error = resp.message);
      Utils.toast('Failed to save', color: Colors.redAccent);
      return;
    }

    // update local
    final updated = LoggedInUserModel.fromJson(resp.data);
    await updated.save();
    Utils.toast('Saved!', color: Colors.green);
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
          'Lifestyle & Preferences',
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

                // Smoking Habit
                FormBuilderDropdown<String>(
                  name: 'smoking_habit',
                  initialValue: _item.smoking_habit,
                  decoration: _dec('Smoking Habit', Icons.smoke_free),
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

                // Drinking Habit
                FormBuilderDropdown<String>(
                  name: 'drinking_habit',
                  initialValue: _item.drinking_habit,
                  decoration: _dec('Drinking Habit', Icons.local_bar),
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
                  decoration: _dec('Pet Preference', Icons.pets),
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

                // Religion
                FormBuilderTextField(
                  name: 'religion',
                  initialValue: _item.religion,
                  decoration: _dec('Religion', Icons.my_location),
                ),
                const SizedBox(height: 16),

                // Political Views
                FormBuilderDropdown<String>(
                  name: 'political_views',
                  initialValue: _item.political_views,
                  decoration: _dec('Political Views', Icons.how_to_vote),
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

                // Languages Spoken
                FormBuilderFilterChips<String>(
                  name: 'languages_spoken',
                  initialValue:
                      _item.languages_spoken
                          .split(',')
                          .map((s) => s.trim())
                          .toList(),
                  decoration: _dec('Languages Spoken', Icons.language),
                  options:
                      ['English', 'Spanish', 'French', 'Other']
                          .map(
                            (l) => FormBuilderChipOption(
                              value: l.toLowerCase(),
                              child: Text(l),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),

                // Education Level
                FormBuilderTextField(
                  name: 'education_level',
                  initialValue: _item.education_level,
                  decoration: _dec('Education Level', Icons.school),
                ),
                const SizedBox(height: 16),

                // Occupation
                FormBuilderTextField(
                  name: 'occupation',
                  initialValue: _item.occupation,
                  decoration: _dec('Occupation', Icons.work),
                ),
                const SizedBox(height: 16),

                // Looking For
                FormBuilderDropdown<String>(
                  name: 'looking_for',
                  initialValue: _item.looking_for,
                  decoration: _dec('Looking For', Icons.search),
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

                // Interested In
                FormBuilderDropdown<String>(
                  name: 'interested_in',
                  initialValue: _item.interested_in,
                  decoration: _dec('Interested In', Icons.people),
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

                // Age Range
                FxText.bodySmall('Age Range', color: CustomTheme.color2),
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

                // Max Distance
                FxText.bodySmall(
                  'Max Distance (km)',
                  color: CustomTheme.color2,
                ),
                FormBuilderSlider(
                  name: 'max_distance',
                  initialValue: double.tryParse(_item.max_distance_km) ?? 50,
                  min: 1,
                  max: 500,
                  divisions: 499,
                  decoration: const InputDecoration(border: InputBorder.none),
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
