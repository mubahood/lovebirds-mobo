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
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final MainController _mainC = Get.find<MainController>();

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

  // Simple color gradients for cards
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
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_filteredMatches.length}',
                style: TextStyle(
                  color: Colors.white,
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
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          )
                          : null,
                  color: isSelected ? null : Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Color(0xFF2a2a3e),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
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

    return ListView.builder(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 80),
      itemCount: _filteredMatches.length,
      itemBuilder: (context, index) {
        return _buildRevolutionaryMatchCard(_filteredMatches[index], index);
      },
    );
  }

  Widget _buildRevolutionaryMatchCard(MatchModel match, int index) {
    final gradientIndex = index % _cardGradients.length;
    final gradient = _cardGradients[gradientIndex];

    // FIXED: Safe date parsing with error handling
    DateTime matchedDate;
    try {
      matchedDate = DateTime.parse(match.matchedAt);
    } catch (e) {
      // Fallback to current time if date parsing fails
      matchedDate = DateTime.now();
    }

    final timeDiff = DateTime.now().difference(matchedDate);
    final timeAgo = _formatTimeAgo(timeDiff);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildRevolutionaryAvatar(match.user, gradient),
                  SizedBox(width: 12),
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
                                  fontSize: 16,
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
                        SizedBox(height: 4),
                        Text(
                          '${match.user.age} years old',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.all(8),
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
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 6),
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
                      SizedBox(height: 8),
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
      width: 60,
      height: 60,
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
                            size: 28,
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
            fontSize: 18,
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
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(17.5),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 16),
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
            padding: EdgeInsets.all(15),
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
                SizedBox(height: 15),
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
