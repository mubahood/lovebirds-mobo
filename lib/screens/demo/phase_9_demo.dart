import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../services/premium_gamification_service.dart';
import '../../widgets/premium/premium_gamification_widget.dart';
import '../../utils/dating_theme.dart';

/// Demo screen showcasing Phase 9: Premium Features & Gamification implementation
/// Advanced premium features, achievements, rewards, and user progression system
class Phase9Demo extends StatefulWidget {
  const Phase9Demo({Key? key}) : super(key: key);

  @override
  State<Phase9Demo> createState() => _Phase9DemoState();
}

class _Phase9DemoState extends State<Phase9Demo> {
  final PremiumGamificationService _gamificationService =
      PremiumGamificationService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePhase9();
  }

  Future<void> _initializePhase9() async {
    await _gamificationService.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Phase 9: Premium & Gamification',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: DatingTheme.primaryPink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(FeatherIcons.refreshCw, color: Colors.white),
            onPressed: _resetDemo,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DatingTheme.primaryPink,
              DatingTheme.primaryPink.withValues(alpha: 0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: Column(
          children: [
            _buildDemoHeader(),
            Expanded(
              child:
                  _isInitialized
                      ? const PremiumGamificationWidget()
                      : _buildLoadingState(),
            ),
            _buildDemoControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DatingTheme.primaryPink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FeatherIcons.star,
                        color: DatingTheme.primaryPink,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Premium Features & Gamification',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DatingTheme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Advanced monetization and user engagement system',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFeatureHighlights(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    return Row(
      children: [
        Expanded(
          child: _buildHighlightCard(
            'Premium Tiers',
            '4 Levels',
            FeatherIcons.layers,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHighlightCard(
            'Achievements',
            '12+ Unlocks',
            FeatherIcons.award,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHighlightCard(
            'Point System',
            'Level Up',
            FeatherIcons.trendingUp,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 8, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(DatingTheme.primaryPink),
          ),
          const SizedBox(height: 16),
          Text(
            'Initializing Premium & Gamification System...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading premium features, achievements, and reward system',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDemoControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Phase 9 Demo Controls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DatingTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDemoButton(
                  'Simulate Achievement',
                  FeatherIcons.award,
                  () => _simulateAchievement(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDemoButton(
                  'Add Points',
                  FeatherIcons.star,
                  () => _addDemoPoints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDemoButton(
                  'Upgrade Tier',
                  FeatherIcons.star,
                  () => _simulateTierUpgrade(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDemoButton(
                  'Redeem Reward',
                  FeatherIcons.gift,
                  () => _redeemDemoReward(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: DatingTheme.primaryPink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _simulateAchievement() async {
    final success = await _gamificationService.unlockAchievement('first_match');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '🏆 Achievement unlocked: First Connection!'
              : '❌ Achievement already unlocked or not found',
        ),
        backgroundColor: success ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<void> _addDemoPoints() async {
    await _gamificationService.awardPoints(150, 'Demo points bonus');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⭐ 150 points added to your account!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _simulateTierUpgrade() async {
    PremiumTier newTier;
    final currentTier = _gamificationService.currentTier.value;

    switch (currentTier) {
      case PremiumTier.basic:
        newTier = PremiumTier.gold;
        break;
      case PremiumTier.gold:
        newTier = PremiumTier.platinum;
        break;
      case PremiumTier.platinum:
        newTier = PremiumTier.diamond;
        break;
      case PremiumTier.diamond:
        // Already at max tier
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💎 Already at maximum tier!'),
            backgroundColor: Colors.purple,
          ),
        );
        return;
    }

    final success = await _gamificationService.upgradePremiumTier(newTier);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '🎉 Upgraded to ${newTier.name.toUpperCase()} tier!'
              : '❌ Failed to upgrade tier',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _redeemDemoReward() async {
    // Try to redeem the first available reward
    final rewards = _gamificationService.availableRewards.value;
    if (rewards.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No rewards available'),
          backgroundColor: Colors.grey,
        ),
      );
      return;
    }

    final reward = rewards.first;
    final success = await _gamificationService.redeemReward(reward.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '🎁 Successfully redeemed ${reward.name}!'
              : '❌ Not enough points or reward unavailable',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _resetDemo() async {
    setState(() {
      _isInitialized = false;
    });

    // Reset gamification data
    await _gamificationService.initialize();

    // Re-initialize
    await _initializePhase9();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Demo reset successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _gamificationService.dispose();
    super.dispose();
  }
}
