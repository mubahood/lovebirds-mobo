import 'package:sqflite/sqflite.dart';

import '../utils/Utilities.dart';
import 'RespondModel.dart';

class LocationModel {
  static String end_point = "locations";
  String id = '';
  String country_id = "";
  String country_text = "";
  String name = "";
  String parent_id = "";
  String parent_text = "";
  String longitude = "";
  String latitude = "";
  String created_at = "";
  String updated_at = "";

  static fromJson(dynamic m) {
    LocationModel obj = LocationModel();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.to_str(m['id'], '');
    obj.country_id = Utils.to_str(m['country_id'], '');
    obj.country_text = Utils.to_str(m['country_text'], '');
    obj.name = Utils.to_str(m['name'], '');
    obj.parent_id = Utils.to_str(m['parent_id'], '');
    obj.parent_text = Utils.to_str(m['parent_text'], '');
    obj.longitude = Utils.to_str(m['longitude'], '');
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');

    return obj;
  }

  static Future<List<LocationModel>> getLocalData({String where = "1"}) async {
    List<LocationModel> data = [];
    if (!(await LocationModel.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps =
        await db.query('locations_1', where: where, orderBy: ' id DESC ');

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(LocationModel.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<LocationModel>> get_items({String where = '1'}) async {
    List<LocationModel> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await LocationModel.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      LocationModel.getOnlineItems();
    }
    return data;
  }

  static Future<List<LocationModel>> getOnlineItems() async {
    List<LocationModel> data = [];

    RespondModel resp =
        RespondModel(await Utils.http_get(LocationModel.end_point, {}));

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
        await LocationModel.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          LocationModel sub = LocationModel.fromJson(x);
          try {
            batch.insert('locations_1', sub.toJson(),
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
        'locations_1',
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
      'country_id': country_id,
      'country_text': country_text,
      'name': name,
      'parent_id': parent_id,
      'parent_text': parent_text,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  static Future initTable() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }

    String sql = " CREATE TABLE IF NOT EXISTS "
        "locations_1 ("
        "id TEXT PRIMARY KEY"
        ",country_id TEXT"
        ",country_text TEXT"
        ",name TEXT"
        ",parent_id TEXT"
        ",parent_text TEXT"
        ",longitude TEXT"
        ",latitude TEXT"
        ",created_at TEXT"
        ",updated_at TEXT"
        ")";

    try {
      //await db.execute("DROP TABLE ${tableName1}");
      await db.execute(sql);
    } catch (e) {
      Utils.log('Failed to create table because ${e.toString()}');

      return false;
    }

    return true;
  }

  static deleteAll() async {
    if (!(await LocationModel.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete('locations_1');
  }

  delete() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return;
    }

    await initTable();

    try {
      await db.delete('locations_1', where: 'id = $id');
    } catch (e) {
      Utils.toast("Failed to save student because ${e.toString()}");
    }
  }
}
