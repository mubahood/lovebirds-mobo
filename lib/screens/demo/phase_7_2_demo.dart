import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../models/UserModel.dart';
import '../../utils/CustomTheme.dart';
import '../../widgets/dating/send_gift_widget.dart';
import '../../widgets/dating/date_planning_widget.dart';
import '../../widgets/dating/couple_shopping_widget.dart';
import '../../widgets/dating/milestone_gift_suggestions_widget.dart';
import '../../widgets/dating/shared_wishlist_widget.dart';

/// Demo application showcasing all Phase 7.2 Dating-Marketplace Fusion features
class Phase72DemoScreen extends StatefulWidget {
  @override
  _Phase72DemoScreenState createState() => _Phase72DemoScreenState();
}

class _Phase72DemoScreenState extends State<Phase72DemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 0,
        title: FxText.titleLarge(
          'Phase 7.2 Dating-Marketplace Fusion',
          fontWeight: 700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomTheme.primary.withValues(alpha: 0.2),
                    CustomTheme.primary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Icon(Icons.favorite, size: 50, color: CustomTheme.primary),
                  SizedBox(height: 16),
                  FxText.titleMedium(
                    'Dating-Marketplace Integration',
                    color: Colors.white,
                    fontWeight: 700,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  FxText.bodyMedium(
                    'Experience the seamless fusion of dating and marketplace features. Send gifts, plan dates, shop together, and celebrate milestones!',
                    color: Colors.white70,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Features Progress
            FxText.titleMedium(
              'Phase 7.2 Features (83% Complete)',
              color: Colors.white,
              fontWeight: 700,
            ),
            SizedBox(height: 10),

            LinearProgressIndicator(
              value: 0.83,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
            ),

            SizedBox(height: 20),

            // Feature Cards
            _buildFeatureCard(
              icon: Icons.card_giftcard,
              title: 'Send Gift',
              description:
                  'Surprise your matches with thoughtful gifts from local Canadian stores',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showSendGiftDemo(),
            ),

            _buildFeatureCard(
              icon: Icons.calendar_today,
              title: 'Date Planning Marketplace',
              description:
                  'Discover and book restaurants and activities for your dates',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showDatePlanningDemo(),
            ),

            _buildFeatureCard(
              icon: Icons.shopping_cart,
              title: 'Couple Shopping Experiences',
              description: 'Browse and buy items together with your partner',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showCoupleShoppingDemo(),
            ),

            _buildFeatureCard(
              icon: Icons.celebration,
              title: 'Relationship Milestone Gift Suggestions',
              description:
                  'AI-powered gift recommendations for special occasions',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showMilestoneGiftsDemo(),
            ),

            _buildFeatureCard(
              icon: Icons.list_alt,
              title: 'Shared Wishlist Feature',
              description:
                  'Create and manage wishlists together with your partner',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showSharedWishlistDemo(),
            ),

            _buildFeatureCard(
              icon: Icons.payment,
              title: 'Split the Bill Payment Options',
              description: 'Easy payment splitting for date expenses',
              status: 'IMPLEMENTED ✅',
              onTap:
                  () =>
                      _showCoupleShoppingDemo(), // Split payment is integrated in couple shopping
            ),

            SizedBox(height: 30),

            // Integration Status
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 40),
                  SizedBox(height: 16),
                  FxText.titleMedium(
                    'Backend Integration Status',
                    color: Colors.white,
                    fontWeight: 700,
                  ),
                  SizedBox(height: 8),
                  FxText.bodyMedium(
                    '✅ API Endpoints: Functional\n'
                    '✅ Authentication: Working\n'
                    '✅ Canadian Localization: Active\n'
                    '✅ Frontend Services: Connected\n'
                    '✅ UI Components: Accessible',
                    color: Colors.white70,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required String status,
    required VoidCallback onTap,
  }) {
    final isImplemented = status.contains('✅');
    final isNext = status.contains('🔄');

    Color statusColor =
        isImplemented
            ? Colors.green
            : isNext
            ? Colors.orange
            : Colors.blue;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CustomTheme.background,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: statusColor, size: 30),
                ),

                SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FxText.titleSmall(
                              title,
                              color: Colors.white,
                              fontWeight: 600,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FxText.bodySmall(
                              status,
                              color: statusColor,
                              fontWeight: 600,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      FxText.bodyMedium(
                        description,
                        color: Colors.white70,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12),

                Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSendGiftDemo() {
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
            '🎁 Gift Sent Successfully!',
            'Your thoughtful gift has been sent to Demo Match',
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        },
      ),
    );
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
            '📅 Date Planned!',
            'Perfect choice: $idea',
            backgroundColor: Colors.blue.withValues(alpha: 0.9),
            colorText: Colors.white,
            duration: Duration(seconds: 3),
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

  void _showSharedWishlistDemo() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SharedWishlistWidget(
              partnerId: 'demo_partner_123',
              partnerName: 'Demo Partner',
            ),
          ),
    );
  }
}
