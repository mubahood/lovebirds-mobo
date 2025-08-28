import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../models/RespondModel.dart';
import '../../../utils/Utilities.dart';
import 'ImageModelLocal.dart';
import 'ProductCategory.dart';

class PriceModel {
  String id = "";
  int min_qty = 0;
  int max_qty = 0;
  String price = "";

  //from json object
  static fromJson(dynamic m) {
    PriceModel obj = PriceModel();
    if (m == null) {
      return obj;
    }
    try {
      obj.id = Utils.to_str(m['id'], '');
      obj.min_qty = Utils.int_parse(m['min_qty']);
      obj.max_qty = Utils.int_parse(m['max_qty']);
      obj.price = Utils.to_str(m['price'], '');
    } catch (e) {
      // Log the error or handle it as needed
      Utils.log('Error parsing PriceModel from JSON: ${e.toString()}');
    }
    return obj;
  }

  //from json list
  static List<PriceModel> fromJsonList(dynamic m) {
    List<PriceModel> data = [];
    if (m == null) {
      return data;
    }
    try {
      for (var x in m) {
        data.add(PriceModel.fromJson(x));
      }
    } catch (e) {
      // Log the error or handle it as needed
      Utils.log('Error parsing PriceModel from JSON: ${e.toString()}');
    }
    return data;
  }

  //to json
  toJson() {
    return {
      'id': id,
      'min_qty': min_qty,
      'max_qty': max_qty,
      'price': price,
    };
  }

  //to json list
  static List<Map<String, dynamic>> toJsonList(List<PriceModel> data) {
    List<Map<String, dynamic>> list = [];
    for (var x in data) {
      list.add(x.toJson());
    }
    return list;
  }
}

class Product {
  static String endPoint = "products-1";
  static String tableName = "products_5";

  int id = 0;
  String name = "";
  String metric = "";
  String currency = "";
  String description = "";
  String summary = "";
  String price_1 = "";
  String price_2 = "";
  String feature_photo = "";
  String rates = "";
  String date_added = "";
  String date_updated = "";
  String user = "";
  String category = "";
  String sub_category = "";
  String supplier = "";
  String url = "";
  String status = "";
  String in_stock = "";
  String keywords = "";
  String p_type = "";
  String percentate_off = "";
  String category_text = "";
  String has_colors = "";
  String colors = "";
  String has_sizes = "";
  String sizes = "";
  String local_id = "";
  List<String> colorList = [];
  List<String> sizesList = [];
  List<PriceModel> pricesList = [];

  List<ImageModel> local_photos = [];
  List<ImageModel> online_photos = [];
  ProductCategory productCategory = ProductCategory();

  //getPrices from keywords as json
  List<PriceModel> getPrices() {
    if (p_type == "No") {
      return [];
    }
    p_type = "No";
    if (keywords.length < 5) {
      return [];
    }
    var temp = null;
    try {
      temp = json.decode(keywords);
    } catch (e) {
      temp = null;
      return [];
    }

    try {
      pricesList = PriceModel.fromJsonList(temp);
    } catch (e) {
      pricesList = [];
    }

    if (pricesList.isNotEmpty) {
      p_type = "Yes";
      pricesList.sort((a, b) => a.min_qty.compareTo(b.min_qty));
    }
    return pricesList;
  }

  String get_price_text() {
    String data = "";
    if (pricesList.isNotEmpty) {
      pricesList.sort((a, b) => a.min_qty.compareTo(b.min_qty));
      for (var x in pricesList) {
        data += "${x.min_qty} - ${x.max_qty} : ${x.price}, ";
      }
    }
    return data;
  }

