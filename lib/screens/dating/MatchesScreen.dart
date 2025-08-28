import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../controllers/MainController.dart';
import '../../models/UserModel.dart';
import '../../services/swipe_service.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/Utilities.dart';
import '../../widgets/dating/MatchFilterWidget.dart';
import 'ProfileViewScreen.dart';
import '../shop/screens/shop/chat/chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with TickerProviderStateMixin {
  List<MatchModel> matches = [];
  bool isLoading = true;
  String errorMessage = '';
  int currentPage = 1;
  bool hasMore = true;
  String selectedFilter = 'all';
  Map<String, int> filterCounts = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadMatches();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        hasMore = true;
        matches.clear();
        errorMessage = '';
      });
    }

    try {
      final response = await SwipeService.getFilteredMatches(
        page: currentPage,
        filter: selectedFilter,
      );

      setState(() {
        if (response.matches.isNotEmpty) {
          matches.addAll(response.matches);
          currentPage++;
          hasMore = response.hasMore;
        } else {
          hasMore = false;
        }
        filterCounts = response.filterCounts;
        isLoading = false;
        errorMessage = '';
      });

      if (mounted) {
        _animationController
          ..reset()
          ..forward();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load matches';
      });
    }
  }

  void _onFilterChanged(String filter) {
    if (filter != selectedFilter) {
      HapticFeedback.lightImpact();
      setState(() {
        selectedFilter = filter;
        matches.clear();
        currentPage = 1;
        isLoading = true;
      });
      _animationController.reset();
      _loadMatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.card,
        elevation: 0,
        title: FxText.titleMedium(
          'My Matches',
          color: Colors.white,
          fontWeight: 700,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: CustomTheme.card,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: MatchFilterWidget(
              selectedFilter: selectedFilter,
              onFilterChanged: _onFilterChanged,
              filterCounts: filterCounts,
            ),
          ),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (isLoading && matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your matches...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (matches.isEmpty) {
      return _buildEmptyWidget();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        color: CustomTheme.primary,
        onRefresh: () => _loadMatches(refresh: true),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            if (!isLoading &&
                hasMore &&
                scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 50) {
              _loadMatches();
            }
            return false;
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: matches.length + (hasMore ? 1 : 0),
            itemBuilder: (context, idx) {
              if (idx == matches.length) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomTheme.primary,
                    ),
                  ),
                );
              }
              return _buildMatchCard(matches[idx]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: CustomTheme.errorRed),
          const SizedBox(height: 16),
          FxText.titleMedium(
            errorMessage,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FxButton.medium(
            backgroundColor: CustomTheme.primary,
            onPressed: () => _loadMatches(refresh: true),
            child: FxText.bodyMedium('Retry', color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    String title, subtitle;
    IconData icon;
    switch (selectedFilter) {
      case 'new':
        title = 'No new matches';
        subtitle = 'Keep swiping to find new connections!';
        icon = Icons.fiber_new;
        break;
      case 'messaged':
        title = 'No messages yet';
        subtitle = 'Chat with your matches to start a conversation';
        icon = Icons.chat_bubble_outline;
        break;
      default:
        title = 'No matches yet';
        subtitle = 'Mutual likes will show up here';
        icon = Icons.favorite_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: CustomTheme.color2),
          const SizedBox(height: 16),
          FxText.titleMedium(title, color: Colors.white),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            subtitle,
            color: Colors.white70,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    return GestureDetector(
      onTap: () => _startChat(match),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: CustomTheme.card,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildUserImage(match.user),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildMatchIndicators(match),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FxText.titleSmall(
                            '${match.user.name}, ${_getAge(match.user) ?? '?'}',
                            color: Colors.white,
                            fontWeight: 700,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (match.user.distance > 0)
                            FxText.bodySmall(
                              '${match.user.distance.toStringAsFixed(1)} km away',
                              color: Colors.white70,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          match.hasMessage
                              ? Icons.chat
                              : Icons.chat_bubble_outline,
                          size: 16,
                        ),
                        label: FxText.bodySmall(
                          match.hasMessage ? 'Chat' : 'Say Hi',
                          color: Colors.white,
                          fontWeight: 600,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _startChat(match);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: CustomTheme.cardDark,
                      child: IconButton(
                        icon: const Icon(Icons.person, size: 18),
                        color: Colors.white,
                        onPressed:
                            () => Get.to(() => ProfileViewScreen(match.user)),
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

  Widget _buildUserImage(UserModel user) {
    final avatarUrl =
        user.avatar.isNotEmpty
            ? (user.avatar.startsWith('http')
                ? user.avatar
                : '${Utils.img(user.avatar)}')
            : null;

    if (avatarUrl != null) {
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: CustomTheme.cardDark),
        errorWidget: (_, __, ___) => Container(color: CustomTheme.cardDark),
      );
    }
    return Container(color: CustomTheme.cardDark);
  }

  Widget _buildMatchIndicators(MatchModel match) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (match.isSuperLike) _buildIndicatorIcon(Icons.star, Colors.blue),
        if (match.isNew)
          _buildIndicatorIcon(Icons.fiber_new, CustomTheme.accentGold),
        _buildIndicatorIcon(Icons.favorite, Colors.pink),
      ],
    );
  }

  Widget _buildIndicatorIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Icon(icon, color: Colors.white, size: 12),
    );
  }

  int? _getAge(UserModel user) {
    if (user.dob.isEmpty) return null;
    try {
      final d = DateTime.parse(user.dob);
      final now = DateTime.now();
      int age = now.year - d.year;
      if (now.month < d.month || (now.month == d.month && now.day < d.day))
        age--;
      return age;
    } catch (_) {
      return null;
    }
  }

  void _startChat(MatchModel match) {
    try {
      final MainController _mainC = Get.find<MainController>();
      Utils.toast('Starting chat with ${match.user.name}');
      Get.to(
        () => ChatScreen({
          'receiver_id': match.user.id.toString(),
          'sender_id': _mainC.userModel.id.toString(),
          'task': 'DATING_CHAT',
          'matchedUser': match.user,
          'compatibilityScore': match.compatibilityScore,
          'isNewMatch': match.isNew,
          'isDatingMode': true,
          'start_message': 'Hi ${match.user.name}! 👋',
        }),
      );
    } catch (e) {
      Utils.toast('Error starting chat: $e');
      print('Error starting chat: $e');
    }
  }
}
