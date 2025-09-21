import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../../controllers/MainController.dart';
// Import moderation dialogs
import '../../../../../features/moderation/widgets/block_user_dialog.dart';
import '../../../../../features/moderation/widgets/report_content_dialog.dart';
import '../../../../../models/RespondModel.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/SubscriptionManager.dart';
import '../../../../../utils/Utilities.dart';
import '../../../../../utils/app_theme.dart';
import '../../../../../widgets/fullscreen_video_player.dart';
import '../../../../../widgets/simple_video_player.dart';
import '../../../models/ChatHead.dart';
import '../../../models/ChatMessage.dart';
import '../../../models/Product.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> params;

  const ChatScreen(this.params, {Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  ChatHead chatHead = ChatHead();
  late Product product;
  late ThemeData theme;
  late CustomTheme ct;
  late ScrollController _scrollC;
  late TextEditingController _txtC;
  late FocusNode _focusNode;

  final MainController _mainC = Get.find<MainController>();
  final List<String> _menuChoices = [
    'Delete chat',
    'Report User',
    'Block User',
  ];
  final List<Timer> _timers = [];

  List<ChatMessage> _msgs = [];
  bool _inputEmpty = true;
  bool _disposed = false, _listenerBusy = false;
  late Future<void> _initFuture;
  late AnimationController _fadeC;

  // Enhanced multimedia support
  final ImagePicker _imagePicker = ImagePicker();
  AudioRecorder? _audioRecorder;
  AudioPlayer? _audioPlayer;
  String? _recordingPath;
  bool _isRecording = false;
  Map<String, VideoPlayerController> _videoControllers = {};
  bool _showMultimediaOptions = false;

  // Audio recording UI state
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  double _recordingAmplitude = 0.0;
  late AnimationController _recordingAnimationC;

  @override
  void initState() {
    super.initState();

    theme = AppTheme.theme;
    ct = AppTheme.customTheme;
    _scrollC = ScrollController();
    if (widget.params.containsKey('start_message')) {
      start_message = widget.params['start_message'].toString().trim();
    }

    _txtC = TextEditingController(text: start_message)
      ..addListener(() => setState(() => _inputEmpty = _txtC.text.isEmpty));
    _txtC.text = start_message;
    _txtC.selection = TextSelection.fromPosition(
      TextPosition(offset: _txtC.text.length),
    );
    _focusNode = FocusNode();

    _fadeC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.0,
    )..forward();

    // Initialize recording animation controller
    _recordingAnimationC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Initialize multimedia components
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();

    _initFuture = _initialize();
  }

  @override
  void dispose() {
    _disposed = true;
    _scrollC.dispose();
    _txtC.dispose();
    _focusNode.dispose();
    _fadeC.dispose();
    _recordingAnimationC.dispose();
    _recordingTimer?.cancel();
    for (var t in _timers) t.cancel();

    // Dispose multimedia components
    _audioRecorder?.dispose();
    _audioPlayer?.dispose();

    // Dispose video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();

    super.dispose();
  }

  List<String> accepted_tasks = ['START_CHAT'];

  String task = '';
  String receiver_id = '';
  String sender_id = '';
  String start_message = '';

  Future<void> _initialize() async {
    try {
      // Enhanced validation of required parameters
      if (!widget.params.containsKey('receiver_id') ||
          widget.params['receiver_id'] == null ||
          widget.params['receiver_id'].toString().trim().isEmpty) {
        _showErrorAndExit('Receiver ID not found or invalid.');
        return;
      }

      // Validate and extract receiver_id
      receiver_id = widget.params['receiver_id'].toString().trim();
      if (receiver_id.isEmpty || receiver_id == 'null') {
        _showErrorAndExit('Receiver ID is empty or invalid.');
        return;
      }

      // Validate chatHead parameter if provided
      if (widget.params.containsKey('chatHead') &&
          widget.params['chatHead'] != null) {
        try {
          chatHead = widget.params['chatHead'] as ChatHead;
          if (chatHead.id > 0) {
            await _markAsRead();
          }
        } catch (e) {
          print('Warning: Invalid chatHead parameter: $e');
          chatHead = ChatHead(); // Reset to new instance
        }
      }

      // Ensure user is logged in with enhanced validation
      if (_mainC.userModel.id < 1) {
        await _mainC.getLoggedInUser();
        if (_mainC.userModel.id < 1) {
          _showErrorAndExit('Please log in to continue chatting.');
          return;
        }
      }

      sender_id = _mainC.userModel.id.toString().trim();
      if (sender_id.isEmpty || sender_id == 'null') {
        _showErrorAndExit('Unable to identify logged in user.');
        return;
      }

      // Prevent self-messaging
      if (sender_id == receiver_id) {
        _showErrorAndExit('You cannot start a conversation with yourself.');
        return;
      }

      // Enhanced chat head resolution with proper error handling
      await _resolveChatHead();

      // Load existing messages
      await _loadMessages();

      // Start polling and mark as read
      await _markAsRead();
      _pollLoop();

      setState(() {});

      // Auto-scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Critical error in chat initialization: $e');
      _showErrorAndExit('Failed to initialize chat. Please try again.');
    }
  }

  void _showErrorAndExit(String message) {
    Utils.toast(message);
    if (mounted && Navigator.canPop(context)) {
      Get.back();
    }
  }

  Future<void> _resolveChatHead() async {
    String product_id = '';

    // Handle product-specific chat
    if (widget.params.containsKey('task') &&
        widget.params['task'] == 'PRODUCT_CHAT') {
      if (!widget.params.containsKey('product') ||
          widget.params['product'] == null) {
        throw Exception('Product information required for product chat');
      }

      try {
        product = widget.params['product'] as Product;
        product_id = product.id.toString();
      } catch (e) {
        throw Exception('Invalid product information provided');
      }

      // Try to find existing product chat
      List<ChatHead> temp_chats = await ChatHead.get_items(
        _mainC.userModel,
        where:
            'product_owner_id = $receiver_id AND customer_id = $sender_id AND product_id = $product_id',
      );

      if (temp_chats.isEmpty) {
        temp_chats = await ChatHead.get_items(
          _mainC.userModel,
          where:
              'product_owner_id = $sender_id AND customer_id = $receiver_id AND product_id = $product_id',
        );
      }

      if (temp_chats.isNotEmpty) {
        chatHead = temp_chats[0];
        return;
      }
    }

    // If no existing chat head found and not product chat, look for general chat
    if (chatHead.id < 1) {
      List<ChatHead> temp_chats = await ChatHead.get_items(
        _mainC.userModel,
        where: 'product_owner_id = $receiver_id AND customer_id = $sender_id',
      );

      if (temp_chats.isEmpty) {
        temp_chats = await ChatHead.get_items(
          _mainC.userModel,
          where: 'product_owner_id = $sender_id AND customer_id = $receiver_id',
        );
      }

      if (temp_chats.isNotEmpty) {
        chatHead = temp_chats[0];
        return;
      }
    }

    // Create new chat head if none exists
    if (chatHead.id < 1) {
      await _createNewChatHead(product_id);
    }
  }

  Future<void> _createNewChatHead(String product_id) async {
    try {
      Utils.showLoader(false);

      final response = await Utils.http_post('chat-start', {
        'sender_id': sender_id,
        'receiver_id': receiver_id,
        'product_id': product_id,
      });

      final resp = RespondModel(response);

      if (resp.code != 1) {
        throw Exception(
          resp.message.isNotEmpty ? resp.message : 'Failed to start chat',
        );
      }

      if (resp.data == null) {
        throw Exception('Invalid response data from server');
      }

      final tempHead = ChatHead.fromJson(resp.data);
      if (tempHead.id < 1) {
        throw Exception('Failed to create chat head');
      }

      chatHead = tempHead;
    } catch (e) {
      throw Exception('Failed to start chat: $e');
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> _loadMessages() async {
    try {
      if (chatHead.id < 1) {
        _msgs = [];
        return;
      }

      _msgs = await ChatMessage.get_items(
        _mainC.userModel,
        where: 'chat_head_id = ${chatHead.id}',
      );

      // Sort messages by ID to ensure proper order
      _msgs.sort((a, b) => a.id.compareTo(b.id));
    } catch (e) {
      print('Error loading messages: $e');
      _msgs = [];
    }
  }

  Future<void> _startChat() async {
    Utils.toast2('Please wait…', is_long: true);
    if (!await Utils.is_connected()) {
      Utils.toast2('No internet connection');
      return;
    }
    // Chat starting logic can be enhanced later if needed
  }

  Future<void> _markAsRead() async {
    if (chatHead.id < 1 || _disposed) {
      return;
    }

    try {
      final response = await Utils.http_post('chat-mark-as-read', {
        'receiver_id': chatHead.customer_id,
        'chat_head_id': chatHead.id,
      });

      final r = RespondModel(response);

      if (r.code == 1) {
        await chatHead.save();
        // Update local chat head data
        await ChatHead.getLocalData();
      } else {
        print('Failed to mark messages as read: ${r.message}');
      }
    } catch (e) {
      print('Error marking messages as read: $e');
      // Don't show toast for this error as it's not critical for user experience
    }
  }

  void _pollLoop() {
    if (_disposed || _listenerBusy || chatHead.id < 1) return;

    _listenerBusy = true;

    ChatMessage.getOnlineItems(
          _mainC.userModel,
          params: {'chat_head_id': chatHead.id, 'doDeleteAll': true},
        )
        .then((_) async {
          if (_disposed) {
            _listenerBusy = false;
            return;
          }

          try {
            final allMessages = await ChatMessage.getLocalData(
              _mainC.userModel,
              where: 'chat_head_id = ${chatHead.id}',
            );

            allMessages.sort((a, b) => a.id.compareTo(b.id));

            // Only update if we have new messages and widget is still mounted
            if (mounted && allMessages.length > _msgs.length) {
              setState(() {
                _msgs = allMessages;
              });

              // Auto-scroll to bottom for new messages
              _scrollToBottom();

              // Mark new messages as read
              await _markAsRead();
            }
          } catch (e) {
            print('Error during polling: $e');
          }

          _listenerBusy = false;

          // Continue polling if not disposed
          if (!_disposed && mounted) {
            Future.delayed(const Duration(seconds: 5), () {
              if (!_disposed && mounted) {
                _pollLoop();
              }
            });
          }
        })
        .catchError((error) {
          print('Polling error: $error');
          _listenerBusy = false;

          // Retry polling after a longer delay on error
          if (!_disposed && mounted) {
            Future.delayed(const Duration(seconds: 10), () {
              if (!_disposed && mounted) {
                _pollLoop();
              }
            });
          }
        });
  }

  Future<void> _onRefresh() => _initialize();

  Future<void> _sendMessage() async {
    final text = _txtC.text.trim();
    if (text.isEmpty) {
      Utils.toast("Cannot send empty message");
      return;
    }

    if (chatHead.id < 1) {
      Utils.toast("Chat not properly initialized. Please try again.");
      return;
    }

    // STRICT SUBSCRIPTION ENFORCEMENT: Check if user has reached daily message limit
    final hasSubscription = await SubscriptionManager.hasActiveSubscription();
    if (!hasSubscription) {
      // Check message limit from backend
      try {
        final response = await Utils.http_get('swipe-stats', {});
        final resp = RespondModel(response);

        if (resp.code == 1) {
          final messagesRemaining =
              int.tryParse(
                resp.data?['daily_messages_remaining']?.toString() ?? '0',
              ) ??
              0;
          if (messagesRemaining <= 0) {
            Utils.toast(
              "Daily message limit reached (0/10). Upgrade to premium for unlimited messaging!",
              color: Colors.red,
            );
            return; // Prevent sending message
          }
        }
      } catch (e) {
        print('Error checking message limits: $e');
        // On error, allow the message but it will be caught by backend
      }
    }

    // Check if user is blocked before sending
    final me = _mainC.userModel.id.toString();
    final other =
        me == chatHead.product_owner_id
            ? chatHead.customer_id
            : chatHead.product_owner_id;

    // Check if the receiver is blocked
    if (await _isUserBlocked(other)) {
      Utils.toast(
        "You cannot send messages to blocked users. Unblock them first to continue chatting.",
      );
      return;
    }

    // Create the message object with proper validation
    final ChatMessage msg =
        ChatMessage()
          ..chat_head_id = chatHead.id.toString()
          ..sender_id = me
          ..receiver_id = other
          ..body = text
          ..type = 'text'
          ..status = 'sending'
          ..created_at = DateTime.now().toIso8601String()
          ..updated_at = DateTime.now().toIso8601String()
          ..isMyMessage = true;

    // Clear input and update UI immediately
    _txtC.clear();
    setState(() {
      _inputEmpty = true;
      _showMultimediaOptions = false;
      _msgs.add(msg);
    });

    _scrollToBottom();

    // Keep keyboard focus for smooth messaging
    if (mounted) {
      _focusNode.requestFocus();
    }

    // Save message locally
    try {
      await msg.save();
    } catch (e) {
      print('Error saving message locally: $e');
    }

    // Send to server
    await _sendMessageToServer(msg);
  }

  Future<void> _sendMessageToServer(ChatMessage msg) async {
    try {
      final response = await Utils.http_post('chat-send', {
        'receiver_id': msg.receiver_id,
        'content': msg.body,
        'message_type': msg.type,
        'chat_head_id': chatHead.id,
      });

      final resp = RespondModel(response);

      if (resp.code == 1) {
        // Message sent successfully
        msg.status = 'sent';
        msg.id = Utils.int_parse(resp.data?['message_id'] ?? 0);

        // Update chatHead with latest message info
        if (resp.data != null && resp.data['chat_head'] != null) {
          final updatedChatHead = ChatHead.fromJson(resp.data['chat_head']);
          if (updatedChatHead.id == chatHead.id) {
            chatHead = updatedChatHead;
          }
        }

        await msg.save();
        await chatHead.save();

        // Refresh the message list to ensure consistency
        if (mounted) {
          setState(() {});
        }
      } else {
        // Handle send failure
        msg.status = 'failed';
        await msg.save();

        if (mounted) {
          Utils.toast('Failed to send message: ${resp.message}');
          setState(() {});
        }
      }
    } catch (e) {
      // Handle network or other errors
      msg.status = 'failed';
      await msg.save();

      if (mounted) {
        Utils.toast('Error sending message. Please check your connection.');
        setState(() {});
      }

      print('Error sending message: $e');
    }
  }

  // Enhanced multimedia message sending with comprehensive error handling
  Future<void> _sendMultimediaMessage({
    required String messageType,
    required String content,
    String? photoUrl,
    String? audioUrl,
    String? videoUrl,
    String? latitude,
    String? longitude,
    String? previewFileName,
  }) async {
    if (chatHead.id < 1) {
      Utils.toast("Chat not properly initialized. Please try again.");
      return;
    }

    final me = _mainC.userModel.id.toString();
    final other =
        me == chatHead.product_owner_id
            ? chatHead.customer_id
            : chatHead.product_owner_id;

    // Check if user is blocked before sending multimedia
    if (await _isUserBlocked(other)) {
      Utils.toast(
        "You cannot send media to blocked users. Unblock them first to continue chatting.",
      );
      return;
    }

    // Create message object with proper validation
    final ChatMessage msg =
        ChatMessage()
          ..chat_head_id = chatHead.id.toString()
          ..sender_id = me
          ..receiver_id = other
          ..body = content
          ..type = messageType
          ..photo = photoUrl ?? ''
          ..audio = audioUrl ?? ''
          ..longitude = longitude ?? ''
          ..latitude = latitude ?? ''
          ..status = 'sending'
          ..created_at = DateTime.now().toIso8601String()
          ..updated_at = DateTime.now().toIso8601String()
          ..isMyMessage = true;

    // Update UI immediately
    setState(() {
      _msgs.add(msg);
      _showMultimediaOptions = false;
    });

    _scrollToBottom();

    // Save locally
    try {
      await msg.save();
    } catch (e) {
      print('Error saving multimedia message locally: $e');
    }

    // Send to server
    await _sendMultimediaToServer(msg, previewFileName);
  }

  Future<void> _sendMultimediaToServer(
    ChatMessage msg,
    String? previewFileName,
  ) async {
    try {
      Map<String, dynamic> requestData = {
        'receiver_id': msg.receiver_id,
        'content': msg.body,
        'message_type': msg.type,
        'chat_head_id': chatHead.id,
      };

      // Add multimedia specific fields
      if (previewFileName != null && previewFileName.isNotEmpty) {
        requestData['preview_file_name'] = previewFileName;
      } else {
        // Legacy support for direct file URLs
        if (msg.photo.isNotEmpty) requestData['photo'] = msg.photo;
        if (msg.audio.isNotEmpty) requestData['audio'] = msg.audio;
        if (msg.longitude.isNotEmpty) requestData['longitude'] = msg.longitude;
        if (msg.latitude.isNotEmpty) requestData['latitude'] = msg.latitude;
      }

      final response = await Utils.http_post('chat-send', requestData);
      final resp = RespondModel(response);

      if (resp.code == 1) {
        // Success
        msg.status = 'sent';
        msg.id = Utils.int_parse(resp.data?['message_id'] ?? 0);

        // Update multimedia URLs from server response if provided
        if (resp.data != null) {
          final responseData = resp.data;
          if (responseData['photo'] != null) msg.photo = responseData['photo'];
          if (responseData['audio'] != null) msg.audio = responseData['audio'];
          if (responseData['video'] != null) msg.video = responseData['video'];
        }

        await msg.save();

        if (mounted) {
          setState(() {});
        }
      } else {
        // Handle failure
        msg.status = 'failed';
        await msg.save();

        if (mounted) {
          Utils.toast('Failed to send ${msg.type}: ${resp.message}');
          setState(() {});
        }
      }
    } catch (e) {
      // Handle errors
      msg.status = 'failed';
      await msg.save();

      if (mounted) {
        Utils.toast('Error sending ${msg.type}. Please check your connection.');
        setState(() {});
      }

      print('Error sending multimedia message: $e');
    }
  }

  void _scrollToBottom() {
    if (!mounted || _disposed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _disposed || !_scrollC.hasClients) return;

      try {
        if (_scrollC.position.maxScrollExtent > 0) {
          _scrollC.animateTo(
            _scrollC.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        print('Error scrolling to bottom: $e');
        // Fallback: try without animation
        try {
          if (_scrollC.hasClients) {
            _scrollC.jumpTo(_scrollC.position.maxScrollExtent);
          }
        } catch (e2) {
          print('Error with fallback scroll: $e2');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            // Enhanced gradient background
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  const Color(0xFF0A0A0A),
                  const Color(0xFF1A1A1A),
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),

                  Expanded(
                    child: FutureBuilder(
                      future: _initFuture,
                      builder: (_, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFF6B6B),
                                        const Color(0xFFFF5252),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFFF5252,
                                        ).withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FxText.bodyMedium(
                                  'Loading conversation...',
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: const Color(0xFFFF6B6B),
                          backgroundColor: const Color(0xFF2C2C2E),
                          child: ListView.separated(
                            controller: _scrollC,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            itemCount: _msgs.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder:
                                (_, i) => AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: 300 + (i * 50),
                                  ),
                                  curve: Curves.easeOutBack,
                                  child: ScaleTransition(
                                    scale: _fadeC,
                                    child: _buildBubble(_msgs[i]),
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildInputBar(),
                ],
              ),
            ),
          ),

          // Audio Recording Overlay
          if (_isRecording) _buildRecordingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black.withValues(alpha: 0.95)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF2C2C2E), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Enhanced back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                FeatherIcons.chevronLeft,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Enhanced user avatar with border and online indicator
          GestureDetector(
            onTap: () {
              _markAsRead();
            },
            child: Stack(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF6B6B),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: Utils.img(chatHead.customer_photo),
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: const Color(0xFF2C2C2E),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white54,
                              size: 24,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF2C2C2E),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white54,
                              size: 24,
                            ),
                          ),
                    ),
                  ),
                ),
                // Online indicator
                if (chatHead.customer_last_seen.toLowerCase() == 'online')
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: 0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Enhanced user info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.titleMedium(
                  chatHead.customer_name,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: 600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            chatHead.customer_last_seen.toLowerCase() ==
                                    'online'
                                ? const Color(0xFF4CAF50)
                                : Colors.grey[500],
                        shape: BoxShape.circle,
                        boxShadow:
                            chatHead.customer_last_seen.toLowerCase() ==
                                    'online'
                                ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                                : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    FxText.bodySmall(
                      chatHead.customer_last_seen.toLowerCase() == 'online'
                          ? 'Active now'
                          : chatHead.customer_last_seen,
                      color:
                          chatHead.customer_last_seen.toLowerCase() == 'online'
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[500],
                      fontSize: 13,
                      fontWeight: 500,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Enhanced menu button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(
                FeatherIcons.moreVertical,
                color: Colors.white,
                size: 20,
              ),
              color: const Color(0xFF2C2C2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              onSelected: (_data) {
                if (_data.toString() == 'Delete chat') {
                  Get.defaultDialog(
                    title: 'Delete chat',
                    titleStyle: const TextStyle(color: Colors.white),
                    middleText: 'Are you sure you want to delete this chat?',
                    middleTextStyle: const TextStyle(color: Colors.white70),
                    backgroundColor: const Color(0xFF2C2C2E),
                    textCancel: 'Cancel',
                    textConfirm: 'Delete',
                    confirmTextColor: Colors.white,
                    cancelTextColor: Colors.white70,
                    buttonColor: const Color(0xFFFF6B6B),
                    onConfirm: () async {
                      Utils.showLoader(true);
                      try {
                        final resp = RespondModel(
                          await Utils.http_post('chat-delete', {
                            'chat_head_id': chatHead.id,
                            'sender_id': sender_id,
                            'receiver_id': receiver_id,
                          }),
                        );
                        if (resp.code == 1) {
                          await chatHead.delete();
                          try {
                            await ChatMessage.deleteForHead(
                              where: 'chat_head_id = ${chatHead.id}',
                            );
                          } catch (e) {
                            Utils.toast('Failed to delete chat messages: $e');
                          }
                          Utils.toast(resp.message);
                          Get.back();
                          Get.back();
                        } else {
                          Utils.toast(resp.message);
                        }
                      } catch (e) {
                        Utils.toast('Failed to delete chat: $e');
                      } finally {
                        Utils.hideLoader();
                      }
                    },
                  );
                } else if (_data.toString() == 'Report User') {
                  _showReportDialog();
                } else if (_data.toString() == 'Block User') {
                  _showBlockDialog();
                }
              },
              itemBuilder:
                  (_) =>
                      _menuChoices
                          .map(
                            (c) => PopupMenuItem(
                              value: c,
                              child: FxText.bodyMedium(
                                c,
                                color:
                                    c == 'Delete chat'
                                        ? const Color(0xFFFF6B6B)
                                        : Colors.white,
                              ),
                            ),
                          )
                          .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage m) {
    final me = m.isMyMessage;
    final align = me ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(me ? 20 : 6),
      bottomRight: Radius.circular(me ? 6 : 20),
    );

    // Enhanced gradient colors for messages
    final gradient =
        me
            ? LinearGradient(
              colors: [
                const Color(0xFFFF6B6B), // Soft coral red
                const Color(0xFFFF5252), // Vibrant red
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
            : LinearGradient(
              colors: [
                const Color(0xFF2C2C2E), // Dark charcoal
                const Color(0xFF1C1C1E), // Deeper dark
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

    final shadowColor =
        me
            ? const Color(0xFFFF5252).withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.2);

    return Align(
      alignment: align,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        margin: EdgeInsets.only(
          left: me ? 40 : 8,
          right: me ? 8 : 40,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: _getMessagePadding(m),
            horizontal: _getMessagePadding(m) + 2,
          ),
          child: Column(
            crossAxisAlignment:
                me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              _buildMessageContent(m, me),
              const SizedBox(height: 4),
              FxText.bodySmall(
                Utils.timeAgo(m.updated_at),
                color:
                    me ? Colors.white.withValues(alpha: 0.8) : Colors.grey[400],
                fontSize: 11,
                fontWeight: 400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getMessagePadding(ChatMessage message) {
    // Reduced padding for media messages, normal for text
    switch (message.type.toLowerCase()) {
      case 'photo':
      case 'image':
      case 'video':
        return 8.0; // Reduced from default
      case 'audio':
      case 'location':
        return 10.0;
      default:
        return 12.0; // Text messages get normal padding
    }
  }

  Widget _buildMessageContent(ChatMessage message, bool isMe) {
    switch (message.type.toLowerCase()) {
      case 'photo':
      case 'image':
        return _buildImageMessage(message, isMe);
      case 'video':
        return _buildVideoMessage(message, isMe);
      case 'audio':
        return _buildAudioMessage(message, isMe);
      case 'location':
        return _buildLocationMessage(message, isMe);
      default:
        return FxText.bodyMedium(
          message.body,
          color: Colors.white,
          fontSize: 16,
          fontWeight: 400,
          height: 1.4, // Better line spacing
        );
    }
  }

  Widget _buildImageMessage(ChatMessage message, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showFullScreenImage(message.photo),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  message.photo.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: Utils.img(message.photo),
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1C1C1E),
                                    const Color(0xFF2C2C2E),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFF6B6B),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1C1C1E),
                                    const Color(0xFF2C2C2E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.white54,
                                size: 32,
                              ),
                            ),
                      )
                      : Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1C1C1E),
                              const Color(0xFF2C2C2E),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Colors.white54,
                          size: 32,
                        ),
                      ),
            ),
          ),
        ),
        if (message.body.isNotEmpty && message.body != 'Image')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FxText.bodyMedium(
              message.body,
              color: Colors.white,
              fontSize: 15,
              fontWeight: 400,
              height: 1.3,
            ),
          ),
      ],
    );
  }

  Widget _buildVideoMessage(ChatMessage message, bool isMe) {
    // Check for emulator

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use our custom video player
        SimpleVideoPlayer(
          videoUrl: Utils.img(message.video),
          width: 220,
          height: 160,
          autoPlay: false,
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Open full-screen video player
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => FullScreenVideoPlayer(
                      videoUrl: Utils.img(message.video),
                      title:
                          message.body.isNotEmpty && message.body != 'Video'
                              ? message.body
                              : 'Video Message',
                    ),
              ),
            );
          },
        ),
        if (message.body.isNotEmpty && message.body != 'Video')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FxText.bodyMedium(
              message.body,
              color: Colors.white,
              fontSize: 15,
              fontWeight: 400,
              height: 1.3,
            ),
          ),
      ],
    );
  }

  Widget _buildAudioMessage(ChatMessage message, bool isMe) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFF6B6B), const Color(0xFFFF5252)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
              onPressed: () {
                String audioUrl = message.audio;
                // Enhanced debug info for audio troubleshooting
                /*  print('=== AUDIO DEBUG INFO ===');
                print('Audio URL: "$audioUrl"');
                print('Audio field from message: "${message.audio}"');
                print('Message body: "${message.body}"');
                print('Message type: "${message.type}"');*/

                // Check for file extension
                if (audioUrl.isNotEmpty) {
                  final fullUrl = Utils.img(audioUrl);

                  // Extract file extension for format info
                  final uri = Uri.tryParse(fullUrl);
                  if (uri != null) {
                    final fileName =
                        uri.pathSegments.isNotEmpty
                            ? uri.pathSegments.last
                            : '';
                    final extension =
                        fileName.contains('.')
                            ? fileName.split('.').last.toLowerCase()
                            : 'unknown';

                    // Check if it's the problematic m4a format
                    if (extension == 'm4a') {
                      Utils.toast(
                        'Audio format (.m4a) may not be compatible. Please use WAV or MP3.',
                      );
                    }
                  }

                  _playAudio(fullUrl);
                } else {
                  // Try alternative audio field names that might be used
                  if (message.body.contains('audio') ||
                      message.body.contains('voice')) {
                    Utils.toast('Audio file found but URL is empty');
                  } else {
                    Utils.toast('Audio not available');
                  }
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.mic, color: Color(0xFFFF6B6B), size: 16),
                    const SizedBox(width: 6),
                    FxText.bodyMedium(
                      'Voice message',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: 500,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Audio waveform indicator (simulated)
                Row(
                  children: List.generate(
                    20,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 2),
                      width: 2,
                      height: (index % 4 + 1) * 3.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FxText.bodySmall('0:15', color: Colors.grey[400], fontSize: 12),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(ChatMessage message, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openLocationInMaps(message.latitude, message.longitude),
          child: Container(
            constraints: const BoxConstraints(minWidth: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B6B),
                            const Color(0xFFFF5252),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF5252,
                            ).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FxText.bodyMedium(
                            'Location shared',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: 600,
                          ),
                          const SizedBox(height: 2),
                          FxText.bodySmall(
                            'Tap to view on map',
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
                if (message.latitude.isNotEmpty && message.longitude.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: Color(0xFFFF6B6B),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: FxText.bodySmall(
                              'Lat: ${double.parse(message.latitude).toStringAsFixed(4)}, '
                              'Lng: ${double.parse(message.longitude).toStringAsFixed(4)}',
                              color: Colors.grey[300],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withValues(alpha: 0.95), Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(color: const Color(0xFF2C2C2E), width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Enhanced multimedia options panel
          if (_showMultimediaOptions)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _multimediaButton(
                    icon: Icons.photo_camera,
                    label: 'Camera',
                    color: const Color(0xFF4CAF50),
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _multimediaButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: const Color(0xFF2196F3),
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  _multimediaButton(
                    icon: Icons.videocam,
                    label: 'Video',
                    color: const Color(0xFF9C27B0),
                    onTap: _pickVideo,
                  ),
                  /*_multimediaButton(
                    icon: Icons.description,
                    label: 'Document',
                    color: const Color(0xFFFF9800),
                    onTap: _pickDocument,
                  ),*/
                  _multimediaButton(
                    icon: Icons.mic,
                    label: 'Audio',
                    color:
                        _isRecording
                            ? const Color(0xFFF44336)
                            : const Color(0xFFFF6B6B),
                    onTap: _isRecording ? _stopRecording : _startRecording,
                  ),
                  _multimediaButton(
                    icon: Icons.location_on,
                    label: 'Location',
                    color: const Color(0xFFFF5722),
                    onTap: _shareLocation,
                  ),
                ],
              ),
            ),
          // Enhanced input area
          Row(
            children: [
              // Attach button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        _showMultimediaOptions
                            ? [const Color(0xFFFF6B6B), const Color(0xFFFF5252)]
                            : [
                              const Color(0xFF2C2C2E),
                              const Color(0xFF1C1C1E),
                            ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          _showMultimediaOptions
                              ? const Color(0xFFFF5252).withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _showMultimediaOptions = !_showMultimediaOptions;
                    });
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _showMultimediaOptions ? Icons.close : Icons.add,
                      key: ValueKey(_showMultimediaOptions),
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Enhanced text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2C2C2E),
                        const Color(0xFF1C1C1E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color:
                          _focusNode.hasFocus
                              ? const Color(0xFFFF6B6B).withValues(alpha: 0.5)
                              : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _txtC,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 5,
                    minLines: 1,
                    keyboardAppearance: Brightness.dark,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    enableSuggestions: true,
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF6B6B),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Enhanced send/record button
              _isRecording
                  ? GestureDetector(
                    onTap: _stopRecording,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF44336),
                            const Color(0xFFD32F2F),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFF44336,
                            ).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                  : Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            _inputEmpty
                                ? [
                                  const Color(0xFF4A4A4A),
                                  const Color(0xFF3A3A3A),
                                ]
                                : [
                                  const Color(0xFFFF6B6B),
                                  const Color(0xFFFF5252),
                                ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              _inputEmpty
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : const Color(
                                    0xFFFF5252,
                                  ).withValues(alpha: 0.4),
                          blurRadius: _inputEmpty ? 4 : 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (_inputEmpty) {
                          Utils.toast('Please type a message');
                          return;
                        }
                        _sendMessage();
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  // Enhanced multimedia helper widget
  Widget _multimediaButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            FxText.bodySmall(
              label,
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: 500,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ======= MULTIMEDIA METHODS WITH PREVIEW SUPPORT =======

  // Image picker with preview
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        await _showMediaPreview(mediaType: 'photo', filePath: image.path);
      }
    } catch (e) {
      Utils.toast('Error picking image: $e');
    }
  }

  // Video picker with preview
  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        await _showMediaPreview(mediaType: 'video', filePath: video.path);
      }
    } catch (e) {
      Utils.toast('Error picking video: $e');
    }
  }

  // Show multimedia preview dialog
  Future<void> _showMediaPreview({
    required String mediaType,
    required String filePath,
  }) async {
    File file = File(filePath);
    if (!await file.exists()) {
      Utils.toast('File not found');
      return;
    }

    showDialog(
      context: context,
      builder:
          (BuildContext context) => _MediaPreviewDialog(
            mediaType: mediaType,
            filePath: filePath,
            onSend: (String? caption) async {
              Navigator.pop(context);
              await _uploadAndSendMedia(
                mediaType: mediaType,
                filePath: filePath,
                caption: caption,
              );
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
    );
  }

  // Upload media for preview then send message
  Future<void> _uploadAndSendMedia({
    required String mediaType,
    required String filePath,
    String? caption,
  }) async {
    try {
      // Show loading
      Utils.showLoading();

      // Upload file to server for preview
      final response = await Utils.http_post_with_files(
        'upload-media-preview',
        data: {'media_type': mediaType},
        files: {mediaType: filePath},
      );

      Utils.hideLoading();

      final resp = RespondModel(response);
      if (resp.code == 1 && resp.data != null) {
        final uploadData = resp.data as Map<String, dynamic>;
        final fileName = uploadData['file_name'] as String?;

        if (fileName != null) {
          // Send message with uploaded file
          await _sendMultimediaMessage(
            messageType: mediaType,
            content: caption ?? _getDefaultCaption(mediaType),
            previewFileName: fileName,
          );
        } else {
          Utils.toast('Failed to upload $mediaType file');
        }
      } else {
        Utils.toast('Upload failed: ${resp.message}');
      }
    } catch (e) {
      Utils.hideLoading();
      Utils.toast('Error uploading $mediaType: $e');
    }
  }

  String _getDefaultCaption(String mediaType) {
    switch (mediaType) {
      case 'photo':
        return 'Photo';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Voice message';
      case 'document':
        return 'Document';
      default:
        return 'Media file';
    }
  }

  // Audio recording methods
  Future<void> _startRecording() async {
    try {
      final permission = await Permission.microphone.request();
      if (permission.isDenied) {
        Utils.toast('Microphone permission required');
        return;
      }

      if (_audioRecorder != null && await _audioRecorder!.hasPermission()) {
        // Try WAV first for best compatibility, fallback to AAC if needed
        RecordConfig config;
        String fileExtension;

        try {
          // WAV format - universally compatible
          config = const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 44100,
          );
          fileExtension = 'wav';
        } catch (e) {
          // Fallback to AAC if WAV is not supported
          config = const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          );
          fileExtension = 'aac';
        }

        final path =
            '${Directory.systemTemp.path}/audio_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        await _audioRecorder!.start(config, path: path);

        // Start the live timer
        _startRecordingTimer();

        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _showMultimediaOptions = false; // Hide multimedia popup
          _recordingDuration = 0;
        });
      }
    } catch (e) {
      Utils.toast('Error starting recording: $e');
    }
  }

  // Start recording timer for live duration
  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording) {
        setState(() {
          _recordingDuration++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      if (_audioRecorder != null && _isRecording) {
        await _audioRecorder!.stop();
        _recordingTimer?.cancel();

        setState(() {
          _isRecording = false;
        });

        if (_recordingPath != null) {
          // Upload and send the audio file using the same preview system as other media
          await _uploadAndSendMedia(
            mediaType: 'audio',
            filePath: _recordingPath!,
            caption: 'Voice message',
          );
        }
      }
    } catch (e) {
      Utils.toast('Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      if (_audioRecorder != null && _isRecording) {
        await _audioRecorder!.stop();
        _recordingTimer?.cancel();

        // Delete the recorded file
        if (_recordingPath != null) {
          final file = File(_recordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        setState(() {
          _isRecording = false;
          _recordingPath = null;
          _recordingDuration = 0;
        });

        Utils.toast('Recording cancelled');
      }
    } catch (e) {
      Utils.toast('Error cancelling recording: $e');
    }
  }

  // Location sharing method
  Future<void> _shareLocation() async {
    try {
      final permission = await Permission.location.request();
      if (permission.isDenied) {
        Utils.toast('Location permission required');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _sendMultimediaMessage(
        messageType: 'location',
        content: 'Location shared',
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      );
    } catch (e) {
      Utils.toast('Error sharing location: $e');
    }
  }

  // Open location in Google Maps
  void _openLocationInMaps(String latitude, String longitude) {
    if (latitude.isEmpty || longitude.isEmpty) {
      Utils.toast('Location coordinates not available');
      return;
    }

    Get.defaultDialog(
      title: 'Open Location',
      titleStyle: const TextStyle(color: Colors.white),
      middleText: 'Open this location in Google Maps?',
      middleTextStyle: const TextStyle(color: Colors.white70),
      backgroundColor: const Color(0xFF2C2C2E),
      textCancel: 'Cancel',
      textConfirm: 'Open Maps',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.white70,
      buttonColor: const Color(0xFFFF6B6B),
      onConfirm: () async {
        Get.back(); // Close dialog first
        try {
          double lat = double.parse(latitude);
          double lng = double.parse(longitude);

          // Create Google Maps URL
          String googleMapsUrl = 'https://www.google.com/maps?q=$lat,$lng';

          // Try to launch the URL
          final Uri url = Uri.parse(googleMapsUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            Utils.toast('Could not open Google Maps');
          }
        } catch (e) {
          Utils.toast('Error opening location: $e');
        }
      },
    );
  }

  // Full screen image viewer
  void _showFullScreenImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      Utils.toast('Image not available');
      return;
    }

    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () => Utils.toast('Download feature coming soon'),
            ),
          ],
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: Utils.img(imageUrl),
              fit: BoxFit.contain,
              placeholder:
                  (context, url) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                  ),
              errorWidget:
                  (context, url, error) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.white54, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
      transition: Transition.fade,
    );
  }

  // Audio playback method with emulator compatibility
  Future<void> _playAudio(String audioUrl) async {
    if (_audioPlayer == null) {
      Utils.toast('Audio player not initialized');
      return;
    }

    try {
      // Check if running on emulator
      bool isEmulator = await _isRunningOnEmulator();

      if (isEmulator) {
        print('🔧 EMULATOR DETECTED: Applying compatibility mode');
        Utils.toast('Emulator detected - audio may have limitations');
      }

      if (audioUrl.startsWith('http')) {
        print('🎵 Playing from URL source: $audioUrl');

        // For emulators, try different approaches
        if (isEmulator) {
          await _playAudioWithEmulatorFix(audioUrl);
        } else {
          await _audioPlayer!.play(UrlSource(audioUrl));
        }

        Utils.toast('Audio playback started');
      } else {
        print('🎵 Playing from device file source');
        await _audioPlayer!.play(DeviceFileSource(audioUrl));
        Utils.toast('Audio playback started');
      }
    } catch (e) {
      print('❌ Audio playback error: $e');
      await _handleAudioError(e, audioUrl);
    }
  }

  // Check if running on emulator
  Future<bool> _isRunningOnEmulator() async {
    try {
      // Multiple ways to detect emulator
      return Platform.isAndroid &&
          (Platform.environment.containsKey('ANDROID_EMULATOR') ||
              await _checkEmulatorByBuild());
    } catch (e) {
      return false;
    }
  }

  // Check emulator by build properties
  Future<bool> _checkEmulatorByBuild() async {
    try {
      // Common emulator indicators
      const emulatorIndicators = [
        'sdk_gphone',
        'emulator',
        'simulator',
        'goldfish',
        'ranchu',
      ];

      // This is a simplified check - in a real app you might use
      // device_info_plus package for more accurate detection
      return emulatorIndicators.any(
        (indicator) => Platform.version.toLowerCase().contains(indicator),
      );
    } catch (e) {
      return false;
    }
  }

  // Special audio handling for emulators
  Future<void> _playAudioWithEmulatorFix(String audioUrl) async {
    try {
      // Method 1: Try with different player mode
      await _audioPlayer!.setPlayerMode(PlayerMode.mediaPlayer);
      await _audioPlayer!.play(UrlSource(audioUrl));
    } catch (e1) {
      try {
        // Method 2: Try with low latency mode
        await _audioPlayer!.setPlayerMode(PlayerMode.lowLatency);
        await _audioPlayer!.play(UrlSource(audioUrl));
      } catch (e2) {
        try {
          // Method 3: Try with explicit audio context
          await _audioPlayer!.setAudioContext(
            AudioContext(
              iOS: AudioContextIOS(
                category: AVAudioSessionCategory.playback,
                options: [AVAudioSessionOptions.defaultToSpeaker],
              ),
              android: AudioContextAndroid(
                isSpeakerphoneOn: true,
                stayAwake: true,
                contentType: AndroidContentType.music,
                usageType: AndroidUsageType.media,
                audioFocus: AndroidAudioFocus.gain,
              ),
            ),
          );
          await _audioPlayer!.play(UrlSource(audioUrl));
        } catch (e3) {
          // Final fallback: Just throw the original error
          throw e1;
        }
      }
    }
  }

  // Audio Recording Overlay UI
  Widget _buildRecordingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              FxText.titleLarge(
                'Recording Voice Message',
                color: Colors.white,
                fontSize: 20,
                fontWeight: 600,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Animated microphone icon with pulsing effect
              AnimatedBuilder(
                animation: _recordingAnimationC,
                builder: (context, child) {
                  return Container(
                    width: 120 + (_recordingAnimationC.value * 20),
                    height: 120 + (_recordingAnimationC.value * 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B6B),
                          const Color(0xFFFF5252),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withValues(
                            alpha: 0.3 + (_recordingAnimationC.value * 0.2),
                          ),
                          blurRadius: 20 + (_recordingAnimationC.value * 10),
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 48),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Live timer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recording indicator dot
                    AnimatedBuilder(
                      animation: _recordingAnimationC,
                      builder: (context, child) {
                        return Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252).withValues(
                              alpha: 0.5 + (_recordingAnimationC.value * 0.5),
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    FxText.titleMedium(
                      _formatDuration(_recordingDuration),
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: 500,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel button
                  GestureDetector(
                    onTap: () async {
                      await _cancelRecording();
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[700]!, Colors.grey[600]!],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  // Stop and send button
                  GestureDetector(
                    onTap: () async {
                      await _stopRecording();
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4CAF50),
                            const Color(0xFF45a049),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Instructions
              FxText.bodySmall(
                'Tap ✓ to send • Tap ✕ to cancel',
                color: Colors.grey[400],
                fontSize: 14,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Format duration for live timer
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Enhanced error handling
  Future<void> _handleAudioError(dynamic error, String audioUrl) async {
    String errorMessage = 'Error playing audio';
    String debugInfo = '';

    if (error.toString().contains('MEDIA_ERROR_UNKNOWN') ||
        error.toString().contains('Failed to set source')) {
      bool isEmulator = await _isRunningOnEmulator();

      if (isEmulator) {
        errorMessage =
            '🔧 Emulator audio limitation detected. Try on a real device for full functionality.';
        debugInfo =
            'Emulator media player has known limitations with network audio streams.';
      } else {
        errorMessage =
            'Audio format not supported. Please use WAV or MP3 format.';
        debugInfo = 'Audio format or codec not supported on this device.';
      }
    } else if (error.toString().contains('Network') ||
        error.toString().contains('IOException')) {
      errorMessage = 'Network error. Check your internet connection.';
      debugInfo = 'Unable to reach audio server or download audio file.';
    } else if (error.toString().contains('Permission')) {
      errorMessage = 'Audio permission denied.';
      debugInfo = 'App needs audio permissions to play sounds.';
    } else if (error.toString().contains('AudioFocus')) {
      errorMessage = 'Audio focus conflict. Close other audio apps.';
      debugInfo = 'Another app is using audio resources.';
    }

    Utils.toast(errorMessage);

    print('🔍 AUDIO DEBUG INFO:');
    print('   Error: $error');
    print('   URL: $audioUrl');
    print('   Diagnosis: $debugInfo');
    print('   Emulator: ${await _isRunningOnEmulator()}');
  }

  void _showReportDialog() {
    final otherUserId =
        _mainC.userModel.id.toString() == chatHead.customer_id
            ? chatHead.product_owner_id
            : chatHead.customer_id;
    final otherUserName =
        _mainC.userModel.id.toString() == chatHead.customer_id
            ? chatHead.product_owner_name
            : chatHead.customer_name;

    showDialog(
      context: context,
      builder:
          (context) => ReportContentDialog(
            contentType: 'User',
            contentPreview: otherUserName,
            contentId: otherUserId,
            reportedUserId: otherUserId,
          ),
    );
  }

  void _showBlockDialog() {
    final otherUserId =
        _mainC.userModel.id.toString() == chatHead.customer_id
            ? chatHead.product_owner_id
            : chatHead.customer_id;
    final otherUserName =
        _mainC.userModel.id.toString() == chatHead.customer_id
            ? chatHead.product_owner_name
            : chatHead.customer_name;
    final otherUserAvatar =
        _mainC.userModel.id.toString() == chatHead.customer_id
            ? chatHead.product_owner_photo
            : chatHead.customer_photo;

    showDialog(
      context: context,
      builder:
          (context) => BlockUserDialog(
            userName: otherUserName,
            userId: otherUserId,
            userAvatar: otherUserAvatar,
          ),
    );
  }

  // Check if a user is blocked
  Future<bool> _isUserBlocked(String userId) async {
    try {
      // TODO: Replace with actual API call to check blocked users
      // For now, return false (no blocking implemented)
      // This should call something like:
      // final response = await Utils.http_post('check-blocked-user', {'user_id': userId});
      // return response.code == 1 && response.data['is_blocked'] == true;

      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Simulate API call
      return false; // Placeholder - implement actual blocking check
    } catch (e) {
      print('Error checking blocked user status: $e');
      return false; // Assume not blocked on error
    }
  }
}

// ======= MULTIMEDIA PREVIEW DIALOG =======

class _MediaPreviewDialog extends StatefulWidget {
  final String mediaType;
  final String filePath;
  final Function(String?) onSend;
  final VoidCallback onCancel;

  const _MediaPreviewDialog({
    required this.mediaType,
    required this.filePath,
    required this.onSend,
    required this.onCancel,
  });

  @override
  _MediaPreviewDialogState createState() => _MediaPreviewDialogState();
}

class _MediaPreviewDialogState extends State<_MediaPreviewDialog> {
  late TextEditingController _captionController;
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();

    if (widget.mediaType == 'video') {
      _initializeVideo();
    } else if (widget.mediaType == 'audio') {
      _audioPlayer = AudioPlayer();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(File(widget.filePath));
    await _videoController!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDialogHeight = screenHeight * 0.8; // 80% of screen height
    final previewHeight =
        maxDialogHeight * 0.6; // 60% of dialog height for preview

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
          maxWidth: screenWidth * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Preview ${widget.mediaType}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Preview content - flexible height
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                constraints: BoxConstraints(
                  maxHeight: previewHeight,
                  minHeight: 200,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildPreviewContent(),
              ),
            ),

            // Bottom section with caption and buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Caption input (for photos and videos) - constrained height
                  if (widget.mediaType == 'photo' ||
                      widget.mediaType == 'video')
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: _captionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a caption...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        maxLines: 2,
                        maxLength: 200, // Limit caption length
                      ),
                    ),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: widget.onCancel,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              () =>
                                  widget.onSend(_captionController.text.trim()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Send'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    switch (widget.mediaType) {
      case 'photo':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(widget.filePath),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        );

      case 'video':
        if (_videoController != null && _videoController!.value.isInitialized) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        _videoController!.pause();
                      } else {
                        _videoController!.play();
                      }
                    });
                  },
                  icon: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

      case 'audio':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.audiotrack, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                'Voice Message',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _toggleAudioPlayback,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _isPlaying ? 'Playing...' : 'Tap to play',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        );

      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                widget.mediaType.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        );
    }
  }

  Future<void> _toggleAudioPlayback() async {
    if (_audioPlayer == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer!.stop();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer!.play(DeviceFileSource(widget.filePath));
        setState(() => _isPlaying = true);

        // Listen for audio completion
        _audioPlayer!.onPlayerComplete.listen((_) {
          setState(() => _isPlaying = false);
        });
      }
    } catch (e) {
      Utils.toast('Error playing audio: $e');
    }
  }
}
