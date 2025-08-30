import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/MainController.dart';
import '../../models/UserModel.dart';
import '../../services/swipe_service.dart';
import '../../utils/lovebirds_theme.dart';
import '../../widgets/dating/send_gift_widget.dart';
import '../../widgets/dating/date_planning_widget.dart';
import '../../widgets/dating/couple_shopping_widget.dart';
import '../../widgets/dating/milestone_gift_suggestions_widget.dart';
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
        'compatibilityScore': match.compatibilityScore.toInt(),
        'isNewMatch': _isNewMatch(match),
        'isDatingMode': true,
      }),
    );
  }

  bool _isNewMatch(MatchModel match) {
    return match.isNew;
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
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildStunningAppBar(),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(child: _buildModernFilterChips()),
          SliverToBoxAdapter(child: SizedBox(height: 12)),
          _buildBeautifulMatchesList(),
        ],
      ),
      floatingActionButton: _buildPremiumFloatingActionButton(),
    );
  }

  Widget _buildStunningAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20, bottom: 20),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Matches',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '${_filteredMatches.length} connections waiting',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                LovebirdsTheme.primary,
                LovebirdsTheme.accent,
                Colors.pink.shade300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Subtle decorative elements
              Positioned(
                top: 40,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: 30,
                child: Icon(
                  Icons.favorite,
                  color: Colors.white.withValues(alpha: 0.12),
                  size: 20,
                ),
              ),
              Positioned(
                top: 30,
                right: 100,
                child: Icon(
                  Icons.favorite,
                  color: Colors.white.withValues(alpha: 0.08),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16, top: 8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: IconButton(
              icon: Icon(Icons.tune_rounded, color: Colors.white, size: 20),
              onPressed: () => _showFilterOptions(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernFilterChips() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(vertical: 4),
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
            margin: EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : LovebirdsTheme.primary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (count > 0) ...[
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withValues(alpha: 0.3)
                            : LovebirdsTheme.accent,
                        borderRadius: BorderRadius.circular(10),
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
              elevation: isSelected ? 6 : 2,
              shadowColor: isSelected ? LovebirdsTheme.primary.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBeautifulMatchesList() {
    if (_isLoading && _currentPage == 1) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [LovebirdsTheme.primary, LovebirdsTheme.accent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Finding your perfect matches...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredMatches.isEmpty) {
      return SliverFillRemaining(child: _buildStunningEmptyState());
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
          return _buildPremiumMatchCard(_filteredMatches[index], index);
        },
        childCount: _filteredMatches.length + (_hasMorePages ? 1 : 0),
      ),
    );
  }

  Widget _buildPremiumMatchCard(MatchModel match, int index) {
    final timeDiff = DateTime.now().difference(DateTime.parse(match.matchedAt));
    final timeAgo = _formatTimeAgo(timeDiff);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 12,
        shadowColor: LovebirdsTheme.primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _openChat(match),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildGorgeousAvatar(match.user),
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
                                  color: Colors.grey.shade800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildBeautifulCompatibilityBadge(match.compatibilityScore.toInt()),
                          ],
                        ),
                        SizedBox(height: 6),
                        if (match.user.age != null && match.user.age! > 0) ...[
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
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
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
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                            SizedBox(width: 4),
                            Text(
                              'Matched $timeAgo',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Spacer(),
                            if (match.isNew) 
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade400,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _buildPremiumActionButton(
                        Icons.chat_bubble_rounded,
                        LovebirdsTheme.primary,
                        () => _openChat(match),
                      ),
                      SizedBox(height: 8),
                      _buildPremiumActionButton(
                        Icons.more_horiz_rounded,
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

  Widget _buildGorgeousAvatar(UserModel user) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            LovebirdsTheme.primary,
            LovebirdsTheme.accent,
            Colors.pink.shade300,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: LovebirdsTheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
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
                    child: Icon(Icons.person, color: Colors.grey.shade400, size: 30),
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
        color: Colors.grey.shade100,
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

  Widget _buildBeautifulCompatibilityBadge(int score) {
    Color badgeColor;
    String label;

    if (score >= 80) {
      badgeColor = Colors.green.shade400;
      label = 'Perfect';
    } else if (score >= 60) {
      badgeColor = LovebirdsTheme.accent;
      label = 'Great';
    } else if (score >= 40) {
      badgeColor = Colors.orange.shade400;
      label = 'Good';
    } else {
      badgeColor = Colors.grey.shade400;
      label = 'Fair';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            '$score%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildStunningEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    switch (_currentFilter) {
      case 'new':
        title = 'No new matches yet';
        subtitle = 'Keep swiping to find fresh connections!';
        icon = Icons.favorite_border_rounded;
        break;
      case 'recent':
        title = 'No recent activity';
        subtitle = 'Start conversations with your matches!';
        icon = Icons.chat_bubble_outline_rounded;
        break;
      case 'unread':
        title = 'All caught up!';
        subtitle = 'No unread messages from matches.';
        icon = Icons.mark_email_read_rounded;
        break;
      default:
        title = 'No matches yet';
        subtitle = 'Start swiping to find your perfect match!';
        icon = Icons.search_rounded;
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
                  LovebirdsTheme.primary.withValues(alpha: 0.1),
                  LovebirdsTheme.accent.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: LovebirdsTheme.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(icon, size: 50, color: LovebirdsTheme.primary.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [LovebirdsTheme.primary, LovebirdsTheme.accent],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: LovebirdsTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.swipe_rounded, color: Colors.white),
              label: Text(
                'Start Swiping',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            LovebirdsTheme.primary,
            LovebirdsTheme.accent,
            Colors.pink.shade300,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: LovebirdsTheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showDatingFeaturesMenu(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
        label: Text(
          'Features',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
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
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Filter Your Matches',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ...['all', 'new', 'recent', 'unread'].map((filter) {
              final isSelected = filter == _currentFilter;
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? LovebirdsTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? LovebirdsTheme.primary.withValues(alpha: 0.3) : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? LovebirdsTheme.primary : Colors.grey.shade200,
                    ),
                    child: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _filterLabels[filter]!,
                    style: TextStyle(
                      color: isSelected ? LovebirdsTheme.primary : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  trailing: _filterCounts[filter] != null && _filterCounts[filter]! > 0
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: LovebirdsTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _filterCounts[filter].toString(),
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _changeFilter(filter);
                  },
                ),
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
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Actions for ${match.user.name}',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ...[
              {'icon': Icons.chat_rounded, 'title': 'Send Message', 'action': 'chat', 'color': LovebirdsTheme.primary},
              {'icon': Icons.card_giftcard_rounded, 'title': 'Send Gift', 'action': 'gift', 'color': Colors.orange.shade400},
              {'icon': Icons.calendar_today_rounded, 'title': 'Plan Date', 'action': 'date', 'color': Colors.green.shade400},
              {'icon': Icons.shopping_cart_rounded, 'title': 'Shop Together', 'action': 'shop', 'color': Colors.purple.shade400},
            ].map((item) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _handleMatchAction(item['action'] as String, match);
                  },
                ),
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
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Dating Features',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ...[
              {
                'icon': Icons.calendar_today_rounded,
                'title': 'Plan a Date',
                'subtitle': 'Find amazing date ideas',
                'action': 'date_planning',
                'color': Colors.green.shade400,
              },
              {
                'icon': Icons.card_giftcard_rounded,
                'title': 'Send Gifts',
                'subtitle': 'Surprise your matches',
                'action': 'send_gifts',
                'color': Colors.orange.shade400,
              },
              {
                'icon': Icons.shopping_cart_rounded,
                'title': 'Shop Together',
                'subtitle': 'Browse items as a couple',
                'action': 'couple_shopping',
                'color': Colors.purple.shade400,
              },
              {
                'icon': Icons.celebration_rounded,
                'title': 'Milestone Gifts',
                'subtitle': 'Celebrate special moments',
                'action': 'milestone_gifts',
                'color': Colors.pink.shade400,
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
                        colors: [item['color'] as Color, (item['color'] as Color).withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(item['icon'] as IconData, color: Colors.white, size: 24),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    item['subtitle'] as String,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 16),
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
