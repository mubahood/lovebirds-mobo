import 'package:sqflite/sqflite.dart';

import '../utils/Utilities.dart';
import 'RespondModel.dart';

class MovieModel {
  static String end_point = "movies";
  static String tableName = "movie_models_2";
  int id = 0;
  String created_at = "";
  String updated_at = "";
  String title = "";
  String external_url = "";
  String url = "";
  String image_url = "";
  String thumbnail_url = "";
  String description = "";
  String year = "";
  String rating = "";
  String duration = "";
  String size = "";
  String genre = "";
  String director = "";
  String stars = "";
  String country = "";
  String language = "";
  String imdb_url = "";
  String imdb_rating = "";
  String imdb_votes = "";
  String imdb_id = "";
  String imdb_text = "";
  String type = "";
  String status = "";
  String error = "";
  String error_message = "";
  String downloads_count = "";
  String views_count = "";
  String likes_count = "";
  String dislikes_count = "";
  String comments_count = "";
  String comments = "";
  String video_is_downloaded_to_server = "";
  String video_downloaded_to_server_start_time = "";
  String video_downloaded_to_server_end_time = "";
  String video_downloaded_to_server_duration = "";
  String video_is_downloaded_to_server_status = "";
  String video_is_downloaded_to_server_error_message = "";
  String category = "";
  String category_id = "";
  String category_text = "";
  String is_processed = "";

  String watched_movie = "";
  String watch_progress = "";
  String max_progress = "";
  String watch_status = "";
  String liked_movie = "";

  double getProgress() {
    if (watch_progress.isEmpty) {
      return 0;
    }
    double progress = 0;
    try {
      progress = double.parse(watch_progress);
    } catch (e) {
      progress = 0;
    }
    double total = 0;
    try {
      total = double.parse(max_progress);
    } catch (e) {
      total = 0;
    }

    if (total < 1) {
      return 0;
    }
    if (progress > total) {
      return 100;
    }
    print("====>${(progress / total)}<======");
    return (progress / total);
  }

  String getThumbnail() {
    return thumbnail_url;
  }

  static fromJson(dynamic m) {
    MovieModel obj = MovieModel();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.title = Utils.to_str(m['title'], '');
    obj.external_url = Utils.to_str(m['external_url'], '');
    obj.url = Utils.to_str(m['url'], '');
    obj.image_url = Utils.to_str(m['image_url'], '');
    obj.thumbnail_url = Utils.to_str(m['thumbnail_url'], '');
    obj.description = Utils.to_str(m['description'], '');
    obj.year = Utils.to_str(m['year'], '');
    obj.rating = Utils.to_str(m['rating'], '');
    obj.duration = Utils.to_str(m['duration'], '');
    obj.size = Utils.to_str(m['size'], '');
    obj.genre = Utils.to_str(m['genre'], '');
    obj.director = Utils.to_str(m['director'], '');
    obj.stars = Utils.to_str(m['stars'], '');
    obj.country = Utils.to_str(m['country'], '');
    obj.language = Utils.to_str(m['language'], '');
    obj.imdb_url = Utils.to_str(m['imdb_url'], '');
    obj.imdb_rating = Utils.to_str(m['imdb_rating'], '');
    obj.imdb_votes = Utils.to_str(m['imdb_votes'], '');
    obj.imdb_id = Utils.to_str(m['imdb_id'], '');
    obj.imdb_text = Utils.to_str(m['imdb_text'], '');
    obj.type = Utils.to_str(m['type'], '');
    obj.status = Utils.to_str(m['status'], '');
    obj.error = Utils.to_str(m['error'], '');
    obj.error_message = Utils.to_str(m['error_message'], '');
    obj.downloads_count = Utils.to_str(m['downloads_count'], '');
    obj.views_count = Utils.to_str(m['views_count'], '');
    obj.likes_count = Utils.to_str(m['likes_count'], '');
    obj.dislikes_count = Utils.to_str(m['dislikes_count'], '');
    obj.comments_count = Utils.to_str(m['comments_count'], '');
    obj.comments = Utils.to_str(m['comments'], '');
    obj.max_progress = Utils.to_str(m['max_progress'], '');
    obj.video_is_downloaded_to_server = Utils.to_str(
      m['video_is_downloaded_to_server'],
      '',
    );
    obj.video_downloaded_to_server_start_time = Utils.to_str(
      m['video_downloaded_to_server_start_time'],
      '',
    );
    obj.video_downloaded_to_server_end_time = Utils.to_str(
      m['video_downloaded_to_server_end_time'],
      '',
    );
    obj.video_downloaded_to_server_duration = Utils.to_str(
      m['video_downloaded_to_server_duration'],
      '',
    );
    obj.video_is_downloaded_to_server_status = Utils.to_str(
      m['video_is_downloaded_to_server_status'],
      '',
    );
    obj.video_is_downloaded_to_server_error_message = Utils.to_str(
      m['video_is_downloaded_to_server_error_message'],
      '',
    );
    obj.category = Utils.to_str(m['category'], '');
    obj.category_id = Utils.to_str(m['category_id'], '');
    obj.category_text = Utils.to_str(m['category_text'], '');
    obj.is_processed = Utils.to_str(m['is_processed'], '');
    obj.get_video_url();

    obj.watched_movie = Utils.to_str(m['watched_movie'], '');
    obj.watch_progress = Utils.to_str(m['watch_progress'], '');
    obj.watch_status = Utils.to_str(m['watch_status'], '');
    obj.liked_movie = Utils.to_str(m['liked_movie'], '');

    return obj;
  }

