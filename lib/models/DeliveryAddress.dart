import 'package:sqflite/sqflite.dart';

import '../utils/Utilities.dart';
import 'RespondModel.dart';

class DeliveryAddress {
  static String end_point = "delivery-addresses";
  static String tableName = "delivery_addresses";
  int id = 0;
  String created_at = "";
  String updated_at = "";
  String address = "";
  String latitude = "";
  String longitude = "";
  String shipping_cost = "";

  static fromJson(dynamic m) {
    DeliveryAddress obj = DeliveryAddress();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.address = Utils.to_str(m['address'], '');
    obj.latitude = Utils.to_str(m['latitude'], '');
    obj.longitude = Utils.to_str(m['longitude'], '');
    obj.shipping_cost = Utils.to_str(m['shipping_cost'], '');

    return obj;
  }

  static Future<List<DeliveryAddress>> getLocalData({
    String where = "1",
  }) async {
    List<DeliveryAddress> data = [];
    if (!(await DeliveryAddress.initTable())) {
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
      orderBy: ' address ASC ',
    );

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(DeliveryAddress.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<DeliveryAddress>> get_items({String where = '1'}) async {
    List<DeliveryAddress> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await DeliveryAddress.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      DeliveryAddress.getOnlineItems();
    }
    return data;
  }

  static Future<List<DeliveryAddress>> getOnlineItems() async {
    List<DeliveryAddress> data = [];

    RespondModel resp = RespondModel(
      await Utils.http_get(DeliveryAddress.end_point, {}),
    );

    if (resp.code != 1) {
      Utils.toast("Failed ${resp.message}");
      return [];
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return [];
    }

    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        await DeliveryAddress.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          DeliveryAddress sub = DeliveryAddress.fromJson(x);

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
          print("failed to save to commit BRECCIAS == ${e.toString()}");
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
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'shipping_cost': shipping_cost,
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
        ",address TEXT"
        ",latitude TEXT"
        ",longitude TEXT"
        ",shipping_cost TEXT"
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
    if (!(await DeliveryAddress.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(DeliveryAddress.tableName);
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
