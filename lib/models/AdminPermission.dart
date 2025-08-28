import 'package:sqflite/sqflite.dart';

import '../utils/Utilities.dart';
import 'RespondModel.dart';

class AdminPermission {
  static String end_point = "permissions";
  static String tableName = "admin_permissions";
  int id = 0;
  String name = "";
  String slug = "";
  String http_method = "";
  String http_path = "";

  static fromJson(dynamic m) {
    AdminPermission obj = AdminPermission();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.name = Utils.to_str(m['name'], '');
    obj.slug = Utils.to_str(m['slug'], '');
    obj.http_method = Utils.to_str(m['http_method'], '');
    obj.http_path = Utils.to_str(m['http_path'], '');

    return obj;
  }

  static Future<List<AdminPermission>> getLocalData(
      {String where = "1"}) async {
    List<AdminPermission> data = [];
    if (!(await AdminPermission.initTable())) {
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
      data.add(AdminPermission.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<AdminPermission>> get_items({String where = '1'}) async {
    List<AdminPermission> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await AdminPermission.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      AdminPermission.getOnlineItems();
    }
    return data;
  }

  static Future<List<AdminPermission>> getOnlineItems() async {
    List<AdminPermission> data = [];

    RespondModel resp =
        RespondModel(await Utils.http_get(AdminPermission.end_point, {}));

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
        await AdminPermission.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          AdminPermission sub = AdminPermission.fromJson(x);
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
      'name': name,
      'slug': slug,
      'http_method': http_method,
      'http_path': http_path,
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
        ",name TEXT"
        ",slug TEXT"
        ",http_method TEXT"
        ",http_path TEXT"
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
    if (!(await AdminPermission.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(AdminPermission.tableName);
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
