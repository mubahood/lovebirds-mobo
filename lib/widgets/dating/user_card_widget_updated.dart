import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../../models/UserModel.dart';
import '../../utils/AppConfig.dart';
import '../../utils/CustomTheme.dart';
import 'multi_photo_gallery.dart';

class UserCardWidget extends StatelessWidget {
  final UserModel user;

  const UserCardWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: CustomTheme.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    // Multi-photo gallery or single photo
                    _buildPhotoContent(),

                    // Photo count indicator
                    if (user.hasMultiplePhotos()) _buildPhotoCountIndicator(),
                  ],
                ),
              ),
            ),
          ),

          // User info
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FxText.bodyMedium(
                    '${user.name.isEmpty ? 'Unknown' : user.name}, ${_getUserAge() ?? '?'}',
                    color: Colors.white,
                    fontWeight: 600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (user.city.isNotEmpty)
                    FxText.bodySmall(
                      user.city,
                      color: CustomTheme.color2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (user.occupation.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    FxText.bodySmall(
                      user.occupation,
                      color: CustomTheme.color2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoContent() {
    if (user.hasMultiplePhotos()) {
      return MultiPhotoGallery(
        user: user,
        height: double.infinity,
        showIndicators: true,
        allowSwipe: true,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: _getAvatarUrl(),
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              color: CustomTheme.primary.withValues(alpha: 0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: CustomTheme.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
      );
    }
  }

  Widget _buildPhotoCountIndicator() {
    final count = user.getPhotoCount();
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library, color: Colors.white, size: 10),
            const SizedBox(width: 2),
            FxText.bodySmall(
              '$count',
              color: Colors.white,
              fontSize: 10,
              fontWeight: 600,
            ),
          ],
        ),
      ),
    );
  }

  String _getAvatarUrl() {
    if (user.avatar.isEmpty) {
      // Use a default image from the available images instead of non-existent no-image.jpg
      return '${AppConfig.BASE_URL}/storage/images/1.jpg';
    }
    if (user.avatar.startsWith('http')) {
      return user.avatar;
    }
    return '${AppConfig.BASE_URL}/storage/${user.avatar}';
  }

  int? _getUserAge() {
    if (user.dob.isEmpty) return null;
    try {
      final dob = DateTime.parse(user.dob);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }
}
