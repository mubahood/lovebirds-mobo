import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../models/RespondModel.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/PremiumFeaturesManager.dart';
import '../../utils/Utilities.dart';

class AdvancedFiltersScreen extends StatefulWidget {
  @override
  _AdvancedFiltersScreenState createState() => _AdvancedFiltersScreenState();
}

class _AdvancedFiltersScreenState extends State<AdvancedFiltersScreen> {
  bool _isLoading = true;
  bool _canUseAdvancedFilters = false;
  bool _isSaving = false;

  // Filter values
  RangeValues _ageRange = RangeValues(18, 35);
  double _distance = 50;
  RangeValues _heightRange = RangeValues(150, 200);
  List<String> _selectedEducation = [];
  List<String> _selectedBodyTypes = [];
  List<String> _selectedLifestyle = [];
  List<String> _selectedRelationshipGoals = [];
  List<String> _selectedInterests = [];

  // Available options
  final List<String> _educationOptions = [
    'High School',
    'Some College',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD/Doctorate',
    'Trade School',
    'Other',
  ];

  final List<String> _bodyTypeOptions = [
    'Slim',
    'Athletic',
    'Average',
    'Curvy',
    'Plus Size',
    'Muscular',
  ];

  final List<String> _lifestyleOptions = [
    'Non-smoker',
    'Social smoker',
    'Regular smoker',
    'Non-drinker',
    'Social drinker',
    'Regular drinker',
    'Vegetarian',
    'Vegan',
    'Fitness enthusiast',
    'Health conscious',
  ];

  final List<String> _relationshipGoalOptions = [
    'Casual dating',
    'Long-term relationship',
    'Marriage',
    'Friendship',
    'Networking',
    'Something casual',
    'Not sure yet',
  ];

  final List<String> _interestOptions = [
    'Travel',
    'Food & Dining',
    'Music',
    'Movies',
    'Sports',
    'Fitness',
    'Reading',
    'Art',
    'Photography',
    'Technology',
    'Gaming',
    'Cooking',
    'Dancing',
    'Hiking',
    'Beach',
    'Pets',
    'Fashion',
    'Business',
    'Entrepreneurship',
    'Volunteering',
  ];

  @override
  void initState() {
    super.initState();
    _checkFilterAccess();
    _loadCurrentFilters();
  }

  void _checkFilterAccess() async {
    final canUse = await PremiumFeaturesManager.canUseAdvancedFilters();
    setState(() {
      _canUseAdvancedFilters = canUse;
    });
  }

