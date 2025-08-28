// lib/screens/downloads/DownloadListScreen.dart

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../../gardens/VideoPlayerScreen.dart';
import '../../../models/MovieDownload.dart';

class DownloadListScreen extends StatefulWidget {
  const DownloadListScreen({Key? key}) : super(key: key);

  @override
  _DownloadListScreenState createState() => _DownloadListScreenState();
}

class _DownloadListScreenState extends State<DownloadListScreen> {
  List<MovieDownload> _downloads = [];
  bool _loading = true;

  bool isListening = false;
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    _loadDownloads().then((_) {
      if (_downloads.isNotEmpty) doListener();
    });
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  Future<void> _loadDownloads() async {
    setState(() => _loading = true);
    final list = await MovieDownload.getLocalData();
    _downloads = list;
    setState(() => _loading = false);
  }

  Future<void> _onRefresh() => _loadDownloads();

  /// Polls flutter_downloader table, updates local records, then re-calls itself.
  Future<void> doListener() async {
    if (disposed || isListening) return;
    isListening = true;
    setState(() {});

    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
      query: 'SELECT * FROM task',
    );

    if (tasks == null || tasks.isEmpty) {
      // nothing or all done
      await Future.delayed(const Duration(seconds: 2));
      isListening = false;
      setState(() {});
      if (!disposed) doListener();
      return;
    }

