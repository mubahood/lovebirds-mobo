import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<dynamic> _blockedUsers = [];
  bool _isLoading = true;
  final _blockUserController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  @override
  void dispose() {
    _blockUserController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ModerationService.getBlockedUsers();
      if (result['code'] == 1 && result['data'] != null) {
        setState(() {
          _blockedUsers = result['data'];
        });
      }
    } catch (e) {
      Utils.toast('Failed to load blocked users');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(String blockedUserId, String userName) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: FxText.titleMedium('Unblock User'),
        content: FxText.bodyMedium(
          'Are you sure you want to unblock $userName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
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
        final result = await ModerationService.unblockUser(
          blockedUserId: blockedUserId,
        );

        if (result['code'] == 1) {
          Utils.toast('User unblocked successfully');
          _loadBlockedUsers(); // Refresh the list
        } else {
          Utils.toast(result['message'] ?? 'Failed to unblock user');
        }
      } catch (e) {
        Utils.toast('An error occurred while unblocking the user');
      }
    }
  }

  Future<void> _showBlockUserDialog() async {
    _blockUserController.clear();
    _reasonController.clear();

    await Get.dialog(
      AlertDialog(
        title: FxText.titleMedium('Block User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FxText.bodySmall(
                'Enter the user ID or username to block:',
                color: Colors.grey[600],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _blockUserController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'User ID or username',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FxText.bodySmall('Reason (optional):', color: Colors.grey[600]),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Why are you blocking this user?',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _blockUser,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Block User',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _blockUser() async {
    if (_blockUserController.text.trim().isEmpty) {
      Utils.toast('Please enter a user ID or username');
      return;
    }

    try {
      final result = await ModerationService.blockUser(
        blockedUserId: _blockUserController.text.trim(),
        reason: _reasonController.text.trim(),
      );

      if (result['code'] == 1) {
        Utils.toast('User blocked successfully');
        Get.back(); // Close dialog
        _loadBlockedUsers(); // Refresh the list
      } else {
        Utils.toast(result['message'] ?? 'Failed to block user');
      }
    } catch (e) {
      Utils.toast('An error occurred while blocking the user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleLarge('Blocked Users', color: Colors.white),
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            onPressed: _showBlockUserDialog,
            icon: const Icon(Icons.person_add_disabled, color: Colors.white),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadBlockedUsers,
                child:
                    _blockedUsers.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _blockedUsers.length,
                          itemBuilder: (context, index) {
                            final user = _blockedUsers[index];
                            return _buildBlockedUserCard(user);
                          },
                        ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBlockUserDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.person_add_disabled, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            FxText.titleMedium(
              'No Blocked Users',
              color: Colors.grey[600],
              fontWeight: 600,
            ),
            const SizedBox(height: 8),
            FxText.bodyMedium(
              'You haven\'t blocked any users yet. Use the + button to block someone.',
              color: Colors.grey[500],
              textAlign: TextAlign.center,
              height: 1.4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedUserCard(dynamic user) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.grey[600]),
        ),
        title: FxText.titleSmall(
          user['blocked_user_name'] ?? 'Unknown User',
          fontWeight: 600,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (user['reason'] != null && user['reason'].toString().isNotEmpty)
              FxText.bodySmall(
                'Reason: ${user['reason']}',
                color: Colors.grey[600],
              ),
            const SizedBox(height: 4),
            FxText.bodySmall(
              'Blocked: ${_formatDate(user['created_at'])}',
              color: Colors.grey[500],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed:
              () => _unblockUser(
                user['blocked_user_id'].toString(),
                user['blocked_user_name'] ?? 'Unknown User',
              ),
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: FxText.bodySmall(
            'Unblock',
            color: Colors.white,
            fontWeight: 600,
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
