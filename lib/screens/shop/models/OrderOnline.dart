import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/RespondModel.dart';
import '../../../utils/AppConfig.dart';
import '../../../utils/Utilities.dart';


class OrderOnline {
  static String end_point = "orders";
  static String table_name = "orders_online_3";
  int id = 0;
  String created_at = "";
  String updated_at = "";
  String user = "";
  String order_state = "";
  String amount = "";
  String date_created = "";
  String payment_confirmation = "";
  String date_updated = "";
  String mail = "";
  String delivery_district = "";
  String temporary_id = "";
  String temporary_text = "";
  String description = "";
  String customer_name = "";
  String customer_phone_number_1 = "";
  String customer_phone_number_2 = "";
  String customer_address = "";
  String order_total = "";
  String order_details = "";
  String stripe_id = "";
  String stripe_text = "";
  String stripe_url = "";
  String stripe_paid = "";

  String delivery_method = "";
  String delivery_address_id = "";
  String delivery_address_text = "";
  String delivery_address_details = "";
  String delivery_amount = "";
  String payable_amount = "";
  String items_text = "";
  String items = "";

  List<Widget> cartItemsObjects = [];

  //getter for 13% tax
  String getTax(String xx) {
    return (Utils.int_parse(xx) * 0.13).toString();
  }

  bool isPaid() {
    return payment_confirmation.toUpperCase() == "PAID";
  }

  //get order status
  String getPaymentLink() {
    return stripe_url;
  }

  String getOrderStatus() {
    String status = "Pending";
    if (order_state == "0") {
      status = "Pending";
    } else if (order_state == "1") {
      status = "Processing";
    } else if (order_state == "2") {
      status = "Completed";
    } else if (order_state == "3") {
      status = "Canceled";
    } else if (order_state == "4") {
      status = "Failed";
    }
    return status;
  }

  get_items_text() {
    items_text = "-";
    if (items.isEmpty) {
      return items_text;
    }
    var data;
    try {
      data = json.decode(items);
    } catch (e) {
      return items_text;
    }

    if (data == null) {
      return items_text;
    }
    cartItemsObjects.clear();
    int i = 0;
    if (data.runtimeType.toString().contains('List')) {
      items_text = "";
      for (var x in data) {
        i++;
        items_text +=
        "$i. ${Utils.shotten(x['product_name'].toString(), 25)}    (x ${x['qty']})\n";
        cartItemsObjects.addAll([
          Row(
            children: <Widget>[
              Container(width: 65),
              Text("$i. ${Utils.shotten(x['product_name'].toString(), 25)}"),
              const Spacer(),
              Text(
                  "${AppConfig.CURRENCY}${Utils.moneyFormat(x['product_price_1'].toString())}"),
              Container(width: 20),
            ],
          ),
          Container(height: 5)
        ]);
      }
    }

    return items_text;
  }

  Future<OrderOnline> getOrder() async {
    RespondModel resp =
    RespondModel(await Utils.http_get('order', {'id': id.toString()}));

    if (resp.code != 1) {
      Utils.toast("Failed to fetch order because ${resp.message}");
      return this;
    }
    OrderOnline tempOrder = OrderOnline.fromJson(resp.data);
    if (tempOrder.id < 1) {
      Utils.toast("Failed to parse order because ${resp.message}");
      return this;
    }
    await tempOrder.save();

    return tempOrder;
  }

  static fromJson(dynamic m) {
    OrderOnline obj = OrderOnline();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.user = Utils.to_str(m['user'], '');
    obj.order_state = Utils.to_str(m['order_state'], '');
    obj.amount = Utils.to_str(m['amount'], '');
    obj.date_created = Utils.to_str(m['date_created'], '');
    obj.payment_confirmation = Utils.to_str(m['payment_confirmation'], '');
    obj.date_updated = Utils.to_str(m['date_updated'], '');
    obj.mail = Utils.to_str(m['mail'], '');
    obj.delivery_district = Utils.to_str(m['delivery_district'], '');
    obj.temporary_id = Utils.to_str(m['temporary_id'], '');
    obj.temporary_text = Utils.to_str(m['temporary_text'], '');
    obj.description = Utils.to_str(m['description'], '');
    obj.customer_name = Utils.to_str(m['customer_name'], '');
    obj.customer_phone_number_1 =
        Utils.to_str(m['customer_phone_number_1'], '');
    obj.customer_phone_number_2 =
        Utils.to_str(m['customer_phone_number_2'], '');
    obj.customer_address = Utils.to_str(m['customer_address'], '');
    obj.order_total = Utils.to_str(m['order_total'], '');
    obj.order_details = Utils.to_str(m['order_details'], '');
    obj.stripe_id = Utils.to_str(m['stripe_id'], '');
    obj.stripe_text = Utils.to_str(m['stripe_text'], '');
    obj.stripe_url = Utils.to_str(m['stripe_url'], '');
    obj.stripe_paid = Utils.to_str(m['stripe_paid'], '');

    obj.delivery_method = Utils.to_str(m['delivery_method'], '');
    obj.delivery_address_id = Utils.to_str(m['delivery_address_id'], '');
    obj.delivery_address_text = Utils.to_str(m['delivery_address_text'], '');
    obj.delivery_address_details =
        Utils.to_str(m['delivery_address_details'], '');
    obj.delivery_amount = Utils.to_str(m['delivery_amount'], '');
    obj.payable_amount = Utils.to_str(m['payable_amount'], '');
    obj.items = Utils.to_str(m['items'], '');

    return obj;
  }

