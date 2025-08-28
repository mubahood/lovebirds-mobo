import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/app_theme.dart';

class GuestAccountSection extends StatefulWidget {
  const GuestAccountSection({Key? key}) : super(key: key);

  @override
  _GuestAccountSectionState createState() => _GuestAccountSectionState();
}

class _GuestAccountSectionState extends State<GuestAccountSection> {
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme = AppTheme.darkTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildGuestInfo(),
              const SizedBox(height: 32),
              _buildAccountOptions(),
              const SizedBox(height: 24),
              _buildAppInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.bodyLarge('Guest Account', color: CustomTheme.primary),
        const SizedBox(height: 8),
        FxText.bodyMedium(
          'Sign in to unlock all features',
          color: Colors.grey[400],
        ),
      ],
    );
  }

  Widget _buildGuestInfo() {
    return FxContainer(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[850],
      borderRadiusAll: 12,
      child: Column(
        children: [
          const Icon(FeatherIcons.user, size: 64, color: CustomTheme.primary),
          const SizedBox(height: 16),
          FxText.titleMedium('Browsing as Guest', color: Colors.white),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            'Create an account to save favorites, create playlists, and get personalized recommendations',
            color: Colors.grey[400],
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FxButton(
                  onPressed: () {
                    Get.toNamed('/login');
                  },
                  backgroundColor: CustomTheme.primary,
                  borderRadiusAll: 8,
                  child: FxText.bodyMedium('Sign In', color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FxButton(
                  onPressed: () {
                    Get.toNamed('/register');
                  },
                  backgroundColor: Colors.transparent,
                  borderColor: CustomTheme.primary,
                  borderRadiusAll: 8,
                  child: FxText.bodyMedium(
                    'Sign Up',
                    color: CustomTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.titleMedium('Features with Account', color: Colors.white),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: FeatherIcons.heart,
          title: 'Save Favorites',
          description: 'Keep track of movies you love',
          isEnabled: false,
        ),
        _buildFeatureItem(
          icon: FeatherIcons.list,
          title: 'Create Playlists',
          description: 'Organize movies into custom lists',
          isEnabled: false,
        ),
        _buildFeatureItem(
          icon: FeatherIcons.messageCircle,
          title: 'Comment & Rate',
          description: 'Share your thoughts on movies',
          isEnabled: false,
        ),
        _buildFeatureItem(
          icon: FeatherIcons.download,
          title: 'Download Movies',
          description: 'Watch offline on your device',
          isEnabled: false,
        ),
        _buildFeatureItem(
          icon: FeatherIcons.bell,
          title: 'Get Notifications',
          description: 'Never miss new releases',
          isEnabled: false,
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FxContainer(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[850],
        borderRadiusAll: 8,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isEnabled
                        ? CustomTheme.primary.withValues(alpha: 0.2)
                        : Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isEnabled ? CustomTheme.primary : Colors.grey[500],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.bodyMedium(
                    title,
                    color: isEnabled ? Colors.white : Colors.grey[400],
                  ),
                  const SizedBox(height: 4),
                  FxText.bodySmall(description, color: Colors.grey[500]),
                ],
              ),
            ),
            if (!isEnabled)
              Icon(FeatherIcons.lock, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.titleMedium('App Information', color: Colors.white),
        const SizedBox(height: 16),
        _buildInfoItem(
          icon: FeatherIcons.info,
          title: 'About Lovebirds Dating',
          onTap: () {
            _showAboutDialog();
          },
        ),
        _buildInfoItem(
          icon: FeatherIcons.helpCircle,
          title: 'Help & Support',
          onTap: () {
            Get.snackbar(
              'Support',
              'For help and support, please contact us through our website',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: CustomTheme.primary,
              colorText: Colors.white,
            );
          },
        ),
        _buildInfoItem(
          icon: FeatherIcons.shield,
          title: 'Privacy Policy',
          onTap: () {
            Get.snackbar(
              'Privacy',
              'Privacy policy available on our website',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );
          },
        ),
        _buildInfoItem(
          icon: FeatherIcons.fileText,
          title: 'Terms of Service',
          onTap: () {
            Get.snackbar(
              'Terms',
              'Terms of service available on our website',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FxButton(
        onPressed: onTap,
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        borderRadiusAll: 8,
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 20),
            const SizedBox(width: 16),
            Expanded(child: FxText.bodyMedium(title, color: Colors.white)),
            Icon(FeatherIcons.chevronRight, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[850],
        title: FxText.titleMedium(
          'About Lovebirds Dating',
          color: Colors.white,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxText.bodyMedium(
              'Lovebirds Dating is your premier destination for meaningful connections and authentic relationships. Find your perfect match with our smart matching system.',
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            FxText.bodySmall('Version: 1.0.0', color: Colors.grey[400]),
            FxText.bodySmall('Build: Release', color: Colors.grey[400]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: FxText.bodyMedium('Close', color: CustomTheme.primary),
          ),
        ],
      ),
    );
  }
}
