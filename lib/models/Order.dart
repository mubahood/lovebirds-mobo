import 'package:flutter/material.dart';

/// Order model class for comprehensive order management
/// Represents a customer order with all related information
class Order {
  final String id;
  final String orderNumber;
  final String customer;
  final double total;
  final String status;
  final DateTime orderDate;
  final int items;
  final String priority;
  final List<OrderItem> orderItems;
  final String? trackingNumber;
  final String? shippingCarrier;
  final DateTime? estimatedDelivery;
  final DateTime? deliveryDate;
  final String? notes;
  final String? shippingAddress;
  final String? carrier;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customer,
    required this.total,
    required this.status,
    required this.orderDate,
    required this.items,
    this.priority = 'normal',
    this.orderItems = const [],
    this.trackingNumber,
    this.shippingCarrier,
    this.estimatedDelivery,
    this.deliveryDate,
    this.notes,
    this.shippingAddress,
    this.carrier,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customer: json['customer'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      orderDate:
          json['orderDate'] != null
              ? DateTime.parse(json['orderDate'])
              : DateTime.now(),
      items: json['items'] ?? 0,
      priority: json['priority'] ?? 'normal',
      orderItems:
          (json['orderItems'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      trackingNumber: json['trackingNumber'],
      shippingCarrier: json['shippingCarrier'],
      estimatedDelivery:
          json['estimatedDelivery'] != null
              ? DateTime.parse(json['estimatedDelivery'])
              : null,
      deliveryDate:
          json['deliveryDate'] != null
              ? DateTime.parse(json['deliveryDate'])
              : null,
      notes: json['notes'],
      shippingAddress: json['shippingAddress'],
      carrier: json['carrier'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'total': total,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'items': items,
      'priority': priority,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'trackingNumber': trackingNumber,
      'shippingCarrier': shippingCarrier,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Create a demo order for testing
  static Order createDemo({
    required String id,
    required String orderNumber,
    required String customer,
    required double total,
    required String status,
    required int items,
    String priority = 'normal',
  }) {
    final orderDate = DateTime.now().subtract(
      Duration(
        hours: id.hashCode % 48, // Random hours between 0-48
      ),
    );

    return Order(
      id: id,
      orderNumber: orderNumber,
      customer: customer,
      total: total,
      status: status,
      orderDate: orderDate,
      items: items,
      priority: priority,
      orderItems: List.generate(
        items,
        (index) => OrderItem.createDemo(index + 1),
      ),
      trackingNumber:
          status == 'shipped' || status == 'delivered'
              ? 'CA${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
              : null,
      shippingCarrier:
          status == 'shipped' || status == 'delivered' ? 'Canada Post' : null,
      estimatedDelivery:
          status != 'delivered' ? orderDate.add(const Duration(days: 3)) : null,
      deliveryDate:
          status == 'delivered' ? orderDate.add(const Duration(days: 2)) : null,
    );
  }
}

/// Order item model for individual products in an order
class OrderItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final String? size;
  final String? color;
  final String? description;

  OrderItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.size,
    this.color,
    this.description,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      size: json['size'],
      color: json['color'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'size': size,
      'color': color,
      'description': description,
    };
  }

  double get totalPrice => price * quantity;

  /// Create a demo order item for testing
  static OrderItem createDemo(int index) {
    final products = [
      {
        'name': 'Wireless Headphones',
        'price': 149.99,
        'imageUrl': 'https://via.placeholder.com/150',
        'description':
            'High-quality wireless headphones with noise cancellation',
      },
      {
        'name': 'Phone Case',
        'price': 39.99,
        'imageUrl': 'https://via.placeholder.com/150',
        'description': 'Protective phone case with premium materials',
      },
      {
        'name': 'Screen Protector',
        'price': 14.99,
        'imageUrl': 'https://via.placeholder.com/150',
        'description': 'Tempered glass screen protector',
      },
      {
        'name': 'Charging Cable',
        'price': 24.99,
        'imageUrl': 'https://via.placeholder.com/150',
        'description': 'Fast charging USB-C cable',
      },
    ];

    final product = products[(index - 1) % products.length];

    return OrderItem(
      id: 'item_$index',
      name: product['name'] as String,
      imageUrl: product['imageUrl'] as String,
      price: product['price'] as double,
      quantity: 1 + (index % 3), // 1-3 items
      description: product['description'] as String,
      size: index % 2 == 0 ? 'Medium' : null,
      color: index % 3 == 0 ? 'Black' : null,
    );
  }
}

/// Timeline event for order tracking
class TimelineEvent {
  final String title;
  final String description;
  final DateTime? timestamp;
  final IconData icon;
  final bool isCompleted;

  TimelineEvent({
    required this.title,
    required this.description,
    this.timestamp,
    required this.icon,
    this.isCompleted = false,
  });
}

/// Tracking event for detailed order tracking
class TrackingEvent {
  final String title;
  final String description;
  final String location;
  final DateTime timestamp;
  final TrackingStatus status;
  final IconData icon;

  TrackingEvent({
    required this.title,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.status,
    required this.icon,
  });
}

/// Tracking status enum
enum TrackingStatus { completed, inProgress, pending }
