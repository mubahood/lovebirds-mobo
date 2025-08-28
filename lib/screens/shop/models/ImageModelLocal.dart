import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/RespondModel.dart';
import '../../../utils/Utilities.dart';


class ImageModel {
  static String tableName = "images_1";
  int id = 0;
  String created_at = "";
  String updated_at = "";
  String administrator_id = "";
  String administrator_text = "";
  String src = "";
  String thumbnail = "";
  String parent_id = "";
  String parent_text = "";
  String size = "";
  String deleted_at = "";
  String type = "";
  String product_id = "";
  String product_text = "";
  String parent_endpoint = "";
  String note = "";
  String parent_local_id = "";
  int updated_at_text = 0;
  int position = 1;

  Future<bool> uploadSelf() async {
    if (parent_local_id.length < 5) {
      return false;
    }
    if (!(await Utils.is_connected())) {
      return false;
    }

    if (!(await File(src).exists())) {
      delete();
      return false;
    }

    Map<String, dynamic> formDataMap = {};

    formDataMap['parent_id'] = parent_id;
    formDataMap['note'] = note;
    formDataMap['product_id'] = product_id;
    formDataMap['parent_endpoint'] = parent_endpoint;
    formDataMap['parent_local_id'] = parent_local_id;
    formDataMap['file'] = await MultipartFile.fromFile(src, filename: src);

    RespondModel r =
    RespondModel(await Utils.http_post('post-media-upload', formDataMap));


    if (r.code == 1) {
      await delete();
      return true;
    } else {
      Utils.toast(r.message);
      Utils.toast("FAILED TO UPLOAD PHOTO");
      return false;
    }
    return false;
  }

  static List<ImageModel> fromJsonList(String m) {
    List<ImageModel> data = [];

    if (m.isNotEmpty) {
      try {
        int counter = 1;
        for (var x in jsonDecode(m)) {
          ImageModel obj = ImageModel.fromJson(x);
          counter++;
          obj.position = counter;
          data.add(obj);
        }
      } catch (e) {
        data = [];
      }
    }
    return data;
  }

  static fromJson(dynamic m) {
    ImageModel obj = ImageModel();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.administrator_id = Utils.to_str(m['administrator_id'], '');
    obj.administrator_text = Utils.to_str(m['administrator_text'], '');
    obj.src = Utils.to_str(m['src'], '');
    obj.thumbnail = Utils.to_str(m['src'], '');
    obj.parent_id = Utils.to_str(m['parent_id'], '');
    obj.parent_text = Utils.to_str(m['parent_text'], '');
    obj.size = Utils.to_str(m['size'], '');
    obj.deleted_at = Utils.to_str(m['deleted_at'], '');
    obj.type = Utils.to_str(m['type'], '');
    obj.product_id = Utils.to_str(m['product_id'], '');
    obj.product_text = Utils.to_str(m['product_text'], '');
    obj.parent_local_id = Utils.to_str(m['parent_local_id'], '');
    obj.parent_endpoint = Utils.to_str(m['parent_endpoint'], '');
    obj.note = Utils.to_str(m['note'], '');
    obj.updated_at_text = Utils.int_parse(m['updated_at_text']);

    if (!obj.thumbnail.contains('images')) {
      obj.thumbnail = "images/${obj.src}";
    }
    if (!obj.src.contains('images')) {
      obj.src = "images/${obj.src}";
    }

    return obj;
  }

  static Future<List<ImageModel>> getLocalData({String where = "1"}) async {
    List<ImageModel> data = [];
    if (!(await ImageModel.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.dbInit();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps = await db.query(tableName,
        where: where, orderBy: ' updated_at_text DESC ');

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(ImageModel.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<ImageModel>> getItems({String where = '1'}) async {
    List<ImageModel> data = await getLocalData(where: where);
    if (data.isEmpty && where.length < 3) {
      await ImageModel.getOnlineItems();
      data = await getLocalData(where: where);
    }
    return data;
  }

  static Future<List<ImageModel>> getOnlineItems() async {
    return [];
    List<ImageModel> data = [];

    RespondModel resp = RespondModel(await Utils.http_get('', {}));

    if (resp.code != 1) {
      return [];
    }

    Database db = await Utils.dbInit();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return [];
    }

    if (resp.data.runtimeType.toString().contains('List')) {
      if (await Utils.is_connected()) {
        //await ImageModel.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          ImageModel sub = ImageModel.fromJson(x);
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
          print("faied to save to commit BRECASE ==> ${e.toString()}");
        }
      });
    }

    return data;
  }

  save() async {
    Database db = await Utils.dbInit();
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
      Utils.log("Failed to save student because ${e.toString()}");
      Utils.toast("Failed to save student because ${e.toString()}");
    }
  }

  delete() async {
    Database db = await Utils.dbInit();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return;
    }

    await initTable();

    try {
      await db.delete(tableName, where: "id = $id");
    } catch (e) {
      Utils.toast("Failed to save student because ${e.toString()}");
    }
  }

  toJson() {
    return {
      'id': id,
      'created_at': created_at,
      'updated_at': updated_at,
      'administrator_id': administrator_id,
      'administrator_text': administrator_text,
      'src': src,
      'thumbnail': thumbnail,
      'parent_id': parent_id,
      'parent_text': parent_text,
      'size': size,
      'deleted_at': deleted_at,
      'type': type,
      'product_id': product_id,
      'product_text': product_text,
      'parent_endpoint': parent_endpoint,
      'parent_local_id': parent_local_id,
      'note': note,
    };
  }

  static Future initTable() async {
    Database db = await Utils.dbInit();
    if (!db.isOpen) {
      return false;
    }

    String sql = " CREATE TABLE IF NOT EXISTS "
        "$tableName ("
        "id INTEGER AUTO_INCREMENT PRIMARY KEY"
        ",parent_local_id TEXT"
        ",created_at TEXT"
        ",updated_at TEXT"
        ",administrator_id TEXT"
        ",administrator_text TEXT"
        ",src TEXT"
        ",thumbnail TEXT"
        ",parent_id TEXT"
        ",parent_text TEXT"
        ",size TEXT"
        ",deleted_at TEXT"
        ",type TEXT"
        ",product_id TEXT"
        ",product_text TEXT"
        ",parent_endpoint TEXT"
        ",note TEXT"
        ",updated_at_text TEXT"
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
    if (!(await ImageModel.initTable())) {
      return;
    }
    Database db = await Utils.dbInit();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(ImageModel.tableName);
  }
}
