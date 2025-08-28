import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../utils/CustomTheme.dart';
import '../../utils/PremiumFeaturesManager.dart';
import '../../widgets/premium/premium_status_widget.dart';
import '../../widgets/premium/profile_boost_widget.dart';
import '../premium/advanced_filters_screen.dart';

class PremiumDemoScreen extends StatefulWidget {
  @override
  _PremiumDemoScreenState createState() => _PremiumDemoScreenState();
}

class _PremiumDemoScreenState extends State<PremiumDemoScreen> {
  PremiumFeatureStatus? _premiumStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPremiumData();
  }

  void _loadPremiumData() async {
    try {
      final status = await PremiumFeaturesManager.getPremiumFeatureStatus();
      setState(() {
        _premiumStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 0,
        title: FxText.titleLarge(
          'Premium Features Demo',
          fontWeight: 700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
          ),
          SizedBox(height: 16),
          FxText.bodyMedium(
            'Loading premium features...',
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Status Overview
          PremiumStatusWidget(
            showFullCard: true,
            onUpgradePressed: _showUpgradeDialog,
          ),

          // Profile Boost Feature
          ProfileBoostWidget(
            onBoostActivated: () {
              Get.snackbar(
                'Boost Active!',
                'Your profile is now boosted for 30 minutes!',
                backgroundColor: Colors.green.withValues(alpha: 0.9),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              _loadPremiumData(); // Refresh status
            },
          ),

          // Premium Features Grid
          _buildPremiumFeaturesGrid(),

          // Feature Comparison
          _buildFeatureComparison(),

          // Bottom padding
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPremiumFeaturesGrid() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(
            'Premium Features',
            color: Colors.white,
            fontWeight: 700,
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildFeatureCard(
                'Unlimited Swipes',
                Icons.swipe,
                _premiumStatus?.unlimitedSwipes ?? false,
                'Swipe as much as you want',
                () => _showFeatureDemo('Unlimited Swipes'),
              ),
              _buildFeatureCard(
                'Super Likes',
                Icons.favorite,
                _premiumStatus?.unlimitedSuperLikes ?? false,
                '5 super likes per day',
                () => _showFeatureDemo('Super Likes'),
              ),
              _buildFeatureCard(
                'Who Liked Me',
                Icons.visibility,
                _premiumStatus?.canSeeWhoLikedMe ?? false,
                'See everyone who liked you',
                () => _showFeatureDemo('Who Liked Me'),
              ),
              _buildFeatureCard(
                'Advanced Filters',
                Icons.tune,
                _premiumStatus?.canUseAdvancedFilters ?? false,
                'Filter by interests & more',
                () => Get.to(() => AdvancedFiltersScreen()),
              ),
              _buildFeatureCard(
                'Undo Swipes',
                Icons.undo,
                _premiumStatus?.canUndoSwipes ?? false,
                'Second chances on great profiles',
                () => _showFeatureDemo('Undo Swipes'),
              ),
              _buildFeatureCard(
                'Read Receipts',
                Icons.mark_email_read,
                _premiumStatus?.canSeeReadReceipts ?? false,
                'Know when messages are read',
                () => _showFeatureDemo('Read Receipts'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    bool isUnlocked,
    String description,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              isUnlocked
                  ? CustomTheme.primary.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: isUnlocked ? onTap : () => _showUpgradeDialog(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: isUnlocked ? CustomTheme.primary : Colors.grey,
                    ),
                    if (!isUnlocked)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Icon(Icons.lock, size: 16, color: Colors.grey),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                FxText.bodyMedium(
                  title,
                  color: isUnlocked ? Colors.white : Colors.grey,
                  fontWeight: 600,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                FxText.bodySmall(
                  description,
                  color: isUnlocked ? Colors.white70 : Colors.grey,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      margin: EdgeInsets.all(16),
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
            'Free vs Premium',
            color: Colors.white,
            fontWeight: 700,
          ),
          SizedBox(height: 16),
          _buildComparisonRow('Daily Swipes', '50', 'Unlimited'),
          _buildComparisonRow('Super Likes', '1 per day', '5 per day'),
          _buildComparisonRow('Who Liked You', '❌', '✅'),
          _buildComparisonRow('Profile Boost', '❌', '✅'),
          _buildComparisonRow('Undo Swipes', '❌', '✅'),
          _buildComparisonRow('Advanced Filters', '❌', '✅'),
          _buildComparisonRow('Read Receipts', '❌', '✅'),

          SizedBox(height: 20),

          if (!(_premiumStatus?.isActive ?? false))
            Center(
              child: ElevatedButton(
                onPressed: _showUpgradeDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white),
                    SizedBox(width: 8),
                    FxText.bodyLarge(
                      'Upgrade to Premium',
                      color: Colors.white,
                      fontWeight: 600,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String feature,
    String freeValue,
    String premiumValue,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: FxText.bodyMedium(
              feature,
              color: Colors.white,
              fontWeight: 500,
            ),
          ),
          Expanded(
            child: FxText.bodySmall(
              freeValue,
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FxText.bodySmall(
              premiumValue,
              color: CustomTheme.primary,
              textAlign: TextAlign.center,
              fontWeight: 600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureDemo(String featureName) {
    if (!(_premiumStatus?.isActive ?? false)) {
      PremiumFeaturesManager.showFeatureUpgradePrompt(context, featureName);
      return;
    }

    // Show feature-specific demo
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomTheme.primary, CustomTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  FxText.titleLarge(
                    '$featureName Active!',
                    color: Colors.white,
                    fontWeight: 700,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  FxText.bodyMedium(
                    'You have access to $featureName as a premium member. This feature is now available throughout the app!',
                    color: Colors.white.withValues(alpha: 0.9),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: FxText.bodyMedium(
                      'Continue',
                      color: CustomTheme.primary,
                      fontWeight: 600,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showUpgradeDialog() {
    PremiumFeaturesManager.showFeatureUpgradePrompt(
      context,
      'Premium Features',
    );
  }
}
