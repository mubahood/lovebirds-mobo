import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../../../../../../models/RespondModel.dart';
import '../../../../../../utils/AppConfig.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/Utilities.dart';
import '../../../models/Order.dart';
import 'InAppPaymentScreen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool isLoading = false;
  Order order = Order();
  Map<String, dynamic> orderDetailsData = {};

  @override
  void initState() {
    super.initState();
    order = widget.order;
    _parseOrderDetails();
    _loadOrderDetails();
  }

  void _parseOrderDetails() {
    try {
      if (order.orderDetails.isNotEmpty) {
        orderDetailsData = jsonDecode(order.orderDetails);
      }
    } catch (e) {
      print('Error parsing order details: $e');
      orderDetailsData = {};
    }
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      RespondModel resp = RespondModel(
        await Utils.http_get('order-details', {
          'order_id': order.id.toString(),
        }),
      );

      if (resp.code == 1 && resp.data != null) {
        setState(() {
          order = Order.fromJson(resp.data);
          _parseOrderDetails();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
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
                FeatherIcons.fileText,
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
                  "Order #${order.id}",
                  fontWeight: 900,
                  color: CustomTheme.accent,
                ),
                FxText.bodySmall(
                  order.getStatusText(),
                  color: _getStatusColor(order.orderState),
                  fontSize: 11,
                  fontWeight: 600,
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _loadOrderDetails,
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
        child:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: CustomTheme.primary,
                    strokeWidth: 2,
                  ),
                )
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Status Card
                        _buildOrderStatusCard(),

                        const SizedBox(height: 20),

                        // Order Summary Card
                        _buildOrderSummaryCard(),

                        const SizedBox(height: 20),

                        // Order Items
                        _buildOrderItemsCard(),

                        const SizedBox(height: 20),

                        // Customer Details
                        _buildCustomerDetailsCard(),

                        const SizedBox(height: 20),

                        // Delivery Information
                        _buildDeliveryInfoCard(),

                        if (order.stripeUrl.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildPaymentCard(),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  order.orderState,
                ).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(order.orderState),
                color: _getStatusColor(order.orderState),
                size: 32,
              ),
            ),

            const SizedBox(height: 16),

            FxText.titleLarge(
              order.getStatusText(),
              color: _getStatusColor(order.orderState),
              fontWeight: 800,
            ),

            const SizedBox(height: 8),

            FxText.bodyMedium(
              _getStatusDescription(order.orderState),
              color: CustomTheme.color2,
              textAlign: TextAlign.center,
              height: 1.4,
            ),

            const SizedBox(height: 16),

            // Order Date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CustomTheme.color4.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FeatherIcons.calendar,
                    size: 16,
                    color: CustomTheme.color2,
                  ),
                  const SizedBox(width: 8),
                  FxText.bodySmall(
                    "Ordered on ${_formatDate(order.createdAt)}",
                    color: CustomTheme.color2,
                    fontWeight: 600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CustomTheme.color4.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.dollarSign,
                  color: CustomTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                FxText.titleMedium(
                  "Order Summary",
                  fontWeight: 700,
                  color: CustomTheme.colorLight,
                ),
              ],
            ),
          ),

          // Summary Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', order.amount),
                const SizedBox(height: 12),
                _buildSummaryRow('Tax (13% VAT)', _calculateTax()),
                const SizedBox(height: 12),
                _buildSummaryRow('Delivery Fee', _getDeliveryFee()),
                const SizedBox(height: 16),
                Container(
                  height: 0.5,
                  color: CustomTheme.color4.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FxText.titleMedium(
                      "Total Amount",
                      color: CustomTheme.colorLight,
                      fontWeight: 800,
                    ),
                    FxText.titleLarge(
                      "${AppConfig.CURRENCY} ${Utils.moneyFormat(order.orderTotal)}",
                      color: CustomTheme.primary,
                      fontWeight: 900,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CustomTheme.color4.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.shoppingCart,
                  color: CustomTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                FxText.titleMedium(
                  "Order Items (${order.items.length})",
                  fontWeight: 700,
                  color: CustomTheme.colorLight,
                ),
              ],
            ),
          ),

          // Items List
          if (order.items.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    color: CustomTheme.color4.withValues(alpha: 0.3),
                  ),
              itemBuilder: (context, index) {
                return _buildOrderItemRow(order.items[index]);
              },
            )
          else
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    FeatherIcons.package,
                    color: CustomTheme.color2,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  FxText.bodyMedium(
                    "No items found for this order",
                    color: CustomTheme.color2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Product Image Placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CustomTheme.color4.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CustomTheme.color4.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Icon(
              FeatherIcons.package,
              color: CustomTheme.color2,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  item.productName.isNotEmpty
                      ? item.productName
                      : "Product #${item.product}",
                  color: CustomTheme.colorLight,
                  fontWeight: 600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.color.isNotEmpty) ...[
                      FxText.bodySmall(
                        "Color: ${item.color}",
                        color: CustomTheme.color2,
                        fontSize: 11,
                      ),
                      if (item.size.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        FxText.bodySmall(
                          "Size: ${item.size}",
                          color: CustomTheme.color2,
                          fontSize: 11,
                        ),
                      ],
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                FxText.bodySmall(
                  "Quantity: ${item.qty}",
                  color: CustomTheme.color2,
                  fontSize: 11,
                ),
              ],
            ),
          ),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FxText.bodyMedium(
                "${AppConfig.CURRENCY} ${Utils.moneyFormat(item.amount)}",
                color: CustomTheme.primary,
                fontWeight: 700,
              ),
              const SizedBox(height: 4),
              FxText.bodySmall(
                "× ${item.qty}",
                color: CustomTheme.color2,
                fontSize: 11,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CustomTheme.color4.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(FeatherIcons.user, color: CustomTheme.primary, size: 20),
                const SizedBox(width: 12),
                FxText.titleMedium(
                  "Customer Details",
                  fontWeight: 700,
                  color: CustomTheme.colorLight,
                ),
              ],
            ),
          ),

          // Customer Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (order.customerName.isNotEmpty)
                  _buildInfoRow(FeatherIcons.user, "Name", order.customerName),
                if (order.mail.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(FeatherIcons.mail, "Email", order.mail),
                ],
                if (order.customerPhoneNumber1.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    FeatherIcons.phone,
                    "Phone",
                    order.customerPhoneNumber1,
                  ),
                ],
                if (order.customerAddress.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    FeatherIcons.mapPin,
                    "Address",
                    order.customerAddress,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    String deliveryMethod = orderDetailsData['delivery_method'] ?? 'Unknown';
    String deliveryAddress = orderDetailsData['delivery_address_text'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CustomTheme.color4.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  deliveryMethod.toLowerCase() == 'pickup'
                      ? FeatherIcons.mapPin
                      : FeatherIcons.truck,
                  color: CustomTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                FxText.titleMedium(
                  "Delivery Information",
                  fontWeight: 700,
                  color: CustomTheme.colorLight,
                ),
              ],
            ),
          ),

          // Delivery Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  FeatherIcons.truck,
                  "Delivery Method",
                  deliveryMethod.toUpperCase(),
                ),
                if (deliveryAddress.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    FeatherIcons.mapPin,
                    "Delivery Address",
                    deliveryAddress,
                  ),
                ],
                const SizedBox(height: 12),
                _buildInfoRow(
                  FeatherIcons.dollarSign,
                  "Delivery Fee",
                  deliveryMethod.toLowerCase() == 'pickup'
                      ? 'FREE'
                      : "${AppConfig.CURRENCY} ${Utils.moneyFormat(_getDeliveryFee())}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CustomTheme.color4.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.creditCard,
                  color: CustomTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                FxText.titleMedium(
                  "Payment Information",
                  fontWeight: 700,
                  color: CustomTheme.colorLight,
                ),
              ],
            ),
          ),

          // Payment Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  FeatherIcons.creditCard,
                  "Payment Status",
                  order.stripePaid == "Yes" ? "PAID" : "PENDING",
                ),
                if (order.stripeId.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    FeatherIcons.hash,
                    "Payment ID",
                    order.stripeId,
                  ),
                ],
                // PRIORITY 1: Show Pay Now button if payment URL exists and not paid
                if (order.stripeUrl.isNotEmpty &&
                    order.stripePaid != "Yes") ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Open payment URL in browser
                        await _openPaymentUrl(order.stripeUrl);
                      },
                      icon: Icon(FeatherIcons.externalLink, size: 16),
                      label: Text("Pay Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ]
                // PRIORITY 2: Show Generate Payment Link button for unpaid orders without payment URL
                else if (order.stripePaid != "Yes") ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Get.to(() => InAppPaymentScreen(order: order));
                      },
                      icon: Icon(FeatherIcons.creditCard, size: 16),
                      label: Text("Payment"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FxText.bodyMedium(label, color: CustomTheme.color2, fontWeight: 500),
        FxText.bodyMedium(
          "${AppConfig.CURRENCY} ${Utils.moneyFormat(amount)}",
          color: CustomTheme.colorLight,
          fontWeight: 600,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: CustomTheme.primary, size: 16),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FxText.bodySmall(
            label,
            color: CustomTheme.color2,
            fontWeight: 500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: FxText.bodyMedium(
            value,
            color: CustomTheme.colorLight,
            fontWeight: 600,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return CustomTheme.color2;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return FeatherIcons.clock;
      case 1:
        return FeatherIcons.truck;
      case 2:
        return FeatherIcons.checkCircle;
      case 3:
        return FeatherIcons.xCircle;
      default:
        return FeatherIcons.circle;
    }
  }

  String _getStatusDescription(int status) {
    switch (status) {
      case 0:
        return "Your order has been received and is pending processing.";
      case 1:
        return "Your order is being processed and will be shipped soon.";
      case 2:
        return "Your order has been completed and delivered successfully.";
      case 3:
        return "Your order has been cancelled.";
      default:
        return "Order status is unknown.";
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }

  String _calculateTax() {
    double subtotal = Utils.double_parse(order.amount);
    double tax = subtotal * 0.13; // 13% VAT
    return tax.toStringAsFixed(2);
  }

  String _getDeliveryFee() {
    String deliveryMethod = orderDetailsData['delivery_method'] ?? '';
    if (deliveryMethod.toLowerCase() == 'pickup') {
      return "0.00";
    }

    String deliveryAmount = orderDetailsData['delivery_amount'] ?? '0';
    return deliveryAmount;
  }

  Future<void> _openPaymentUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Utils.toast("Unable to open payment link", color: Colors.red);
      }
    } catch (e) {
      Utils.toast(
        "Unable to open payment link. Please try again.",
        color: Colors.red,
      );
    }
  }
}
