import 'package:sqflite/sqflite.dart';

import '../../../models/RespondModel.dart';
import '../../../utils/Utilities.dart';


class ProductCategory {
  static String endPoint = "api/ProductCategory";
  static String tableName = "ProductCategory";

  int id = 0;
  String category = "";
  String image = "";
  String image_origin = "";
  String banner_image = "";
  String show_in_banner = "";
  String show_in_categories = "";
  String attributes = "";
  List<String> attributesList = [];

  Map<String, String> attributesData = {};

  getAttributesList() {
    if (attributes.isEmpty) {
      attributesList = [];
      return [];
    }
    try {
      attributesList = [];
      attributes = attributes.replaceAll('"', '');
      attributes = attributes.replaceAll('[', '');
      attributes = attributes.replaceAll(']', '');
      List<String> temp = attributes.split(",");
      for (var element in temp) {
        attributesList.add(element.toString());
      }
    } catch (e) {
      attributesList = [];
    }
  }

  static fromJson(dynamic m) {
    ProductCategory obj = ProductCategory();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.category = Utils.to_str(m['category'], '');
    obj.image = Utils.to_str(m['image'], '');
    obj.image_origin = Utils.to_str(m['image_origin'], '');
    obj.banner_image = Utils.to_str(m['banner_image'], '');
    obj.show_in_banner = Utils.to_str(m['show_in_banner'], '');
    obj.show_in_categories = Utils.to_str(m['show_in_categories'], '');
    obj.attributes = Utils.to_str(m['attributes'], '');
    print(obj.image);
    obj.getAttributesList();
    return obj;
  }

  static Future<List<ProductCategory>> getLocalData(
      {String where = "1"}) async {
    List<ProductCategory> data = [];
    if (!(await ProductCategory.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps = await db.query(ProductCategory.tableName, where: where);

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(ProductCategory.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<ProductCategory>> getItems({String where = '1'}) async {
    List<ProductCategory> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await ProductCategory.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      data = await getLocalData(where: where);
      ProductCategory.getOnlineItems();
    }
    data.sort((b, a) => b.id.compareTo(a.id));
    return data;
  }

  static Future<List<ProductCategory>> getOnlineItems() async {
    List<ProductCategory> data = [];

    RespondModel resp = RespondModel(
        await Utils.http_get(ProductCategory.endPoint, {'is_not_private': 1}));

    print("=============");
    print(resp.code.toString());
    print(resp.data.toString());
    print(resp.message.toString());
    print("=============");

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
        await ProductCategory.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          ProductCategory sub = ProductCategory.fromJson(x);
          try {
            batch.insert(tableName, sub.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace);
          } catch (e) {}
        }

        try {
          await batch.commit(continueOnError: true);
        } catch (e) {}
      });
    }

    return [];

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
      'category': category,
      'image': image,
      'image_origin': image_origin,
      'banner_image': banner_image,
      'attributes': attributes,
      'show_in_categories': show_in_categories,
      'show_in_banner': show_in_banner,
    };
  }

  static Future<bool> initTable() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }

    String sql = "CREATE TABLE  IF NOT EXISTS  ${ProductCategory.tableName} (  "
        "id INTEGER PRIMARY KEY,"
        " category TEXT,"
        " image_origin TEXT,"
        " banner_image TEXT,"
        " show_in_categories TEXT,"
        " show_in_banner TEXT,"
        " attributes TEXT,"
        " image TEXT)";
    try {
      //await db.execute('DROP TABLE $tableName');

      await db.execute(sql);
    } catch (e) {
      Utils.log('Failed to create table because ${e.toString()}');

      return false;
    }

    return true;
  }

  static deleteAll() async {
    if (!(await ProductCategory.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(tableName);
  }
}
