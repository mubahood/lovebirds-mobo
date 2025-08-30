import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:get/get.dart';
import 'package:lovebirds/config/CustomTheme.dart';
import '../../../models/Order.dart';
import '../../../widgets/Mywidgets.dart';
import '../../../API/API.dart';
import 'dart:convert';

class OrderPaymentDebugScreen extends StatefulWidget {
  const OrderPaymentDebugScreen({Key? key}) : super(key: key);

  @override
  State<OrderPaymentDebugScreen> createState() =>
      _OrderPaymentDebugScreenState();
}

class _OrderPaymentDebugScreenState extends State<OrderPaymentDebugScreen> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final response = await API.makeApiCall(url: API.orders, method: 'get');

      if (response != null) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          orders = data.map((item) => Order.fromJson(item)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Payment Debug'),
        backgroundColor: CustomTheme.primary,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildDebugRow('Order State:', '${order.orderState}'),
                          _buildDebugRow('Stripe Paid:', '${order.stripePaid}'),
                          _buildDebugRow('Stripe URL:', '${order.stripeUrl}'),
                          _buildDebugRow('Stripe ID:', '${order.stripeId}'),
                          _buildDebugRow(
                            'Total Amount:',
                            '\$${order.totalAmount}',
                          ),
                          _buildDebugRow(
                            'Payment Confirmation:',
                            '${order.paymentConfirmation}',
                          ),
                          SizedBox(height: 16),

                          // Payment Button Logic Analysis
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Button Logic Analysis:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'stripePaid != "Yes": ${order.stripePaid != "Yes"}',
                                ),
                                Text(
                                  'stripeUrl.isNotEmpty: ${order.stripeUrl.isNotEmpty}',
                                ),
                                Text(
                                  'stripeUrl.isEmpty: ${order.stripeUrl.isEmpty}',
                                ),
                                Text(
                                  'orderState == 0: ${order.orderState == 0}',
                                ),
                                Text(
                                  'orderState == 1: ${order.orderState == 1}',
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _getButtonDecision(order),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          // Show what buttons would appear
                          Row(
                            children: [
                              // Current MyOrdersScreen logic
                              if (order.stripePaid != "Yes" &&
                                  order.stripeUrl.isNotEmpty)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      MyWidgets.showToast(
                                        'Pay Now button clicked',
                                      );
                                    },
                                    icon: Icon(
                                      FeatherIcons.creditCard,
                                      size: 16,
                                    ),
                                    label: Text("Pay Now"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                )
                              else if (order.orderState == 0 ||
                                  order.orderState == 1)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      MyWidgets.showToast(
                                        'Track Order button clicked',
                                      );
                                    },
                                    icon: Icon(FeatherIcons.truck, size: 16),
                                    label: Text("Track Order"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CustomTheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                )
                              else if (order.stripePaid != "Yes" &&
                                  order.stripeUrl.isEmpty)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      MyWidgets.showToast(
                                        'Generate Payment button clicked',
                                      );
                                    },
                                    icon: Icon(
                                      FeatherIcons.creditCard,
                                      size: 16,
                                    ),
                                    label: Text("Generate Payment"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CustomTheme.accent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'No Payment Button Shown',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '(empty)' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.red : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonDecision(Order order) {
    if (order.stripePaid != "Yes" && order.stripeUrl.isNotEmpty) {
      return 'SHOULD SHOW: Pay Now Button';
    } else if (order.orderState == 0 || order.orderState == 1) {
      return 'SHOULD SHOW: Track Order Button';
    } else if (order.stripePaid != "Yes" && order.stripeUrl.isEmpty) {
      return 'SHOULD SHOW: Generate Payment Button';
    } else {
      return 'SHOULD SHOW: No Button (ISSUE!)';
    }
  }
}
