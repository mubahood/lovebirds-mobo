import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/CustomTheme.dart';

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
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  bool _isBlocking = false;
  bool _alsoReportUser = false;
  String? selectedBlockDuration;

  // Block duration options for dating context
  final List<Map<String, String>> blockDurations = [
    {
      'id': 'temporary',
      'title': '24 Hours',
      'description': 'Temporary block - they can find you again after 24 hours',
    },
    {
      'id': 'week',
      'title': '1 Week',
      'description':
          'Block for one week - prevents them from seeing your profile',
    },
    {
      'id': 'month',
      'title': '1 Month',
      'description': 'Block for one month - complete dating interaction ban',
    },
    {
      'id': 'permanent',
      'title': 'Permanent',
      'description': 'Block permanently - they will never see you again',
    },
  ];

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
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CustomTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.block,
                        color: CustomTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Block User',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Prevent interactions with this user',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // User info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: CustomTheme.primary,
                        backgroundImage:
                            widget.userAvatar != null
                                ? NetworkImage(widget.userAvatar!)
                                : null,
                        child:
                            widget.userAvatar == null
                                ? Text(
                                  widget.userName.isNotEmpty
                                      ? widget.userName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'User ID: ${widget.userId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
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
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Block Duration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Duration options
                ...blockDurations
                    .map(
                      (duration) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedBlockDuration = duration['id'];
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    selectedBlockDuration == duration['id']
                                        ? CustomTheme.primary
                                        : Colors.grey[600]!,
                                width:
                                    selectedBlockDuration == duration['id']
                                        ? 2
                                        : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color:
                                  selectedBlockDuration == duration['id']
                                      ? CustomTheme.primary.withValues(
                                        alpha: 0.1,
                                      )
                                      : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: duration['id']!,
                                  groupValue: selectedBlockDuration,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBlockDuration = value;
                                    });
                                  },
                                  activeColor: CustomTheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        duration['title']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        duration['description']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),

                const SizedBox(height: 16),

                // Also report user option
                InkWell(
                  onTap: () {
                    setState(() {
                      _alsoReportUser = !_alsoReportUser;
                    });
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: _alsoReportUser,
                        onChanged: (value) {
                          setState(() {
                            _alsoReportUser = value ?? false;
                          });
                        },
                        activeColor: CustomTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Also report this user',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Report for violating dating community standards',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Warning message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Blocked users cannot see your profile, send you messages, or interact with you in any way.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isBlocking ? null : () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed:
                            _isBlocking || selectedBlockDuration == null
                                ? null
                                : _blockUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.primary,
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
              ], // Close Column children
            ), // Close Column
          ), // Close Container
        ), // Close SingleChildScrollView
      ), // Close ConstrainedBox
    ); // Close Dialog
  }

  Future<void> _blockUser() async {
    if (selectedBlockDuration == null) return;

    setState(() {
      _isBlocking = true;
    });

    try {
      // TODO: Implement actual blocking API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      Get.back(); // Close dialog
      Get.snackbar(
        'User Blocked',
        '${widget.userName} has been blocked successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: Icon(Icons.check_circle, color: Colors.green[700]),
        duration: const Duration(seconds: 3),
      );

      // If also reporting, open report dialog
      if (_alsoReportUser) {
        // TODO: Open report dialog or automatically submit report
        Get.snackbar(
          'Report Submitted',
          'User has also been reported to moderators',
          backgroundColor: Colors.blue[100],
          colorText: Colors.blue[800],
          icon: Icon(Icons.flag, color: Colors.blue[700]),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to block user. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: Icon(Icons.error, color: Colors.red[700]),
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBlocking = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

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
