import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:get/get.dart';

import '../../controllers/MainController.dart';
import '../../models/UserModel.dart';
import '../../models/RespondModel.dart';
import '../../utils/dating_theme.dart';
import '../../utils/Utilities.dart';
import '../../utils/AppConfig.dart';
import '../shop/screens/shop/chat/chat_screen.dart';

/// Dating-specific conversation list screen
/// Shows conversations with matched users only
class DatingChatListScreen extends StatefulWidget {
  const DatingChatListScreen({Key? key}) : super(key: key);

  @override
  _DatingChatListScreenState createState() => _DatingChatListScreenState();
}

class _DatingChatListScreenState extends State<DatingChatListScreen>
    with TickerProviderStateMixin {
  List<DatingChatHead> conversations = [];
  bool isLoading = true;
  bool showSearch = false;
  String searchQuery = '';
  Timer? refreshTimer;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadConversations();
    _startPeriodicRefresh();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadConversations(isRefresh: true);
      }
    });
  }

  Future<void> _loadConversations({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final response = await Utils.http_get('chat-heads', {});
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final chatData = resp.data['chat_heads'] as List? ?? [];
        final newConversations =
            chatData.map((data) => DatingChatHead.fromJson(data)).toList();

        setState(() {
          conversations = newConversations;
          isLoading = false;
        });

        if (!isRefresh) {
          _animationController.forward();
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!isRefresh) {
        Utils.toast('Failed to load conversations');
      }
    }
  }

  List<DatingChatHead> get filteredConversations {
    if (!showSearch || searchQuery.isEmpty) return conversations;

    final query = searchQuery.toLowerCase();
    return conversations.where((conv) {
      return conv.otherUser.name.toLowerCase().contains(query) ||
          conv.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (showSearch) _buildSearchBar(),
          Expanded(
            child: isLoading ? _buildLoadingState() : _buildConversationsList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: DatingTheme.primaryPink,
      elevation: 0,
      title: Text(
        showSearch ? 'Search Conversations' : 'Messages',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            showSearch ? FeatherIcons.x : FeatherIcons.search,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              showSearch = !showSearch;
              if (!showSearch) searchQuery = '';
            });
          },
        ),
        IconButton(
          icon: const Icon(FeatherIcons.refreshCw, color: Colors.white),
          onPressed: () => _loadConversations(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: DatingTheme.primaryPink.withValues(alpha: 0.1),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          prefixIcon: const Icon(FeatherIcons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) => _buildShimmerTile(),
    );
  }

  Widget _buildShimmerTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 25, backgroundColor: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 150, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    final convs = filteredConversations;

    if (convs.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () => _loadConversations(),
        child: ListView.builder(
          itemCount: convs.length,
          itemBuilder: (context, index) {
            return _buildConversationTile(convs[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FeatherIcons.messageCircle, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with your matches!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(DatingChatHead conversation, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openChat(conversation),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          conversation.otherUser.avatar.isNotEmpty
                              ? CachedNetworkImageProvider(
                                '${AppConfig.BASE_URL}/storage/${conversation.otherUser.avatar}',
                              )
                              : null,
                      backgroundColor: DatingTheme.primaryPink.withValues(
                        alpha: 0.2,
                      ),
                      child:
                          conversation.otherUser.avatar.isEmpty
                              ? Text(
                                conversation.otherUser.name.isNotEmpty
                                    ? conversation.otherUser.name[0]
                                        .toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: DatingTheme.primaryPink,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              : null,
                    ),
                    if (conversation.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conversation.otherUser.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(conversation.lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    conversation.unreadCount > 0
                                        ? DatingTheme.primaryText
                                        : Colors.grey[600],
                                fontWeight:
                                    conversation.unreadCount > 0
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: DatingTheme.primaryPink,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                conversation.unreadCount > 99
                                    ? '99+'
                                    : conversation.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _openChat(DatingChatHead conversation) {
    final MainController _mainC = Get.find<MainController>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen({
              'receiver_id': conversation.otherUser.id.toString(),
              'sender_id': _mainC.userModel.id.toString(),
              'task': 'DATING_CHAT',
              'matchedUser': conversation.otherUser,
              'isNewMatch': false,
              'isDatingMode': true,
            }),
      ),
    );
  }
}

/// Model for dating conversation list item
class DatingChatHead {
  final UserModel otherUser;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  DatingChatHead({
    required this.otherUser,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });

  factory DatingChatHead.fromJson(Map<String, dynamic> json) {
    return DatingChatHead(
      otherUser: UserModel.fromJson(json['other_user'] ?? {}),
      lastMessage: json['last_message'] ?? '',
      lastMessageTime:
          DateTime.tryParse(json['last_message_time'] ?? '') ?? DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
    );
  }
}

/// Simple chat message model for conversation previews
class ChatMessage {
  final String content;
  final DateTime timestamp;
  final bool isFromMe;
  final bool isRead;

  ChatMessage({
    required this.content,
    required this.timestamp,
    required this.isFromMe,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isFromMe: json['is_from_me'] ?? false,
      isRead: json['is_read'] ?? false,
    );
  }
}
