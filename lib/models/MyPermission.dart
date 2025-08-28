import 'package:sqflite/sqflite.dart';

import '../utils/Utilities.dart';

class MyPermission {
  static String end_point = "my-permissions";
  static String tableName = "my_permissions";
  int id = 0;
  String name = "";
  String slug = "";

  static fromJson(dynamic m) {
    MyPermission obj = MyPermission();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.name = Utils.to_str(m['name'], '');
    obj.slug = Utils.to_str(m['slug'], '');

    return obj;
  }

  static Future<List<MyPermission>> getLocalData({String where = "1"}) async {
    List<MyPermission> data = [];
    if (!(await MyPermission.initTable())) {
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
      data.add(MyPermission.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<MyPermission>> get_items({String where = '1'}) async {
    List<MyPermission> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await MyPermission.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      MyPermission.getOnlineItems();
    }
    return data;
  }

  static Future<List<MyPermission>> getOnlineItems() async {
    List<MyPermission> data = [];
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
    return {'id': id, 'name': name, 'slug': slug};
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
        ",name TEXT"
        ",slug TEXT"
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
    if (!(await MyPermission.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(MyPermission.tableName);
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
