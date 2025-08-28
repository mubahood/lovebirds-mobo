import 'package:sqflite/sqflite.dart';

import '../utils/Utilities.dart';

class MyRole {
  static String end_point = "my-roles";
  static String tableName = "my_roles";
  int role_id = 0;
  String role_name = "";
  String slug = "";

  static fromJson(dynamic m) {
    MyRole obj = MyRole();
    if (m == null) {
      return obj;
    }

    obj.role_id = Utils.int_parse(m['role_id']);
    obj.role_name = Utils.to_str(m['role_name'], '');
    obj.slug = Utils.to_str(m['slug'], '');

    return obj;
  }

  static Future<List<MyRole>> getLocalData() async {
    List<MyRole> data = [];
    if (!(await MyRole.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps = await db.query(tableName);

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(MyRole.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<MyRole>> get_items() async {
    List<MyRole> data = await getLocalData();
    if (data.isEmpty) {
      await MyRole.getOnlineItems();
      data = await getLocalData();
    } else {
      MyRole.getOnlineItems();
    }
    return data;
  }

  static Future<List<MyRole>> getOnlineItems() async {
    List<MyRole> data = [];
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
    return {'role_id': role_id, 'role_name': role_name, 'slug': slug};
  }

  static Future initTable() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }

    String sql =
        " CREATE TABLE IF NOT EXISTS "
        "$tableName ("
        "role_id INTEGER PRIMARY KEY"
        ",role_name TEXT"
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
    if (!(await MyRole.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(MyRole.tableName);
  }

  delete() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return;
    }

    await initTable();

    try {
      await db.delete(tableName, where: 'role_id = $role_id');
    } catch (e) {
      Utils.toast("Failed to save student because ${e.toString()}");
    }
  }
}
