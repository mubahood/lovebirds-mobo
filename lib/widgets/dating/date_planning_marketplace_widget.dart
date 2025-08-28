import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';

import '../../models/UserModel.dart';
import '../../services/date_marketplace_service.dart';
import '../../services/date_planning_service.dart';
import '../../utils/dating_theme.dart';

/// Date Planning Marketplace Widget with booking capabilities
class DatePlanningMarketplaceWidget extends StatefulWidget {
  final UserModel currentUser;
  final UserModel matchedUser;
  final Function(String) onDateBooked;

  const DatePlanningMarketplaceWidget({
    Key? key,
    required this.currentUser,
    required this.matchedUser,
    required this.onDateBooked,
  }) : super(key: key);

  @override
  _DatePlanningMarketplaceWidgetState createState() =>
      _DatePlanningMarketplaceWidgetState();
}

class _DatePlanningMarketplaceWidgetState
    extends State<DatePlanningMarketplaceWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<RestaurantSuggestion> _restaurants = [];
  List<DateActivitySuggestion> _activities = [];
  List<DatePackage> _datePackages = [];
  List<BookingHistory> _bookingHistory = [];

  bool _isLoading = true;
  bool _isBooking = false;

  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  String _selectedTime = '';
  int _partySize = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _loadMarketplaceData();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketplaceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        DatePlanningService.getRestaurantSuggestions(
          currentUser: widget.currentUser,
          matchedUser: widget.matchedUser,
          maxDistance: 15.0,
        ),
        DatePlanningService.getDateActivitySuggestions(
          currentUser: widget.currentUser,
          matchedUser: widget.matchedUser,
        ),
        DateMarketplaceService.getDatePackages(
          currentUser: widget.currentUser,
          matchedUser: widget.matchedUser,
        ),
        DateMarketplaceService.getBookingHistory(
          userId: widget.currentUser.id,
          limit: 10,
        ),
      ]);

      _restaurants = results[0] as List<RestaurantSuggestion>;
      _activities = results[1] as List<DateActivitySuggestion>;
      _datePackages = results[2] as List<DatePackage>;
      _bookingHistory = results[3] as List<BookingHistory>;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading marketplace data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child:
                  _isLoading
                      ? _buildLoadingState()
                      : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRestaurantsTab(),
                          _buildActivitiesTab(),
                          _buildPackagesTab(),
                          _buildHistoryTab(),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(FeatherIcons.calendar, color: DatingTheme.primaryPink, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.titleMedium(
                  'Date Planning Marketplace',
                  color: Colors.white,
                  fontWeight: 600,
                ),
                FxText.bodySmall(
                  'Book restaurants, activities & complete date packages',
                  color: DatingTheme.secondaryText,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(FeatherIcons.x, color: DatingTheme.secondaryText),
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
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: DatingTheme.primaryPink,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: DatingTheme.secondaryText,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        tabs: const [
          Tab(text: 'Restaurants'),
          Tab(text: 'Activities'),
          Tab(text: 'Packages'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(DatingTheme.primaryPink),
          ),
          const SizedBox(height: 16),
          FxText.bodyMedium(
            'Loading marketplace options...',
            color: DatingTheme.secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    if (_restaurants.isEmpty) {
      return _buildEmptyState(
        'No restaurants available',
        'Try different filters or check back later',
        FeatherIcons.coffee,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return _buildBookableRestaurantCard(restaurant);
      },
    );
  }

  Widget _buildActivitiesTab() {
    if (_activities.isEmpty) {
      return _buildEmptyState(
        'No activities available',
        'Check back soon for exciting date activities',
        FeatherIcons.activity,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return _buildBookableActivityCard(activity);
      },
    );
  }

  Widget _buildPackagesTab() {
    if (_datePackages.isEmpty) {
      return _buildEmptyState(
        'No packages available',
        'Complete date packages coming soon',
        FeatherIcons.package,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _datePackages.length,
      itemBuilder: (context, index) {
        final package = _datePackages[index];
        return _buildDatePackageCard(package);
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_bookingHistory.isEmpty) {
      return _buildEmptyState(
        'No booking history',
        'Your date bookings will appear here',
        FeatherIcons.clock,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookingHistory.length,
      itemBuilder: (context, index) {
        final booking = _bookingHistory[index];
        return _buildHistoryCard(booking);
      },
    );
  }

  Widget _buildBookableRestaurantCard(RestaurantSuggestion restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: DatingTheme.darkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant info header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.titleSmall(
                        restaurant.name,
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            FeatherIcons.mapPin,
                            size: 14,
                            color: DatingTheme.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant.distance.toStringAsFixed(1)}km • ${restaurant.cuisine}',
                            style: TextStyle(
                              color: DatingTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            size: 14,
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DatingTheme.primaryPink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    restaurant.priceRange,
                    style: TextStyle(
                      color: DatingTheme.primaryPink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FxText.bodySmall(
              restaurant.description,
              color: DatingTheme.secondaryText,
              maxLines: 2,
            ),
          ),

          // Booking section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  'Book a Table',
                  color: Colors.white,
                  fontWeight: 600,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDateSelector()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPartySizeSelector()),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isBooking ? null : () => _bookRestaurant(restaurant),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DatingTheme.primaryPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child:
                        _isBooking
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Booking...'),
                              ],
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FeatherIcons.calendar, size: 16),
                                const SizedBox(width: 8),
                                Text('Book Table'),
                              ],
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

  Widget _buildBookableActivityCard(DateActivitySuggestion activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: DatingTheme.darkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity info header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DatingTheme.primaryPink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    FeatherIcons.activity,
                    color: DatingTheme.primaryPink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.titleSmall(
                        activity.title,
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                      Text(
                        '${activity.category} • ${activity.duration}',
                        style: TextStyle(
                          color: DatingTheme.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DatingTheme.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activity.priceRange,
                    style: TextStyle(
                      color: DatingTheme.accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FxText.bodySmall(
              activity.description,
              color: DatingTheme.secondaryText,
              maxLines: 2,
            ),
          ),

          // Compatibility score
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DatingTheme.secondaryPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    FeatherIcons.heart,
                    color: DatingTheme.secondaryPurple,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FxText.bodySmall(
                      activity.whyPerfectMatch,
                      color: DatingTheme.secondaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Book button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : () => _bookActivity(activity),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DatingTheme.secondaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FeatherIcons.bookmark, size: 16),
                    const SizedBox(width: 8),
                    Text('Book Activity'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePackageCard(DatePackage package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: DatingTheme.darkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package header with savings badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.titleMedium(
                        package.name,
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                      const SizedBox(height: 4),
                      FxText.bodySmall(
                        package.description,
                        color: DatingTheme.secondaryText,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DatingTheme.successGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Save \$${package.savings.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: DatingTheme.successGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${package.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Package details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FeatherIcons.clock,
                      size: 14,
                      color: DatingTheme.secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      package.duration,
                      style: TextStyle(
                        color: DatingTheme.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.star, size: 14, color: DatingTheme.accentGold),
                    const SizedBox(width: 4),
                    Text(
                      '${package.rating} (${package.reviewCount})',
                      style: TextStyle(
                        color: DatingTheme.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FxText.bodySmall(
                  'Includes:',
                  color: Colors.white,
                  fontWeight: 600,
                ),
                const SizedBox(height: 8),
                ...package.includes
                    .take(3)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              FeatherIcons.check,
                              size: 12,
                              color: DatingTheme.successGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: DatingTheme.secondaryText,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (package.includes.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+ ${package.includes.length - 3} more items',
                      style: TextStyle(
                        color: DatingTheme.primaryPink,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Book package button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : () => _bookPackage(package),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DatingTheme.successGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FeatherIcons.gift, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Book Complete Package',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BookingHistory booking) {
    Color statusColor;
    IconData statusIcon;

    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = DatingTheme.successGreen;
        statusIcon = FeatherIcons.checkCircle;
        break;
      case BookingStatus.completed:
        statusColor = DatingTheme.secondaryPurple;
        statusIcon = FeatherIcons.check;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = FeatherIcons.xCircle;
        break;
      default:
        statusColor = DatingTheme.accentGold;
        statusIcon = FeatherIcons.clock;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  booking.title,
                  color: Colors.white,
                  fontWeight: 600,
                ),
                Text(
                  '${booking.type.toString().split('.').last.toUpperCase()} • \$${booking.cost.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: DatingTheme.secondaryText,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                  style: TextStyle(
                    color: DatingTheme.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (booking.status == BookingStatus.completed && booking.rating > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DatingTheme.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 12, color: DatingTheme.accentGold),
                  const SizedBox(width: 4),
                  Text(
                    booking.rating.toString(),
                    style: TextStyle(
                      color: DatingTheme.accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DatingTheme.darkBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              FeatherIcons.calendar,
              size: 16,
              color: DatingTheme.secondaryText,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_selectedDate.day}/${_selectedDate.month}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartySizeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DatingTheme.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(FeatherIcons.users, size: 16, color: DatingTheme.secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$_partySize people',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
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

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: DatingTheme.primaryPink,
              surface: DatingTheme.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _bookRestaurant(RestaurantSuggestion restaurant) async {
    setState(() {
      _isBooking = true;
    });

    try {
      final result = await DateMarketplaceService.bookRestaurant(
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
        currentUser: widget.currentUser,
        matchedUser: widget.matchedUser,
        preferredDate: _selectedDate,
        preferredTime: _selectedTime.isEmpty ? '7:00 PM' : _selectedTime,
        partySize: _partySize,
        paymentMethod: 'interac_debit',
      );

      if (result.status == BookingStatus.confirmed) {
        widget.onDateBooked(
          'Great news! I just booked us a table at ${restaurant.name} for ${_selectedDate.day}/${_selectedDate.month} at ${result.reservationTime}. '
          'Confirmation #${result.confirmationNumber}. Looking forward to our date! 💕',
        );
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restaurant booked successfully!'),
            backgroundColor: DatingTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      print('Error booking restaurant: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }

  void _bookActivity(DateActivitySuggestion activity) async {
    setState(() {
      _isBooking = true;
    });

    try {
      final result = await DateMarketplaceService.bookActivity(
        activityId: activity.id,
        activityName: activity.title,
        currentUser: widget.currentUser,
        matchedUser: widget.matchedUser,
        preferredDate: _selectedDate,
        preferredTime: '2:00 PM',
        numberOfPeople: 2,
        paymentMethod: 'interac_debit',
      );

      if (result.status == BookingStatus.confirmed) {
        widget.onDateBooked(
          'Exciting! I booked us for ${activity.title} on ${_selectedDate.day}/${_selectedDate.month}. '
          'Confirmation #${result.confirmationNumber}. ${activity.whyPerfectMatch} 🎉',
        );
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Activity booked successfully!'),
            backgroundColor: DatingTheme.secondaryPurple,
          ),
        );
      }
    } catch (e) {
      print('Error booking activity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }

  void _bookPackage(DatePackage package) async {
    setState(() {
      _isBooking = true;
    });

    try {
      final result = await DateMarketplaceService.bookDatePackage(
        packageId: package.id,
        currentUser: widget.currentUser,
        matchedUser: widget.matchedUser,
        preferredDate: _selectedDate,
        paymentMethod: 'interac_debit',
      );

      if (result.status == BookingStatus.confirmed) {
        widget.onDateBooked(
          'Amazing! I booked us the complete "${package.name}" package for ${_selectedDate.day}/${_selectedDate.month}. '
          'Confirmation #${result.confirmationNumber}. This is going to be an incredible date! 💖',
        );
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Date package booked successfully!'),
            backgroundColor: DatingTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      print('Error booking package: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }
}
