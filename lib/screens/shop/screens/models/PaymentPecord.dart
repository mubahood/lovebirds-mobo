import 'package:sqflite/sqflite.dart';

import '../../../../models/RespondModel.dart';
import '../../../../utils/Utilities.dart';

class PaymentRecord {
  static String end_point = "payment-records";
  static String tableName = "payment_records";
  int id = 0;
  String created_at = "";
  String updated_at = "";
  String consultation_id = "";
  String consultation_text = "";
  String description = "";
  String amount_payable = "";
  String amount_paid = "";
  String balance = "";
  String payment_date = "";
  String payment_time = "";
  String payment_method = "";
  String payment_reference = "";
  String payment_status = "";
  String payment_remarks = "";
  String payment_phone_number = "";
  String payment_channel = "";
  String cash_received_by_id = "";
  String cash_received_by_text = "";
  String created_by_id = "";
  String created_by_text = "";
  String cash_receipt_number = "";
  String card_id = "";
  String card_text = "";
  String company_id = "";
  String company_text = "";
  String card_number = "";
  String card_type = "";
  String flutterwave_reference = "";
  String flutterwave_payment_type = "";
  String flutterwave_payment_status = "";
  String flutterwave_payment_message = "";
  String flutterwave_payment_code = "";
  String flutterwave_payment_data = "";
  String flutterwave_payment_link = "";
  String flutterwave_payment_amount = "";
  String flutterwave_payment_customer_name = "";
  String flutterwave_payment_customer_id = "";
  String flutterwave_payment_customer_text = "";
  String flutterwave_payment_customer_email = "";
  String flutterwave_payment_customer_phone_number = "";
  String flutterwave_payment_customer_full_name = "";
  String flutterwave_payment_customer_created_at = "";

  static fromJson(dynamic m) {
    PaymentRecord obj = PaymentRecord();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.created_at = Utils.to_str(m['created_at'], '');
    obj.updated_at = Utils.to_str(m['updated_at'], '');
    obj.consultation_id = Utils.to_str(m['consultation_id'], '');
    obj.consultation_text = Utils.to_str(m['consultation_text'], '');
    obj.description = Utils.to_str(m['description'], '');
    obj.amount_payable = Utils.to_str(m['amount_payable'], '');
    obj.amount_paid = Utils.to_str(m['amount_paid'], '');
    obj.balance = Utils.to_str(m['balance'], '');
    obj.payment_date = Utils.to_str(m['payment_date'], '');
    obj.payment_time = Utils.to_str(m['payment_time'], '');
    obj.payment_method = Utils.to_str(m['payment_method'], '');
    obj.payment_reference = Utils.to_str(m['payment_reference'], '');
    obj.payment_status = Utils.to_str(m['payment_status'], '');
    obj.payment_remarks = Utils.to_str(m['payment_remarks'], '');
    obj.payment_phone_number = Utils.to_str(m['payment_phone_number'], '');
    obj.payment_channel = Utils.to_str(m['payment_channel'], '');
    obj.cash_received_by_id = Utils.to_str(m['cash_received_by_id'], '');
    obj.cash_received_by_text = Utils.to_str(m['cash_received_by_text'], '');
    obj.created_by_id = Utils.to_str(m['created_by_id'], '');
    obj.created_by_text = Utils.to_str(m['created_by_text'], '');
    obj.cash_receipt_number = Utils.to_str(m['cash_receipt_number'], '');
    obj.card_id = Utils.to_str(m['card_id'], '');
    obj.card_text = Utils.to_str(m['card_text'], '');
    obj.company_id = Utils.to_str(m['company_id'], '');
    obj.company_text = Utils.to_str(m['company_text'], '');
    obj.card_number = Utils.to_str(m['card_number'], '');
    obj.card_type = Utils.to_str(m['card_type'], '');
    obj.flutterwave_reference = Utils.to_str(m['flutterwave_reference'], '');
    obj.flutterwave_payment_type =
        Utils.to_str(m['flutterwave_payment_type'], '');
    obj.flutterwave_payment_status =
        Utils.to_str(m['flutterwave_payment_status'], '');
    obj.flutterwave_payment_message =
        Utils.to_str(m['flutterwave_payment_message'], '');
    obj.flutterwave_payment_code =
        Utils.to_str(m['flutterwave_payment_code'], '');
    obj.flutterwave_payment_data =
        Utils.to_str(m['flutterwave_payment_data'], '');
    obj.flutterwave_payment_link =
        Utils.to_str(m['flutterwave_payment_link'], '');
    obj.flutterwave_payment_amount =
        Utils.to_str(m['flutterwave_payment_amount'], '');
    obj.flutterwave_payment_customer_name =
        Utils.to_str(m['flutterwave_payment_customer_name'], '');
    obj.flutterwave_payment_customer_id =
        Utils.to_str(m['flutterwave_payment_customer_id'], '');
    obj.flutterwave_payment_customer_text =
        Utils.to_str(m['flutterwave_payment_customer_text'], '');
    obj.flutterwave_payment_customer_email =
        Utils.to_str(m['flutterwave_payment_customer_email'], '');
    obj.flutterwave_payment_customer_phone_number =
        Utils.to_str(m['flutterwave_payment_customer_phone_number'], '');
    obj.flutterwave_payment_customer_full_name =
        Utils.to_str(m['flutterwave_payment_customer_full_name'], '');
    obj.flutterwave_payment_customer_created_at =
        Utils.to_str(m['flutterwave_payment_customer_created_at'], '');

    return obj;
  }

