import 'package:sqflite/sqflite.dart';

import '../utils/AppConfig.dart';
import '../utils/Utilities.dart';
import 'RespondModel.dart';

class SeriesModel {
  static String end_point = "api/SeriesMovie";
  static String tableName = "series_movies";
  int id = 0;
  String created_at = "";
  String updated_at = "";
  String title = "";
  String Category = "";
  String description = "";
  String thumbnail = "";
  String total_seasons = "";
  String total_episodes = "";
  String total_views = "";
  String total_rating = "";
  String image_url = "";

  String getThumbnail() {
    //print("==> ${AppConfig.STORAGE_URL + thumbnail_url} <==");
    if (thumbnail.length > 3) {
      return AppConfig.STORAGE_URL + thumbnail;
    }
    return image_url;
  }

  static fromJson(dynamic m) {
    SeriesModel obj = SeriesModel();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.title = Utils.to_str(m['title'], '');
    obj.Category = Utils.to_str(m['Category'], '');
    obj.description = Utils.to_str(m['description'], '');
    obj.thumbnail = Utils.to_str(m['thumbnail'], '');
    obj.total_seasons = Utils.to_str(m['total_seasons'], '');
    obj.total_episodes = Utils.to_str(m['total_episodes'], '');
    obj.total_views = Utils.to_str(m['total_views'], '');
    obj.total_rating = Utils.to_str(m['total_rating'], '');
    obj.getThumbnail();

    return obj;
  }

  static Future<List<SeriesModel>> getLocalData({String where = "1"}) async {
    List<SeriesModel> data = [];
    if (!(await SeriesModel.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps =
        await db.query(tableName, where: where, orderBy: ' id DESC ');

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(SeriesModel.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<SeriesModel>> get_items({String where = '1'}) async {
    //await SeriesModel.deleteAll();
    List<SeriesModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await SeriesModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      SeriesModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<SeriesModel>> getOnlineItems() async {
    List<SeriesModel> data = [];

    RespondModel resp =
        RespondModel(await Utils.http_get(SeriesModel.end_point, {}));

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
        await SeriesModel.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          SeriesModel sub = SeriesModel.fromJson(x);
          try {
            batch.insert(tableName, sub.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace);
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
      'Category': Category,
      'description': description,
      'thumbnail': thumbnail,
      'total_seasons': total_seasons,
      'total_episodes': total_episodes,
      'total_views': total_views,
      'total_rating': total_rating,
    };
  }

  static Future initTable() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }

    String sql = " CREATE TABLE IF NOT EXISTS "
        "$tableName ("
        "id INTEGER PRIMARY KEY"
        ",created_at TEXT"
        ",updated_at TEXT"
        ",title TEXT"
        ",Category TEXT"
        ",description TEXT"
        ",thumbnail TEXT"
        ",total_seasons TEXT"
        ",total_episodes TEXT"
        ",total_views TEXT"
        ",total_rating TEXT"
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
    if (!(await SeriesModel.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(SeriesModel.tableName);
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
