import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../controllers/MainController.dart';
import '../../../utils/AppConfig.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';
import '../../auth/login_screen.dart';
import 'order_history_screen.dart';
import 'marketplace_settings_screen.dart';

class MarketplaceProfileScreen extends StatefulWidget {
  const MarketplaceProfileScreen({Key? key}) : super(key: key);

  @override
  _MarketplaceProfileScreenState createState() =>
      _MarketplaceProfileScreenState();
}

class _MarketplaceProfileScreenState extends State<MarketplaceProfileScreen> {
  final MainController mainController = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildMenuSection(),
            const SizedBox(height: 32),
            _buildAccountActions(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: CustomTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(FeatherIcons.arrowLeft, color: CustomTheme.accent),
        onPressed: () => Navigator.pop(context),
      ),
      title: FxText.titleLarge(
        '${AppConfig.MARKETPLACE_NAME} Profile',
        color: CustomTheme.color,
        fontWeight: 700,
      ),
      actions: [
        IconButton(
          icon: Icon(FeatherIcons.edit3, color: CustomTheme.accent),
          onPressed: _editProfile,
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final user = mainController.userModel;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomTheme.primary.withValues(alpha: 0.1),
            CustomTheme.primaryDark.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CustomTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: CustomTheme.primary, width: 3),
            ),
            child: ClipOval(
              child:
                  user.avatar.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: Utils.img(user.avatar),
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => Container(
                              color: CustomTheme.card,
                              child: Icon(
                                FeatherIcons.user,
                                size: 40,
                                color: CustomTheme.primary,
                              ),
                            ),
                        errorWidget:
                            (_, __, ___) => Container(
                              color: CustomTheme.card,
                              child: Icon(
                                FeatherIcons.user,
                                size: 40,
                                color: CustomTheme.primary,
                              ),
                            ),
                      )
                      : Container(
                        color: CustomTheme.card,
                        child: Icon(
                          FeatherIcons.user,
                          size: 40,
                          color: CustomTheme.primary,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 16),
          FxText.titleLarge(
            '${user.first_name} ${user.last_name}'.trim(),
            fontWeight: 700,
            color: CustomTheme.colorLight,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            user.email,
            color: CustomTheme.color3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Orders', '12', FeatherIcons.shoppingBag),
              Container(width: 1, height: 40, color: CustomTheme.color4),
              _buildStatItem('Wishlist', '8', FeatherIcons.heart),
              Container(width: 1, height: 40, color: CustomTheme.color4),
              _buildStatItem('Reviews', '5', FeatherIcons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: CustomTheme.primary, size: 20),
        const SizedBox(height: 4),
        FxText.bodyLarge(value, fontWeight: 700, color: CustomTheme.colorLight),
        FxText.bodySmall(label, color: CustomTheme.color3),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.titleMedium(
          'Account',
          fontWeight: 700,
          color: CustomTheme.colorLight,
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: FeatherIcons.shoppingBag,
          title: 'Order History',
          subtitle: 'View your past orders and track current ones',
          onTap: () => Get.to(() => const OrderHistoryScreen()),
        ),
        _buildMenuItem(
          icon: FeatherIcons.heart,
          title: 'Wishlist',
          subtitle: 'Items you\'ve saved for later',
          onTap: () => Utils.toast('Wishlist feature coming soon!'),
        ),
        _buildMenuItem(
          icon: FeatherIcons.mapPin,
          title: 'Addresses',
          subtitle: 'Manage your shipping addresses',
          onTap: () => Utils.toast('Address management coming soon!'),
        ),
        _buildMenuItem(
          icon: FeatherIcons.creditCard,
          title: 'Payment Methods',
          subtitle: 'Manage your payment options',
          onTap: () => Utils.toast('Payment methods managed through Stripe'),
        ),
        const SizedBox(height: 32),
        FxText.titleMedium(
          'App Settings',
          fontWeight: 700,
          color: CustomTheme.colorLight,
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: FeatherIcons.settings,
          title: 'Settings',
          subtitle: 'Notifications, privacy & more',
          onTap: () => Get.to(() => const MarketplaceSettingsScreen()),
        ),
        _buildMenuItem(
          icon: FeatherIcons.helpCircle,
          title: 'Help & Support',
          subtitle: 'Get help with your orders',
          onTap: () => Utils.toast('Support feature coming soon!'),
        ),
        _buildMenuItem(
          icon: FeatherIcons.fileText,
          title: 'Terms & Privacy',
          subtitle: 'Legal information',
          onTap: () => Utils.toast('Terms & Privacy coming soon!'),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CustomTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CustomTheme.color4),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CustomTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: CustomTheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyLarge(
                        title,
                        fontWeight: 600,
                        color: CustomTheme.colorLight,
                      ),
                      const SizedBox(height: 4),
                      FxText.bodySmall(
                        subtitle,
                        color: CustomTheme.color3,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Icon(
                  FeatherIcons.chevronRight,
                  color: CustomTheme.color3,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(FeatherIcons.logOut, size: 20),
            label: FxText.bodyLarge('Logout', fontWeight: 600),
          ),
        ),
        const SizedBox(height: 16),
        FxText.bodySmall(
          '${AppConfig.MARKETPLACE_NAME} v${AppConfig.APP_VERSION}',
          color: CustomTheme.color3,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _editProfile() {
    // TODO: Navigate to profile edit screen
    Utils.toast('Profile editing coming soon!');
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: CustomTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: FxText.titleMedium(
              'Logout',
              color: CustomTheme.colorLight,
              fontWeight: 700,
            ),
            content: FxText.bodyMedium(
              'Are you sure you want to logout from ${AppConfig.MARKETPLACE_NAME}?',
              color: CustomTheme.color,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: FxText.bodyMedium('Cancel', color: CustomTheme.color3),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  // Clear user data
                  await Utils.logout();

                  // Navigate to login
                  Get.offAll(() => const LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: FxText.bodyMedium('Logout', fontWeight: 600),
              ),
            ],
          ),
    );
  }
}
