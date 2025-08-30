import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/MainController.dart';
import '../../models/UserModel.dart';
import '../../services/swipe_service.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/lovebirds_theme.dart';
import '../../widgets/dating/send_gift_widget.dart';
import '../../widgets/dating/date_planning_widget.dart';
import '../../widgets/dating/couple_shopping_widget.dart';
import '../../widgets/dating/milestone_gift_suggestions_widget.dart';
import 'who_liked_me_screen.dart';
import '../shop/screens/shop/chat/chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MainController _mainC = Get.find<MainController>();

  List<MatchModel> _allMatches = [];
  List<MatchModel> _filteredMatches = [];
  Map<String, int> _filterCounts = {};
  bool _isLoading = true;
  String _currentFilter = 'all';
  int _currentPage = 1;
  bool _hasMorePages = true;
  final ScrollController _scrollController = ScrollController();

  final List<String> _filters = ['all', 'new', 'recent', 'unread'];
  final Map<String, String> _filterLabels = {
    'all': 'All Matches',
    'new': 'New',
    'recent': 'Recent',
    'unread': 'Unread',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMatches();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMatches() async {
    try {
      final response = await SwipeService.getFilteredMatches(
        page: _currentPage,
        filter: _currentFilter,
      );

      setState(() {
        if (_currentPage == 1) {
          _allMatches = response.matches;
          _filteredMatches = response.matches;
          _filterCounts = response.filterCounts;
        } else {
          _allMatches.addAll(response.matches);
          _filteredMatches.addAll(response.matches);
        }
        _isLoading = false;
        _hasMorePages = response.hasMore;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load matches: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMorePages &&
        !_isLoading) {
      _currentPage++;
      _isLoading = true;
      _loadMatches();
    }
  }

  void _changeFilter(String filter) {
    if (filter != _currentFilter) {
      setState(() {
        _currentFilter = filter;
        _currentPage = 1;
        _isLoading = true;
        _filteredMatches.clear();
      });
      _loadMatches();
    }
  }

  void _openChat(MatchModel match) {
    // Navigate to enhanced chat screen with dating parameters
    Get.to(
      () => ChatScreen({
        'chatHead': {
          'customer_id': match.user.id.toString(),
          'product_owner_id': _mainC.userModel.id.toString(),
        },
        'matchedUser': match.user,
        'compatibilityScore': match.compatibilityScore,
        'isNewMatch': _isNewMatch(match),
        'isDatingMode': true, // Flag to enable dating features
      }),
    );
  }

  bool _isNewMatch(MatchModel match) {
    // Check if this match is from today (new)
    final now = DateTime.now();
    final matchDate = DateTime.parse(match.matchedAt);
    return now.difference(matchDate).inDays == 0;
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'date_planning':
        _showDatePlanningDemo();
        break;
      case 'send_gifts':
        _showSendGiftsDemo();
        break;
      case 'couple_shopping':
        _showCoupleShoppingDemo();
        break;
      case 'milestone_gifts':
        _showMilestoneGiftsDemo();
        break;
    }
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(title, color: Colors.white, fontWeight: 600),
                FxText.bodySmall(subtitle, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDatingFeaturesMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CustomTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                FxText.titleMedium(
                  'Dating & Marketplace Features',
                  color: Colors.white,
                  fontWeight: 700,
                ),
                SizedBox(height: 20),
                _buildFeatureButton(
                  Icons.calendar_today,
                  'Plan a Date',
                  'Discover restaurants and activities',
                  () => _showDatePlanningDemo(),
                ),
                _buildFeatureButton(
                  Icons.card_giftcard,
                  'Send Gifts',
                  'Surprise your matches with thoughtful gifts',
                  () => _showSendGiftsDemo(),
                ),
                _buildFeatureButton(
                  Icons.shopping_cart,
                  'Shop Together',
                  'Browse and buy items as a couple',
                  () => _showCoupleShoppingDemo(),
                ),
                _buildFeatureButton(
                  Icons.celebration,
                  'Milestone Gifts',
                  'Special gifts for relationship milestones',
                  () => _showMilestoneGiftsDemo(),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildFeatureButton(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CustomTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: CustomTheme.primary, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyMedium(
                        title,
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                      SizedBox(height: 4),
                      FxText.bodySmall(subtitle, color: Colors.white70),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDatePlanningDemo() {
    // Create demo user models
    final demoCurrentUser = UserModel();
    demoCurrentUser.id = 1;
    demoCurrentUser.name = 'Current User';
    demoCurrentUser.email = 'current@demo.com';

    final demoMatchedUser = UserModel();
    demoMatchedUser.id = 2;
    demoMatchedUser.name = 'Demo Match';
    demoMatchedUser.email = 'match@demo.com';

    Get.to(
      () => DatePlanningWidget(
        currentUser: demoCurrentUser,
        matchedUser: demoMatchedUser,
        onDateIdeaSelected: (idea) {
          Get.back();
          Get.snackbar(
            'Date Idea Selected',
            idea,
            backgroundColor: CustomTheme.primary.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  void _showSendGiftsDemo() {
    // Create demo user models
    final demoCurrentUser = UserModel();
    demoCurrentUser.id = 1;
    demoCurrentUser.name = 'Current User';
    demoCurrentUser.email = 'current@demo.com';

    final demoMatchedUser = UserModel();
    demoMatchedUser.id = 2;
    demoMatchedUser.name = 'Demo Match';
    demoMatchedUser.email = 'match@demo.com';

    Get.to(
      () => SendGiftWidget(
        currentUser: demoCurrentUser,
        matchedUser: demoMatchedUser,
        onGiftSent: (result) {
          Get.back();
          Get.snackbar(
            'Gift Sent',
            'Gift sent successfully to ${demoMatchedUser.name}!',
            backgroundColor: CustomTheme.primary.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  void _showCoupleShoppingDemo() {
    Get.to(
      () => CoupleShoppingWidget(
        partnerId: 'demo_partner',
        partnerName: 'Demo Match',
      ),
    );
  }

  void _showMilestoneGiftsDemo() {
    Get.to(
      () => MilestoneGiftSuggestionsWidget(
        partnerId: 'demo_partner',
        partnerName: 'Demo Match',
        relationshipStartDate:
            DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
      ),
    );
  }

  void _handleMatchAction(String action, MatchModel match) {
    switch (action) {
      case 'send_gift':
        _openSendGiftForMatch(match);
        break;
      case 'plan_date':
        _openDatePlanningForMatch(match);
        break;
      case 'shop_together':
        _openCoupleShoppingForMatch(match);
        break;
      case 'milestone_gifts':
        _openMilestoneGiftsForMatch(match);
        break;
    }
  }

  Widget _buildMatchMenuItem(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        SizedBox(width: 12),
        FxText.bodyMedium(title, color: Colors.white),
      ],
    );
  }

  void _openSendGiftForMatch(MatchModel match) {
    // Create demo user models
    final demoCurrentUser = UserModel();
    demoCurrentUser.id = 1;
    demoCurrentUser.name = 'Current User';
    demoCurrentUser.email = 'current@demo.com';

    final matchedUser = UserModel();
    matchedUser.id = match.user.id;
    matchedUser.name = match.user.name;
    matchedUser.email = match.user.email;

    Get.to(
      () => SendGiftWidget(
        currentUser: demoCurrentUser,
        matchedUser: matchedUser,
        onGiftSent: (result) {
          Get.back();
          Get.snackbar(
            'Gift Sent',
            'Gift sent successfully to ${match.user.name}!',
            backgroundColor: CustomTheme.primary.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  void _openDatePlanningForMatch(MatchModel match) {
    final demoCurrentUser = UserModel();
    demoCurrentUser.id = 1;
    demoCurrentUser.name = 'Current User';
    demoCurrentUser.email = 'current@demo.com';

    final matchedUser = UserModel();
    matchedUser.id = match.user.id;
    matchedUser.name = match.user.name;
    matchedUser.email = match.user.email;

    Get.to(
      () => DatePlanningWidget(
        currentUser: demoCurrentUser,
        matchedUser: matchedUser,
        onDateIdeaSelected: (idea) {
          Get.back();
          Get.snackbar(
            'Date Planned',
            'Date idea selected for ${match.user.name}: $idea',
            backgroundColor: CustomTheme.primary.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  void _openCoupleShoppingForMatch(MatchModel match) {
    Get.to(
      () => CoupleShoppingWidget(
        partnerId: match.user.id.toString(),
        partnerName: match.user.name,
      ),
    );
  }

  void _openMilestoneGiftsForMatch(MatchModel match) {
    Get.to(
      () => MilestoneGiftSuggestionsWidget(
        partnerId: match.user.id.toString(),
        partnerName: match.user.name,
        relationshipStartDate: match.matchedAt,
      ),
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
          'Matches',
          fontWeight: 700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Quick access to dating features
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: CustomTheme.background,
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'date_planning',
                    child: _buildMenuItem(
                      Icons.calendar_today,
                      'Plan a Date',
                      'Discover and book date activities',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'send_gifts',
                    child: _buildMenuItem(
                      Icons.card_giftcard,
                      'Send Gifts',
                      'Surprise your matches with gifts',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'couple_shopping',
                    child: _buildMenuItem(
                      Icons.shopping_cart,
                      'Shop Together',
                      'Browse and buy items together',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'milestone_gifts',
                    child: _buildMenuItem(
                      Icons.celebration,
                      'Milestone Gifts',
                      'Gifts for special occasions',
                    ),
                  ),
                ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: LovebirdsTheme.primary,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('My Matches'),
                  ),
                ),
                Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Who Liked Me'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMatchesTab(), WhoLikedMeScreen()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDatingFeaturesMenu(),
        backgroundColor: CustomTheme.primary,
        icon: Icon(Icons.favorite, color: Colors.white),
        label: FxText.bodyMedium(
          'Dating Features',
          color: Colors.white,
          fontWeight: 600,
        ),
      ),
    );
  }

  Widget _buildMatchesTab() {
    return Column(
      children: [
        // Filter tabs
        _buildFilterTabs(),

        // Matches content
        Expanded(child: _buildMatchesContent()),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final label = _filterLabels[filter]!;
          final count = _filterCounts[filter] ?? 0;
          final isSelected = filter == _currentFilter;

          return Container(
            margin: EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _changeFilter(filter),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? CustomTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? CustomTheme.primary : Colors.white30,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FxText.bodyMedium(
                      label,
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? 600 : 400,
                    ),
                    if (count > 0) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : CustomTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FxText.bodySmall(
                          count.toString(),
                          color: Colors.white,
                          fontWeight: 600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchesContent() {
    if (_isLoading && _currentPage == 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
            ),
            SizedBox(height: 16),
            FxText.bodyMedium('Loading your matches...', color: Colors.white70),
          ],
        ),
      );
    }

    if (_filteredMatches.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: _filteredMatches.length + (_hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _filteredMatches.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
              ),
            ),
          );
        }

        final match = _filteredMatches[index];
        return _buildMatchCard(match);
      },
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    switch (_currentFilter) {
      case 'new':
        title = 'No new matches';
        subtitle = 'Keep swiping to find new people!';
        icon = Icons.fiber_new;
        break;
      case 'recent':
        title = 'No recent activity';
        subtitle = 'Start conversations with your matches!';
        icon = Icons.access_time;
        break;
      case 'unread':
        title = 'All caught up!';
        subtitle = 'No unread messages from your matches.';
        icon = Icons.mark_email_read;
        break;
      default:
        title = 'No matches yet';
        subtitle = 'Start swiping to find your perfect match!';
        icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          SizedBox(height: 24),
          FxText.titleMedium(title, color: Colors.white, fontWeight: 600),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: FxText.bodyMedium(
              subtitle,
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.swipe, color: Colors.white),
            label: FxText.bodyMedium(
              'Start Swiping',
              color: Colors.white,
              fontWeight: 600,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    final timeDiff = DateTime.now().difference(DateTime.parse(match.matchedAt));
    final timeAgo = _formatTimeAgo(timeDiff);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _openChat(match),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // User photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 60,
                    height: 60,
                    child: _buildUserAvatar(match.user),
                  ),
                ),

                SizedBox(width: 16),

                // User info
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: FxText.titleSmall(
                              match.user.name,
                              color: Colors.white,
                              fontWeight: 600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (match.messagesCount > 0) ...[
                            SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: CustomTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: 4),

                      FxText.bodySmall(
                        match.conversationStarter.isNotEmpty
                            ? match.conversationStarter
                            : 'Say hello to ${match.user.name}!',
                        color: Colors.white70,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4),

                      FxText.bodySmall(
                        'Matched $timeAgo',
                        color: Colors.white60,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12),

                // Quick action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chat button
                    GestureDetector(
                      onTap: () => _openChat(match),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CustomTheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: CustomTheme.primary,
                          size: 20,
                        ),
                      ),
                    ),

                    SizedBox(width: 8),

                    // Dating features menu
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.more_horiz,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      color: CustomTheme.background,
                      onSelected: (value) => _handleMatchAction(value, match),
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'send_gift',
                              child: _buildMatchMenuItem(
                                Icons.card_giftcard,
                                'Send Gift',
                              ),
                            ),
                            PopupMenuItem(
                              value: 'plan_date',
                              child: _buildMatchMenuItem(
                                Icons.calendar_today,
                                'Plan Date',
                              ),
                            ),
                            PopupMenuItem(
                              value: 'shop_together',
                              child: _buildMatchMenuItem(
                                Icons.shopping_cart,
                                'Shop Together',
                              ),
                            ),
                            PopupMenuItem(
                              value: 'milestone_gifts',
                              child: _buildMatchMenuItem(
                                Icons.celebration,
                                'Milestone Gifts',
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(Duration difference) {
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildUserAvatar(UserModel user) {
    final avatarUrl = user.avatar.isNotEmpty ? user.avatar : null;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: CustomTheme.card,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipOval(
        child:
            avatarUrl != null
                ? CachedNetworkImage(
                  imageUrl: avatarUrl,
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                  placeholder:
                      (context, url) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: CustomTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              CustomTheme.primary,
                            ),
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => _buildFallbackAvatar(user),
                )
                : _buildFallbackAvatar(user),
      ),
    );
  }

  Widget _buildFallbackAvatar(UserModel user) {
    final initials = _getInitials(user.name);
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: CustomTheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0][0].toUpperCase();
  }
}
