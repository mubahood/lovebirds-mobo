import 'package:flutter/material.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/Utilities.dart';
import '../widgets/block_user_dialog.dart';

class QuickBlockButton extends StatelessWidget {
  final String userId;
  final String userName;

  const QuickBlockButton({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showBlockOptions(context),
      icon: const Icon(Icons.block, color: Colors.red),
      tooltip: 'Block $userName',
    );
  }

  void _showBlockOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Block $userName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: const Text('Block User'),
                  subtitle: const Text('Block this user with custom options'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder:
                          (context) => BlockUserDialog(
                            userId: userId,
                            userName: userName,
                          ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timer, color: Colors.orange),
                  title: const Text('Quick block - 24 hours'),
                  subtitle: const Text('Block for 24 hours'),
                  onTap: () => _quickBlock(context, '24_hours'),
                ),
                ListTile(
                  leading: const Icon(Icons.block_flipped, color: Colors.red),
                  title: const Text('Quick block - Permanent'),
                  subtitle: const Text('Block permanently'),
                  onTap: () => _quickBlock(context, 'permanent'),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _quickBlock(BuildContext context, String duration) async {
    Navigator.pop(context);
    Utils.showLoader(false);

    try {
      final result = await ModerationService.blockUser(
        blockedUserId: userId,
        reason: 'Quick block: $duration',
      );

      Utils.hideLoader();

      if (result['code'] == 1) {
        Utils.toast('User blocked successfully');
      } else {
        Utils.toast(
          result['message'] ?? 'Failed to block user',
          color: Colors.red,
        );
      }
    } catch (e) {
      Utils.hideLoader();
      Utils.toast('Failed to block user: ${e.toString()}', color: Colors.red);
    }
  }
}
