import '../../../utils/Utilities.dart';

class Order {
  int id = 0;
  String user = "";
  int orderState = 0;
  int temporaryId = 0;
  String amount = "0";
  String orderTotal = "0";
  String paymentConfirmation = "";
  String description = "";
  String mail = "";
  String orderDetails = "";
  String dateCreated = "";
  String dateUpdated = "";
  String deliveryDistrict = "";
  String customerName = "";
  String customerPhoneNumber1 = "";
  String customerPhoneNumber2 = "";
  String customerAddress = "";
  String stripeId = "";
  String stripeText = "";
  String stripeUrl = "";
  String stripePaid = "No";
  String stripeProductId = "";
  String stripePriceId = "";
  String totalAmount = "0";
  String createdAt = "";
  String updatedAt = "";
  List<OrderItem> items = [];

  Order();

  static Order fromJson(dynamic m) {
    Order obj = Order();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.user = Utils.to_str(m['user'], '');
    obj.orderState = Utils.int_parse(m['order_state']);
    obj.temporaryId = Utils.int_parse(m['temporary_id']);
    obj.amount = Utils.to_str(m['amount'], '0');
    obj.orderTotal = Utils.to_str(m['order_total'], '0');
    obj.paymentConfirmation = Utils.to_str(m['payment_confirmation'], '');
    obj.description = Utils.to_str(m['description'], '');
    obj.mail = Utils.to_str(m['mail'], '');
    obj.orderDetails = Utils.to_str(m['order_details'], '');
    obj.dateCreated = Utils.to_str(m['date_created'], '');
    obj.dateUpdated = Utils.to_str(m['date_updated'], '');
    obj.deliveryDistrict = Utils.to_str(m['delivery_district'], '');
    obj.customerName = Utils.to_str(m['customer_name'], '');
    obj.customerPhoneNumber1 = Utils.to_str(m['customer_phone_number_1'], '');
    obj.customerPhoneNumber2 = Utils.to_str(m['customer_phone_number_2'], '');
    obj.customerAddress = Utils.to_str(m['customer_address'], '');
    obj.stripeId = Utils.to_str(m['stripe_id'], '');
    obj.stripeText = Utils.to_str(m['stripe_text'], '');
    obj.stripeUrl = Utils.to_str(m['stripe_url'], '');
    obj.stripePaid = Utils.to_str(m['stripe_paid'], 'No');
    obj.stripeProductId = Utils.to_str(m['stripe_product_id'], '');
    obj.stripePriceId = Utils.to_str(m['stripe_price_id'], '');
    obj.totalAmount = Utils.to_str(m['total_amount'], '0');
    obj.createdAt = Utils.to_str(m['created_at'], '');
    obj.updatedAt = Utils.to_str(m['updated_at'], '');

    // Parse order items if available
    if (m['items'] != null && m['items'] is List) {
      obj.items = [];
      for (var itemData in m['items']) {
        obj.items.add(OrderItem.fromJson(itemData));
      }
    }

    return obj;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'order_state': orderState,
      'temporary_id': temporaryId,
      'amount': amount,
      'order_total': orderTotal,
      'payment_confirmation': paymentConfirmation,
      'description': description,
      'mail': mail,
      'order_details': orderDetails,
      'date_created': dateCreated,
      'date_updated': dateUpdated,
      'delivery_district': deliveryDistrict,
      'customer_name': customerName,
      'customer_phone_number_1': customerPhoneNumber1,
      'customer_phone_number_2': customerPhoneNumber2,
      'customer_address': customerAddress,
      'stripe_id': stripeId,
      'stripe_text': stripeText,
      'stripe_url': stripeUrl,
      'stripe_paid': stripePaid,
      'stripe_product_id': stripeProductId,
      'stripe_price_id': stripePriceId,
      'total_amount': totalAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  String getStatusText() {
    switch (orderState) {
      case 0:
        return "Pending";
      case 1:
        return "Processing";
      case 2:
        return "Completed";
      case 3:
        return "Cancelled";
      default:
        return "Unknown";
    }
  }

  double getOrderTotalDouble() {
    return Utils.double_parse(orderTotal);
  }

  double getAmountDouble() {
    return Utils.double_parse(amount);
  }
}

class OrderItem {
  int id = 0;
  String order = "";
  String product = "";
  String qty = "1";
  String amount = "0";
  String color = "";
  String size = "";
  String createdAt = "";
  String updatedAt = "";

  // Additional product info (if populated by backend)
  String productName = "";
  String productImage = "";
  String productPrice = "";

  OrderItem();

  static OrderItem fromJson(dynamic m) {
    OrderItem obj = OrderItem();
    if (m == null) {
      return obj;
    }

    obj.id = Utils.int_parse(m['id']);
    obj.order = Utils.to_str(m['order'], '');
    obj.product = Utils.to_str(m['product'], '');
    obj.qty = Utils.to_str(m['qty'], '1');
    obj.amount = Utils.to_str(m['amount'], '0');
    obj.color = Utils.to_str(m['color'], '');
    obj.size = Utils.to_str(m['size'], '');
    obj.createdAt = Utils.to_str(m['created_at'], '');
    obj.updatedAt = Utils.to_str(m['updated_at'], '');

    // Additional product info
    obj.productName = Utils.to_str(m['product_name'], '');
    obj.productImage = Utils.to_str(m['product_image'], '');
    obj.productPrice = Utils.to_str(m['product_price'], '');

    return obj;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'product': product,
      'qty': qty,
      'amount': amount,
      'color': color,
      'size': size,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product_name': productName,
      'product_image': productImage,
      'product_price': productPrice,
    };
  }

  int getQtyInt() {
    return Utils.int_parse(qty);
  }

  double getAmountDouble() {
    return Utils.double_parse(amount);
  }

  double getTotalPrice() {
    return getAmountDouble() * getQtyInt();
  }
}
