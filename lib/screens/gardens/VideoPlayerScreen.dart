import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/models/NewMovieModel.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';
import 'package:lovebirds_app/utils/Utilities.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../shop/models/MovieDownload.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> params;

  const VideoPlayerScreen(this.params, {Key? key}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  late VideoPlayerController _ctrl;
  bool _inited = false;
  bool _showOverlay = true;
  bool _locked = false;
  bool _showSettings = false;
  bool _uploading = false;
  bool _pageActive = true;

  Timer? _hideTimer, _uploadTimer;

  static const int skipSeconds = 10;
  final speeds = [0.5, 1.0, 1.5, 2.0];
  final volumes = [0.0, 0.5, 1.0];
  int _speedIndex = 1;
  int _volIndex = 2;

  late NewMovieModel movie;

  bool _pipShown = false;
  bool isLocalFile = false;
  MovieDownload md = MovieDownload();

  @override
  void initState() {
    super.initState();
    if (widget.params.containsKey('video_item')) {
      movie = widget.params['video_item'] as NewMovieModel;
      isLocalFile = false;
    } else if (widget.params.containsKey('LOCAL_MOVIE')) {
      isLocalFile = true;
      md = widget.params['LOCAL_MOVIE'] as MovieDownload;

      if (md.movie_model_text != 'UPLOADED') {
        md.doUpload();
      }

      movie = NewMovieModel.fromJson(md.toJson());
      movie.id = Utils.int_parse(md.movie_model_id);
      movie.url = md.local_video_link;
      print(md.local_video_link);
      movie.image_url = md.thumbnail_url;
      movie.title = md.title;
// movie.watch_progress = int.parse(md.watch_progress);
      setState(() {});
    } else {
      Utils.toast("No video item found.");
      return;
    }

    WidgetsBinding.instance.addObserver(this);
    _enterFullscreen();
    WakelockPlus.enable();
    _initVideo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageActive = false;
    _uploadTimer?.cancel();
    _hideTimer?.cancel();
    _uploadProgress(finalUpload: true);
    _ctrl.dispose();
    _exitFullscreen();
    WakelockPlus.disable();
    // Note: we do NOT dismiss our overlay here, so it will remain up
    super.dispose();
  }

  Future<void> _initVideo() async {
    if (isLocalFile) {
      _ctrl = VideoPlayerController.file(File(movie.url));
    } else {
      _ctrl = VideoPlayerController.network(movie.get_video_url());
    }
    try {
      await _ctrl.initialize();

      await _ctrl.setVolume(volumes[_volIndex]);
      await _ctrl.setPlaybackSpeed(speeds[_speedIndex]);
      _ctrl.play();
      setState(() => _inited = true);
      _startUploadTimer();
      _startHideTimer();
    } catch (_) {
      Utils.toast("Failed to load video.");
      Get.back();
    }
    _ctrl.setLooping(false);
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

  void _startHideTimer() {
    return;
    if (_locked || _showSettings) return;
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      setState(() => _showOverlay = false);
    });
  }

  void _toggleOverlay() {
    if (_locked || _showSettings) return;
    setState(() => _showOverlay = !_showOverlay);
    if (_showOverlay) _startHideTimer();
  }

  void _startUploadTimer() {
    _uploadTimer?.cancel();
    _uploadTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageActive) _uploadProgress();
    });
  }

  Future<void> _uploadProgress({bool finalUpload = false}) async {
    if (!_inited || _uploading) return;
    _uploading = true;
    int pos = _ctrl.value.position.inSeconds;
    int total = _ctrl.value.duration.inSeconds;
    int saved = Utils.int_parse(movie.watch_progress);
    if (finalUpload || (pos - saved).abs() >= 5) {
      // movie.watch_progress = pos;
      // movie.max_progress = total;
      // movie.watch_status = 'Active';
      // movie.watched_movie = 'Yes';

      // movie.save();

      await movie.submitViewProgress(pos, total);
    }
    _uploading = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_inited) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pageActive = false;
      _ctrl.pause();
    } else if (state == AppLifecycleState.resumed) {
      _pageActive = true;
      _ctrl.play();
      _startUploadTimer();
    }
  }

  Future<bool> _onWillPop() async {
    showMini();
    return true; // allow full‐screen to pop
  }

  showMini() {
    //add are you
    if (!_pipShown) {
      _pipShown = true;
      /*      // show mini‐player overlay at top
      showOverlay((context, t) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: FxContainer(
            color: Colors.red,
            borderRadiusAll: 20,
            child: FxText("data go here"),
          ),

          */ /* Draggable(
            feedback: _miniPlayer(),
            childWhenDragging: const SizedBox(),
            child: _miniPlayer(),
          ),*/ /*
        );
      }, duration: Duration(minutes: 2));*/
    }
  }

  @override
  Widget build(BuildContext context) {
    // _showSettings = false;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Exit Player'),
                  content: const Text(
                    'Are you sure you want to exit the video player?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Exit'),
                    ),
                  ],
                ),
          );
          if ((shouldExit ?? false) && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        /* appBar: AppBar(
          title: FxButton(
            child: FxText("asa", color: Colors.white),
            onPressed: () {
              _pipShown = false;
              showMini();
            },
          ),
        ),*/
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleOverlay,
          child: Stack(
            children: [
              Center(
                child:
                    _inited
                        ? AspectRatio(
                          aspectRatio: _ctrl.value.aspectRatio,
                          child: VideoPlayer(_ctrl),
                        )
                        : _buildLoadingOverlay(),
              ),
              if (_showOverlay) ...[
                _buildOverlay(),
                if (_showSettings) _buildSettingsPanel(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniPlayer() {
    return GestureDetector(
      onTap: () {
        // reopen full‐screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen({'video_item': movie}),
          ),
        );
      },
      child: Container(
        width: 160,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
        ),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
          aspectRatio: _ctrl.value.aspectRatio,
          child: VideoPlayer(_ctrl),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    final thumb =
        movie.thumbnail_url.isNotEmpty ? movie.thumbnail_url : movie.image_url;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumb.isNotEmpty)
          CachedNetworkImage(
            imageUrl: thumb,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.black),
            errorWidget: (_, __, ___) => Container(color: Colors.black),
          ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(color: Colors.black54),
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: Colors.yellow,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Loading...",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverlay() {
    if (_locked) {
      return Center(
        child: IconButton(
          iconSize: 50,
          color: Colors.white70,
          icon: const Icon(Icons.lock_outline),
          onPressed: () {
            setState(() => _locked = false);
            _startHideTimer();
          },
        ),
      );
    }
    return Positioned.fill(
      child: Container(
        color: Colors.black38,
        child: Column(
          children: [
            SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Exit Player'),
                              content: const Text(
                                'Are you sure you want to exit the video player?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  // Dismiss dialog
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Dismiss dialog
                                    Navigator.pop(context); // Exit screen
                                  },
                                  child: const Text('Exit'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  //add title
                  Expanded(
                    child: Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _locked ? Icons.lock : Icons.lock_open,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _locked = !_locked);
                      if (!_locked) _startHideTimer();
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 40,
                  color: Colors.white,
                  icon: const Icon(Icons.replay_10),
                  onPressed: () => _skip(-skipSeconds),
                ),
                IconButton(
                  iconSize: 60,
                  color: Colors.white,
                  icon: Icon(
                    _ctrl.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  onPressed: _playPause,
                ),
                IconButton(
                  iconSize: 40,
                  color: Colors.white,
                  icon: const Icon(Icons.forward_10),
                  onPressed: () => _skip(skipSeconds),
                ),
              ],
            ),
            const Spacer(),
            Container(
              color: Colors.black45,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Text(
                    _format(_ctrl.value.position),
                    style: const TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 15,
                      child: VideoProgressIndicator(
                        _ctrl,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        colors: const VideoProgressColors(
                          playedColor: CustomTheme.accent,
                          bufferedColor: Colors.white30,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _format(_ctrl.value.duration),
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showSettings = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playPause() {
    if (!_inited) return;
    if (_ctrl.value.isPlaying) {
      _ctrl.pause();
    } else {
      _ctrl.play();
      _startUploadTimer();
    }
    setState(() {});
  }

  void _skip(int seconds) {
    if (!_inited) return;
    final curr = _ctrl.value.position;
    var target = curr + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > _ctrl.value.duration) target = _ctrl.value.duration;
    _ctrl.seekTo(target);
  }

  String _format(Duration d) {
    if (d.inHours > 0) {
      return "${d.inHours}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    } else if (d.inMinutes > 0) {
      return "${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    } else {
      return "0:${d.inSeconds.toString().padLeft(2, '0')}";
    }
  }

  Widget _buildSettingsPanel() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {}, // consume
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Playback Speed: ${speeds[_speedIndex]}×",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children:
                        speeds.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final s = entry.value;
                          return ChoiceChip(
                            label: Text(
                              "$s×",
                              style: TextStyle(
                                color:
                                    idx == _speedIndex
                                        ? Colors.black
                                        : Colors.white,
                              ),
                            ),
                            selected: idx == _speedIndex,
                            selectedColor: Colors.yellow,
                            backgroundColor: Colors.white12,
                            onSelected: (_) {
                              setState(() {
                                _speedIndex = idx;
                                _ctrl.setPlaybackSpeed(s);
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Volume: ${(volumes[_volIndex] * 100).round()}%",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children:
                        volumes.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final v = entry.value;
                          return ChoiceChip(
                            label: Icon(
                              v == 0 ? Icons.volume_off : Icons.volume_up,
                              color:
                                  idx == _volIndex
                                      ? Colors.black
                                      : Colors.white,
                            ),
                            selected: idx == _volIndex,
                            selectedColor: Colors.yellow,
                            backgroundColor: Colors.white12,
                            onSelected: (_) {
                              setState(() {
                                _volIndex = idx;
                                _ctrl.setVolume(v);
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: const Text(
                        "Done",
                        style: TextStyle(color: Colors.yellow),
                      ),
                      onPressed: () {
                        setState(() => _showSettings = false);
                        _startHideTimer();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