  static Future<List<PaymentRecord>> getLocalData({String where = "1"}) async {
    List<PaymentRecord> data = [];
    if (!(await PaymentRecord.initTable())) {
      Utils.toast("Failed to init dynamic store.");
      return data;
    }

    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return data;
    }

    List<Map> maps =
        await db.query(tableName, where: where, orderBy: ' id DESC ');

    if (maps.isEmpty) {
      return data;
    }
    List.generate(maps.length, (i) {
      data.add(PaymentRecord.fromJson(maps[i]));
    });

    return data;
  }

  static Future<List<PaymentRecord>> get_items({String where = '1'}) async {
    List<PaymentRecord> data = await getLocalData(where: where);
    if (data.isEmpty) {
      await PaymentRecord.getOnlineItems();
      data = await getLocalData(where: where);
    } else {
      PaymentRecord.getOnlineItems();
    }
    return data;
  }

  static Future<List<PaymentRecord>> getOnlineItems() async {
    List<PaymentRecord> data = [];

    RespondModel resp =
        RespondModel(await Utils.http_get(PaymentRecord.end_point, {
      'is_not_private': '1',
    }));

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
        await PaymentRecord.deleteAll();
      }

      await db.transaction((txn) async {
        var batch = txn.batch();

        for (var x in resp.data) {
          PaymentRecord sub = PaymentRecord.fromJson(x);
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
      Utils.toast("Failed to save because ${e.toString()}");
    }
  }

  toJson() {
    return {
      'id': id,
      'created_at': created_at,
      'updated_at': updated_at,
      'consultation_id': consultation_id,
      'consultation_text': consultation_text,
      'description': description,
      'amount_payable': amount_payable,
      'amount_paid': amount_paid,
      'balance': balance,
      'payment_date': payment_date,
      'payment_time': payment_time,
      'payment_method': payment_method,
      'payment_reference': payment_reference,
      'payment_status': payment_status,
      'payment_remarks': payment_remarks,
      'payment_phone_number': payment_phone_number,
      'payment_channel': payment_channel,
      'cash_received_by_id': cash_received_by_id,
      'cash_received_by_text': cash_received_by_text,
      'created_by_id': created_by_id,
      'created_by_text': created_by_text,
      'cash_receipt_number': cash_receipt_number,
      'card_id': card_id,
      'card_text': card_text,
      'company_id': company_id,
      'company_text': company_text,
      'card_number': card_number,
      'card_type': card_type,
      'flutterwave_reference': flutterwave_reference,
      'flutterwave_payment_type': flutterwave_payment_type,
      'flutterwave_payment_status': flutterwave_payment_status,
      'flutterwave_payment_message': flutterwave_payment_message,
      'flutterwave_payment_code': flutterwave_payment_code,
      'flutterwave_payment_data': flutterwave_payment_data,
      'flutterwave_payment_link': flutterwave_payment_link,
      'flutterwave_payment_amount': flutterwave_payment_amount,
      'flutterwave_payment_customer_name': flutterwave_payment_customer_name,
      'flutterwave_payment_customer_id': flutterwave_payment_customer_id,
      'flutterwave_payment_customer_text': flutterwave_payment_customer_text,
      'flutterwave_payment_customer_email': flutterwave_payment_customer_email,
      'flutterwave_payment_customer_phone_number':
          flutterwave_payment_customer_phone_number,
      'flutterwave_payment_customer_full_name':
          flutterwave_payment_customer_full_name,
      'flutterwave_payment_customer_created_at':
          flutterwave_payment_customer_created_at,
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
        ",consultation_id TEXT"
        ",consultation_text TEXT"
        ",description TEXT"
        ",amount_payable TEXT"
        ",amount_paid TEXT"
        ",balance TEXT"
        ",payment_date TEXT"
        ",payment_time TEXT"
        ",payment_method TEXT"
        ",payment_reference TEXT"
        ",payment_status TEXT"
        ",payment_remarks TEXT"
        ",payment_phone_number TEXT"
        ",payment_channel TEXT"
        ",cash_received_by_id TEXT"
        ",cash_received_by_text TEXT"
        ",created_by_id TEXT"
        ",created_by_text TEXT"
        ",cash_receipt_number TEXT"
        ",card_id TEXT"
        ",card_text TEXT"
        ",company_id TEXT"
        ",company_text TEXT"
        ",card_number TEXT"
        ",card_type TEXT"
        ",flutterwave_reference TEXT"
        ",flutterwave_payment_type TEXT"
        ",flutterwave_payment_status TEXT"
        ",flutterwave_payment_message TEXT"
        ",flutterwave_payment_code TEXT"
        ",flutterwave_payment_data TEXT"
        ",flutterwave_payment_link TEXT"
        ",flutterwave_payment_amount TEXT"
        ",flutterwave_payment_customer_name TEXT"
        ",flutterwave_payment_customer_id TEXT"
        ",flutterwave_payment_customer_text TEXT"
        ",flutterwave_payment_customer_email TEXT"
        ",flutterwave_payment_customer_phone_number TEXT"
        ",flutterwave_payment_customer_full_name TEXT"
        ",flutterwave_payment_customer_created_at TEXT"
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
    if (!(await PaymentRecord.initTable())) {
      return;
    }
    Database db = await Utils.getDb();
    if (!db.isOpen) {
      return false;
    }
    await db.delete(PaymentRecord.tableName);
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
      Utils.toast("Failed to save because ${e.toString()}");
    }
  }
}