  List<String> getColors() {
    colorList = [];

    try {
      var temp = json.decode(colors);
      colorList = [];
      for (var key in temp) {
        colorList.add(key.toString().trim());
      }
    } catch (e) {
      colorList = [];
    }

    try {
      dynamic commaColorList = colors.split(',');
      if (commaColorList != null) {
        //if is list
        if (commaColorList is List) {
          for (var key in commaColorList) {
            String myKey = key.toString().trim();
            myKey.replaceAll(' ', '');
            myKey.replaceAll('[', '');
            myKey.replaceAll(']', '');
            myKey.replaceAll('"', '');
            myKey.replaceAll('\'', '');
            if (myKey.isNotEmpty) {
              if (!colorList.contains(myKey)) {
                colorList.add(myKey);
              }
            }
          }
        }
      }
    } catch (e) {}

    if (colorList.isNotEmpty) {
      colorList.sort((a, b) => a.compareTo(b));
      has_colors = 'Yes';
    }

    //    print("=====> ${colors} <======= ");
    return colorList;
  }

  List<String> getSizes() {
    sizesList = [];
    try {
      var temp = json.decode(sizes);
      for (var key in temp) {
        sizesList.add(key.toString().trim());
      }
    } catch (e) {
      sizesList = [];
    }

    try {
      dynamic commaColorList = sizes.split(',');
      if (commaColorList != null) {
        //if is list
        if (commaColorList is List) {
          for (var key in commaColorList) {
            String myKey = key.toString().trim();
            myKey.replaceAll(' ', '');
            myKey.replaceAll('[', '');
            myKey.replaceAll(']', '');
            myKey.replaceAll('"', '');
            myKey.replaceAll('\'', '');
            if (myKey.isNotEmpty) {
              if (!sizesList.contains(myKey)) {
                sizesList.add(myKey);
              }
            }
          }
        }
      }
    } catch (e) {}

    if (sizesList.isNotEmpty) {
      sizesList.sort((a, b) => a.compareTo(b));
      has_sizes = 'Yes';
    }

    //sort sizesList
    sizesList.sort((a, b) => a.compareTo(b));

    return sizesList;
  }

  List<Map<String, String>> attributes = [];

  getAttributes() {
    if (summary.length > 3) {
      try {
        attributes = [];
        var temp = jsonDecode(summary);
        temp.forEach((key, value) {
          attributes.add(
              {"key": key.toString().trim(), "value": value.toString().trim()});
        });
      } catch (e) {
        attributes = [];
      }
    }
  }

  getOnlinePhotos() {
    online_photos.clear();

    online_photos.addAll(ImageModel.fromJsonList(rates));
    int x = 0;
    if (online_photos.isEmpty) {
      if (feature_photo.isNotEmpty) {
        x++;
        ImageModel img = ImageModel();
        img.src = feature_photo;
        img.thumbnail = feature_photo;
        img.position = x;
        online_photos.add(img);
      }
    }
  }

  static fromJson(dynamic m) {
    Product obj = Product();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.name = Utils.to_str(m['name'], '');
    obj.metric = Utils.to_str(m['metric'], '');
    obj.currency = Utils.to_str(m['currency'], '');
    obj.description = Utils.to_str(m['description'], '');
    obj.summary = Utils.to_str(m['summary'], '');
    obj.price_1 = Utils.to_str(m['price_1'], '');
    obj.price_2 = Utils.to_str(m['price_2'], '');
    obj.feature_photo = Utils.to_str(m['feature_photo'], '');
    obj.rates = Utils.to_str(m['rates'], '');
    obj.date_added = Utils.to_str(m['date_added'], '');
    obj.date_updated = Utils.to_str(m['date_updated'], '');
    obj.user = Utils.to_str(m['user'], '');
    obj.category = Utils.to_str(m['category'], '');
    obj.sub_category = Utils.to_str(m['sub_category'], '');
    obj.supplier = Utils.to_str(m['supplier'], '');
    obj.url = Utils.to_str(m['url'], '');
    obj.status = Utils.to_str(m['status'], '');
    obj.in_stock = Utils.to_str(m['in_stock'], '');
    obj.keywords = Utils.to_str(m['keywords'], '');
    obj.p_type = Utils.to_str(m['p_type'], '');
    obj.category_text = Utils.to_str(m['category_text'], '');
    obj.has_colors = Utils.to_str(m['has_colors'], '');
    obj.colors = Utils.to_str(m['colors'], '');
    obj.has_sizes = Utils.to_str(m['has_sizes'], '');
    obj.sizes = Utils.to_str(m['sizes'], '');
    obj.local_id = Utils.to_str(m['local_id'], '');
    obj.getPrices();

    int p1 = Utils.int_parse(obj.price_1);
    int p2 = Utils.int_parse(obj.price_2);
    if (p1 > 0 && p2 > 0) {
      obj.percentate_off = ((p1 - p2) / p1 * 100).toStringAsFixed(0);
    } else {
      obj.percentate_off = "";
    }

    if (!obj.feature_photo.contains('images')) {
      obj.feature_photo = "images/${obj.feature_photo}";
    }
    try {
      obj.getAttributes();
    } catch (e) {
      obj.attributes = [];
    }
    try {
      obj.getColors();
    } catch (e) {
      obj.colorList = [];
    }
    try {
      obj.getSizes();
    } catch (e) {
      obj.sizesList = [];
    }

    return obj;
  }

