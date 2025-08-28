import 'package:sqflite/sqflite.dart';

import '../../../models/LoggedInUserModel.dart';
import '../../../models/RespondModel.dart';
import '../../../utils/Utilities.dart';

class ChatMessage {
  static String end_point = "chat-messages";
  static String tableName = "chat_messages";
  int id = 0;
  String created_at = "";
  String updated_at = "";
  String chat_head_id = "";
  String chat_head_text = "";
  String sender_id = "";
  String sender_text = "";
  String receiver_id = "";
  String receiver_text = "";
  String sender_name = "";
  String sender_photo = "";
  String receiver_name = "";
  String receiver_photo = "";
  String body = "";
  String type = "";
  String status = "unsent";
  String audio = "";
  String video = "";
  String product_id = "";
  String document = "";
  String photo = "";
  String longitude = "";
  String latitude = "";

  bool isMyMessage = false;

  static fromJson(dynamic m, LoggedInUserModel u) {
    ChatMessage obj = ChatMessage();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.chat_head_id = Utils.to_str(m['chat_head_id'], '');
    obj.chat_head_text = Utils.to_str(m['chat_head_text'], '');
    obj.sender_id = Utils.to_str(m['sender_id'], '');
    obj.sender_text = Utils.to_str(m['sender_text'], '');
    obj.receiver_id = Utils.to_str(m['receiver_id'], '');
    obj.receiver_text = Utils.to_str(m['receiver_text'], '');
    obj.sender_name = Utils.to_str(m['sender_name'], '');
    obj.sender_photo = Utils.to_str(m['sender_photo'], '');
    obj.receiver_name = Utils.to_str(m['receiver_name'], '');
    obj.receiver_photo = Utils.to_str(m['receiver_photo'], '');
    obj.body = Utils.to_str(m['body'], '');
    obj.type = Utils.to_str(m['type'], '');
    obj.status = Utils.to_str(m['status'], '');
    obj.audio = Utils.to_str(m['audio'], '');
    obj.video = Utils.to_str(m['video'], '');
    obj.product_id = Utils.to_str(m['product_id'], '');
    obj.document = Utils.to_str(m['document'], '');
    obj.photo = Utils.to_str(m['photo'], '');
    obj.longitude = Utils.to_str(m['longitude'], '');
    obj.latitude = Utils.to_str(m['latitude'], '');
    obj.isMyMessage = u.id.toString() == obj.sender_id.toString();

    return obj;
  }

  static Future<List<ChatMessage>> getLocalData(
    LoggedInUserModel u, {
    String where = "1",
  }) async {
    List<ChatMessage> data = [];
    if (!(await ChatMessage.initTable())) {
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
      data.add(ChatMessage.fromJson(maps[i], u));
    });

    return data;
  }

  static Future<List<ChatMessage>> get_items(
    LoggedInUserModel u, {
    String where = '1',
  }) async {
    List<ChatMessage> data = await getLocalData(where: where, u);
    if (data.isEmpty) {
      await ChatMessage.getOnlineItems(u, params: {'doDeleteAll': false});
      data = await getLocalData(where: where, u);
    } else {
      ChatMessage.getOnlineItems(u, params: {'doDeleteAll': false});
    }
    return data;
  }

  static Future<List<ChatMessage>> getOnlineItems(
    LoggedInUserModel u, {
    required Map<String, Object> params,
  }) async {
    List<ChatMessage> data = [];
    Map<String, dynamic> params = {};
    bool doDeleteAll = false;
    if (params['doDeleteAll'] != null) {
      if (params['doDeleteAll'] == true) {
        doDeleteAll = true;
      }
    }
    RespondModel resp = RespondModel(
      await Utils.http_get(ChatMessage.end_point, params),
    );

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
        if (!doDeleteAll) {
          await ChatMessage.deleteAll();
        } else {}
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          ChatMessage sub = ChatMessage.fromJson(x, u);
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
      'chat_head_id': chat_head_id,
      'chat_head_text': chat_head_text,
      'sender_id': sender_id,
      'sender_text': sender_text,
      'receiver_id': receiver_id,
      'receiver_text': receiver_text,
      'sender_name': sender_name,
      'sender_photo': sender_photo,
      'receiver_name': receiver_name,
      'receiver_photo': receiver_photo,
      'body': body,
      'type': type,
      'status': status,
      'audio': audio,
      'video': video,
      'product_id': product_id,
      'document': document,
      'photo': photo,
      'longitude': longitude,
      'latitude': latitude,
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
        ",chat_head_id TEXT"
        ",chat_head_text TEXT"
        ",sender_id TEXT"
        ",sender_text TEXT"
        ",receiver_id TEXT"
        ",receiver_text TEXT"
        ",sender_name TEXT"
        ",sender_photo TEXT"
        ",receiver_name TEXT"
        ",receiver_photo TEXT"
        ",body TEXT"
        ",type TEXT"
        ",status TEXT"
        ",audio TEXT"
        ",video TEXT"
        ",product_id TEXT"
        ",document TEXT"
        ",photo TEXT"
        ",longitude TEXT"
        ",latitude TEXT"
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
    if (!(await ChatMessage.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(ChatMessage.tableName);
  }

  static Future<void> deleteForHead({required String where}) async {
    if (!(await ChatMessage.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return;
    }
    await db.delete(ChatMessage.tableName, where: where);
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

  Future<String> uploadSelf(LoggedInUserModel u) async {
    String answer = "";

    if (await Utils.is_connected()) {
      RespondModel resp = RespondModel(
        await Utils.http_post('chat-send', toJson()),
      );

      if (resp.code != 1) {
        answer = resp.message;
        return answer;
      }
      delete();
      answer = "";
      ChatMessage newMsg = ChatMessage.fromJson(resp.data, u);
      await newMsg.save();
    } else {
      answer = "You are offline.";
    }

    return answer;
  }
}
