import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../utils/CustomTheme.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  bool _loading = true;
  List<BlockedUserModel> _blockedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _loading = true);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading

      // Mock data - replace with actual API response
      _blockedUsers = [
        BlockedUserModel(
          id: '1',
          name: 'Jane Smith',
          avatar: 'https://example.com/avatar1.jpg',
          blockedDate: DateTime.now().subtract(const Duration(days: 2)),
          blockDuration: '1 Week',
          reason: 'Inappropriate behavior',
        ),
        BlockedUserModel(
          id: '2',
          name: 'Mike Johnson',
          avatar: '',
          blockedDate: DateTime.now().subtract(const Duration(days: 7)),
          blockDuration: 'Permanent',
          reason: 'Fake profile',
        ),
      ];
    } catch (e) {
      print('Error loading blocked users: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _unblockUser(BlockedUserModel user) async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: CustomTheme.card,
        title: Text(
          'Unblock ${user.name}?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'This person will be able to see your profile and send you messages again.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primary,
            ),
            child: const Text('Unblock', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Call unblock API
        setState(() {
          _blockedUsers.removeWhere((u) => u.id == user.id);
        });

        Get.snackbar(
          'User Unblocked',
          '${user.name} has been unblocked successfully',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          icon: Icon(Icons.check_circle, color: Colors.green[700]),
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to unblock user. Please try again.',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          icon: Icon(Icons.error, color: Colors.red[700]),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        iconTheme: const IconThemeData(color: CustomTheme.accent),
        elevation: 1,
        title: FxText.titleLarge(
          'Blocked Users',
          color: CustomTheme.accent,
          fontWeight: 700,
        ),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(CustomTheme.accent),
                ),
              )
              : _blockedUsers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _blockedUsers.length,
                itemBuilder: (context, index) {
                  final user = _blockedUsers[index];
                  return _buildBlockedUserCard(user);
                },
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CustomTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.block, size: 64, color: CustomTheme.primary),
          ),
          const SizedBox(height: 24),
          FxText.titleLarge(
            'No Blocked Users',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: FxText.bodyMedium(
              'You haven\'t blocked anyone yet. Blocked users will appear here, and you can unblock them anytime.',
              color: CustomTheme.color2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text(
              'Back to Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUserCard(BlockedUserModel user) {
    final daysSinceBlocked = DateTime.now().difference(user.blockedDate).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: CustomTheme.primary,
              backgroundImage:
                  user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
              child:
                  user.avatar.isEmpty
                      ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 16),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.bodyLarge(
                    user.name,
                    color: Colors.white,
                    fontWeight: 600,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.block, size: 14, color: Colors.red[400]),
                      const SizedBox(width: 4),
                      FxText.bodySmall(
                        'Blocked ${daysSinceBlocked == 0 ? 'today' : '$daysSinceBlocked days ago'}',
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                  if (user.reason.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    FxText.bodySmall(
                      'Reason: ${user.reason}',
                      color: CustomTheme.color2,
                    ),
                  ],
                  FxText.bodySmall(
                    'Duration: ${user.blockDuration}',
                    color: CustomTheme.color2,
                  ),
                ],
              ),
            ),

            // Unblock button
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: CustomTheme.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => _unblockUser(user),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'Unblock',
                  style: TextStyle(
                    color: CustomTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model for blocked user data
class BlockedUserModel {
  final String id;
  final String name;
  final String avatar;
  final DateTime blockedDate;
  final String blockDuration;
  final String reason;

  BlockedUserModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.blockedDate,
    required this.blockDuration,
    required this.reason,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) {
    return BlockedUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      blockedDate:
          DateTime.tryParse(json['blocked_date'] ?? '') ?? DateTime.now(),
      blockDuration: json['block_duration'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}