  void _loadCurrentFilters() async {
    try {
      final response = await Utils.http_get('search-filters', {});
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        setState(() {
          _ageRange = RangeValues(
            double.tryParse(resp.data['min_age']?.toString() ?? '18') ?? 18,
            double.tryParse(resp.data['max_age']?.toString() ?? '35') ?? 35,
          );
          _distance =
              double.tryParse(resp.data['distance']?.toString() ?? '50') ?? 50;
          _heightRange = RangeValues(
            double.tryParse(resp.data['min_height']?.toString() ?? '150') ??
                150,
            double.tryParse(resp.data['max_height']?.toString() ?? '200') ??
                200,
          );
          _selectedEducation = List<String>.from(resp.data['education'] ?? []);
          _selectedBodyTypes = List<String>.from(resp.data['body_types'] ?? []);
          _selectedLifestyle = List<String>.from(resp.data['lifestyle'] ?? []);
          _selectedRelationshipGoals = List<String>.from(
            resp.data['relationship_goals'] ?? [],
          );
          _selectedInterests = List<String>.from(resp.data['interests'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading filters: $e');
    }
  }

  Future<void> _saveFilters() async {
    if (!_canUseAdvancedFilters) {
      PremiumFeaturesManager.showFeatureUpgradePrompt(
        context,
        'Advanced Filters',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await Utils.http_post('save-search-filters', {
        'min_age': _ageRange.start.round().toString(),
        'max_age': _ageRange.end.round().toString(),
        'distance': _distance.round().toString(),
        'min_height': _heightRange.start.round().toString(),
        'max_height': _heightRange.end.round().toString(),
        'education': _selectedEducation,
        'body_types': _selectedBodyTypes,
        'lifestyle': _selectedLifestyle,
        'relationship_goals': _selectedRelationshipGoals,
        'interests': _selectedInterests,
      });

      final resp = RespondModel(response);

      if (resp.code == 1) {
        Get.snackbar(
          'Filters Saved',
          'Your advanced search filters have been updated successfully!',
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Track usage
        await PremiumFeaturesManager.trackFeatureUsage('advanced_filters');

        Navigator.pop(
          context,
          true,
        ); // Return true to indicate filters were saved
      } else {
        _showErrorSnackbar(
          resp.message.isNotEmpty ? resp.message : 'Failed to save filters',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Network error occurred: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _ageRange = RangeValues(18, 99);
      _distance = 100;
      _heightRange = RangeValues(140, 220);
      _selectedEducation.clear();
      _selectedBodyTypes.clear();
      _selectedLifestyle.clear();
      _selectedRelationshipGoals.clear();
      _selectedInterests.clear();
    });
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 0,
        title: FxText.titleLarge(
          'Advanced Filters',
          fontWeight: 700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (!_canUseAdvancedFilters)
            IconButton(
              icon: Icon(Icons.star, color: CustomTheme.primary),
              onPressed:
                  () => PremiumFeaturesManager.showFeatureUpgradePrompt(
                    context,
                    'Advanced Filters',
                  ),
            ),
          TextButton(
            onPressed: _clearAllFilters,
            child: FxText.bodyMedium(
              'Clear',
              color: CustomTheme.primary,
              fontWeight: 600,
            ),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildFiltersContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
          ),
          SizedBox(height: 16),
          FxText.bodyMedium('Loading your filters...', color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildFiltersContent() {
    if (!_canUseAdvancedFilters) {
      return _buildUpgradePrompt();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicFilters(),
          SizedBox(height: 24),
          _buildMultiSelectSection(
            'Education Level',
            _educationOptions,
            _selectedEducation,
          ),
          SizedBox(height: 24),
          _buildMultiSelectSection(
            'Body Type',
            _bodyTypeOptions,
            _selectedBodyTypes,
          ),
          SizedBox(height: 24),
          _buildMultiSelectSection(
            'Lifestyle',
            _lifestyleOptions,
            _selectedLifestyle,
          ),
          SizedBox(height: 24),
          _buildMultiSelectSection(
            'Relationship Goals',
            _relationshipGoalOptions,
            _selectedRelationshipGoals,
          ),
          SizedBox(height: 24),
          _buildMultiSelectSection(
            'Interests',
            _interestOptions,
            _selectedInterests,
          ),
          SizedBox(height: 100), // Bottom padding for floating action button
        ],
      ),
    );
  }

  Widget _buildUpgradePrompt() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CustomTheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.tune, size: 60, color: CustomTheme.primary),
            ),

            SizedBox(height: 24),

            FxText.titleLarge(
              'Advanced Filters',
              color: Colors.white,
              fontWeight: 700,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

            FxText.bodyMedium(
              'Find your perfect match with advanced search filters. Filter by education, body type, lifestyle, and more!',
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            ElevatedButton(
              onPressed:
                  () => PremiumFeaturesManager.showFeatureUpgradePrompt(
                    context,
                    'Advanced Filters',
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: FxText.bodyLarge(
                'Upgrade to Premium',
                color: Colors.white,
                fontWeight: 600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Age range
        _buildRangeFilter(
          'Age Range',
          _ageRange,
          18,
          99,
          (values) => setState(() => _ageRange = values),
          '${_ageRange.start.round()} - ${_ageRange.end.round()} years',
        ),

        SizedBox(height: 24),

        // Distance
        _buildSliderFilter(
          'Distance',
          _distance,
          1,
          100,
          (value) => setState(() => _distance = value),
          '${_distance.round()} km',
        ),

        SizedBox(height: 24),

        // Height range
        _buildRangeFilter(
          'Height Range',
          _heightRange,
          140,
          220,
          (values) => setState(() => _heightRange = values),
          '${_heightRange.start.round()} - ${_heightRange.end.round()} cm',
        ),
      ],
    );
  }

  Widget _buildRangeFilter(
    String title,
    RangeValues values,
    double min,
    double max,
    Function(RangeValues) onChanged,
    String displayText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FxText.titleSmall(title, color: Colors.white, fontWeight: 600),
            FxText.bodyMedium(
              displayText,
              color: CustomTheme.primary,
              fontWeight: 600,
            ),
          ],
        ),
        SizedBox(height: 12),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          activeColor: CustomTheme.primary,
          inactiveColor: Colors.white.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSliderFilter(
    String title,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    String displayText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FxText.titleSmall(title, color: Colors.white, fontWeight: 600),
            FxText.bodyMedium(
              displayText,
              color: CustomTheme.primary,
              fontWeight: 600,
            ),
          ],
        ),
        SizedBox(height: 12),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: CustomTheme.primary,
          inactiveColor: Colors.white.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMultiSelectSection(
    String title,
    List<String> options,
    List<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.titleSmall(title, color: Colors.white, fontWeight: 600),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected = selected.contains(option);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selected.remove(option);
                      } else {
                        selected.add(option);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? CustomTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? CustomTheme.primary
                                : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: FxText.bodySmall(
                      option,
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? 600 : 400,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.background,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomTheme.primary,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child:
              _isSaving
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      FxText.bodyLarge(
                        'Saving Filters...',
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                    ],
                  )
                  : FxText.bodyLarge(
                    'Apply Filters',
                    color: Colors.white,
                    fontWeight: 600,
                  ),
        ),
      ),
    );
  }
}
