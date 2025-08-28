import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/CustomTheme.dart';
import '../../../services/moderation_service.dart';
import '../../../utils/Utilities.dart';

class BlockUserDialog extends StatefulWidget {
  final String userName;
  final String userId;
  final String? userAvatar;
  final String? reason; // Optional pre-filled reason

  const BlockUserDialog({
    Key? key,
    required this.userName,
    required this.userId,
    this.userAvatar,
    this.reason,
  }) : super(key: key);

  @override
  State<BlockUserDialog> createState() => _BlockUserDialogState();

  /// Static method to show block user dialog
  static Future<void> show({
    required BuildContext context,
    required String userId,
    required String userName,
    String? userAvatar,
    String? reason,
  }) async {
    return showDialog(
      context: context,
      builder:
          (context) => BlockUserDialog(
            userId: userId,
            userName: userName,
            userAvatar: userAvatar,
            reason: reason,
          ),
    );
  }
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  bool _isBlocking = false;
  bool _alsoReportUser = false;
  String? selectedBlockDuration;
  final TextEditingController _reasonController = TextEditingController();

  // Block duration options
  final List<Map<String, String>> blockDurations = [
    {'id': 'temporary', 'title': '24 Hours', 'description': 'Temporary block'},
    {'id': 'week', 'title': '1 Week', 'description': 'Block for one week'},
    {'id': 'month', 'title': '1 Month', 'description': 'Block for one month'},
    {
      'id': 'permanent',
      'title': 'Permanent',
      'description': 'Block permanently',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.reason != null) {
      _reasonController.text = widget.reason!;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CustomTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.block, color: Colors.red, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Block User',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Block ${widget.userName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // User info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            widget.userAvatar != null
                                ? NetworkImage(widget.userAvatar!)
                                : null,
                        child:
                            widget.userAvatar == null
                                ? Icon(Icons.person, color: Colors.grey[600])
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'This user will not be able to interact with you',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Block duration selection
                Text(
                  'Block Duration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                Column(
                  children:
                      blockDurations.map((duration) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: RadioListTile<String>(
                            value: duration['id']!,
                            groupValue: selectedBlockDuration,
                            onChanged: (value) {
                              setState(() {
                                selectedBlockDuration = value;
                              });
                            },
                            title: Text(
                              duration['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              duration['description']!,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            dense: true,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),

                // Optional reason
                Text(
                  'Reason (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    hintText: 'Why are you blocking this user?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Also report checkbox
                CheckboxListTile(
                  value: _alsoReportUser,
                  onChanged: (value) {
                    setState(() {
                      _alsoReportUser = value ?? false;
                    });
                  },
                  title: const Text('Also report this user'),
                  subtitle: Text(
                    'Report user for violating community guidelines',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            selectedBlockDuration != null && !_isBlocking
                                ? _blockUser
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isBlocking
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Block User',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
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

  Future<void> _blockUser() async {
    if (selectedBlockDuration == null) return;

    setState(() {
      _isBlocking = true;
    });

    try {
      final result = await ModerationService.blockUser(
        blockedUserId: widget.userId,
        reason: _reasonController.text.trim(),
      );

      if (result['code'] == 1) {
        Utils.toast('User has been blocked successfully');
        Get.back();

        // Show report dialog if also reporting
        if (_alsoReportUser) {
          Utils.toast('User has also been reported to moderators');
        }
      } else {
        Utils.toast(result['message'] ?? 'Failed to block user');
      }
    } catch (e) {
      Utils.toast('Failed to block user. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isBlocking = false;
        });
      }
    }
  }
}
