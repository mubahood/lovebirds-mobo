import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import '../../models/UserModel.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/Utilities.dart';
import '../shop/screens/shop/chat/chat_screen.dart';
// Import moderation dialogs
import '../../features/moderation/widgets/block_user_dialog.dart';
import '../../features/moderation/widgets/report_content_dialog.dart';
// Import multi-photo gallery
import '../../widgets/dating/multi_photo_gallery.dart';

class ProfileViewScreen extends StatelessWidget {
  final UserModel user;

  const ProfileViewScreen(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Multi-photo gallery instead of single image
                      MultiPhotoGallery(
                        user: user,
                        height: 320,
                        showIndicators: true,
                        allowSwipe: true,
                      ),
                      _buildProfileOverlay(),
                    ],
                  ),
                ),
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: CustomTheme.accent),
                  onPressed: () => Get.back(),
                ),
                // Add actions menu for reporting and blocking
                actions: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: CustomTheme.accent),
                    color: CustomTheme.card,
                    onSelected: (value) => _handleMenuAction(value, context),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'report',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Report User',
                                  style: TextStyle(color: CustomTheme.accent),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'block',
                            child: Row(
                              children: [
                                Icon(Icons.block, color: Colors.red, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'Block User',
                                  style: TextStyle(color: CustomTheme.accent),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonalInfo(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('About Me'),
                      _buildBioSection(),
                      _buildDetailsGrid(),
                      _buildPreferencesGrid(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context) {
    switch (value) {
      case 'report':
        // Show report content dialog
        showDialog(
          context: context,
          builder:
              (context) => ReportContentDialog(
                contentType: 'User',
                contentPreview: user.name,
                contentId: user.id.toString(),
                reportedUserId: user.id.toString(),
              ),
        );
        break;
      case 'block':
        // Show block user dialog
        showDialog(
          context: context,
          builder:
              (context) => BlockUserDialog(
                userName: user.name,
                userId: user.id.toString(),
                userAvatar: user.avatar,
              ),
        );
        break;
    }
  }

  Widget _buildProfileOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
          stops: const [0.1, 0.5],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FxText.displaySmall(
                user.name,
                color: CustomTheme.accent,
                fontWeight: 900,
                letterSpacing: 0.8,
              ),
              if (user.tagline.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FxText.bodyLarge(
                    user.tagline,
                    color: CustomTheme.color,
                    fontWeight: 500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Container(
      height: 40,

      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildInfoBadge(Icons.cake, '${_calculateAge(user.dob)} Years'),
          const SizedBox(width: 12),
          _buildInfoBadge(
            Icons.location_pin,
            user.city.isNotEmpty ? user.city : 'Location not set',
          ),
          const SizedBox(width: 12),
          _buildInfoBadge(
            user.sex == 'male' ? Icons.male : Icons.female,
            user.sex.capitalizeFirst ?? '',
          ),
          if (user.isOnline) ...[
            const SizedBox(width: 12),
            _buildOnlineIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: CustomTheme.primary),
          const SizedBox(width: 6),
          FxText.bodySmall(text, color: CustomTheme.color, fontWeight: 600),
        ],
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          FxText.bodySmall('Online Now', color: Colors.green, fontWeight: 700),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(15),
      ),
      child:
          user.bio.isNotEmpty
              ? FxText.bodyMedium(
                user.bio,
                color: CustomTheme.color,
                height: 1.4,
              )
              : FxText.bodyMedium(
                'No bio added yet',
                color: CustomTheme.color2,
              ),
    );
  }

  Widget _buildDetailsGrid() {
    final details = {
      Icons.work: user.occupation,
      Icons.school: user.education_level,
      Icons.height: user.height_cm.isNotEmpty ? '${user.height_cm} cm' : null,
      Icons.favorite: user.looking_for,
      Icons.people: user.interested_in,
      Icons.category: user.body_type,
    };

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.5,
      children:
          details.entries.map((entry) {
            return _buildDetailItem(entry.key, entry.value.toString());
          }).toList(),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: CustomTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: FxText.bodyMedium(
              text.isNotEmpty ? text : 'Not specified',
              color: CustomTheme.color,
              fontWeight: 500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesGrid() {
    final preferences = {
      '🚭 Smoking': user.smoking_habit,
      '🍷 Drinking': user.drinking_habit,
      '🐾 Pets': user.pet_preference,
      '🙏 Religion': user.religion,
      '🗳️ Politics': user.political_views,
      '💬 Languages': user.languages_spoken,
    };

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.6,
      children:
          preferences.entries.map((entry) {
            return _buildPreferenceItem(entry.key, entry.value);
          }).toList(),
    );
  }

  Widget _buildPreferenceItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CustomTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.bodySmall(title, color: CustomTheme.primary, fontWeight: 700),
          const SizedBox(height: 4),
          FxText.bodyMedium(
            value.toString().isEmpty ? 'Not specified' : value,
            color: CustomTheme.color,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: FxText.titleLarge(
        title,
        color: CustomTheme.accent,
        fontWeight: 800,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Row(
        children: [
          FxContainer(
            borderRadiusAll: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: CustomTheme.primary,
            child: Row(
              children: [
                Icon(Icons.chat, color: CustomTheme.accent),
                const SizedBox(width: 8),
                FxText.titleLarge(
                  'Send Message',
                  color: CustomTheme.accent,
                  height: 1,
                  fontWeight: 900,
                ),
              ],
            ),
            onTap: () {
              Get.to(
                () => ChatScreen({
                  'task': 'START_CHAT',
                  'receiver_id': user.id.toString(),
                  'receiver': user,
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  int _calculateAge(String dob) {
    try {
      final birthDate = DateTime.parse(dob);
      final currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      if (currentDate.month < birthDate.month ||
          (currentDate.month == birthDate.month &&
              currentDate.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}
