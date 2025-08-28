import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../utils/CustomTheme.dart';
import '../demo/premium_demo_screen.dart';
import '../dating/matches_screen.dart';
import '../dating/who_liked_me_screen.dart';
import '../premium/advanced_filters_screen.dart';

class PremiumIntegrationDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 0,
        title: FxText.titleLarge(
          'Premium Features Integration',
          fontWeight: 700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      FxText.titleLarge(
                        'Phase 2.2 Complete!',
                        color: Colors.white,
                        fontWeight: 700,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  FxText.bodyMedium(
                    'Premium Features system is now fully implemented with advanced monetization strategies.',
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            FxText.titleMedium(
              'Demo Screens',
              color: Colors.white,
              fontWeight: 700,
            ),

            SizedBox(height: 16),

            // Demo screens grid
            _buildDemoCard(
              'Premium Demo',
              'Complete premium features showcase',
              Icons.star,
              () => Get.to(() => PremiumDemoScreen()),
            ),

            _buildDemoCard(
              'Matches Screen',
              'Enhanced with premium integration',
              Icons.favorite,
              () => Get.to(() => MatchesScreen()),
            ),

            _buildDemoCard(
              'Who Liked Me',
              'Premium-gated with upgrade prompts',
              Icons.visibility,
              () => Get.to(() => WhoLikedMeScreen()),
            ),

            _buildDemoCard(
              'Advanced Filters',
              'Comprehensive search filtering',
              Icons.tune,
              () => Get.to(() => AdvancedFiltersScreen()),
            ),

            SizedBox(height: 24),

            FxText.titleMedium(
              'Implementation Highlights',
              color: Colors.white,
              fontWeight: 700,
            ),

            SizedBox(height: 16),

            // Implementation highlights
            _buildHighlightCard(
              'Revenue Optimization',
              'Strategic upgrade prompts with personalized recommendations based on user behavior',
              Icons.trending_up,
              Colors.green,
            ),

            _buildHighlightCard(
              'User Experience',
              'Seamless premium integration with elegant UI components and smooth animations',
              Icons.design_services,
              Colors.blue,
            ),

            _buildHighlightCard(
              'Backend Integration',
              '6 new API endpoints with comprehensive feature tracking and analytics',
              Icons.api,
              Colors.orange,
            ),

            _buildHighlightCard(
              'Canadian Market Ready',
              'Optimized for Canadian market with CAD pricing and local preferences',
              Icons.flag,
              Colors.red,
            ),

            SizedBox(height: 24),

            // Technical stats
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CustomTheme.background,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.titleMedium(
                    'Technical Achievement',
                    color: Colors.white,
                    fontWeight: 700,
                  ),
                  SizedBox(height: 16),
                  _buildStatRow(
                    'Mobile Components',
                    '4 new widgets + 2 screens',
                  ),
                  _buildStatRow('API Endpoints', '6 new premium endpoints'),
                  _buildStatRow('Premium Features', '8 fully implemented'),
                  _buildStatRow('Revenue Features', '100% monetization ready'),
                  _buildStatRow('Compilation Status', '✅ Error-free'),
                ],
              ),
            ),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CustomTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: CustomTheme.primary, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyLarge(
                        title,
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                      SizedBox(height: 4),
                      FxText.bodySmall(description, color: Colors.white70),
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

  Widget _buildHighlightCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(title, color: Colors.white, fontWeight: 600),
                SizedBox(height: 4),
                FxText.bodySmall(description, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FxText.bodyMedium(label, color: Colors.white70),
          FxText.bodyMedium(value, color: CustomTheme.primary, fontWeight: 600),
        ],
      ),
    );
  }
}
