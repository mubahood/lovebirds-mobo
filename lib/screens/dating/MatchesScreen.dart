import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';

import '../../models/UserModel.dart';
import '../../services/swipe_service.dart';
import '../../utils/Utilities.dart';
import '../shop/screens/shop/chat/chat_screen.dart';
import 'ProfileViewScreen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<MatchModel> _allMatches = [];
  List<MatchModel> _filteredMatches = [];
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

  @override
  void initState() {
    super.initState();
    _loadMatches();
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
        } else {
          _allMatches.addAll(response.matches);
          _filteredMatches.addAll(response.matches);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load matches: $e');
    }
  }

  Future<void> _refreshMatches() async {
    setState(() {
      _currentPage = 1;
      _isLoading = true;
      _filteredMatches.clear();
    });
    _loadMatches();
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
    HapticFeedback.lightImpact();
    Get.to(
      () => ChatScreen({
        'receiver_id':
            match.user.id
                .toString(), // FIXED: Use receiver_id instead of chatHead
        'matchedUser': match.user,
        'compatibilityScore': (match.compatibilityScore * 100).toInt(),
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
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f0f23),
      extendBodyBehindAppBar: true,
      body: Container(
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
              SizedBox(height: 4),
              _buildModernFilterTabs(),
              SizedBox(height: 6),
              Expanded(child: _buildRevolutionaryMatchesList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevolutionaryHeader() {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.red, Colors.redAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              '💖 Matches',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_filteredMatches.length}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFilterTabs() {
    return Container(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final label = _filterLabels[filter]!;
          final isSelected = filter == _currentFilter;

          return Container(
            margin: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _changeFilter(filter);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? LinearGradient(
                            colors: [Colors.red, Colors.redAccent],
                          )
                          : null,
                  color: isSelected ? null : Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.transparent
                            : Colors.yellow.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.yellow.withOpacity(0.8),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevolutionaryMatchesList() {
    if (_isLoading && _currentPage == 1) {
      return _buildLoadingState();
    }

    if (_filteredMatches.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: Colors.red,
      backgroundColor: Color(0xFF1a1a2e),
      onRefresh: () => _refreshMatches(),
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio:
              0.72, // Adjusted for better Stack layout proportions
        ),
        itemCount: _filteredMatches.length,
        itemBuilder: (context, index) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight,
                child: _buildRevolutionaryMatchCard(
                  _filteredMatches[index],
                  index,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRevolutionaryMatchCard(MatchModel match, int index) {
    final age = match.user.age; // Use the computed age property from UserModel

    // Debug logging to understand data issues

    // print('   DOB: "${match.user.dob}"');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.redAccent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.yellow.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Color(0xFF1a1a2e),
        ),
        child: Stack(
          children: [
            // Background image takes full container - CLICKABLE FOR PROFILE
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _openFullProfile(match),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child:
                      match.user.avatar.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: Utils.img(match.user.avatar),
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red.withOpacity(0.3),
                                        Colors.redAccent.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.red,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget: (context, url, error) {
                              print(
                                '🚫 Image load error for ${match.user.name}: $error',
                              );
                              print('   Failed URL: $url');
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.withOpacity(0.3),
                                      Colors.redAccent.withOpacity(0.2),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    match.user.name.isNotEmpty
                                        ? match.user.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                          : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.withOpacity(0.3),
                                  Colors.redAccent.withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                match.user.name.isNotEmpty
                                    ? match.user.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                ),
              ),
            ),

            // Gradient overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // NEW badge overlay
            if (match.isNew)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            // User info overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name - CLICKABLE FOR PROFILE
                    GestureDetector(
                      onTap: () => _openFullProfile(match),
                      child: Text(
                        match.user.name,
                        style: TextStyle(
                          color: CustomTheme.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),

/*                    SizedBox(height: 4),

                    // Age with better debugging
                    Text(
                      age == 'Unknown' || age.isEmpty
                          ? 'Age not specified'
                          : '$age years old',
                      style: TextStyle(
                        color: Colors.yellow.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),*/

                    SizedBox(height: 8),

                    // Chat button - ONLY THIS OPENS CHAT
                    Container(
                      width: double.infinity,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _openChat(match),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Chat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          SizedBox(height: 15),
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
          SizedBox(height: 15),
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
          SizedBox(height: 20),
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
              onPressed: () => Get.back(),
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
}

// HELPER METHODS

void _openFullProfile(MatchModel match) {
  HapticFeedback.lightImpact();
  Get.to(
    () => ProfileViewScreen(match.user),
    transition: Transition.rightToLeftWithFade,
    duration: Duration(milliseconds: 300),
  );
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
