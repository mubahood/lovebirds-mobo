import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';

import '../../utils/dating_theme.dart';
import '../../managers/nearby_users_manager.dart';
import '../../models/UserModel.dart';
import '../../screens/location/location_preferences_screen.dart';

class NearbyUsersWidget extends StatefulWidget {
  final Function(UserModel)? onUserTap;
  final int maxUsers;
  final bool showHeader;

  const NearbyUsersWidget({
    Key? key,
    this.onUserTap,
    this.maxUsers = 6,
    this.showHeader = true,
  }) : super(key: key);

  @override
  _NearbyUsersWidgetState createState() => _NearbyUsersWidgetState();
}

class _NearbyUsersWidgetState extends State<NearbyUsersWidget> {
  List<UserModel> _nearbyUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeNearbyUsers();
  }

  Future<void> _initializeNearbyUsers() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize nearby users manager
    await NearbyUsersManager.instance.initialize();

    // Add listener for updates
    NearbyUsersManager.instance.addNearbyUsersListener(_onNearbyUsersUpdate);

    // Get initial nearby users
    await NearbyUsersManager.instance.updateNearbyUsers();
  }

  void _onNearbyUsersUpdate(List<UserModel> users) {
    if (mounted) {
      setState(() {
        _nearbyUsers = users.take(widget.maxUsers).toList();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    NearbyUsersManager.instance.removeNearbyUsersListener(_onNearbyUsersUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader) _buildHeader(),
          if (widget.showHeader) const SizedBox(height: 16),
          _buildNearbyUsersList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: DatingTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                FeatherIcons.mapPin,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby',
                  style: TextStyle(
                    color: DatingTheme.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_nearbyUsers.length} people around you',
                  style: TextStyle(
                    color: DatingTheme.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () => Get.to(() => const LocationPreferencesScreen()),
          icon: Icon(
            FeatherIcons.settings,
            color: DatingTheme.secondaryText,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyUsersList() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_nearbyUsers.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _nearbyUsers.length,
        itemBuilder: (context, index) {
          return _buildNearbyUserCard(_nearbyUsers[index]);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: DatingTheme.getSwipeCardDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: DatingTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: DatingTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 30,
                  height: 6,
                  decoration: BoxDecoration(
                    color: DatingTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: DatingTheme.getSwipeCardDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.mapPin,
              color: DatingTheme.secondaryText,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'No one nearby',
              style: TextStyle(color: DatingTheme.secondaryText, fontSize: 14),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => Get.to(() => const LocationPreferencesScreen()),
              child: Text(
                'Adjust distance',
                style: TextStyle(
                  color: DatingTheme.primaryPink,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyUserCard(UserModel user) {
    return GestureDetector(
      onTap: () => widget.onUserTap?.call(user),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: DatingTheme.getSwipeCardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile photo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: DatingTheme.primaryPink.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child:
                    user.avatar.isNotEmpty
                        ? Image.network(
                          user.avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar(user);
                          },
                        )
                        : _buildDefaultAvatar(user),
              ),
            ),

            const SizedBox(height: 8),

            // Name
            Text(
              user.getFirstName(),
              style: TextStyle(
                color: DatingTheme.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Distance
            Text(
              NearbyUsersManager.instance.formatDistance(user.distance),
              style: TextStyle(color: DatingTheme.secondaryText, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        gradient: DatingTheme.primaryGradient,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Center(
        child: Text(
          user.getFirstName().isNotEmpty
              ? user.getFirstName()[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
