import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/dating/matches_screen.dart';
import '../screens/dating/who_liked_me_screen.dart';
import '../utils/CustomTheme.dart';

class MatchNavigationManager {
  /// Creates a floating action button for accessing matches
  static Widget createMatchesFAB(BuildContext context) {
    return FloatingActionButton(
      heroTag: "matches_fab",
      onPressed: () => navigateToMatches(context),
      backgroundColor: CustomTheme.primary,
      child: Stack(
        children: [
          Icon(Icons.favorite, color: Colors.white, size: 28),
          // Add notification badge if needed
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '', // Add count here later when implementing notifications
                style: TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a bottom navigation bar item for matches
  static BottomNavigationBarItem createMatchesNavItem() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      activeIcon: Icon(Icons.favorite),
      label: 'Matches',
    );
  }

  /// Creates an app bar action button for matches
  static Widget createMatchesAppBarAction(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.favorite, color: Colors.white, size: 26),
          // Add notification badge if needed
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: BoxConstraints(minWidth: 12, minHeight: 12),
            ),
          ),
        ],
      ),
      onPressed: () => navigateToMatches(context),
    );
  }

  /// Creates a who liked me action button
  static Widget createWhoLikedMeAction(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.thumb_up, color: CustomTheme.primary, size: 26),
          // Add notification badge if needed
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: BoxConstraints(minWidth: 12, minHeight: 12),
            ),
          ),
        ],
      ),
      onPressed: () => navigateToWhoLikedMe(context),
    );
  }

  /// Navigate to matches screen
  static void navigateToMatches(BuildContext context) {
    Get.to(() => MatchesScreen());
  }

  /// Navigate to who liked me screen
  static void navigateToWhoLikedMe(BuildContext context) {
    Get.to(() => WhoLikedMeScreen());
  }

  /// Creates a matches card for dashboard
  static Widget createMatchesDashboardCard(
    BuildContext context, {
    required int matchCount,
    required int newLikesCount,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomTheme.primary.withValues(alpha: 0.8),
            CustomTheme.primaryDark.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => navigateToMatches(context),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.favorite, color: Colors.white, size: 24),
                ),

                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Matches',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$matchCount matches • $newLikesCount new likes',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a quick action card for who liked me
  static Widget createWhoLikedMeCard(
    BuildContext context, {
    required int likesCount,
    required bool hasSubscription,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: CustomTheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => navigateToWhoLikedMe(context),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CustomTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.thumb_up,
                    color: CustomTheme.primary,
                    size: 24,
                  ),
                ),

                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Who Liked You',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!hasSubscription) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: CustomTheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Premium',
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
                      SizedBox(height: 4),
                      Text(
                        hasSubscription
                            ? '$likesCount people liked you'
                            : '$likesCount likes waiting for you',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
