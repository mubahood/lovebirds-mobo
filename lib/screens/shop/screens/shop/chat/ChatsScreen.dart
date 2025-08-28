import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../controllers/MainController.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/ChatHead.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final MainController mainController = Get.find<MainController>();
  List<ChatHead> _allHeads = [];

  // A computed property to filter heads based on the search query.
  List<ChatHead> get _filteredHeads {
    if (!_showSearch || _searchQuery.isEmpty) return _allHeads;
    final q = _searchQuery.toLowerCase();
    return _allHeads.where((h) {
      // It's good practice to have a method in your ChatHead model
      // to get the correct name of the other user.
      final otherUserName =
          (mainController.loggedInUser.id.toString() == h.customer_id
                  ? h.product_owner_name
                  : h.customer_name)
              .toLowerCase();
      return otherUserName.contains(q) ||
          h.last_message_body.toLowerCase().contains(q);
    }).toList();
  }

  bool _loading = true;
  bool _showSearch = false;
  String _searchQuery = '';
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadHeads(); // Initial load
    _startPolling(); // Start periodic updates
  }

  @override
  void dispose() {
    _pollingTimer
        ?.cancel(); // Important: cancel the timer to prevent memory leaks
    super.dispose();
  }

  // Starts a recurring timer to refresh the chat heads list.
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted) {
        _loadHeads(isPolling: true);
      } else {
        timer.cancel();
      }
    });
  }

  // Fetches chat heads from the source.
  Future<void> _loadHeads({bool isPolling = false}) async {
    // Only show the full loading shimmer on the initial load.
    if (!isPolling && _allHeads.isEmpty) {
      setState(() => _loading = true);
    }

    await mainController.getLoggedInUser();
    final heads = await ChatHead.get_items(mainController.loggedInUser);

    if (mounted) {
      setState(() {
        _allHeads = heads;
        _loading = false;
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background, // Use theme color
      appBar: AppBar(
        elevation: 0,
        // Modern flat look
        backgroundColor: CustomTheme.card,
        // A slightly different shade for depth
        foregroundColor: Colors.white,
        // Color for back arrow and icons
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              _showSearch
                  ? _buildSearchField()
                  : Align(
                    alignment: Alignment.centerLeft,
                    child: FxText.titleLarge(
                      "Messages",
                      fontWeight: 700,
                      color: CustomTheme.accent,
                      textAlign: TextAlign.start,
                    ),
                  ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: CustomTheme.accent,
            ),
            onPressed: _toggleSearch,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return _buildShimmerList();
    }
    if (_filteredHeads.isEmpty) {
      return _buildEmptyState();
    }
    return RefreshIndicator(
      color: CustomTheme.primary,
      backgroundColor: CustomTheme.card,
      onRefresh: () => _loadHeads(),
      child: ListView.separated(
        separatorBuilder:
            (context, index) => Divider(
              color: Colors.grey.withValues(alpha: 0.1),
              height: 1,
              indent: 88, // Aligns separator with text, not avatar
            ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredHeads.length,
        itemBuilder: (ctx, i) => _buildAnimatedItem(_filteredHeads[i], i),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 40,
      child: TextField(
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        cursorColor: CustomTheme.primary,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          hintText: "Search messages or people...",
          hintStyle: TextStyle(color: Colors.grey[500]),
          filled: true,
          fillColor: CustomTheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  // NEW: A beautiful shimmer loading state
  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder:
            (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const CircleAvatar(radius: 30, backgroundColor: Colors.black),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  // NEW: A more engaging empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FeatherIcons.messageSquare, color: Colors.grey[700], size: 72),
            const SizedBox(height: 24),
            FxText.titleMedium(
              _showSearch ? "No results found" : "No Messages Yet",
              color: Colors.white,
              fontWeight: 600,
            ),
            const SizedBox(height: 8),
            FxText.bodyMedium(
              _showSearch
                  ? "Try a different search term."
                  : "Start a conversation to see it here.",
              color: Colors.grey[500],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FxButton.outlined(
              onPressed: () => _loadHeads(),
              borderColor: CustomTheme.primary,
              splashColor: CustomTheme.primary.withValues(alpha: 0.2),
              borderRadiusAll: 12,
              child: FxText.bodyMedium(
                "Refresh",
                color: CustomTheme.primary,
                fontWeight: 600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(ChatHead head, int index) {
    // Staggered animation for list items
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder:
          (ctx, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, (1 - v) * 20),
              child: child,
            ),
          ),
      child: _buildChatTile(head),
    );
  }

  // NEW: The redesigned chat tile
  Widget _buildChatTile(ChatHead head) {
    // It's best practice to have a helper method in your ChatHead model
    // to determine who the "other party" is.
    final bool amICustomer =
        mainController.loggedInUser.id.toString() == head.customer_id;
    final otherUserName =
        amICustomer ? head.product_owner_name : head.customer_name;
    final otherUserPhoto =
        amICustomer ? head.product_owner_photo : head.customer_photo;
    final otherUserId = amICustomer ? head.product_owner_id : head.customer_id;

    final int unreadCount = head.myUnread(mainController.loggedInUser);
    final bool isUnread = unreadCount > 0;

    return InkWell(
      onTap: () {
        Get.to(
          () => ChatScreen({
            'chatHead': head,
            'receiver_id': otherUserId,
            'sender_id': mainController.loggedInUser.id.toString(),
          }),
        )?.then(
          (_) => _loadHeads(isPolling: true),
        ); // Refresh after closing chat
      },
      splashColor: CustomTheme.primary.withValues(alpha: 0.2),
      highlightColor: CustomTheme.card,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with Unread Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: Utils.getImageUrl(otherUserPhoto),
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                    placeholder:
                        (context, url) => Container(color: Colors.grey[800]),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: Icon(
                            FeatherIcons.user,
                            color: Colors.grey[600],
                          ),
                        ),
                  ),
                ),
                if (isUnread)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: CustomTheme.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CustomTheme.background,
                          width: 2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 22,
                        minHeight: 22,
                      ),
                      child: Center(
                        child: FxText.bodySmall(
                          '${unreadCount}',
                          color: Colors.black,
                          fontWeight: 800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Name and Message Snippet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FxText.bodyLarge(
                          otherUserName,
                          fontWeight: isUnread ? 800 : 700,
                          color: isUnread ? Colors.white : Colors.grey[300],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FxText.bodySmall(
                        Utils.timeAgo(head.last_message_time),
                        color:
                            isUnread
                                ? CustomTheme.accent.withValues(alpha: 0.8)
                                : Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FxText.bodyMedium(
                    head.last_message_body,
                    color: isUnread ? Colors.grey[400] : Colors.grey[500],
                    fontWeight: isUnread ? 700 : 400,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
