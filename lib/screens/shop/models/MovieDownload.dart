import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lovebirds_app/models/RespondModel.dart';

import '../../../utils/Utilities.dart';

class MovieDownload {
  static String end_point = "movie-downloads";
  static String tableName = "movie_downloads";
  int id = 0;
  String created_at = "";
  String updated_at = "";
  String local_id = "";
  String user_id = "";
  String movie_model_id = "";
  String status = "";
  String error_message = "";
  String local_video_link = "";
  String download_started_at = "";
  String download_completed_at = "";
  String download_duration = "";
  String file_size = "";
  String download_progress = "";
  String watch_progress = "";
  String title = "";
  String url = "";
  String image_url = "";
  String local_image_url = "";
  String thumbnail_url = "";
  String description = "";
  String genre = "";
  String vj = "";
  String content_type = "";
  String content_is_video = "";
  String is_premium = "";
  String episode_number = "";
  String is_first_episode = "";
  String local_text = "";
  String user_text = "";
  String movie_model_text = "";

  Future<String> checkDownloadProgress() async {
    //get download tas DownloadTask for given task id
    final task = await FlutterDownloader.loadTasksWithRawQuery(
      query: 'SELECT * FROM task WHERE task_id="${user_text}"',
    );
    if (task == null || task.isEmpty) {
      Utils.toast("Download task not found!");
      return '';
    }
    final t = task.first;
    String status = t.status.name.toString();
    if (status == 'complete') {
      if (movie_model_text != 'UPLOADED') {
        doUpload();
      }
    }
    return status;
  }

  Future<String> getVideoPath() async {
    if (await File(local_video_link).exists()) {
      return local_video_link;
    }

    //get phone download directory
    Directory? dir = await Utils.getMyRealDownload();
    if (dir != null) {
      local_video_link = '${dir.path}/$title';
      //check if the file exists
      if (await File(local_video_link).exists()) {
        return local_video_link;
      }
    }

    //
    if (local_video_link.toString().toLowerCase().contains('/') &&
        local_video_link.toString().toLowerCase().contains('.mp4')) {
      return local_video_link;
    }
    return local_video_link + "/" + title;
  }

  Future<void> doUpload() async {
    if (movie_model_text == 'UPLOADED') {
      return;
    }
    RespondModel? r;
    try {
      Map<String, dynamic> data = toJson();
      data.remove('id');
      data['model'] = 'MovieDownload';
      r = RespondModel(await Utils.http_post('dynamic-save', data));
    } catch (e) {
      r = null;
    }
    if (r == null) {
      return;
    }
    if (r.code == 1) {
      movie_model_text = 'UPLOADED';
      Utils.toast("uploaded!");
      await save();
    }
  }

  static fromJson(dynamic m) {
    MovieDownload obj = new MovieDownload();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.local_id = Utils.to_str(m['local_id'], '');
    obj.local_text = Utils.to_str(m['local_text'], '');
    obj.user_id = Utils.to_str(m['user_id'], '');
    obj.user_text = Utils.to_str(m['user_text'], '');
    obj.movie_model_id = Utils.to_str(m['movie_model_id'], '');
    obj.movie_model_text = Utils.to_str(m['movie_model_text'], '');
    obj.status = Utils.to_str(m['status'], '');
    obj.error_message = Utils.to_str(m['error_message'], '');
    obj.local_video_link = Utils.to_str(m['local_video_link'], '');
    obj.download_started_at = Utils.to_str(m['download_started_at'], '');
    obj.download_completed_at = Utils.to_str(m['download_completed_at'], '');
    obj.download_duration = Utils.to_str(m['download_duration'], '');
    obj.file_size = Utils.to_str(m['file_size'], '');
    obj.download_progress = Utils.to_str(m['download_progress'], '');
    obj.watch_progress = Utils.to_str(m['watch_progress'], '');
    obj.title = Utils.to_str(m['title'], '');
    obj.url = Utils.to_str(m['url'], '');
    obj.image_url = Utils.to_str(m['image_url'], '');
    obj.local_image_url = Utils.to_str(m['local_image_url'], '');
    obj.thumbnail_url = Utils.to_str(m['thumbnail_url'], '');
    obj.description = Utils.to_str(m['description'], '');
    obj.genre = Utils.to_str(m['genre'], '');
    obj.vj = Utils.to_str(m['vj'], '');
    obj.content_type = Utils.to_str(m['content_type'], '');
    obj.content_is_video = Utils.to_str(m['content_is_video'], '');
    obj.is_premium = Utils.to_str(m['is_premium'], '');
    obj.episode_number = Utils.to_str(m['episode_number'], '');
    obj.is_first_episode = Utils.to_str(m['is_first_episode'], '');

    return obj;
  }

