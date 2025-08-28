import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../../models/UserModel.dart';
import '../../models/LoggedInUserModel.dart';
import '../../services/smart_search_service.dart';
import '../../utils/dating_theme.dart';
import '../../widgets/search/search_result_cards.dart';
import 'enhanced_search_filters_screen.dart';

/// Main enhanced search screen with filters and smart results
class EnhancedSearchScreen extends StatefulWidget {
  const EnhancedSearchScreen({Key? key}) : super(key: key);

  @override
  _EnhancedSearchScreenState createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<SearchCandidate> _searchResults = [];
  List<String> _suggestions = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  SearchFilters? _activeFilters;
  UserModel? _currentUser;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadCurrentUser();
    _loadSavedFilters();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final loggedInUser = await LoggedInUserModel.getLoggedInUser();
      setState(() {
        _currentUser = _convertToUserModel(loggedInUser);
      });
      _loadSuggestions();
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  UserModel _convertToUserModel(LoggedInUserModel loggedInUser) {
    final user = UserModel();
    user.id = loggedInUser.id;
    user.first_name = loggedInUser.first_name;
    user.last_name = loggedInUser.last_name;
    user.dob = loggedInUser.dob;
    user.city = loggedInUser.city;
    user.occupation = loggedInUser.occupation;
    user.education_level = loggedInUser.education_level;
    user.smoking_habit = loggedInUser.smoking_habit;
    user.drinking_habit = loggedInUser.drinking_habit;
    user.looking_for = loggedInUser.looking_for;
    user.height_cm = loggedInUser.height_cm;
    user.body_type = loggedInUser.body_type;
    user.latitude = loggedInUser.latitude;
    user.longitude = loggedInUser.longitude;
    return user;
  }

  Future<void> _loadSavedFilters() async {
    final filters = await SmartSearchService.getSavedSearchPreferences();
    if (filters != null) {
      setState(() {
        _activeFilters = filters;
      });
    }
  }

