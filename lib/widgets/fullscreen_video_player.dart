import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const FullScreenVideoPlayer({Key? key, required this.videoUrl, this.title})
    : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _enterFullscreen();
    _initializePlayer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller?.dispose();
    _exitFullscreen();
    super.dispose();
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  Future<void> _initializePlayer() async {
    try {
      // Check for emulator and apply compatibility settings
      bool isEmulator = await _isRunningOnEmulator();

      if (isEmulator) {
        print('🔧 EMULATOR DETECTED: Applying video compatibility mode');
      }

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      // Apply emulator-specific settings
      if (isEmulator) {
        // Add longer timeout for emulator
        await _controller!.initialize().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Video initialization timeout on emulator');
          },
        );
      } else {
        await _controller!.initialize();
      }

      setState(() {
        _isInitialized = true;
        _hasError = false;
        _isLoading = false;
      });

      _controller!.play();
      _controller!.addListener(() {
        setState(() {});
      });

      _startHideControlsTimer();
    } catch (e) {
      print('❌ Video initialization error: $e');

      // Provide emulator-specific error messages
      bool isEmulator = await _isRunningOnEmulator();
      if (isEmulator && e.toString().contains('timeout')) {
        print('⚠️ Emulator video timeout - this is normal for emulators');
      }

      setState(() {
        _hasError = true;
        _isInitialized = false;
        _isLoading = false;
      });
    }
  }

  // Check if running on emulator
  Future<bool> _isRunningOnEmulator() async {
    try {
      if (!Platform.isAndroid) return false;

      // Check for emulator environment variables and build properties
      return Platform.environment.containsKey('ANDROID_EMULATOR') ||
          Platform.version.toLowerCase().contains('sdk_gphone') ||
          Platform.version.toLowerCase().contains('emulator') ||
          Platform.version.toLowerCase().contains('goldfish') ||
          Platform.version.toLowerCase().contains('ranchu');
    } catch (e) {
      return false;
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_hasError) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
      _startHideControlsTimer();
    }
  }

  void _seekTo(double percentage) {
    if (_controller == null || !_isInitialized) return;

    final duration = _controller!.value.duration;
    final position = duration * percentage;
    _controller!.seekTo(position);
  }

  void _skip(int seconds) {
    if (_controller == null || !_isInitialized) return;

    final current = _controller!.value.position;
    final target = current + Duration(seconds: seconds);
    final duration = _controller!.value.duration;

    if (target < Duration.zero) {
      _controller!.seekTo(Duration.zero);
    } else if (target > duration) {
      _controller!.seekTo(duration);
    } else {
      _controller!.seekTo(target);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Color(0xFFFF6B6B),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Loading video...",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 64),
            const SizedBox(height: 16),
            const Text(
              "Failed to load video",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<bool>(
              future: _isRunningOnEmulator(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return const Column(
                    children: [
                      Text(
                        "⚠️ Running on emulator",
                        style: TextStyle(color: Colors.orange, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Video playback may be limited on emulators.\nTry on a real device for full functionality.",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                } else {
                  return const Text(
                    "Please check your internet connection",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Retry initialization
                    setState(() {
                      _hasError = false;
                      _isLoading = true;
                    });
                    _initializePlayer();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Retry"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildLoadingScreen(),
      );
    }

    if (_hasError) {
      return Scaffold(backgroundColor: Colors.black, body: _buildErrorScreen());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video Player
            Center(
              child:
                  _isInitialized
                      ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                      : const SizedBox(),
            ),

            // Controls Overlay
            if (_showControls)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top Controls
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              widget.title ?? "Video",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Center Play/Pause Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 36,
                            color: Colors.white,
                            icon: const Icon(Icons.replay_10),
                            onPressed: () => _skip(-10),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFF5252),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF6B6B,
                                    ).withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _controller!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            iconSize: 36,
                            color: Colors.white,
                            icon: const Icon(Icons.forward_10),
                            onPressed: () => _skip(10),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Bottom Progress Controls
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            // Progress Bar
                            GestureDetector(
                              onTapDown: (details) {
                                final RenderBox box =
                                    context.findRenderObject() as RenderBox;
                                final Offset localPosition = box.globalToLocal(
                                  details.globalPosition,
                                );
                                final double percentage =
                                    (localPosition.dx - 16) /
                                    (box.size.width - 32);
                                _seekTo(percentage.clamp(0.0, 1.0));
                              },
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: LinearProgressIndicator(
                                  value:
                                      _controller!
                                          .value
                                          .position
                                          .inMilliseconds /
                                      _controller!
                                          .value
                                          .duration
                                          .inMilliseconds,
                                  backgroundColor: Colors.transparent,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFF6B6B),
                                      ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Duration Text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_controller!.value.position),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatDuration(_controller!.value.duration),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
              ),
          ],
        ),
      ),
    );
  }
}