  static Future<List<MovieDownload>> getLocalData({String where = "1"}) async {
    List<MovieDownload> data = [];
    if (!(await MovieDownload.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps = await db.query(
      tableName,
      where: where,
      orderBy: ' id DESC ',
    );

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(MovieDownload.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<MovieDownload>> get_items({String where = '1'}) async {
    List<MovieDownload> data = await getLocalData(where: where);

    return data;
  }

  save() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return;
    }

    await initTable();

    try {
      await db.insert(
        tableName,
        toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      Utils.toast("Failed to save student because ${e.toString()}");
    }
  }

  toJson() {
    return {
      'id': id,
      'created_at': created_at,
      'updated_at': updated_at,
      'local_id': local_id,
      'local_text': local_text,
      'user_id': user_id,
      'user_text': user_text,
      'movie_model_id': movie_model_id,
      'movie_model_text': movie_model_text,
      'status': status,
      'error_message': error_message,
      'local_video_link': local_video_link,
      'download_started_at': download_started_at,
      'download_completed_at': download_completed_at,
      'download_duration': download_duration,
      'file_size': file_size,
      'download_progress': download_progress,
      'watch_progress': watch_progress,
      'title': title,
      'url': url,
      'image_url': image_url,
      'local_image_url': local_image_url,
      'thumbnail_url': thumbnail_url,
      'description': description,
      'genre': genre,
      'vj': vj,
      'content_type': content_type,
      'content_is_video': content_is_video,
      'is_premium': is_premium,
      'episode_number': episode_number,
      'is_first_episode': is_first_episode,
    };
  }

  static Future initTable() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }

    String sql =
        " CREATE TABLE IF NOT EXISTS "
        "$tableName ("
        "id INTEGER PRIMARY KEY"
        ",created_at TEXT"
        ",updated_at TEXT"
        ",local_id TEXT"
        ",local_text TEXT"
        ",user_id TEXT"
        ",user_text TEXT"
        ",movie_model_id TEXT"
        ",movie_model_text TEXT"
        ",status TEXT"
        ",error_message TEXT"
        ",local_video_link TEXT"
        ",download_started_at TEXT"
        ",download_completed_at TEXT"
        ",download_duration TEXT"
        ",file_size TEXT"
        ",download_progress TEXT"
        ",watch_progress TEXT"
        ",title TEXT"
        ",url TEXT"
        ",image_url TEXT"
        ",local_image_url TEXT"
        ",thumbnail_url TEXT"
        ",description TEXT"
        ",genre TEXT"
        ",vj TEXT"
        ",content_type TEXT"
        ",content_is_video TEXT"
        ",is_premium TEXT"
        ",episode_number TEXT"
        ",is_first_episode TEXT"
        ")";

    try {
      //await db.execute("DROP TABLE ${tableName}");
      await db.execute(sql);
    } catch (e) {
      Utils.log('Failed to create table because ${e.toString()}');

      return false;
    }

    return true;
  }

  static deleteAll() async {
    if (!(await MovieDownload.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(MovieDownload.tableName);
  }

  delete() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return;
    }

    await initTable();

    try {
      await db.delete(tableName, where: 'id = $id');

      //delete file if exists
      File file = File(local_video_link);
      if (await file.exists()) {
        await file.delete();
        Utils.toast("File deleted successfully.", color: Colors.green);
      } else {
        Utils.toast("File not found, cannot delete.", color: Colors.red);
      }
    } catch (e) {
      Utils.toast("Failed because  ${e.toString()}");
    }
  }
}
