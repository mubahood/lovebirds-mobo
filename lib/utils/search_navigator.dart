import 'package:flutter/material.dart';

import '../screens/search/enhanced_search_screen.dart';
import '../screens/search/enhanced_search_filters_screen.dart';
import '../screens/search/search_history_screen.dart';

/// Navigation helper for advanced search features
class SearchNavigator {
  /// Navigate to the main enhanced search screen
  static Future<T?> toEnhancedSearch<T>(BuildContext context) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => const EnhancedSearchScreen()),
    );
  }

  /// Navigate to search filters screen
  static Future<Map<String, dynamic>?> toSearchFilters(BuildContext context) {
    return Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedSearchFiltersScreen(),
      ),
    );
  }

  /// Navigate to search history screen
  static Future<Map<String, dynamic>?> toSearchHistory(BuildContext context) {
    return Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const SearchHistoryScreen()),
    );
  }

  /// Navigate with slide transition
  static Future<T?> toSearchWithSlide<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Navigate with fade transition
  static Future<T?> toSearchWithFade<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
