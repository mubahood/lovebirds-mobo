import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';

class BlockUserScreen extends StatefulWidget {
  final String? userId;
  final String? userName;

  const BlockUserScreen({Key? key, this.userId, this.userName})
    : super(key: key);

  @override
  State<BlockUserScreen> createState() => _BlockUserScreenState();
}

class _BlockUserScreenState extends State<BlockUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _userIdController.text = widget.userId!;
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _blockUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ModerationService.blockUser(
        blockedUserId: _userIdController.text.trim(),
        reason: _reasonController.text.trim(),
      );

      if (result['code'] == 1) {
        Utils.toast('User blocked successfully');
        Get.back(result: true);
      } else {
        Utils.toast(result['message'] ?? 'Failed to block user');
      }
    } catch (e) {
      Utils.toast('An error occurred while blocking the user');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleLarge('Block User', color: Colors.white),
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning message
                Card(
                  color: Colors.red[50],
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            FxText.titleSmall(
                              'Block User Warning',
                              fontWeight: 600,
                              color: Colors.red[800],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FxText.bodySmall(
                          'Blocking a user will:\n'
                          '• Prevent them from contacting you\n'
                          '• Hide their content from your view\n'
                          '• Remove them from your interactions\n'
                          '• This action can be reversed later',
                          color: Colors.red[700],
                          height: 1.6,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User information
                if (widget.userName != null) ...[
                  FxText.titleSmall(
                    'User to Block',
                    fontWeight: 600,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
                      title: FxText.titleSmall(
                        widget.userName!,
                        fontWeight: 600,
                      ),
                      subtitle: FxText.bodySmall(
                        'User ID: ${widget.userId}',
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // User ID field (if not pre-filled)
                if (widget.userId == null) ...[
                  FxText.titleSmall(
                    'User ID or Username',
                    fontWeight: 600,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter user ID or username to block',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a user ID or username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Reason field
                FxText.titleSmall(
                  'Reason for Blocking (Optional)',
                  fontWeight: 600,
                  color: Colors.grey[800],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Why are you blocking this user?',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: FxText.titleSmall(
                          'Cancel',
                          color: Colors.grey[700],
                          fontWeight: 600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _blockUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isSubmitting
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : FxText.titleSmall(
                                  'Block User',
                                  color: Colors.white,
                                  fontWeight: 600,
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
}
