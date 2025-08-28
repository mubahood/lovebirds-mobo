import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../../utils/dating_theme.dart';

/// Enhanced search filters screen with premium UI components
class EnhancedSearchFiltersScreen extends StatefulWidget {
  const EnhancedSearchFiltersScreen({Key? key}) : super(key: key);

  @override
  _EnhancedSearchFiltersScreenState createState() =>
      _EnhancedSearchFiltersScreenState();
}

class _EnhancedSearchFiltersScreenState
    extends State<EnhancedSearchFiltersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Filter state variables
  RangeValues _ageRange = const RangeValues(18, 35);
  double _maxDistance = 50.0;
  RangeValues _heightRange = const RangeValues(150, 200);
  List<String> _selectedBodyTypes = [];
  List<String> _selectedEducationLevels = [];
  List<String> _selectedOccupations = [];
  List<String> _selectedRelationshipGoals = [];
  Map<String, bool> _lifestylePreferences = {
    'smoking': false,
    'drinking': false,
    'fitness': false,
    'pets': false,
    'travel': false,
  };

  // Filter options
  final List<String> _bodyTypes = [
    'Slim',
    'Athletic',
    'Average',
    'Curvy',
    'Plus Size',
    'Muscular',
  ];

  final List<String> _educationLevels = [
    'High School',
    'Some College',
    'Bachelor\'s',
    'Master\'s',
    'PhD',
    'Trade School',
  ];

  final List<String> _occupationCategories = [
    'Technology',
    'Healthcare',
    'Education',
    'Business',
    'Creative Arts',
    'Engineering',
    'Legal',
    'Finance',
    'Sales',
    'Other',
  ];

  final List<String> _relationshipGoals = [
    'Casual Dating',
    'Serious Relationship',
    'Marriage',
    'Friendship',
    'Networking',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadSavedFilters();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedFilters() async {
    // Load saved filter preferences
    // This would typically come from SharedPreferences or user profile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: _buildFilterContent(),
          );
        },
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Row(
        children: [
          Icon(Icons.tune, color: DatingTheme.primaryPink, size: 24),
          const SizedBox(width: 8),
          FxText.titleLarge(
            'Advanced Filters',
            color: Colors.white,
            fontWeight: 600,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _resetFilters,
          child: FxText.bodyMedium(
            'Reset',
            color: DatingTheme.primaryPink,
            fontWeight: 500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPremiumHeader(),
          const SizedBox(height: 24),
          _buildAgeRangeFilter(),
          const SizedBox(height: 24),
          _buildDistanceFilter(),
          const SizedBox(height: 24),
          _buildHeightRangeFilter(),
          const SizedBox(height: 24),
          _buildBodyTypeFilter(),
          const SizedBox(height: 24),
          _buildEducationFilter(),
          const SizedBox(height: 24),
          _buildOccupationFilter(),
          const SizedBox(height: 24),
          _buildRelationshipGoalsFilter(),
          const SizedBox(height: 24),
          _buildLifestylePreferences(),
          const SizedBox(height: 100), // Space for bottom buttons
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: DatingTheme.premiumGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DatingTheme.premiumGold.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.titleMedium(
                  'Premium Filters',
                  color: Colors.white,
                  fontWeight: 700,
                ),
                FxText.bodySmall(
                  'Find your perfect match with advanced search options',
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRangeFilter() {
    return _buildFilterSection(
      title: 'Age Range',
      icon: Icons.cake_outlined,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyLarge(
                '${_ageRange.start.round()} years',
                color: Colors.white,
                fontWeight: 600,
              ),
              FxText.bodyLarge(
                '${_ageRange.end.round()} years',
                color: Colors.white,
                fontWeight: 600,
              ),
            ],
          ),
          const SizedBox(height: 16),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 80,
            divisions: 62,
            activeColor: DatingTheme.primaryPink,
            inactiveColor: DatingTheme.primaryPink.withValues(alpha: 0.3),
            onChanged: (RangeValues values) {
              setState(() {
                _ageRange = values;
              });
            },
            labels: RangeLabels(
              '${_ageRange.start.round()}',
              '${_ageRange.end.round()}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return _buildFilterSection(
      title: 'Maximum Distance',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyLarge(
                '${_maxDistance.round()} km',
                color: Colors.white,
                fontWeight: 600,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DatingTheme.primaryPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FxText.bodySmall(
                  _maxDistance >= 100 ? 'Anywhere' : 'Nearby',
                  color: DatingTheme.primaryPink,
                  fontWeight: 600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _maxDistance,
            min: 1,
            max: 100,
            divisions: 99,
            activeColor: DatingTheme.primaryPink,
            inactiveColor: DatingTheme.primaryPink.withValues(alpha: 0.3),
            onChanged: (double value) {
              setState(() {
                _maxDistance = value;
              });
            },
            label: '${_maxDistance.round()} km',
          ),
        ],
      ),
    );
  }

  Widget _buildHeightRangeFilter() {
    return _buildFilterSection(
      title: 'Height Preference',
      icon: Icons.height,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyLarge(
                '${_heightRange.start.round()} cm',
                color: Colors.white,
                fontWeight: 600,
              ),
              FxText.bodyLarge(
                '${_heightRange.end.round()} cm',
                color: Colors.white,
                fontWeight: 600,
              ),
            ],
          ),
          const SizedBox(height: 16),
          RangeSlider(
            values: _heightRange,
            min: 140,
            max: 220,
            divisions: 80,
            activeColor: DatingTheme.primaryPink,
            inactiveColor: DatingTheme.primaryPink.withValues(alpha: 0.3),
            onChanged: (RangeValues values) {
              setState(() {
                _heightRange = values;
              });
            },
            labels: RangeLabels(
              '${_heightRange.start.round()}cm',
              '${_heightRange.end.round()}cm',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTypeFilter() {
    return _buildFilterSection(
      title: 'Body Type',
      icon: Icons.accessibility_new,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _bodyTypes.map((type) {
              final isSelected = _selectedBodyTypes.contains(type);
              return FilterChip(
                label: FxText.bodyMedium(
                  type,
                  color: isSelected ? Colors.white : DatingTheme.secondaryText,
                  fontWeight: isSelected ? 600 : 400,
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedBodyTypes.add(type);
                    } else {
                      _selectedBodyTypes.remove(type);
                    }
                  });
                },
                backgroundColor: DatingTheme.cardBackground,
                selectedColor: DatingTheme.primaryPink,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color:
                      isSelected
                          ? DatingTheme.primaryPink
                          : DatingTheme.secondaryText,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildEducationFilter() {
    return _buildFilterSection(
      title: 'Education Level',
      icon: Icons.school_outlined,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _educationLevels.map((level) {
              final isSelected = _selectedEducationLevels.contains(level);
              return FilterChip(
                label: FxText.bodyMedium(
                  level,
                  color: isSelected ? Colors.white : DatingTheme.secondaryText,
                  fontWeight: isSelected ? 600 : 400,
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedEducationLevels.add(level);
                    } else {
                      _selectedEducationLevels.remove(level);
                    }
                  });
                },
                backgroundColor: DatingTheme.cardBackground,
                selectedColor: DatingTheme.primaryPink,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color:
                      isSelected
                          ? DatingTheme.primaryPink
                          : DatingTheme.secondaryText,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildOccupationFilter() {
    return _buildFilterSection(
      title: 'Occupation Category',
      icon: Icons.work_outline,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _occupationCategories.map((category) {
              final isSelected = _selectedOccupations.contains(category);
              return FilterChip(
                label: FxText.bodyMedium(
                  category,
                  color: isSelected ? Colors.white : DatingTheme.secondaryText,
                  fontWeight: isSelected ? 600 : 400,
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedOccupations.add(category);
                    } else {
                      _selectedOccupations.remove(category);
                    }
                  });
                },
                backgroundColor: DatingTheme.cardBackground,
                selectedColor: DatingTheme.primaryPink,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color:
                      isSelected
                          ? DatingTheme.primaryPink
                          : DatingTheme.secondaryText,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildRelationshipGoalsFilter() {
    return _buildFilterSection(
      title: 'Relationship Goals',
      icon: Icons.favorite_outline,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _relationshipGoals.map((goal) {
              final isSelected = _selectedRelationshipGoals.contains(goal);
              return FilterChip(
                label: FxText.bodyMedium(
                  goal,
                  color: isSelected ? Colors.white : DatingTheme.secondaryText,
                  fontWeight: isSelected ? 600 : 400,
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedRelationshipGoals.add(goal);
                    } else {
                      _selectedRelationshipGoals.remove(goal);
                    }
                  });
                },
                backgroundColor: DatingTheme.cardBackground,
                selectedColor: DatingTheme.primaryPink,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color:
                      isSelected
                          ? DatingTheme.primaryPink
                          : DatingTheme.secondaryText,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLifestylePreferences() {
    return _buildFilterSection(
      title: 'Lifestyle Preferences',
      icon: Icons.style_outlined,
      child: Column(
        children:
            _lifestylePreferences.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Switch(
                      value: entry.value,
                      onChanged: (bool value) {
                        setState(() {
                          _lifestylePreferences[entry.key] = value;
                        });
                      },
                      activeColor: DatingTheme.primaryPink,
                      inactiveThumbColor: DatingTheme.secondaryText,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FxText.bodyLarge(
                        _getLifestyleLabel(entry.key),
                        color: Colors.white,
                        fontWeight: entry.value ? 600 : 400,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DatingTheme.primaryPink, size: 20),
              const SizedBox(width: 8),
              FxText.titleMedium(title, color: Colors.white, fontWeight: 600),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DatingTheme.darkBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _previewResults,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: DatingTheme.primaryPink),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: FxText.bodyLarge(
                'Preview Results',
                color: DatingTheme.primaryPink,
                fontWeight: 600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: DatingTheme.primaryPink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: FxText.bodyLarge(
                'Apply Filters',
                color: Colors.white,
                fontWeight: 600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLifestyleLabel(String key) {
    switch (key) {
      case 'smoking':
        return 'Non-Smoker Preferred';
      case 'drinking':
        return 'Social Drinker Okay';
      case 'fitness':
        return 'Fitness Enthusiast';
      case 'pets':
        return 'Pet Lover';
      case 'travel':
        return 'Loves to Travel';
      default:
        return key;
    }
  }

  void _resetFilters() {
    setState(() {
      _ageRange = const RangeValues(18, 35);
      _maxDistance = 50.0;
      _heightRange = const RangeValues(150, 200);
      _selectedBodyTypes.clear();
      _selectedEducationLevels.clear();
      _selectedOccupations.clear();
      _selectedRelationshipGoals.clear();
      _lifestylePreferences.updateAll((key, value) => false);
    });
  }

  void _previewResults() {
    // Show preview of filtered results
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPreviewSheet(),
    );
  }

  Widget _buildPreviewSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FxText.titleLarge(
              'Filter Preview',
              color: Colors.white,
              fontWeight: 600,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.bodyLarge(
                    'Your filters will show profiles matching:',
                    color: Colors.white,
                    fontWeight: 500,
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewItem(
                    'Age',
                    '${_ageRange.start.round()}-${_ageRange.end.round()} years',
                  ),
                  _buildPreviewItem(
                    'Distance',
                    '${_maxDistance.round()} km radius',
                  ),
                  _buildPreviewItem(
                    'Height',
                    '${_heightRange.start.round()}-${_heightRange.end.round()} cm',
                  ),
                  if (_selectedBodyTypes.isNotEmpty)
                    _buildPreviewItem(
                      'Body Type',
                      _selectedBodyTypes.join(', '),
                    ),
                  if (_selectedEducationLevels.isNotEmpty)
                    _buildPreviewItem(
                      'Education',
                      _selectedEducationLevels.join(', '),
                    ),
                  if (_selectedRelationshipGoals.isNotEmpty)
                    _buildPreviewItem(
                      'Goals',
                      _selectedRelationshipGoals.join(', '),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: DatingTheme.primaryPink,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: DatingTheme.primaryPink,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    // Apply filters and return to discovery screen
    final filters = {
      'age_range': _ageRange,
      'max_distance': _maxDistance,
      'height_range': _heightRange,
      'body_types': _selectedBodyTypes,
      'education_levels': _selectedEducationLevels,
      'occupations': _selectedOccupations,
      'relationship_goals': _selectedRelationshipGoals,
      'lifestyle_preferences': _lifestylePreferences,
    };

    Navigator.pop(context, filters);
  }
}
