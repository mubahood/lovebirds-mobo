import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';

import '../../utils/dating_theme.dart';
import '../dating/OrbitalSwipeScreen.dart';
import '../dating/matches_screen.dart';
import '../shop/screens/shop/ProductsScreen.dart';
import '../dating/dating_chat_list_screen.dart';
import '../dating/AccountEditMainScreen.dart';
import '../shop/screens/full_app_controller.dart';

class DatingMainNavigationScreen extends StatefulWidget {
  const DatingMainNavigationScreen({Key? key}) : super(key: key);

  @override
  _DatingMainNavigationScreenState createState() =>
      _DatingMainNavigationScreenState();
}

class _DatingMainNavigationScreenState extends State<DatingMainNavigationScreen>
    with SingleTickerProviderStateMixin {
  late FullAppController controller;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const OrbitalSwipeScreen(), // Discover - Main dating swipe interface
    MatchesScreen(), // Matches - View matches and who liked you
    ProductsScreen({}), // Marketplace - Shopping and gifts
    const DatingChatListScreen(), // Messages - Dating conversations
    const AccountEditMainScreen(), // Profile - User profile management
  ];

  final List<DatingNavItem> _navItems = [
    DatingNavItem(
      title: 'Discover',
      icon: FeatherIcons.heart,
      activeColor: DatingTheme.primaryPink,
      description: 'Find new connections',
    ),
    DatingNavItem(
      title: 'Matches',
      icon: FeatherIcons.users,
      activeColor: DatingTheme.primaryRose,
      description: 'View your matches',
    ),
    DatingNavItem(
      title: 'Shop',
      icon: FeatherIcons.shoppingCart,
      activeColor: DatingTheme.accentGold,
      description: 'Gifts & experiences',
    ),
    DatingNavItem(
      title: 'Messages',
      icon: FeatherIcons.messageCircle,
      activeColor: DatingTheme.secondaryPurple,
      description: 'Chat with matches',
    ),
    DatingNavItem(
      title: 'Profile',
      icon: FeatherIcons.user,
      activeColor: DatingTheme.primaryPink,
      description: 'Manage your profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    controller = FxControllerStore.putOrFind(FullAppController(this));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildDatingBottomNavigationBar(),
    );
  }

  Widget _buildDatingBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = _currentIndex == index;

                  return GestureDetector(
                    onTap: () => _onNavItemTapped(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration:
                          isActive
                              ? BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    item.activeColor.withValues(alpha: 0.2),
                                    item.activeColor.withValues(alpha: 0.1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              )
                              : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration:
                                isActive
                                    ? BoxDecoration(
                                      color: item.activeColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    )
                                    : null,
                            child: Icon(
                              item.icon,
                              color:
                                  isActive
                                      ? item.activeColor
                                      : DatingTheme.secondaryText,
                              size: isActive ? 24 : 22,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.title,
                            style: TextStyle(
                              color:
                                  isActive
                                      ? item.activeColor
                                      : DatingTheme.secondaryText,
                              fontSize: isActive ? 11 : 10,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Add haptic feedback for better UX
    _addHapticFeedback(index);

    // Track navigation analytics
    _trackNavigation(index);
  }

  void _addHapticFeedback(int index) {
    // Add light haptic feedback when switching tabs
    // HapticFeedback.lightImpact();
  }

  void _trackNavigation(int index) {
    // Track navigation to different sections for analytics
    final sectionName = _navItems[index].title.toLowerCase();
    print('Navigation: User switched to $sectionName section');

    // Could integrate with analytics service here
    // AnalyticsService.trackEvent('navigation_switch', {'section': sectionName});
  }
}

class DatingNavItem {
  final String title;
  final IconData icon;
  final Color activeColor;
  final String description;

  DatingNavItem({
    required this.title,
    required this.icon,
    required this.activeColor,
    required this.description,
  });
}