  static Future<List<OrderOnline>> getLocalData({String where = "1"}) async {
    List<OrderOnline> data = [];
    if (!(await OrderOnline.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps =
    await db.query(table_name, where: where, orderBy: ' id DESC ');

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(OrderOnline.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<OrderOnline>> getItems({String where = '1'}) async {
    List<OrderOnline> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await OrderOnline.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      OrderOnline.getOnlineItems();
    }
    return data;
  }

  static Future<List<OrderOnline>> getOnlineItems() async {
    List<OrderOnline> data = [];

    RespondModel resp =
    RespondModel(await Utils.http_get(OrderOnline.end_point, {}));

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
        await OrderOnline.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          OrderOnline sub = OrderOnline.fromJson(x);
          try {
            batch.insert(table_name, sub.toJson(),
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
        table_name,
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
      'user': user,
      'order_state': order_state,
      'amount': amount,
      'date_created': date_created,
      'payment_confirmation': payment_confirmation,
      'date_updated': date_updated,
      'mail': mail,
      'items': items,
      'delivery_district': delivery_district,
      'temporary_id': temporary_id,
      'temporary_text': temporary_text,
      'description': description,
      'customer_name': customer_name,
      'customer_phone_number_1': customer_phone_number_1,
      'customer_phone_number_2': customer_phone_number_2,
      'customer_address': customer_address,
      'order_total': order_total,
      'order_details': order_details,
      'stripe_id': stripe_id,
      'stripe_text': stripe_text,
      'stripe_url': stripe_url,
      'stripe_paid': stripe_paid,
      'delivery_method': delivery_method,
      'delivery_address_id': delivery_address_id,
      'delivery_address_text': delivery_address_text,
      'delivery_address_details': delivery_address_details,
      'delivery_amount': delivery_amount,
      'payable_amount': payable_amount,
    };
  }

  static Future initTable() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }

    String sql = " CREATE TABLE IF NOT EXISTS "
        "$table_name ("
        "id INTEGER PRIMARY KEY"
        ",created_at TEXT"
        ",updated_at TEXT"
        ",user TEXT"
        ",order_state TEXT"
        ",amount TEXT"
        ",date_created TEXT"
        ",payment_confirmation TEXT"
        ",date_updated TEXT"
        ",mail TEXT"
        ",delivery_district TEXT"
        ",temporary_id TEXT"
        ",temporary_text TEXT"
        ",description TEXT"
        ",customer_name TEXT"
        ",customer_phone_number_1 TEXT"
        ",customer_phone_number_2 TEXT"
        ",customer_address TEXT"
        ",order_total TEXT"
        ",items TEXT"
        ",order_details TEXT"
        ",stripe_id TEXT"
        ",stripe_text TEXT"
        ",stripe_url TEXT"
        ",stripe_paid TEXT"
        ",delivery_method TEXT"
        ",delivery_address_id TEXT"
        ",delivery_address_text TEXT"
        ",delivery_address_details TEXT"
        ",delivery_amount TEXT"
        ",payable_amount TEXT"
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
    if (!(await OrderOnline.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(OrderOnline.table_name);
  }

  delete() async {
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      Utils.toast("Failed to init local store.");
      return;
    }

    await initTable();

    try {
      await db.delete(table_name, where: 'id = $id');
    } catch (e) {
      Utils.toast("Failed to save student because ${e.toString()}");
    }
  }
}