  static Future<List<Product>> getLocalData({String where = "1"}) async {
    List<Product> data = [];
    if (!(await Product.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.dbInit();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps = await db.query(Product.tableName, where: where);

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(Product.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<Product>> getItems({String where = '1'}) async {
    List<Product> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await Product.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      data = await getLocalData(where: where);
      Product.getOnlineItems();
    }
    data.sort((a, b) => b.id.compareTo(a.id));
    return data;
  }

  //function to delete the current product
  static Future<void> deleteProduct(int id) async {
    Database db = await Utils.dbInit();
    if (!db.isOpen) {
      return;
    }
    await db.delete(tableName, where: 'id = $id');
  }

  static Future<List<Product>> getOnlineItems() async {
    List<Product> data = [];

    RespondModel resp =
    RespondModel(await Utils.http_get(Product.endPoint, {}));

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
        await Product.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          Product sub = Product.fromJson(x);
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
      Utils.toast("Failed to save student because ${e.toString()}");
    }
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'metric': metric,
      'currency': currency,
      'description': description,
      'summary': summary,
      'price_1': price_1,
      'price_2': price_2,
      'feature_photo': feature_photo,
      'rates': rates,
      'date_added': date_added,
      'date_updated': date_updated,
      'user': user,
      'category': category,
      'sub_category': sub_category,
      'supplier': supplier,
      'url': url,
      'status': status,
      'in_stock': in_stock,
      'keywords': keywords,
      'p_type': p_type,
      'category_text': category_text,
      'has_colors': has_colors,
      'colors': colors,
      'has_sizes': has_sizes,
      'sizes': sizes,
      'local_id': local_id,
    };
  }

  static Future<bool> initTable() async {
    Database db = await Utils.dbInit();
    if (!db.isOpen) {
      return false;
    }

    String sql = "CREATE TABLE  IF NOT EXISTS  ${Product.tableName} (  "
        "id INTEGER PRIMARY KEY,"
        " name TEXT,"
        " metric TEXT,"
        " currency TEXT,"
        " description TEXT,"
        " summary TEXT,"
        " price_1 TEXT,"
        " price_2 TEXT,"
        " feature_photo TEXT,"
        " rates TEXT,"
        " date_added TEXT,"
        " date_updated TEXT,"
        " user TEXT,"
        " category TEXT,"
        " sub_category TEXT,"
        " supplier TEXT,"
        " url TEXT,"
        " status TEXT,"
        " in_stock TEXT,"
        " keywords TEXT,"
        " category_text TEXT,"
        " has_colors TEXT,"
        " colors TEXT,"
        " has_sizes TEXT,"
        " sizes TEXT,"
        " local_id TEXT,"
        " p_type TEXT)";
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
    if (!(await Product.initTable())) {
      return;
    }
    Database db = await Utils.dbInit();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(tableName);
  }
}