  Future<void> _loadSuggestions() async {
    if (_currentUser != null) {
      final suggestions = await SmartSearchService.getSearchSuggestions(
        _currentUser!,
      );
      setState(() {
        _suggestions = suggestions;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildSearchTab(), _buildFiltersTab()],
            ),
          ),
        ],
      ),
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
          Icon(Icons.search, color: DatingTheme.primaryPink, size: 24),
          const SizedBox(width: 8),
          FxText.titleLarge(
            'Smart Search',
            color: Colors.white,
            fontWeight: 600,
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _openFilters,
          icon: Stack(
            children: [
              const Icon(Icons.tune, color: Colors.white),
              if (_activeFilters != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: DatingTheme.primaryPink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for your perfect match...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search, color: DatingTheme.primaryPink),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults.clear();
                        _hasSearched = false;
                      });
                    },
                    icon: const Icon(Icons.clear, color: Colors.white),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        onSubmitted: _performSearch,
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: DatingTheme.primaryPink,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: DatingTheme.secondaryText,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [Tab(text: 'Search Results'), Tab(text: 'Quick Filters')],
      ),
    );
  }

  Widget _buildSearchTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(DatingTheme.primaryPink),
        ),
      );
    }

    if (!_hasSearched) {
      return _buildSearchSuggestions();
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _searchResults.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _searchResults.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  DatingTheme.primaryPink,
                ),
              ),
            ),
          );
        }

        final candidate = _searchResults[index];
        return SearchResultCard(
          candidate: candidate,
          onTap: () => _viewProfile(candidate),
          onLike: () => _likeUser(candidate),
          onMessage: () => _messageUser(candidate),
        );
      },
    );
  }

  Widget _buildFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(
            'Quick Filters',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 16),
          _buildQuickFilterChips(),
          const SizedBox(height: 24),
          _buildAdvancedFiltersButton(),
          if (_activeFilters != null) ...[
            const SizedBox(height: 24),
            _buildActiveFiltersDisplay(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(
            'Search Suggestions',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 16),
          if (_suggestions.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _suggestions.map((suggestion) {
                    return GestureDetector(
                      onTap: () => _performSearch(suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: DatingTheme.primaryPink.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: DatingTheme.primaryPink.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: FxText.bodyMedium(
                          suggestion,
                          color: DatingTheme.primaryPink,
                          fontWeight: 500,
                        ),
                      ),
                    );
                  }).toList(),
            )
          else
            FxText.bodyLarge(
              'Start typing to search for your perfect match!',
              color: DatingTheme.secondaryText,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChips() {
    final quickFilters = [
      'Nearby (10km)',
      'Age 25-35',
      'University Educated',
      'Professional',
      'Non-Smoker',
      'Social Drinker',
      'Fitness Lover',
      'Travel Enthusiast',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          quickFilters.map((filter) {
            return FilterChip(
              label: FxText.bodyMedium(
                filter,
                color: Colors.white,
                fontWeight: 500,
              ),
              onSelected: (selected) => _applyQuickFilter(filter),
              backgroundColor: DatingTheme.cardBackground,
              selectedColor: DatingTheme.primaryPink,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: DatingTheme.primaryPink.withValues(alpha: 0.5),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildAdvancedFiltersButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openFilters,
        style: ElevatedButton.styleFrom(
          backgroundColor: DatingTheme.primaryPink,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.tune, color: Colors.white),
        label: FxText.bodyLarge(
          'Advanced Filters',
          color: Colors.white,
          fontWeight: 600,
        ),
      ),
    );
  }

  Widget _buildActiveFiltersDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DatingTheme.primaryPink.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: DatingTheme.primaryPink, size: 20),
              const SizedBox(width: 8),
              FxText.titleMedium(
                'Active Filters',
                color: Colors.white,
                fontWeight: 600,
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: FxText.bodyMedium(
                  'Clear All',
                  color: DatingTheme.primaryPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Display active filter summary
          FxText.bodyMedium(
            'Filters applied - tap "Advanced Filters" to modify',
            color: DatingTheme.secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          FxText.headlineSmall(
            'No matches found',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 8),
          FxText.bodyLarge(
            'Try adjusting your search filters',
            color: DatingTheme.secondaryText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _openFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: DatingTheme.primaryPink,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Adjust Filters'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _currentPage = 1;
    });

    try {
      final filters = _activeFilters ?? SearchFilters();
      final result = await SmartSearchService.searchUsers(
        filters: filters,
        currentUser: _currentUser,
        page: _currentPage,
      );

      setState(() {
        _searchResults = result.candidates;
        _hasMore = result.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Search failed: $e');
    }
  }

  Future<void> _loadMoreResults() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    try {
      final filters = _activeFilters ?? SearchFilters();
      final result = await SmartSearchService.searchUsers(
        filters: filters,
        currentUser: _currentUser,
        page: _currentPage,
      );

      setState(() {
        _searchResults.addAll(result.candidates);
        _hasMore = result.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentPage--; // Revert page increment
      });
    }
  }

  void _openFilters() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedSearchFiltersScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _activeFilters = SearchFilters(
          ageRange: result['age_range'],
          maxDistance: result['max_distance'],
          heightRange: result['height_range'],
          bodyTypes: List<String>.from(result['body_types'] ?? []),
          educationLevels: List<String>.from(result['education_levels'] ?? []),
          occupations: List<String>.from(result['occupations'] ?? []),
          relationshipGoals: List<String>.from(
            result['relationship_goals'] ?? [],
          ),
          lifestylePreferences: Map<String, bool>.from(
            result['lifestyle_preferences'] ?? {},
          ),
        );
      });

      // Save filters and perform search
      if (_activeFilters != null) {
        SmartSearchService.saveSearchPreferences(_activeFilters!);
        _performSearch(
          _searchController.text.isEmpty ? 'search' : _searchController.text,
        );
      }
    }
  }

  void _applyQuickFilter(String filter) {
    // Implementation for quick filter application
    // This would set specific filter values based on the quick filter selected
    _performSearch(filter);
  }

  void _clearFilters() {
    setState(() {
      _activeFilters = null;
    });
  }

  void _viewProfile(SearchCandidate candidate) {
    // Navigate to profile view
    print('View profile: ${candidate.user.first_name}');
  }

  void _likeUser(SearchCandidate candidate) {
    // Implement like functionality
    print('Like user: ${candidate.user.first_name}');
  }

  void _messageUser(SearchCandidate candidate) {
    // Navigate to chat
    print('Message user: ${candidate.user.first_name}');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: DatingTheme.errorRed),
    );
  }
}
