// lib/utils/download_manager.dart

import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import 'MovieDownload.dart';

typedef void DownloadCallback(
  String taskId,
  DownloadTaskStatus status,
  int progress,
);

class DownloadManager {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// 1) Call once during app startup:
  ///    await DownloadManager.initialize();
  static Future<void> initialize() async {


    // 1b) Initialize local notifications (Android settings only here)
    const androidInit = AndroidInitializationSettings('@drawable/logo');
    await _notifications.initialize(
      const InitializationSettings(android: androidInit),
    );
  }

  /// 2) After initialize(), hook up the background callback:
  static void registerCallback() {
    // register the Dart entry for the downloader isolate
    // FlutterDownloader.registerCallback(_downloadCallback);

    // register a ReceivePort so the isolate can send us updates
    final port = ReceivePort();
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      'downloader_send_port',
    );
    port.listen(_onDownloadEvent);
  }

  @pragma('vm:entry-point')
  static void _downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    final send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  /// Handles events sent from the downloader isolate
  static Future<void> _onDownloadEvent(dynamic raw) async {
    final data = raw as List<dynamic>;
    final String taskId = data[0] as String;
    final int statusVal = data[1] as int;
    final int progress = data[2] as int;

    final status = DownloadTaskStatus.values[statusVal];
    final list = await MovieDownload.getLocalData(
      where: "local_id = '$taskId'",
    );
    if (list.isEmpty) return;
    final md = list.first;

    // update model
    md.download_progress = progress.toString();
    switch (status) {
      case DownloadTaskStatus.running:
        md.status = 'downloading';
        break;
      case DownloadTaskStatus.paused:
        md.status = 'paused';
        break;
      case DownloadTaskStatus.complete:
        md.status = 'completed';
        final dir = await getApplicationDocumentsDirectory();
        md.local_video_link = '${dir.path}/${md.movie_model_id}.mp4';
        md.download_completed_at = DateTime.now().toIso8601String();
        break;
      case DownloadTaskStatus.failed:
        md.status = 'failed';
        md.error_message = 'Download failed';
        break;
      default:
        break;
    }

    await md.save();
    await _showOrUpdateNotification(md);
  }

  /// Enqueue a single download and persist the taskId
  static Future<void> enqueueDownload(MovieDownload md) async {
    final dir = await getApplicationDocumentsDirectory();
    final taskId = await FlutterDownloader.enqueue(
      url: md.url,
      savedDir: dir.path,
      fileName: '${md.movie_model_id}.mp4',
      showNotification: false,
      openFileFromNotification: false,
    );
    md.local_id = taskId!;
    md.status = 'downloading';
    md.download_started_at = DateTime.now().toIso8601String();
    await md.save();
  }

  /// Show or update a persistent notification of download progress
  static Future<void> _showOrUpdateNotification(MovieDownload md) async {
    final androidDetails = AndroidNotificationDetails(
      'downloads',
      'Downloads',
      channelDescription: 'Movie download progress',
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: int.tryParse(md.download_progress) ?? 0,
      importance: Importance.low,
      priority: Priority.low,
    );
    await _notifications.show(
      md.id, // use your DB id
      md.title,
      md.status == 'completed' ? 'Download complete' : 'Downloading…',
      NotificationDetails(android: androidDetails),
    );
  }
}
