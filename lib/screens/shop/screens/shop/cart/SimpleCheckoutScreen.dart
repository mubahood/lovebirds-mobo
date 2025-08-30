import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../controllers/SimpleCartManager.dart';
import '../../../../../controllers/MainController.dart';
import '../../../../../models/LoggedInUserModel.dart';
import '../../../../../models/RespondModel.dart';
import '../../../../../utils/AppConfig.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/OrderOnline.dart';

class SimpleCheckoutScreen extends StatefulWidget {
  final OrderOnline order;
  final SimpleCartManager cartManager;

  const SimpleCheckoutScreen(this.order, this.cartManager, {Key? key}) : super(key: key);

  @override
  _SimpleCheckoutScreenState createState() => _SimpleCheckoutScreenState();
}

class _SimpleCheckoutScreenState extends State<SimpleCheckoutScreen> {
  final MainController mainController = Get.find<MainController>();
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _initializeOrder();
  }

  Future<void> _initializeOrder() async {
    await mainController.getLoggedInUser();
    
    // Ensure user is properly set
    if (mainController.userModel.id > 0) {
      widget.order.user = mainController.userModel.id.toString();
      widget.order.mail = mainController.userModel.email;
      widget.order.customer_name = '${mainController.userModel.first_name} ${mainController.userModel.last_name}';
      widget.order.customer_phone_number_1 = mainController.userModel.phone_number;
      widget.order.customer_phone_number_2 = mainController.userModel.phone_number_2;
    }
    
    setState(() {});
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
                FeatherIcons.creditCard,
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
                  "Checkout",
                  fontWeight: 900,
                  color: CustomTheme.accent,
                ),
                FxText.bodySmall(
                  "Review your order",
                  color: CustomTheme.color2,
                  fontSize: 11,
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Confirmation Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CustomTheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FeatherIcons.info,
                        color: CustomTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FxText.bodyMedium(
                          "Please confirm your order details below before proceeding to payment.",
                          color: CustomTheme.colorLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Order Summary Card
                Container(
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
                              FeatherIcons.fileText,
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

                      // Summary Items
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Order Items Total',
                              'Total amount of all items in your cart',
                              'UGX ${Utils.moneyFormat(widget.cartManager.subtotal.toString())}',
                              FeatherIcons.shoppingCart,
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow(
                              'Tax',
                              '13% VAT',
                              'UGX ${Utils.moneyFormat(widget.cartManager.tax.toString())}',
                              FeatherIcons.percent,
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow(
                              widget.order.delivery_method.toLowerCase() == "pickup"
                                  ? "Pickup Cost"
                                  : "Delivery Cost",
                              widget.order.delivery_method.toLowerCase() == "pickup"
                                  ? "You will pick up the items yourself."
                                  : '${widget.order.delivery_address_text}.',
                              widget.order.delivery_method.toLowerCase() == "pickup"
                                  ? "UGX 0"
                                  : "UGX ${Utils.moneyFormat(widget.order.delivery_amount)}",
                              widget.order.delivery_method.toLowerCase() == "pickup"
                                  ? FeatherIcons.mapPin
                                  : FeatherIcons.truck,
                            ),

                            const SizedBox(height: 20),

                            // Total Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CustomTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: CustomTheme.primary.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FxText.titleLarge(
                                        "Total Amount",
                                        color: CustomTheme.colorLight,
                                        fontWeight: 800,
                                      ),
                                      const SizedBox(height: 4),
                                      FxText.bodySmall(
                                        "Final amount to pay",
                                        fontWeight: 500,
                                        color: CustomTheme.color2,
                                      ),
                                    ],
                                  ),
                                  FxText.titleLarge(
                                    "UGX ${Utils.moneyFormat(widget.cartManager.totalAmount(widget.order.delivery_method).toString())}",
                                    color: CustomTheme.primary,
                                    fontWeight: 900,
                                    fontSize: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Error Message
                if (errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FeatherIcons.alertCircle,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FxText.bodyMedium(
                            errorMessage,
                            color: Colors.red,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              FxText.titleMedium(
                                "Submitting Order...",
                                color: Colors.white,
                                fontWeight: 600,
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FeatherIcons.creditCard,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              FxText.titleMedium(
                                "SUBMIT ORDER",
                                color: Colors.white,
                                fontWeight: 700,
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String subtitle, String amount, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CustomTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: CustomTheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FxText.bodyMedium(
                title,
                color: CustomTheme.colorLight,
                fontWeight: 600,
              ),
              const SizedBox(height: 2),
              FxText.bodySmall(
                subtitle,
                color: CustomTheme.color2,
                height: 1.2,
              ),
            ],
          ),
        ),
        FxText.bodyLarge(
          amount,
          color: CustomTheme.primary,
          fontWeight: 700,
        ),
      ],
    );
  }

  Future<void> _submitOrder() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    // Final user validation
    if (widget.order.user.isEmpty || mainController.userModel.id <= 0) {
      await LoggedInUserModel.getLoggedInUser();
      await mainController.getLoggedInUser();

      LoggedInUserModel loggedUser = await LoggedInUserModel.getLoggedInUser();
      LoggedInUserModel userToUse =
          mainController.userModel.id > 0 ? mainController.userModel : loggedUser;

      if (userToUse.id > 0) {
        widget.order.user = userToUse.id.toString();
        widget.order.mail = userToUse.email;
        widget.order.customer_name = '${userToUse.first_name} ${userToUse.last_name}';
        widget.order.customer_phone_number_1 = userToUse.phone_number;
        widget.order.customer_phone_number_2 = userToUse.phone_number_2;
      }
    }

    if (widget.order.user.isEmpty) {
      setState(() {
        errorMessage = "Unable to identify user. Please login again to submit your order.";
        isLoading = false;
      });
      return;
    }

    try {
      // Prepare order data
      Map<String, dynamic> delivery = widget.order.toJson();
      delivery['user_id'] = widget.order.user;
      delivery['phone_number'] = widget.order.customer_phone_number_1;
      delivery['phone_number_1'] = widget.order.customer_phone_number_1;
      delivery['phone_number_2'] = widget.order.customer_phone_number_2.isEmpty 
          ? widget.order.customer_phone_number_1 
          : widget.order.customer_phone_number_2;

      // Debug logging
      print('=== ORDER SUBMISSION DEBUG ===');
      print('User ID: ${widget.order.user}');
      print('Customer Name: ${widget.order.customer_name}');
      print('Subtotal: ${widget.cartManager.subtotal}');
      print('Tax: ${widget.cartManager.tax}');
      print('Delivery Fee: ${widget.order.delivery_amount}');
      print('Total: ${widget.cartManager.totalAmount(widget.order.delivery_method)}');

      // Submit order
      RespondModel resp = RespondModel(
        await Utils.http_post('orders-create', {
          'items': jsonEncode(widget.cartManager.cartItems),
          'delivery': jsonEncode(delivery),
        }),
      );

      if (resp.code == 1) {
        // Success
        Get.snackbar(
          'Order Submitted Successfully!',
          'Your order has been placed and is being processed.',
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
          icon: Icon(FeatherIcons.checkCircle, color: Colors.white),
        );

        // Clear cart
        await widget.cartManager.clearCart();

        // Navigate back to products
        Get.offAllNamed('/'); // or however you navigate back to main screen
      } else {
        // Error
        setState(() {
          errorMessage = resp.message.isNotEmpty 
              ? resp.message 
              : 'Failed to submit order. Please try again.';
          isLoading = false;
        });

        Get.snackbar(
          'Order Submission Failed',
          errorMessage,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 5),
          icon: Icon(FeatherIcons.xCircle, color: Colors.white),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
        isLoading = false;
      });
      
      Get.snackbar(
        'Network Error',
        'Please check your internet connection and try again.',
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
        icon: Icon(FeatherIcons.wifiOff, color: Colors.white),
      );
    }
  }
}
