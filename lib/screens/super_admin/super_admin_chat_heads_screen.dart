import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/RespondModel.dart';
import '../../utils/Utilities.dart';
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

  void _openChat(dynamic chatHead) {
    Get.to(() => const SuperAdminChatScreen(), arguments: chatHead);
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: const Color(0xFF1E1E1E),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[700],
              backgroundImage:
                  testAccountPhoto.isNotEmpty
                      ? NetworkImage(testAccountPhoto)
                      : null,
              child:
                  testAccountPhoto.isEmpty
                      ? Text(
                        testAccountName.isNotEmpty
                            ? testAccountName[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      )
                      : null,
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Account: $testAccountName',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Chatting with: $otherUserName',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              lastMessage.length > 50
                  ? '${lastMessage.substring(0, 50)}...'
                  : lastMessage,
              style: TextStyle(color: Colors.grey[300], fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[500], size: 12),
                const SizedBox(width: 4),
                Text(
                  lastMessageTime,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TEST ACCOUNT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _openChat(chatHead),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Super Admin - Test Account Chats',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadChatHeads,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                ),
              )
              : _errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[400], size: 64),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadChatHeads,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
              : _chatHeads.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No test account chats found',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Test accounts will appear here when they start chatting',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadChatHeads,
                color: const Color(0xFF8B5CF6),
                child: ListView.builder(
                  itemCount: _chatHeads.length,
                  itemBuilder: (context, index) {
                    return _buildChatHeadItem(_chatHeads[index]);
                  },
                ),
              ),
    );
  }
}
