import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../../models/UserModel.dart';
import '../../services/date_planning_service.dart';
import '../../utils/dating_theme.dart';

/// Widget for date planning features within chat
class DatePlanningWidget extends StatefulWidget {
  final UserModel currentUser;
  final UserModel matchedUser;
  final Function(String) onDateIdeaSelected;

  const DatePlanningWidget({
    Key? key,
    required this.currentUser,
    required this.matchedUser,
    required this.onDateIdeaSelected,
  }) : super(key: key);

  @override
  _DatePlanningWidgetState createState() => _DatePlanningWidgetState();
}

class _DatePlanningWidgetState extends State<DatePlanningWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<RestaurantSuggestion> _restaurants = [];
  List<DateActivitySuggestion> _activities = [];
  List<PersonalizedDateIdea> _personalizedIdeas = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDateSuggestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDateSuggestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load restaurants, activities, and personalized ideas
      final results = await Future.wait([
        DatePlanningService.getRestaurantSuggestions(
          currentUser: widget.currentUser,
          matchedUser: widget.matchedUser,
          maxDistance: 10.0,
        ),
        DatePlanningService.getDateActivitySuggestions(
          currentUser: widget.currentUser,
          matchedUser: widget.matchedUser,
        ),
      ]);

      _restaurants = results[0] as List<RestaurantSuggestion>;
      _activities = results[1] as List<DateActivitySuggestion>;

      // Generate personalized ideas
      _personalizedIdeas = DatePlanningService.generatePersonalizedDateIdeas(
        currentUser: widget.currentUser,
        matchedUser: widget.matchedUser,
        compatibilityScore: 0.8, // Could be passed from parent
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading date suggestions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child:
                _isLoading
                    ? _buildLoadingState()
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRestaurantsTab(),
                        _buildActivitiesTab(),
                        _buildPersonalizedTab(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: DatingTheme.primaryPink, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.titleMedium(
                  'Plan Your Date',
                  color: Colors.white,
                  fontWeight: 600,
                ),
                FxText.bodySmall(
                  'Get personalized suggestions for ${widget.matchedUser.first_name}',
                  color: DatingTheme.secondaryText,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DatingTheme.darkBackground,
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
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        tabs: const [
          Tab(text: 'Restaurants'),
          Tab(text: 'Activities'),
          Tab(text: 'Ideas'),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(DatingTheme.primaryPink),
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    if (_restaurants.isEmpty) {
      return _buildEmptyState(
        'No restaurants found',
        'Try adjusting your search preferences',
        Icons.restaurant,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return _buildRestaurantCard(restaurant);
      },
    );
  }

  Widget _buildActivitiesTab() {
    if (_activities.isEmpty) {
      return _buildEmptyState(
        'No activities found',
        'We\'ll find great date activities for you',
        Icons.local_activity,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildPersonalizedTab() {
    if (_personalizedIdeas.isEmpty) {
      return _buildEmptyState(
        'Generating ideas...',
        'Personalized suggestions based on your compatibility',
        Icons.lightbulb,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _personalizedIdeas.length,
      itemBuilder: (context, index) {
        final idea = _personalizedIdeas[index];
        return _buildPersonalizedIdeaCard(idea);
      },
    );
  }

  Widget _buildRestaurantCard(RestaurantSuggestion restaurant) {
    return GestureDetector(
      onTap: () => _selectRestaurant(restaurant),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DatingTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyLarge(
                        restaurant.name,
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            restaurant.cuisine,
                            style: TextStyle(
                              color: DatingTheme.primaryPink,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(color: DatingTheme.secondaryText),
                          ),
                          Text(
                            restaurant.priceRange,
                            style: TextStyle(
                              color: DatingTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(color: DatingTheme.secondaryText),
                          ),
                          Icon(
                            Icons.star,
                            size: 12,
                            color: DatingTheme.accentGold,
                          ),
                          Text(
                            restaurant.rating.toString(),
                            style: TextStyle(
                              color: DatingTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: DatingTheme.secondaryText,
                    ),
                    FxText.bodySmall(
                      '${restaurant.distance.toStringAsFixed(1)}km',
                      color: DatingTheme.secondaryText,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            FxText.bodyMedium(
              restaurant.description,
              color: DatingTheme.secondaryText,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DatingTheme.primaryPink.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FxText.bodySmall(
                restaurant.reasonForSuggestion,
                color: DatingTheme.primaryPink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(DateActivitySuggestion activity) {
    return GestureDetector(
      onTap: () => _selectActivity(activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DatingTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FxText.bodyLarge(
                    activity.title,
                    color: Colors.white,
                    fontWeight: 600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DatingTheme.primaryRose.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FxText.bodySmall(
                    activity.category,
                    color: DatingTheme.primaryRose,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FxText.bodyMedium(
              activity.description,
              color: DatingTheme.secondaryText,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: DatingTheme.secondaryText,
                ),
                const SizedBox(width: 4),
                FxText.bodySmall(
                  activity.duration,
                  color: DatingTheme.secondaryText,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: DatingTheme.secondaryText,
                ),
                FxText.bodySmall(
                  activity.priceRange,
                  color: DatingTheme.secondaryText,
                ),
                const Spacer(),
                if (activity.isIndoor)
                  Icon(Icons.home, size: 16, color: DatingTheme.accentGold),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DatingTheme.primaryPink.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FxText.bodySmall(
                activity.whyPerfectMatch,
                color: DatingTheme.primaryPink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedIdeaCard(PersonalizedDateIdea idea) {
    return GestureDetector(
      onTap: () => _selectPersonalizedIdea(idea),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DatingTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(idea.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: FxText.bodyLarge(
                    idea.title,
                    color: Colors.white,
                    fontWeight: 600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DatingTheme.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FxText.bodySmall(
                    idea.category,
                    color: DatingTheme.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FxText.bodyMedium(
              idea.description,
              color: DatingTheme.secondaryText,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: DatingTheme.secondaryText,
                ),
                const SizedBox(width: 4),
                FxText.bodySmall(
                  idea.duration,
                  color: DatingTheme.secondaryText,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.local_atm,
                  size: 16,
                  color: DatingTheme.secondaryText,
                ),
                FxText.bodySmall(
                  idea.estimatedCost,
                  color: DatingTheme.secondaryText,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DatingTheme.primaryPink.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FxText.bodySmall(
                idea.personalizedReason,
                color: DatingTheme.primaryPink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          FxText.titleMedium(title, color: Colors.white, fontWeight: 600),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            subtitle,
            color: DatingTheme.secondaryText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _selectRestaurant(RestaurantSuggestion restaurant) {
    final message =
        "How about we check out ${restaurant.name}? It's a ${restaurant.cuisine.toLowerCase()} restaurant with great reviews (${restaurant.rating}⭐). ${restaurant.reasonForSuggestion}";
    widget.onDateIdeaSelected(message);
    Navigator.pop(context);
  }

  void _selectActivity(DateActivitySuggestion activity) {
    final message =
        "I have an idea! What do you think about ${activity.title.toLowerCase()}? ${activity.description} It would take about ${activity.duration} and ${activity.whyPerfectMatch.toLowerCase()}";
    widget.onDateIdeaSelected(message);
    Navigator.pop(context);
  }

  void _selectPersonalizedIdea(PersonalizedDateIdea idea) {
    final message =
        "${idea.icon} ${idea.title} sounds perfect! ${idea.description} ${idea.personalizedReason} What do you think?";
    widget.onDateIdeaSelected(message);
    Navigator.pop(context);
  }
}