  String video_url = "";

  String get_video_url() {
    video_url = url;
    return url;
  }

  static Future<List<MovieModel>> getLocalData({String where = "1"}) async {
    List<MovieModel> data = [];
    if (!(await MovieModel.initTable())) {
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
      orderBy: ' title ASC ',
    );

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(MovieModel.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<MovieModel>> get_items({String where = '1'}) async {
    List<MovieModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await MovieModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      MovieModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<MovieModel>> getOnlineItems() async {
    List<MovieModel> data = [];

    RespondModel resp = RespondModel(
      await Utils.http_get(MovieModel.end_point, {'logged_in_user_id': '1'}),
    );

    if (resp.code != 1) {
      return [];
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return [];
    }

    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await MovieModel.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          MovieModel sub = MovieModel.fromJson(x);
          try {
            batch.insert(
              tableName,
              sub.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } catch (e) {
            print("faied to save becaus ${e.toString()}");
          }
        }

        try {
          await batch.commit(continueOnError: true);
        } catch (e) {
          print("faied to save to commit BRECASE == ${e.toString()}");
        }
      });
    }

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
      'title': title,
      'external_url': external_url,
      'url': url,
      'image_url': image_url,
      'thumbnail_url': thumbnail_url,
      'description': description,
      'year': year,
      'rating': rating,
      'duration': duration,
      'size': size,
      'max_progress': max_progress,
      'genre': genre,
      'director': director,
      'stars': stars,
      'country': country,
      'language': language,
      'imdb_url': imdb_url,
      'imdb_rating': imdb_rating,
      'imdb_votes': imdb_votes,
      'imdb_id': imdb_id,
      'imdb_text': imdb_text,
      'type': type,
      'status': status,
      'error': error,
      'error_message': error_message,
      'downloads_count': downloads_count,
      'views_count': views_count,
      'likes_count': likes_count,
      'dislikes_count': dislikes_count,
      'comments_count': comments_count,
      'comments': comments,
      'video_is_downloaded_to_server': video_is_downloaded_to_server,
      'video_downloaded_to_server_start_time':
          video_downloaded_to_server_start_time,
      'video_downloaded_to_server_end_time':
          video_downloaded_to_server_end_time,
      'video_downloaded_to_server_duration':
          video_downloaded_to_server_duration,
      'video_is_downloaded_to_server_status':
          video_is_downloaded_to_server_status,
      'video_is_downloaded_to_server_error_message':
          video_is_downloaded_to_server_error_message,
      'category': category,
      'category_id': category_id,
      'category_text': category_text,
      'is_processed': is_processed,
      'watched_movie': watched_movie,
      'watch_progress': watch_progress,
      'watch_status': watch_status,
      'liked_movie': watch_status,
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
        ",title TEXT"
        ",external_url TEXT"
        ",url TEXT"
        ",image_url TEXT"
        ",thumbnail_url TEXT"
        ",description TEXT"
        ",year TEXT"
        ",rating TEXT"
        ",duration TEXT"
        ",size TEXT"
        ",genre TEXT"
        ",director TEXT"
        ",stars TEXT"
        ",country TEXT"
        ",language TEXT"
        ",imdb_url TEXT"
        ",imdb_rating TEXT"
        ",imdb_votes TEXT"
        ",imdb_id TEXT"
        ",imdb_text TEXT"
        ",type TEXT"
        ",status TEXT"
        ",error TEXT"
        ",error_message TEXT"
        ",downloads_count TEXT"
        ",views_count TEXT"
        ",likes_count TEXT"
        ",dislikes_count TEXT"
        ",comments_count TEXT"
        ",comments TEXT"
        ",video_is_downloaded_to_server TEXT"
        ",video_downloaded_to_server_start_time TEXT"
        ",video_downloaded_to_server_end_time TEXT"
        ",video_downloaded_to_server_duration TEXT"
        ",video_is_downloaded_to_server_status TEXT"
        ",video_is_downloaded_to_server_error_message TEXT"
        ",category TEXT"
        ",category_id TEXT"
        ",category_text TEXT"
        ",is_processed TEXT"
        ",watched_movie TEXT"
        ",watch_progress TEXT"
        ",watch_status TEXT"
        ",liked_movie TEXT"
        ",max_progress TEXT"
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

  //submit view progress
  Future submitViewProgress(
    int progress,
    int maxProgress, {
    status = 'Active',
  }) async {
    RespondModel resp = RespondModel(
      await Utils.http_post('save-view-progress', {
        'movie_id': id.toString(),
        'progress': progress.toString(),
        'max_progress': maxProgress.toString(),
        'status': status,
      }),
    );

    if (resp.code != 1) {
      Utils.toast(resp.message);
      return;
    }

    //print("==> ${resp.data} <==");
    //Utils.toast(resp.message);
  }

  static deleteAll() async {
    if (!(await MovieModel.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(MovieModel.tableName);
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
    } catch (e) {
      Utils.toast("Failed to save student because ${e.toString()}");
    }
  }
}
