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

class ModernMatchesScreen extends StatefulWidget {
  @override
  _ModernMatchesScreenState createState() => _ModernMatchesScreenState();
}

class _ModernMatchesScreenState extends State<ModernMatchesScreen>
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
    'all': 'All',
    'new': 'New',
    'recent': 'Active',
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
    Get.to(
      () => ChatScreen({
        'chatHead': {
          'customer_id': match.user.id.toString(),
          'product_owner_id': _mainC.userModel.id.toString(),
        },
        'matchedUser': match.user,
        'compatibilityScore': match.compatibilityScore,
        'isNewMatch': _isNewMatch(match),
        'isDatingMode': true,
      }),
    );
  }

  bool _isNewMatch(MatchModel match) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LovebirdsTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildModernAppBar(),
          SliverToBoxAdapter(child: _buildFilterChips()),
          _buildMatchesList(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: LovebirdsTheme.background,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'Matches',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                LovebirdsTheme.primary,
                LovebirdsTheme.accent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 12, top: 8),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: IconButton(
              icon: Icon(Icons.tune, color: Colors.white, size: 20),
              onPressed: () => _showFilterOptions(),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Container(
          height: 50,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: LovebirdsTheme.primary,
            unselectedLabelColor: Colors.white,
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            tabs: [
              Tab(child: Text('My Matches')),
              Tab(child: Text('Liked Me')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
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
            margin: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : LovebirdsTheme.primary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  if (count > 0) ...[
                    SizedBox(width: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withValues(alpha: 0.3)
                            : LovebirdsTheme.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (_) => _changeFilter(filter),
              selectedColor: LovebirdsTheme.primary,
              backgroundColor: Colors.white,
              elevation: isSelected ? 4 : 1,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchesList() {
    if (_isLoading && _currentPage == 1) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(LovebirdsTheme.primary),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Finding your perfect matches...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredMatches.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= _filteredMatches.length) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(LovebirdsTheme.primary),
                ),
              ),
            );
          }
          return _buildModernMatchCard(_filteredMatches[index], index);
        },
        childCount: _filteredMatches.length + (_hasMorePages ? 1 : 0),
      ),
    );
  }

  Widget _buildModernMatchCard(MatchModel match, int index) {
    final timeDiff = DateTime.now().difference(DateTime.parse(match.matchedAt));
    final timeAgo = _formatTimeAgo(timeDiff);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 8,
        shadowColor: LovebirdsTheme.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openChat(match),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildEnhancedAvatar(match.user),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                match.user.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: LovebirdsTheme.background,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildCompatibilityBadge(match.compatibilityScore),
                          ],
                        ),
                        SizedBox(height: 4),
                        if (match.user.age != null) ...[
                          Text(
                            '${match.user.age} years old',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                        Text(
                          match.conversationStarter.isNotEmpty
                              ? match.conversationStarter
                              : 'Say hello to ${match.user.name}! 👋',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                            SizedBox(width: 4),
                            Text(
                              'Matched $timeAgo',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _buildActionButton(
                        Icons.chat_bubble_rounded,
                        LovebirdsTheme.primary,
                        () => _openChat(match),
                      ),
                      SizedBox(height: 8),
                      _buildActionButton(
                        Icons.more_horiz,
                        Colors.grey.shade400,
                        () => _showMatchActions(match),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAvatar(UserModel user) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [LovebirdsTheme.primary, LovebirdsTheme.accent],
        ),
        boxShadow: [
          BoxShadow(
            color: LovebirdsTheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3),
        child: ClipOval(
          child: user.avatar.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: user.avatar,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: Colors.grey.shade400),
                  ),
                  errorWidget: (context, url, error) => _buildFallbackAvatar(user),
                )
              : _buildFallbackAvatar(user),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(user.name),
          style: TextStyle(
            color: LovebirdsTheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCompatibilityBadge(int score) {
    Color badgeColor;
    String label;

    if (score >= 80) {
      badgeColor = Colors.green;
      label = 'Perfect';
    } else if (score >= 60) {
      badgeColor = LovebirdsTheme.accent;
      label = 'Great';
    } else if (score >= 40) {
      badgeColor = Colors.orange;
      label = 'Good';
    } else {
      badgeColor = Colors.grey;
      label = 'Fair';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, size: 12, color: Colors.white),
          SizedBox(width: 2),
          Text(
            '$score%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    switch (_currentFilter) {
      case 'new':
        title = 'No new matches';
        subtitle = 'Keep swiping to find new connections!';
        icon = Icons.favorite_border;
        break;
      case 'recent':
        title = 'No recent activity';
        subtitle = 'Start conversations with your matches!';
        icon = Icons.chat_bubble_outline;
        break;
      case 'unread':
        title = 'All caught up!';
        subtitle = 'No unread messages from matches.';
        icon = Icons.mark_email_read;
        break;
      default:
        title = 'No matches yet';
        subtitle = 'Start swiping to find your perfect match!';
        icon = Icons.search;
    }

    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  LovebirdsTheme.primary.withValues(alpha: 0.2),
                  LovebirdsTheme.accent.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Icon(icon, size: 60, color: Colors.white70),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.swipe, color: Colors.white),
            label: Text(
              'Start Swiping',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: LovebirdsTheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [LovebirdsTheme.primary, LovebirdsTheme.accent],
        ),
        boxShadow: [
          BoxShadow(
            color: LovebirdsTheme.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showDatingFeaturesMenu(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Icon(Icons.favorite, color: Colors.white),
        label: Text(
          'Features',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [LovebirdsTheme.background, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
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
            Text(
              'Filter Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ...['all', 'new', 'recent', 'unread'].map((filter) {
              return ListTile(
                leading: Icon(
                  filter == _currentFilter ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: filter == _currentFilter ? LovebirdsTheme.primary : Colors.white70,
                ),
                title: Text(
                  _filterLabels[filter]!,
                  style: TextStyle(
                    color: filter == _currentFilter ? Colors.white : Colors.white70,
                    fontWeight: filter == _currentFilter ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: _filterCounts[filter] != null && _filterCounts[filter]! > 0
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: LovebirdsTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _filterCounts[filter].toString(),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _changeFilter(filter);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showMatchActions(MatchModel match) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [LovebirdsTheme.background, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
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
            Text(
              'Actions for ${match.user.name}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ...[
              {'icon': Icons.chat, 'title': 'Send Message', 'action': 'chat'},
              {'icon': Icons.card_giftcard, 'title': 'Send Gift', 'action': 'gift'},
              {'icon': Icons.calendar_today, 'title': 'Plan Date', 'action': 'date'},
              {'icon': Icons.shopping_cart, 'title': 'Shop Together', 'action': 'shop'},
            ].map((item) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: LovebirdsTheme.primary.withValues(alpha: 0.2),
                  child: Icon(item['icon'] as IconData, color: LovebirdsTheme.primary),
                ),
                title: Text(
                  item['title'] as String,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleMatchAction(item['action'] as String, match);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showDatingFeaturesMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [LovebirdsTheme.background, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
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
            Text(
              'Dating Features',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ...[
              {
                'icon': Icons.calendar_today,
                'title': 'Plan a Date',
                'subtitle': 'Find amazing date ideas',
                'action': 'date_planning'
              },
              {
                'icon': Icons.card_giftcard,
                'title': 'Send Gifts',
                'subtitle': 'Surprise your matches',
                'action': 'send_gifts'
              },
              {
                'icon': Icons.shopping_cart,
                'title': 'Shop Together',
                'subtitle': 'Browse items as a couple',
                'action': 'couple_shopping'
              },
              {
                'icon': Icons.celebration,
                'title': 'Milestone Gifts',
                'subtitle': 'Celebrate special moments',
                'action': 'milestone_gifts'
              },
            ].map((item) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [LovebirdsTheme.primary, LovebirdsTheme.accent],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(item['icon'] as IconData, color: Colors.white, size: 24),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    item['subtitle'] as String,
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _handleMenuAction(item['action'] as String);
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _handleMatchAction(String action, MatchModel match) {
    switch (action) {
      case 'chat':
        _openChat(match);
        break;
      case 'gift':
        _openSendGiftForMatch(match);
        break;
      case 'date':
        _openDatePlanningForMatch(match);
        break;
      case 'shop':
        _openCoupleShoppingForMatch(match);
        break;
    }
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

  void _showDatePlanningDemo() {
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
            backgroundColor: LovebirdsTheme.primary.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  void _showSendGiftsDemo() {
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
            backgroundColor: LovebirdsTheme.primary.withValues(alpha: 0.9),
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
        relationshipStartDate: DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
      ),
    );
  }

  void _openSendGiftForMatch(MatchModel match) {
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
            backgroundColor: LovebirdsTheme.primary.withValues(alpha: 0.9),
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
            backgroundColor: LovebirdsTheme.primary.withValues(alpha: 0.9),
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

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0][0].toUpperCase();
  }
}
