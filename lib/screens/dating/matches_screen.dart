import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/MainController.dart';
import '../../models/UserModel.dart';
import '../../services/swipe_service.dart';
import '../shop/screens/shop/chat/chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _heroAnimationController;
  late AnimationController _cardStaggerController;
  late Animation<double> _heroAnimation;
  late Animation<double> _titleAnimation;
  late List<Animation<double>> _cardAnimations;

  final MainController _mainC = Get.find<MainController>();

  List<MatchModel> _allMatches = [];
  List<MatchModel> _filteredMatches = [];
  Map<String, int> _filterCounts = {};
  bool _isLoading = true;
  String _currentFilter = 'all';
  int _currentPage = 1;

  final List<String> _filters = ['all', 'new', 'recent', 'unread'];
  final Map<String, String> _filterLabels = {
    'all': 'All Matches',
    'new': 'Fresh',
    'recent': 'Active',
    'unread': 'Unread',
  };

  // Revolutionary color scheme
  final List<List<Color>> _cardGradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFFa8edea), Color(0xFFfed6e3)],
    [Color(0xFFffecd2), Color(0xFFfcb69f)],
    [Color(0xFF89f7fe), Color(0xFF66a6ff)],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _heroAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardStaggerController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _initializeCardAnimations();
    _loadMatches();

    // Start hero animation
    _heroAnimationController.forward();
  }

  void _initializeCardAnimations() {
    _cardAnimations = List.generate(
      6,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardStaggerController,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _heroAnimationController.dispose();
    _cardStaggerController.dispose();
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
      });

      // Start card animations after data loads
      if (_filteredMatches.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 600), () {
          if (mounted) _cardStaggerController.forward();
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load matches: $e');
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

      // Reset and restart animations
      _cardStaggerController.reset();
      _loadMatches();
    }
  }

  void _openChat(MatchModel match) {
    HapticFeedback.lightImpact();
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
      transition: Transition.rightToLeftWithFade,
      duration: Duration(milliseconds: 300),
    );
  }

  bool _isNewMatch(MatchModel match) {
    return match.isNew;
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Oops!',
      message,
      backgroundColor: Color(0xFF1a1a2e),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 15,
      margin: EdgeInsets.all(15),
      duration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f0f23),
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _heroAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  Color(0xFF1a1a2e).withOpacity(0.8),
                  Color(0xFF16213e).withOpacity(0.9),
                  Color(0xFF0f0f23),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildRevolutionaryHeader(),
                  SizedBox(height: 20),
                  _buildModernFilterTabs(),
                  SizedBox(height: 25),
                  Expanded(child: _buildRevolutionaryMatchesList()),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildRevolutionaryHeader() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _heroAnimation.value)),
          child: Opacity(
            opacity: _heroAnimation.value,
            child: Container(
              height: 150,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                    Color(0xFFf093fb),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 25,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CustomPaint(painter: BackgroundPatternPainter()),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedBuilder(
                          animation: _titleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * _titleAnimation.value),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Matches',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          '${_filteredMatches.length} connections',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      if (_isLoading)
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Action buttons
                        Row(
                          children: [
                            _buildHeaderAction(Icons.tune_rounded, 'Filters'),
                            SizedBox(width: 15),
                            _buildHeaderAction(
                              Icons.favorite_border_rounded,
                              'Likes',
                            ),
                            SizedBox(width: 15),
                            _buildHeaderAction(
                              Icons.chat_bubble_outline_rounded,
                              'Chats',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderAction(IconData icon, String label) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFilterTabs() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _heroAnimation.value)),
          child: Opacity(
            opacity: _heroAnimation.value,
            child: Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final label = _filterLabels[filter]!;
                  final count = _filterCounts[filter] ?? 0;
                  final isSelected = filter == _currentFilter;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _changeFilter(filter);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? LinearGradient(
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2),
                                    ],
                                  )
                                  : null,
                          color: isSelected ? null : Color(0xFF1a1a2e),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.transparent
                                    : Color(0xFF2a2a3e),
                            width: 1.5,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Color(0xFF667eea).withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[400],
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            if (count > 0) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.white.withOpacity(0.3)
                                          : Color(0xFF667eea),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  count.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevolutionaryMatchesList() {
    if (_isLoading && _currentPage == 1) {
      return _buildLoadingState();
    }

    if (_filteredMatches.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 100),
      itemCount: _filteredMatches.length,
      itemBuilder: (context, index) {
        final animationIndex = index % _cardAnimations.length;
        return AnimatedBuilder(
          animation: _cardAnimations[animationIndex],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                50 * (1 - _cardAnimations[animationIndex].value),
              ),
              child: Transform.scale(
                scale: 0.9 + (0.1 * _cardAnimations[animationIndex].value),
                child: Opacity(
                  opacity: _cardAnimations[animationIndex].value,
                  child: _buildRevolutionaryMatchCard(
                    _filteredMatches[index],
                    index,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRevolutionaryMatchCard(MatchModel match, int index) {
    final gradientIndex = index % _cardGradients.length;
    final gradient = _cardGradients[gradientIndex];
    final timeDiff = DateTime.now().difference(DateTime.parse(match.matchedAt));
    final timeAgo = _formatTimeAgo(timeDiff);

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () => _openChat(match),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              color: Color(0xFF1a1a2e),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildRevolutionaryAvatar(match.user, gradient),
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
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildCompatibilityChip(
                              match.compatibilityScore.toInt(),
                              gradient,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${match.user.age} years old',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF2a2a3e),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            match.conversationStarter.isNotEmpty
                                ? match.conversationStarter
                                : 'Say hello to ${match.user.name}! 👋',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Matched $timeAgo',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                            Spacer(),
                            if (match.isNew)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: gradient),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
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
                      _buildActionButton(
                        Icons.chat_bubble_rounded,
                        gradient,
                        () => _openChat(match),
                      ),
                      SizedBox(height: 12),
                      _buildActionButton(Icons.more_horiz_rounded, [
                        Colors.grey[600]!,
                        Colors.grey[700]!,
                      ], () => _showMatchActions(match)),
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

  Widget _buildRevolutionaryAvatar(UserModel user, List<Color> gradient) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: gradient),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3),
        child: ClipOval(
          child:
              user.avatar.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: user.avatar,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: Color(0xFF2a2a3e),
                          child: Icon(
                            Icons.person,
                            color: Colors.grey[400],
                            size: 35,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => _buildAvatarFallback(user),
                  )
                  : _buildAvatarFallback(user),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2a2a3e),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(user.name),
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCompatibilityChip(int score, List<Color> gradient) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(22.5),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: 25),
          Text(
            'Finding your perfect matches...',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea).withOpacity(0.2),
                  Color(0xFF764ba2).withOpacity(0.2),
                ],
              ),
              border: Border.all(
                color: Color(0xFF667eea).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 50,
              color: Color(0xFF667eea),
            ),
          ),
          SizedBox(height: 25),
          Text(
            'No matches yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Start swiping to find your perfect match!',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 35),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667eea).withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
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
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMenu() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _heroAnimation.value)),
          child: Opacity(
            opacity: _heroAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                    Color(0xFFf093fb),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667eea).withOpacity(0.4),
                    blurRadius: 25,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showDatingFeaturesMenu();
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                label: Text(
                  'Features',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMatchActions(MatchModel match) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Color(0xFF1a1a2e),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Actions for ${match.user.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 25),
                ...[
                  {
                    'icon': Icons.chat_rounded,
                    'title': 'Send Message',
                    'color': Color(0xFF667eea),
                  },
                  {
                    'icon': Icons.card_giftcard_rounded,
                    'title': 'Send Gift',
                    'color': Color(0xFFf093fb),
                  },
                  {
                    'icon': Icons.calendar_today_rounded,
                    'title': 'Plan Date',
                    'color': Color(0xFF4facfe),
                  },
                  {
                    'icon': Icons.shopping_cart_rounded,
                    'title': 'Shop Together',
                    'color': Color(0xFF89f7fe),
                  },
                ].map((item) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[500],
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Handle action
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
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Color(0xFF1a1a2e),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Dating Features',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 25),
                ...[
                  {
                    'icon': Icons.calendar_today_rounded,
                    'title': 'Plan a Date',
                    'subtitle': 'Find amazing date ideas',
                    'color': Color(0xFF4facfe),
                  },
                  {
                    'icon': Icons.card_giftcard_rounded,
                    'title': 'Send Gifts',
                    'subtitle': 'Surprise your matches',
                    'color': Color(0xFFf093fb),
                  },
                  {
                    'icon': Icons.shopping_cart_rounded,
                    'title': 'Shop Together',
                    'subtitle': 'Browse items as a couple',
                    'color': Color(0xFF89f7fe),
                  },
                  {
                    'icon': Icons.celebration_rounded,
                    'title': 'Milestone Gifts',
                    'subtitle': 'Celebrate special moments',
                    'color': Color(0xFFffecd2),
                  },
                ].map((item) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      leading: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              item['color'] as Color,
                              (item['color'] as Color).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: (item['color'] as Color).withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      subtitle: Text(
                        item['subtitle'] as String,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[500],
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Handle feature
                      },
                    ),
                  );
                }).toList(),
              ],
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

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0][0].toUpperCase();
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    // Draw geometric pattern
    final path = Path();

    // Create hexagonal pattern
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        final centerX = (size.width / 4) * i + 30;
        final centerY = (size.height / 3) * j + 25;
        final radius = 15.0;

        path.moveTo(centerX + radius, centerY);
        for (int k = 1; k <= 6; k++) {
          final angle = (k * 60) * (3.14159 / 180);
          path.lineTo(
            centerX + radius * cos(angle),
            centerY + radius * sin(angle),
          );
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

double cos(double angle) => math.cos(angle);
double sin(double angle) => math.sin(angle);
