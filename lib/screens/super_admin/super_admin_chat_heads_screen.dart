import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/RespondModel.dart';
import '../../utils/Utilities.dart';
import '../../utils/CustomTheme.dart';
import 'super_admin_chat_screen.dart';

// Note: Utils is available globally but we use Utilities for explicit imports

class SuperAdminChatHeadsScreen extends StatefulWidget {
  const SuperAdminChatHeadsScreen({Key? key}) : super(key: key);

  @override
  State<SuperAdminChatHeadsScreen> createState() =>
      _SuperAdminChatHeadsScreenState();
}

class _SuperAdminChatHeadsScreenState extends State<SuperAdminChatHeadsScreen> {
  bool _isLoading = true;
  List<dynamic> _chatHeads = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadChatHeads();
  }

  Future<void> _loadChatHeads() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await Utils.http_get('super-admin-chat-heads', {});
      final resp = RespondModel(response);

      if (resp.code == 1) {
        setState(() {
          _chatHeads = resp.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              resp.message.isNotEmpty
                  ? resp.message
                  : 'Failed to load chat heads';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _openChat(dynamic chatHead) async {
    // Navigate to the chat screen
    await Get.to(() => const SuperAdminChatScreen(), arguments: chatHead);

    // Refresh the chat heads list when returning from chat
    // This will update the unread counts after messages are marked as read
    await _loadChatHeads();
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';

    try {
      final DateTime dateTime = DateTime.parse(timeString);
      final Duration difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildChatHeadItem(dynamic chatHead) {
    final String testAccountName =
        chatHead['test_account_name'] ?? 'Unknown Test Account';
    final String otherUserName = chatHead['other_user_name'] ?? 'Unknown User';
    final String lastMessage = chatHead['last_message_body'] ?? 'No messages';
    final String lastMessageTime = _formatTime(chatHead['last_message_time']);
    final int unreadCount = chatHead['unread_messages_count'] ?? 0;
    final String testAccountPhoto = chatHead['test_account_photo'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.card, CustomTheme.cardDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openChat(chatHead),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Enhanced avatar with gradient background
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CustomTheme.primary.withValues(alpha: 0.8),
                            CustomTheme.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: CustomTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child:
                          testAccountPhoto.isNotEmpty
                              ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: Utils.img(testAccountPhoto),
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              CustomTheme.color2,
                                              CustomTheme.color2.withValues(
                                                alpha: 0.7,
                                              ),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: CustomTheme.accent,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              CustomTheme.color2,
                                              CustomTheme.color2.withValues(
                                                alpha: 0.7,
                                              ),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            testAccountName.isNotEmpty
                                                ? testAccountName[0]
                                                    .toUpperCase()
                                                : 'T',
                                            style: const TextStyle(
                                              color: CustomTheme.accent,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                              )
                              : Center(
                                child: Text(
                                  testAccountName.isNotEmpty
                                      ? testAccountName[0].toUpperCase()
                                      : 'T',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    ),
                    // Unread count badge
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CustomTheme.primary,
                                CustomTheme.primaryDark,
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CustomTheme.card,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CustomTheme.primary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Message content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Test account info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CustomTheme.primary,
                                  CustomTheme.primaryDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: CustomTheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'TEST ACCOUNT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              testAccountName,
                              style: TextStyle(
                                color: CustomTheme.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Other user info
                      Text(
                        'Chatting with: $otherUserName',
                        style: TextStyle(
                          color: CustomTheme.color2,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Last message
                      Text(
                        lastMessage.length > 60
                            ? '${lastMessage.substring(0, 60)}...'
                            : lastMessage,
                        style: TextStyle(
                          color: CustomTheme.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Time and chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (lastMessageTime.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CustomTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CustomTheme.color2.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          lastMessageTime,
                          style: TextStyle(
                            color: CustomTheme.color2,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CustomTheme.primary.withValues(alpha: 0.2),
                            CustomTheme.primary.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: CustomTheme.primary,
                        size: 20,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.card,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CustomTheme.card, CustomTheme.cardDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Super Admin - Test Account Chats',
          style: TextStyle(
            color: CustomTheme.accent,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomTheme.accent),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomTheme.primary.withValues(alpha: 0.2),
                  CustomTheme.primary.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, color: CustomTheme.primary),
              onPressed: _loadChatHeads,
              tooltip: 'Reload chats',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CustomTheme.background,
              CustomTheme.background.withValues(blue: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            _isLoading
                ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [CustomTheme.card, CustomTheme.cardDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CustomTheme.primary,
                          ),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading chats...',
                          style: TextStyle(
                            color: CustomTheme.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : _errorMessage.isNotEmpty
                ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [CustomTheme.card, CustomTheme.cardDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CustomTheme.primary.withValues(alpha: 0.2),
                                CustomTheme.primary.withValues(alpha: 0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: CustomTheme.primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            color: CustomTheme.accent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            color: CustomTheme.color,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CustomTheme.primary,
                                CustomTheme.primaryDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: CustomTheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _loadChatHeads,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Try Again',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : _chatHeads.isEmpty
                ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [CustomTheme.card, CustomTheme.cardDark],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CustomTheme.color2.withValues(alpha: 0.3),
                                CustomTheme.color2.withValues(alpha: 0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: CustomTheme.color2,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No test account chats found',
                          style: TextStyle(
                            color: CustomTheme.accent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Test accounts will appear here when they start chatting with other users',
                            style: TextStyle(
                              color: CustomTheme.color2,
                              fontSize: 15,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CustomTheme.primary,
                                CustomTheme.primaryDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: CustomTheme.primary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _loadChatHeads,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text(
                              'Reload',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _loadChatHeads,
                  color: CustomTheme.primary,
                  backgroundColor: CustomTheme.card,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _chatHeads.length,
                    itemBuilder: (context, index) {
                      return _buildChatHeadItem(_chatHeads[index]);
                    },
                  ),
                ),
      ),
    );
  }
}
