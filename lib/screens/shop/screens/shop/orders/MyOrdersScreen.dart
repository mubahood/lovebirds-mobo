import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../../models/RespondModel.dart';
import '../../../../../../utils/AppConfig.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/Utilities.dart';
import '../../models/Order.dart';
import 'OrderDetailsScreen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool isLoading = true;
  List<Order> orders = [];
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      RespondModel resp = RespondModel(
        await Utils.http_get('my-orders', {}),
      );

      if (resp.code == 1) {
        List<Order> loadedOrders = [];
        if (resp.data != null && resp.data is List) {
          for (var orderData in resp.data) {
            loadedOrders.add(Order.fromJson(orderData));
          }
        }
        
        setState(() {
          orders = loadedOrders;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = resp.message.isNotEmpty 
            ? resp.message 
            : 'Failed to load orders';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            FeatherIcons.arrowLeft,
            color: CustomTheme.colorLight,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CustomTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                FeatherIcons.shoppingBag,
                color: CustomTheme.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FxText.titleMedium(
                  "My Orders",
                  fontWeight: 900,
                  color: CustomTheme.accent,
                ),
                FxText.bodySmall(
                  "Order history",
                  color: CustomTheme.color2,
                  fontSize: 11,
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _loadOrders,
              icon: Icon(
                FeatherIcons.refreshCw,
                color: CustomTheme.colorLight,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: CustomTheme.primary,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            FxText.bodyMedium(
              "Loading your orders...",
              color: CustomTheme.color2,
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  FeatherIcons.alertCircle,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              FxText.titleMedium(
                "Failed to Load Orders",
                color: CustomTheme.colorLight,
                fontWeight: 700,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              FxText.bodyMedium(
                errorMessage,
                color: CustomTheme.color2,
                textAlign: TextAlign.center,
                height: 1.4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadOrders,
                  icon: Icon(FeatherIcons.refreshCw, size: 18),
                  label: Text("Try Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CustomTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  FeatherIcons.shoppingBag,
                  color: CustomTheme.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              FxText.titleMedium(
                "No Orders Yet",
                color: CustomTheme.colorLight,
                fontWeight: 700,
              ),
              const SizedBox(height: 8),
              FxText.bodyMedium(
                "You haven't placed any orders yet. Start shopping to see your orders here!",
                color: CustomTheme.color2,
                textAlign: TextAlign.center,
                height: 1.4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: Icon(FeatherIcons.shoppingCart, size: 18),
                  label: Text("Start Shopping"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: CustomTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.color4.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => OrderDetailsScreen(order: order)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.orderState).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getStatusIcon(order.orderState),
                          color: _getStatusColor(order.orderState),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FxText.bodyMedium(
                            "Order #${order.id}",
                            color: CustomTheme.colorLight,
                            fontWeight: 700,
                          ),
                          FxText.bodySmall(
                            _formatDate(order.createdAt),
                            color: CustomTheme.color2,
                            fontSize: 11,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.orderState).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FxText.bodySmall(
                      _getStatusText(order.orderState),
                      color: _getStatusColor(order.orderState),
                      fontWeight: 600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Order Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FxText.bodySmall(
                          "Total Amount",
                          color: CustomTheme.color2,
                          fontSize: 11,
                        ),
                        const SizedBox(height: 2),
                        FxText.titleMedium(
                          "${AppConfig.CURRENCY} ${Utils.moneyFormat(order.orderTotal.toString())}",
                          color: CustomTheme.primary,
                          fontWeight: 800,
                        ),
                      ],
                    ),
                  ),
                  if (order.customerName.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FxText.bodySmall(
                            "Customer",
                            color: CustomTheme.color2,
                            fontSize: 11,
                          ),
                          const SizedBox(height: 2),
                          FxText.bodyMedium(
                            order.customerName,
                            color: CustomTheme.colorLight,
                            fontWeight: 600,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Button
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.to(() => OrderDetailsScreen(order: order)),
                      icon: Icon(FeatherIcons.eye, size: 16),
                      label: Text("View Details"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomTheme.primary,
                        side: BorderSide(color: CustomTheme.primary.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (order.orderState == 0 || order.orderState == 1)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _trackOrder(order),
                        icon: Icon(FeatherIcons.truck, size: 16),
                        label: Text("Track Order"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0: return Colors.orange;
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      default: return CustomTheme.color2;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0: return FeatherIcons.clock;
      case 1: return FeatherIcons.truck;
      case 2: return FeatherIcons.checkCircle;
      case 3: return FeatherIcons.xCircle;
      default: return FeatherIcons.circle;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0: return "PENDING";
      case 1: return "PROCESSING";
      case 2: return "COMPLETED";
      case 3: return "CANCELLED";
      default: return "UNKNOWN";
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  void _trackOrder(Order order) {
    Get.snackbar(
      'Order Tracking',
      'Your order #${order.id} is ${_getStatusText(order.orderState).toLowerCase()}',
      backgroundColor: _getStatusColor(order.orderState).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(_getStatusIcon(order.orderState), color: Colors.white),
    );
  }
}
