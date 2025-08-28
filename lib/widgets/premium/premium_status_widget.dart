import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../../utils/CustomTheme.dart';
import '../../utils/PremiumFeaturesManager.dart';

class PremiumStatusWidget extends StatefulWidget {
  final bool showFullCard;
  final VoidCallback? onUpgradePressed;

  const PremiumStatusWidget({
    Key? key,
    this.showFullCard = true,
    this.onUpgradePressed,
  }) : super(key: key);

  @override
  _PremiumStatusWidgetState createState() => _PremiumStatusWidgetState();
}

class _PremiumStatusWidgetState extends State<PremiumStatusWidget> {
  PremiumFeatureStatus? _premiumStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  void _loadPremiumStatus() async {
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
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_premiumStatus == null) {
      return SizedBox.shrink();
    }

    if (widget.showFullCard) {
      return _buildFullCard();
    } else {
      return _buildCompactBadge();
    }
  }

  Widget _buildLoadingState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
            ),
          ),
          SizedBox(width: 12),
          FxText.bodyMedium('Loading premium status...', color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildCompactBadge() {
    if (_premiumStatus!.isActive) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [CustomTheme.primary, CustomTheme.primaryDark],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.white, size: 16),
            SizedBox(width: 4),
            FxText.bodySmall('Premium', color: Colors.white, fontWeight: 600),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: widget.onUpgradePressed ?? () => _showUpgradeDialog(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: CustomTheme.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_border, color: CustomTheme.primary, size: 16),
              SizedBox(width: 4),
              FxText.bodySmall(
                'Upgrade',
                color: CustomTheme.primary,
                fontWeight: 600,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildFullCard() {
    if (_premiumStatus!.isActive) {
      return _buildActivePremiumCard();
    } else {
      return _buildUpgradePromptCard();
    }
  }

  Widget _buildActivePremiumCard() {
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
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.star, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.titleMedium(
                        'Premium Active',
                        color: Colors.white,
                        fontWeight: 700,
                      ),
                      SizedBox(height: 2),
                      FxText.bodySmall(
                        _premiumStatus!.expiryText,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ),
                if (_premiumStatus!.remainingBoosts > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FxText.bodySmall(
                      '${_premiumStatus!.remainingBoosts} boosts',
                      color: Colors.white,
                      fontWeight: 600,
                    ),
                  ),
              ],
            ),

            SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildFeatureBadge('Unlimited Swipes', Icons.swipe),
                _buildFeatureBadge('Super Likes', Icons.favorite),
                _buildFeatureBadge('See Who Liked', Icons.visibility),
                _buildFeatureBadge('Profile Boost', Icons.trending_up),
                _buildFeatureBadge('Undo Swipes', Icons.undo),
                _buildFeatureBadge('Advanced Filters', Icons.tune),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradePromptCard() {
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
          onTap: widget.onUpgradePressed ?? () => _showUpgradeDialog(),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CustomTheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.star_border,
                        color: CustomTheme.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FxText.titleMedium(
                            'Upgrade to Premium',
                            color: Colors.white,
                            fontWeight: 700,
                          ),
                          SizedBox(height: 2),
                          FxText.bodySmall(
                            'Unlock all premium features',
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: CustomTheme.primary,
                      size: 16,
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildUpgradeFeature(
                        'Unlimited Swipes',
                        Icons.swipe,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildUpgradeFeature(
                        'See Who Liked',
                        Icons.visibility,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildUpgradeFeature(
                        'Profile Boost',
                        Icons.trending_up,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildUpgradeFeature('Undo Swipes', Icons.undo),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String feature, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          SizedBox(width: 4),
          FxText.bodySmall(feature, color: Colors.white, fontWeight: 500),
        ],
      ),
    );
  }

  Widget _buildUpgradeFeature(String feature, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: CustomTheme.primary, size: 16),
        SizedBox(width: 6),
        Expanded(
          child: FxText.bodySmall(
            feature,
            color: Colors.white70,
            fontWeight: 500,
          ),
        ),
      ],
    );
  }

  void _showUpgradeDialog() async {
    PremiumFeaturesManager.showFeatureUpgradePrompt(
      context,
      'Premium Features',
    );
  }
}
