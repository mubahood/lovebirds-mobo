import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lovebirds_app/utils/Utilities.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../../models/RespondModel.dart';

class ImageModelLocal {

  static String tableName = "local_images";
  int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  static String endPoint = "images-local";
  String created_at = "";
  String updated_at = "";
  String administrator_id = "";
  String media_path = "";
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
  String item_type = "";
  String note = "";
  String ready_to_upload = "";
  String local_parent_id = "";
  String online_parent_id = "";
  int updated_at_text = 0;

  Future<bool> uploadSelf() async {
    if (!(await Utils.is_connected())) {
      return false;
    }

    if(media_path.length < 2){
      media_path = src;
    }


    if (!(await File(media_path).exists())) {
      Utils.toast2("File not exist.");
      await delete();
      return true;
    }

    Map<String, dynamic> formDataMap = {};

    formDataMap['parent_id'] = parent_id;
    formDataMap['note'] = note;
    formDataMap['online_parent_id'] = online_parent_id;
    formDataMap['local_parent_id'] = local_parent_id;
    formDataMap['product_id'] = product_id;
    formDataMap['item_type'] = item_type;
    formDataMap['online_parent_id'] = online_parent_id;
    formDataMap['parent_endpoint'] = parent_endpoint;
    formDataMap['file'] =
        await MultipartFile.fromFile(media_path, filename: media_path);


    RespondModel r =
        RespondModel(await Utils.http_post('post-media-upload', formDataMap));
    if (r.code == 1) {
      //Utils.toast2(r.message);
      await delete();
      return true;
    } else {
      Utils.toast(r.message);
      return false;
    }
    return false;
  }

  static fromJson(dynamic m) {
    ImageModelLocal obj = ImageModelLocal();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.administrator_id = Utils.to_str(m['administrator_id'], '');
    obj.administrator_text = Utils.to_str(m['administrator_text'], '');
    obj.src = Utils.to_str(m['src'], '');
    obj.thumbnail = Utils.to_str(m['thumbnail'], '');
    obj.parent_id = Utils.to_str(m['parent_id'], '');
    obj.parent_text = Utils.to_str(m['parent_text'], '');
    obj.size = Utils.to_str(m['size'], '');
    obj.deleted_at = Utils.to_str(m['deleted_at'], '');
    obj.type = Utils.to_str(m['type'], '');
    obj.product_id = Utils.to_str(m['product_id'], '');
    obj.ready_to_upload = Utils.to_str(m['ready_to_upload'], '');
    obj.media_path = Utils.to_str(m['media_path'], '');
    obj.product_text = Utils.to_str(m['product_text'], '');
    obj.parent_endpoint = Utils.to_str(m['parent_endpoint'], '');
    obj.online_parent_id = Utils.to_str(m['online_parent_id'], '');
    obj.item_type = Utils.to_str(m['item_type'], '');
    obj.note = Utils.to_str(m['note'], '');
    obj.local_parent_id = Utils.to_str(m['local_parent_id'], '');
    obj.updated_at_text = Utils.int_parse(m['updated_at_text']);

    return obj;
  }

  static Future<List<ImageModelLocal>> getLocalData({String where = "1"}) async {
    List<ImageModelLocal> data = [];
    if (!(await ImageModelLocal.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps = await db.query(tableName, where: where);
    if (maps.isEmpty) {
      return data;
    }

    List.generate(maps.length, (i) {
      data.add(ImageModelLocal.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<ImageModelLocal>> getItems({String where = '1'}) async {
    return await getLocalData(where: where);

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
      'item_type': item_type,
      'ready_to_upload': ready_to_upload,
      'product_text': product_text,
      'media_path': media_path,
      'local_parent_id': local_parent_id,
      'parent_endpoint': parent_endpoint,
      'online_parent_id': online_parent_id,
      'note': note,
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
        ",updated_at_text INTEGER"
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
        ",ready_to_upload TEXT"
        ",type TEXT"
        ",product_id INTEGER"
        ",product_text TEXT"
        ",item_type TEXT"
        ",media_path TEXT"
        ",parent_endpoint TEXT"
        ",local_parent_id INTEGER"
        ",online_parent_id INTEGER"
        ",note TEXT"
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
    if (!(await ImageModelLocal.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(ImageModelLocal.tableName);
  }
}