    // reload local after possible new entries
    _downloads = await MovieDownload.getLocalData();
    for (var md in _downloads) {
      DownloadTask? t;
      for (DownloadTask x in tasks) {
        if (x.taskId == md.user_text) {
          t = x;
          break;
        }
      }

      if (t == null) {
        // task not found, remove local record
        continue;
      }

      // skip if already complete
      if (md.status.trim() == DownloadTaskStatus.complete.name) continue;

      // newly completed?
      if (t.status.name.toString() ==
          DownloadTaskStatus.complete.name.toString()) {
        md.status = t.status.name;
        md.download_completed_at = DateTime.now().toIso8601String();

        DateTime? start;
        try {
          start = DateTime.parse(md.download_started_at);
        } catch (e) {
          start = DateTime.now();
        }
        DateTime end = DateTime.now();
        Duration? diff = end.difference(start);
        md.download_duration = diff.inSeconds.toString();
        File x = File(md.local_video_link);

        if (await x.exists()) {
          md.file_size = _readableFileSize(x.lengthSync());
        }

        md.download_progress = '100';
        File file = File(md.local_video_link);
        if (await file.exists()) {
          md.file_size = _readableFileSize(file.lengthSync());
          //to get file size to mb
          md.file_size =
              '${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB';
          md.local_video_link = file.path;
        } else {
          md.file_size = '0';

        }

        //save changes
        await md.save();
        await md.doUpload();

        Utils.toast("Download complete: ${md.title}", color: Colors.green);
      } else {
        // update progress & status
        md.download_progress = t.progress.toString();
        md.status = t.status.name;
      }
      await md.save();
      setState(() {});
    }
    _downloads = await MovieDownload.getLocalData();
    setState(() {});
    await Future.delayed(const Duration(seconds: 5));
    isListening = false;
    if (!disposed) doListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FxText.titleLarge(
          'My Downloads',
          color: Colors.white,
          fontWeight: 700,
        ),
        backgroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _onRefresh,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: CustomTheme.primary,
        onRefresh: _onRefresh,
        child:
            _loading
                ? _buildShimmerList()
                : _downloads.isEmpty
                ? Center(
                  child: FxText.bodyMedium(
                    'No downloads yet.',
                    color: Colors.white70,
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: _downloads.length,
                  itemBuilder: (_, i) => _buildTile(_downloads[i]),
                ),
      ),
    );
  }

  Widget _buildShimmerList() => ListView.builder(
    padding: const EdgeInsets.only(top: 8, bottom: 16),
    itemCount: 5,
    itemBuilder:
        (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[850]!,
            highlightColor: Colors.grey[700]!,
            child: Row(
              children: [
                Container(width: 56, height: 56, color: Colors.white24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, color: Colors.white24),
                      const SizedBox(height: 6),
                      Container(height: 10, width: 120, color: Colors.white24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
  );

  Widget _buildTile(MovieDownload md) {
    final progress = int.tryParse(md.download_progress) ?? 0;
    final downloading = ['running', 'enqueued', 'pending'].contains(md.status);
    final paused = md.status == DownloadTaskStatus.paused.name;
    final completed = md.status.startsWith('complete');
    final failed = md.status == DownloadTaskStatus.failed.name;

    // compute file size if newly completed
    if (completed && md.file_size.isEmpty && md.local_video_link.isNotEmpty) {
      final f = File(md.local_video_link);
      if (f.existsSync()) md.file_size = _readableFileSize(f.lengthSync());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Stack(
        children: [
          Material(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                File movieFile = File(md.local_video_link);

                bool fileExists = false;
                //check if file exists
                if (!await movieFile.exists()) {
                  fileExists = false;
                } else {
                  fileExists = true;
                }

                if (!fileExists) {
                  //get download tas DownloadTask for given task id
                  final task = await FlutterDownloader.loadTasksWithRawQuery(
                    query: 'SELECT * FROM task WHERE task_id="${md.user_text}"',
                  );
                  if (task == null || task.isEmpty) {
                    Utils.toast("Download task not found!");
                    return;
                  }
                  final t = task.first;

                  File file = File('${t.savedDir}/${t.filename}');
                  if (!(await file.exists())) {
                    Directory? dir = await Utils.getMyRealDownload();
                    if (dir != null) {
                      file = File('${dir.path}/${t.filename}');
                    }
                  }

                  if ((await file.exists())) {
                    md.local_video_link = file.path;
                    Utils.toast(md.local_video_link);
                    Utils.toast('File found: ${file.path}');
                    await md.save();
                  } else {
                    Utils.toast('File not found at ${file.path}');
                    return;
                  }
                }

                //PLAY MOVIE
                if (completed) {
                  Get.to(() => VideoPlayerScreen({'LOCAL_MOVIE': md}));
                } else {
                  Utils.toast("Download not complete ${md.user_text}");
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    _buildThumbnail(md, downloading, paused, completed, failed),
                    const SizedBox(width: 10),
                    _buildDetails(
                      md,
                      progress,
                      downloading,
                      paused,
                      completed,
                      failed,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: PopupMenuButton<String>(
              color: Colors.grey[850],
              icon: const Icon(
                FeatherIcons.moreVertical,
                color: CustomTheme.primary,
                size: 24,
              ),
              onSelected: (action) => _handleAction(md, action),
              itemBuilder:
                  (_) => [
                    if (downloading)
                      const PopupMenuItem(value: 'pause', child: Text('Pause')),
                    if (paused)
                      const PopupMenuItem(
                        value: 'resume',
                        child: Text('Resume'),
                      ),
                    if (failed)
                      const PopupMenuItem(value: 'retry', child: Text('Retry')),
                    if (completed)
                      const PopupMenuItem(
                        value: 'open',
                        child: Text('Play Movie'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(
    MovieDownload md,
    bool dl,
    bool paused,
    bool cpl,
    bool fl,
  ) {
    //failed, retry
    if (md.status == DownloadTaskStatus.failed.name) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: md.thumbnail_url,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[800]),
              errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              FeatherIcons.xCircle,
              size: 16,
              color: Colors.redAccent,
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CachedNetworkImage(
            imageUrl: md.thumbnail_url,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.grey[800]),
            errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
          ),
        ),
        if (md.episode_number.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: const BoxDecoration(
                color: CustomTheme.primary,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: FxText.bodySmall(
                'Ep ${md.episode_number}',
                color: Colors.white,
                fontWeight: 600,
              ),
            ),
          ),
        Positioned(
          top: 0,
          right: 0,
          child: Icon(
            cpl
                ? FeatherIcons.checkCircle
                : fl
                ? FeatherIcons.xCircle
                : paused
                ? FeatherIcons.pauseCircle
                : FeatherIcons.downloadCloud,
            size: 16,
            color:
                cpl
                    ? Colors.greenAccent
                    : fl
                    ? Colors.redAccent
                    : paused
                    ? Colors.orangeAccent
                    : CustomTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(
    MovieDownload md,
    int prog,
    bool dl,
    bool paused,
    bool cpl,
    bool fl,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: FxText.bodySmall(
              md.title,
              color: Colors.white,
              fontWeight: 900,
              maxLines: 2,
              height: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (md.file_size.isNotEmpty)
                FxText.bodySmall(md.file_size, color: Colors.grey[500]),
              if (md.file_size.isNotEmpty) const SizedBox(width: 8),
              if (md.download_started_at.isNotEmpty)
                FxText.bodySmall(
                  'Started ${Utils.timeAgo(md.download_started_at)}',
                  color: Colors.grey[500],
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (dl || paused)
            LinearProgressIndicator(
              value: prog / 100,
              color: paused ? Colors.orangeAccent : CustomTheme.primary,
              backgroundColor: Colors.white12,
            )
          else
            FxText.bodySmall(
              cpl
                  ? 'Downloaded'
                  : fl
                  ? 'Failed'
                  : md.status,
              color:
                  cpl
                      ? Colors.greenAccent
                      : fl
                      ? Colors.redAccent
                      : Colors.white70,
            ),
        ],
      ),
    );
  }

  Future<void> _handleAction(MovieDownload md, String action) async {
    switch (action) {
      case 'pause':
        await FlutterDownloader.pause(taskId: md.local_text);
        break;
      case 'resume':
        final newId =
            await FlutterDownloader.resume(taskId: md.local_text) ??
            md.local_text;
        md.local_text = newId;
        md.status = DownloadTaskStatus.running.name;
        await md.save();
        break;
      case 'retry':
        final retryId =
            await FlutterDownloader.retry(taskId: md.local_text) ??
            md.local_text;
        md.local_text = retryId;
        md.status = DownloadTaskStatus.enqueued.name;
        await md.save();
        break;
      case 'open':
        Get.to(() => VideoPlayerScreen({'LOCAL_MOVIE': md}));
        break;
      case 'delete':
        _confirmDelete(md);
        break;
    }
    await _loadDownloads();
  }

  void _confirmDelete(MovieDownload md) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Delete download?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'This removes the file and record.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final file = File(md.local_video_link);
                  if (await file.exists()) await file.delete();
                  await md.delete();
                  await _loadDownloads();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }

  String _readableFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(1)} GB';
  }
}
