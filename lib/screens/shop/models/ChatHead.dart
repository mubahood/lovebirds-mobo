import 'package:sqflite/sqflite.dart';

import '../../../models/LoggedInUserModel.dart';
import '../../../models/RespondModel.dart';
import '../../../utils/Utilities.dart';



class ChatHead {
  static String end_point = "chat-heads";
  static String tableName = "chat_heads";
  int id = 0;
  String created_at = "";
  String updated_at = "";
  String product_id = "";
  String product_text = "";
  String product_name = "";
  String product_photo = "";
  String product_owner_id = "";
  String product_owner_text = "";
  String product_owner_name = "";
  String product_owner_photo = "";
  String product_owner_last_seen = "";
  String customer_id = "";
  String customer_text = "";
  String customer_name = "";
  String customer_photo = "";
  String customer_last_seen = "";
  String last_message_body = "";
  String last_message_time = "";
  String last_message_status = "";
  String customer_unread_messages_count ='';
  String product_owner_unread_messages_count ='';
  int myUnreadCount = 0;


  int myUnread (LoggedInUserModel u){
    if(u.id.toString() == product_owner_id){
      myUnreadCount =  Utils.int_parse(product_owner_unread_messages_count);
    }else{
      myUnreadCount =   Utils.int_parse(customer_unread_messages_count);
    }
    return myUnreadCount;
  }

  static fromJson(dynamic m) {
    ChatHead obj = ChatHead();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.product_id = Utils.to_str(m['product_id'], '');
    obj.product_text = Utils.to_str(m['product_text'], '');
    obj.product_name = Utils.to_str(m['product_name'], '');
    obj.product_photo = Utils.to_str(m['product_photo'], '');
    obj.product_owner_id = Utils.to_str(m['product_owner_id'], '');
    obj.product_owner_text = Utils.to_str(m['product_owner_text'], '');
    obj.product_owner_name = Utils.to_str(m['product_owner_name'], '');
    obj.product_owner_photo = Utils.to_str(m['product_owner_photo'], '');
    obj.product_owner_last_seen =
        Utils.to_str(m['product_owner_last_seen'], '');
    obj.customer_id = Utils.to_str(m['customer_id'], '');
    obj.customer_text = Utils.to_str(m['customer_text'], '');
    obj.customer_name = Utils.to_str(m['customer_name'], '');
    obj.customer_photo = Utils.to_str(m['customer_photo'], '');
    obj.customer_last_seen = Utils.to_str(m['customer_last_seen'], '');
    obj.last_message_body = Utils.to_str(m['last_message_body'], '');
    obj.last_message_time = Utils.to_str(m['last_message_time'], '');
    obj.last_message_status = Utils.to_str(m['last_message_status'], '');
    obj.customer_unread_messages_count = Utils.to_str(m['customer_unread_messages_count'], '');
    obj.product_owner_unread_messages_count = Utils.to_str(m['product_owner_unread_messages_count'], '');

    return obj;
  }

  static Future<List<ChatHead>> getLocalData({String where = "1"}) async {
    List<ChatHead> data = [];
    if (!(await ChatHead.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps =
        await db.query(tableName, where: where, orderBy: ' updated_at DESC ');

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(ChatHead.fromJson(maps[i]));
    });



    return data;
  }

  static Future<List<ChatHead>> get_items(LoggedInUserModel u, {String where = '1'}) async {
    List<ChatHead> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await ChatHead.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      ChatHead.getOnlineItems();
    }
    if (data.isEmpty) {

      return [];
    }
    List<ChatHead> data0 = [];
    for (var x in data) {
      x.myUnread(u);
      data0.add(x);
    }
    return data0;
  }

  static Future<List<ChatHead>> getOnlineItems() async {
    List<ChatHead> data = [];

    RespondModel resp =
        RespondModel(await Utils.http_get(ChatHead.end_point, {}));

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
        await ChatHead.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          ChatHead sub = ChatHead.fromJson(x);
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
      'created_at': created_at,
      'updated_at': updated_at,
      'product_id': product_id,
      'product_text': product_text,
      'product_name': product_name,
      'product_photo': product_photo,
      'product_owner_id': product_owner_id,
      'product_owner_text': product_owner_text,
      'product_owner_name': product_owner_name,
      'product_owner_photo': product_owner_photo,
      'product_owner_last_seen': product_owner_last_seen,
      'customer_id': customer_id,
      'customer_text': customer_text,
      'customer_name': customer_name,
      'customer_photo': customer_photo,
      'customer_last_seen': customer_last_seen,
      'last_message_body': last_message_body,
      'last_message_time': last_message_time,
      'last_message_status': last_message_status,
      'customer_unread_messages_count': customer_unread_messages_count,
      'product_owner_unread_messages_count': product_owner_unread_messages_count,
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
        ",created_at TEXT"
        ",updated_at TEXT"
        ",product_id TEXT"
        ",product_text TEXT"
        ",product_name TEXT"
        ",product_photo TEXT"
        ",product_owner_id TEXT"
        ",product_owner_text TEXT"
        ",product_owner_name TEXT"
        ",product_owner_photo TEXT"
        ",product_owner_last_seen TEXT"
        ",customer_id TEXT"
        ",customer_text TEXT"
        ",customer_name TEXT"
        ",customer_photo TEXT"
        ",customer_last_seen TEXT"
        ",last_message_body TEXT"
        ",last_message_time TEXT"
        ",last_message_status TEXT"
        ",customer_unread_messages_count TEXT"
        ",product_owner_unread_messages_count TEXT"
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
    if (!(await ChatHead.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(ChatHead.tableName);
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
