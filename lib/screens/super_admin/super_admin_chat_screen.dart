import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../../models/RespondModel.dart';
import '../../utils/Utilities.dart';
import '../../utils/CustomTheme.dart';

class SuperAdminChatScreen extends StatefulWidget {
  const SuperAdminChatScreen({Key? key}) : super(key: key);

  @override
  State<SuperAdminChatScreen> createState() => _SuperAdminChatScreenState();
}

class _SuperAdminChatScreenState extends State<SuperAdminChatScreen>
    with WidgetsBindingObserver {
  dynamic chatHead = Get.arguments;
  bool _isLoading = true;
  List<dynamic> _messages = [];
  String _errorMessage = '';
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    if (chatHead != null) {
      _loadMessages();
    } else {
      setState(() {
        _errorMessage = 'Chat head data not found';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Remove observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Mark messages as read when app becomes active
    if (state == AppLifecycleState.resumed) {
      _markMessagesAsRead();
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await Utils.http_get('super-admin-chat-messages', {
        'chat_head_id': chatHead['id'].toString(),
      });
      final resp = RespondModel(response);

      if (resp.code == 1) {
        setState(() {
          _messages = resp.data ?? [];
          _isLoading = false;
        });

        // Mark messages as read after loading them successfully
        await _markMessagesAsRead();
      } else {
        setState(() {
          _errorMessage =
              resp.message.isNotEmpty
                  ? resp.message
                  : 'Failed to load messages';
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

  Future<void> _markMessagesAsRead() async {
    try {
      final response = await Utils.http_post('super-admin-mark-as-read', {
        'chat_head_id': chatHead['id'].toString(),
      });
      final resp = RespondModel(response);

      if (resp.code == 1) {
        // Successfully marked as read
        // You can optionally show a subtle indication or update UI
        debugPrint('✅ Messages marked as read successfully');
      } else {
        // Silent fail for mark as read - don't show error to user
        debugPrint('⚠️ Failed to mark messages as read: ${resp.message}');
      }
    } catch (e) {
      // Silent fail for mark as read - don't show error to user
      debugPrint('⚠️ Error marking messages as read: ${e.toString()}');
    }
  }

  Future<void> _sendMessage({
    String? content,
    String messageType = 'text',
  }) async {
    final messageText = content ?? _messageController.text.trim();
    if (messageText.isEmpty || _isSending) return;

    if (messageType == 'text') {
      _messageController.clear();
    }

    setState(() {
      _isSending = true;
    });

    try {
      final response = await Utils.http_post('super-admin-send-message', {
        'chat_head_id': chatHead['id'].toString(),
        'sender_id': chatHead['test_account_id'].toString(),
        'content': messageText,
        'message_type': messageType,
      });
      final resp = RespondModel(response);

      if (resp.code == 1) {
        // Message sent successfully, reload messages
        await _loadMessages();
        Utils.toast('Message sent successfully', color: Colors.green);
      } else {
        Utils.toast(
          resp.message.isNotEmpty ? resp.message : 'Failed to send message',
          color: Colors.red,
        );
      }
    } catch (e) {
      Utils.toast('Error: ${e.toString()}', color: Colors.red);
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.card, CustomTheme.cardDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Multimedia input row
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _buildMultimediaButton(
                      icon: Icons.photo_camera,
                      label: 'Photo',
                      onTap: _pickImage,
                      color: CustomTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildMultimediaButton(
                      icon: Icons.videocam,
                      label: 'Video',
                      onTap: _pickVideo,
                      color: CustomTheme.color2,
                    ),
                    const SizedBox(width: 12),
                    _buildMultimediaButton(
                      icon: Icons.mic,
                      label: 'Audio',
                      onTap: _recordAudio,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildMultimediaButton(
                      icon: Icons.location_on,
                      label: 'Location',
                      onTap: _shareLocation,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              // Text input row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CustomTheme.cardDark,
                            CustomTheme.cardDark.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: CustomTheme.color2.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                          color: CustomTheme.color,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Send as test account...',
                          hintStyle: TextStyle(
                            color: CustomTheme.color2.withValues(alpha: 0.7),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.only(left: 8, right: 8),
                            child: Icon(
                              Icons.science,
                              color: CustomTheme.primary.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            _isSending
                                ? [
                                  CustomTheme.color2.withValues(alpha: 0.5),
                                  CustomTheme.color2.withValues(alpha: 0.3),
                                ]
                                : [
                                  CustomTheme.primary,
                                  CustomTheme.primaryDark,
                                ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow:
                          _isSending
                              ? []
                              : [
                                BoxShadow(
                                  color: CustomTheme.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                    ),
                    child: IconButton(
                      onPressed: _isSending ? null : () => _sendMessage(),
                      icon:
                          _isSending
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              )
                              : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 22,
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultimediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _showMediaPreview(mediaType: 'photo', filePath: image.path);
      }
    } catch (e) {
      Utils.toast('Error selecting image: ${e.toString()}', color: Colors.red);
    }
  }

  void _pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        await _showMediaPreview(mediaType: 'video', filePath: video.path);
      }
    } catch (e) {
      Utils.toast('Error selecting video: ${e.toString()}', color: Colors.red);
    }
  }

  void _recordAudio() {
    Utils.toast(
      'Audio recording feature coming soon!',
      color: CustomTheme.primary,
    );
    // Audio recording implementation would go here
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

    String? caption;

    showDialog(
      context: context,
      builder:
          (BuildContext context) => _MediaPreviewDialog(
            type: mediaType,
            filePath: filePath,
            onSend: () async {
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
            onCaptionChanged: (String newCaption) {
              caption = newCaption;
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

  // Send multimedia message
  Future<void> _sendMultimediaMessage({
    required String messageType,
    required String content,
    String? previewFileName,
  }) async {
    try {
      Map<String, dynamic> requestData = {
        'sender_id': chatHead['test_account_id'].toString(),
        'receiver_id': chatHead['user_id'].toString(),
        'body': content,
        'message_type': messageType,
        'chat_head_id': chatHead['id'],
      };

      // Add multimedia specific fields
      if (previewFileName != null && previewFileName.isNotEmpty) {
        requestData['preview_file_name'] = previewFileName;
      }

      final response = await Utils.http_post(
        'super-admin-send-message',
        requestData,
      );

      final resp = RespondModel(response);
      if (resp.code == 1) {
        Utils.toast('Message sent successfully!', color: CustomTheme.primary);
        await _refreshMessages();
      } else {
        Utils.toast(
          'Failed to send message: ${resp.message}',
          color: Colors.red,
        );
      }
    } catch (e) {
      Utils.toast('Error sending message: $e', color: Colors.red);
    }
  }

  void _shareLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Utils.toast('Please enable location services', color: Colors.red);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Utils.toast('Location permission denied', color: Colors.red);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      String locationData = '${position.latitude},${position.longitude}';

      await _sendMessage(content: locationData, messageType: 'location');
    } catch (e) {
      Utils.toast('Error getting location: ${e.toString()}', color: Colors.red);
    }
  }

  Future<void> _refreshMessages() async {
    // Fetch fresh messages from the server
    // This should call your API to get updated chat messages
    setState(() {
      // Update your message list here
    });
  }

  Widget _MediaPreviewDialog({
    required String filePath,
    required String type,
    required VoidCallback onSend,
    required VoidCallback onCancel,
    required Function(String) onCaptionChanged,
    String? thumbnailPath,
  }) {
    VideoPlayerController? videoController;
    AudioPlayer? audioPlayer;

    if (type == 'video') {
      videoController = VideoPlayerController.file(File(filePath));
      videoController.initialize();
    }

    if (type == 'audio') {
      audioPlayer = AudioPlayer();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: Get.width * 0.9,
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Preview ${type.toUpperCase()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      videoController?.dispose();
                      audioPlayer?.dispose();
                      onCancel();
                    },
                    child: Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),

            // Media Preview
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Media Display
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildMediaPreview(
                          type: type,
                          filePath: filePath,
                          videoController: videoController,
                          audioPlayer: audioPlayer,
                          thumbnailPath: thumbnailPath,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Caption Input
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Add a caption...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      maxLines: 3,
                      onChanged: onCaptionChanged,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        videoController?.dispose();
                        audioPlayer?.dispose();
                        onCancel();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        videoController?.dispose();
                        audioPlayer?.dispose();
                        onSend();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Send'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview({
    required String type,
    required String filePath,
    VideoPlayerController? videoController,
    AudioPlayer? audioPlayer,
    String? thumbnailPath,
  }) {
    switch (type) {
      case 'photo':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(filePath),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        );

      case 'video':
        return StatefulBuilder(
          builder: (context, setState) {
            bool isPlaying = videoController?.value.isPlaying ?? false;

            return Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      videoController != null &&
                              videoController.value.isInitialized
                          ? AspectRatio(
                            aspectRatio: videoController.value.aspectRatio,
                            child: VideoPlayer(videoController),
                          )
                          : Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.video_library,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                          ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (videoController != null) {
                        if (isPlaying) {
                          videoController.pause();
                        } else {
                          videoController.play();
                        }
                        setState(() {
                          // Update will be handled by the video controller state
                        });
                      }
                    },
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            );
          },
        );

      case 'audio':
        return StatefulBuilder(
          builder: (context, setState) {
            bool isPlaying = false;
            Duration duration = Duration.zero;
            Duration position = Duration.zero;

            if (audioPlayer != null) {
              audioPlayer.onDurationChanged.listen((newDuration) {
                setState(() {
                  duration = newDuration;
                });
              });

              audioPlayer.onPositionChanged.listen((newPosition) {
                setState(() {
                  position = newPosition;
                });
              });

              audioPlayer.onPlayerStateChanged.listen((state) {
                setState(() {
                  isPlaying = state == PlayerState.playing;
                });
              });
            }

            return Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.audiotrack, size: 64, color: CustomTheme.primary),
                  SizedBox(height: 24),
                  Text(
                    'Audio Recording',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: CustomTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            if (audioPlayer != null) {
                              if (isPlaying) {
                                await audioPlayer.pause();
                              } else {
                                await audioPlayer.play(
                                  DeviceFileSource(filePath),
                                );
                              }
                            }
                          },
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value:
                                  duration.inMilliseconds > 0
                                      ? position.inMilliseconds /
                                          duration.inMilliseconds
                                      : 0.0,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                CustomTheme.primary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );

      default:
        return Container(
          child: Icon(Icons.attach_file, size: 64, color: Colors.grey[600]),
        );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
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

  Widget _buildMessage(dynamic message) {
    final String senderName = message['sender_details']['name'] ?? 'Unknown';
    final String messageBody = message['body'] ?? '';
    final String messageTime = _formatTime(message['created_at']);
    final String senderPhoto = message['sender_details']['photo'] ?? '';
    final String messageType = message['message_type'] ?? 'text';

    // Determine if this is from the test account (admin) for styling
    final bool isFromAdmin =
        message['sender_id'] == chatHead['test_account_id'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isFromAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromAdmin) ...[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    CustomTheme.color2.withValues(alpha: 0.3),
                    CustomTheme.color2.withValues(alpha: 0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.transparent,
                backgroundImage:
                    senderPhoto.isNotEmpty
                        ? CachedNetworkImageProvider(senderPhoto)
                        : null,
                child:
                    senderPhoto.isEmpty
                        ? Text(
                          senderName.isNotEmpty
                              ? senderName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: CustomTheme.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isFromAdmin
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isFromAdmin
                              ? [CustomTheme.primary, CustomTheme.primaryDark]
                              : [CustomTheme.card, CustomTheme.cardDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isFromAdmin ? 20 : 6),
                      topRight: Radius.circular(isFromAdmin ? 6 : 20),
                      bottomLeft: const Radius.circular(20),
                      bottomRight: const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isFromAdmin
                                ? CustomTheme.primary
                                : Colors.black)
                            .withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildMessageContent(
                          messageType,
                          messageBody,
                          isFromAdmin,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(
                    left: isFromAdmin ? 0 : 4,
                    right: isFromAdmin ? 4 : 0,
                  ),
                  child: Text(
                    messageTime,
                    style: TextStyle(
                      color: CustomTheme.color2.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isFromAdmin) ...[
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    CustomTheme.primary.withValues(alpha: 0.8),
                    CustomTheme.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: CustomTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.transparent,
                backgroundImage:
                    senderPhoto.isNotEmpty
                        ? CachedNetworkImageProvider(senderPhoto)
                        : null,
                child:
                    senderPhoto.isEmpty
                        ? Icon(Icons.science, color: Colors.white, size: 16)
                        : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(
    String messageType,
    String content,
    bool isFromAdmin,
  ) {
    switch (messageType) {
      case 'image':
        return _buildImageMessage(content, isFromAdmin);
      case 'video':
        return _buildVideoMessage(content, isFromAdmin);
      case 'audio':
        return _buildAudioMessage(content, isFromAdmin);
      case 'location':
        return _buildLocationMessage(content, isFromAdmin);
      case 'text':
      default:
        return Text(
          content,
          style: TextStyle(
            color: isFromAdmin ? Colors.white : CustomTheme.color,
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        );
    }
  }

  Widget _buildImageMessage(String imageUrl, bool isFromAdmin) {
    return GestureDetector(
      onTap: () => _showImagePreview(imageUrl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250, maxHeight: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  height: 200,
                  color: (isFromAdmin ? Colors.white : CustomTheme.color2)
                      .withValues(alpha: 0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFromAdmin ? Colors.white : CustomTheme.primary,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ),
            errorWidget:
                (context, url, error) => Container(
                  height: 200,
                  color: (isFromAdmin ? Colors.white : CustomTheme.color2)
                      .withValues(alpha: 0.1),
                  child: Icon(
                    Icons.broken_image,
                    color: isFromAdmin ? Colors.white : CustomTheme.color2,
                    size: 40,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoMessage(String videoUrl, bool isFromAdmin) {
    return GestureDetector(
      onTap: () => _showVideoPreview(videoUrl),
      child: Container(
        width: 250,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: (isFromAdmin ? Colors.white : CustomTheme.color2).withValues(
            alpha: 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.videocam,
              color: isFromAdmin ? Colors.white : CustomTheme.primary,
              size: 32,
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                'Video Message',
                style: TextStyle(
                  color: isFromAdmin ? Colors.white : CustomTheme.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isFromAdmin ? Colors.white : CustomTheme.primary)
                    .withValues(alpha: 0.9),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.play_arrow,
                color: isFromAdmin ? CustomTheme.primary : Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage(String audioUrl, bool isFromAdmin) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: (isFromAdmin ? Colors.white : CustomTheme.primary).withValues(
          alpha: 0.1,
        ),
        border: Border.all(
          color: (isFromAdmin ? Colors.white : CustomTheme.primary).withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _playAudio(audioUrl),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFromAdmin ? Colors.white : CustomTheme.primary,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.play_arrow,
                color: isFromAdmin ? CustomTheme.primary : Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    color: (isFromAdmin ? Colors.white : CustomTheme.primary)
                        .withValues(alpha: 0.3),
                  ),
                  child: LinearProgressIndicator(
                    value: 0.0,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFromAdmin ? Colors.white : CustomTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Audio Message',
                  style: TextStyle(
                    color: isFromAdmin ? Colors.white : CustomTheme.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(String locationData, bool isFromAdmin) {
    return GestureDetector(
      onTap: () => _showLocationPreview(locationData),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: (isFromAdmin ? Colors.white : CustomTheme.primary).withValues(
            alpha: 0.1,
          ),
          border: Border.all(
            color: (isFromAdmin ? Colors.white : CustomTheme.primary)
                .withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.location_on,
              color: isFromAdmin ? Colors.white : CustomTheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Location Shared',
              style: TextStyle(
                color: isFromAdmin ? Colors.white : CustomTheme.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to view on map',
              style: TextStyle(
                color: (isFromAdmin ? Colors.white : CustomTheme.color2)
                    .withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black87,
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVideoPreview(String videoUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black87,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  'Video Player would be initialized here\n$videoUrl',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationPreview(String locationData) {
    Get.dialog(
      Dialog(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: CustomTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CustomTheme.accent,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Text(
                    'Map view would be shown here\n$locationData',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CustomTheme.color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playAudio(String audioUrl) {
    // Audio player implementation would go here
    Utils.toast('Playing audio: $audioUrl', color: CustomTheme.primary);
  }

  @override
  Widget build(BuildContext context) {
    final String testAccountName =
        chatHead?['test_account_name'] ?? 'Unknown Test Account';
    final String otherUserName = chatHead?['other_user_name'] ?? 'Unknown User';

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CustomTheme.primary.withValues(alpha: 0.2),
                        CustomTheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CustomTheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.science, color: CustomTheme.primary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'TEST',
                        style: TextStyle(
                          color: CustomTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    testAccountName,
                    style: TextStyle(
                      color: CustomTheme.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: CustomTheme.color2,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Chatting with: $otherUserName',
                    style: TextStyle(
                      color: CustomTheme.color2,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
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
              onPressed: _loadMessages,
              tooltip: 'Reload messages',
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
        child: Column(
          children: [
            // Messages area
            Expanded(
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
                                'Loading messages...',
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
                                      CustomTheme.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                      CustomTheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
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
                                  onPressed: _loadMessages,
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
                      : _messages.isEmpty
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
                                'No messages yet',
                                style: TextStyle(
                                  color: CustomTheme.accent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Start the conversation below as the test account',
                                  style: TextStyle(
                                    color: CustomTheme.color2,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          // Reverse the order to show newest at bottom
                          final reversedIndex = _messages.length - 1 - index;
                          return _buildMessage(_messages[reversedIndex]);
                        },
                      ),
            ),

            // Message input area
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }
}
