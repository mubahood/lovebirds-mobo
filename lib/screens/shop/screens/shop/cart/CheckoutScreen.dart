import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/screens/onboarding/modern_onboarding_screen.dart';

import '../../../../../controllers/MainController.dart';
import '../../../../../models/LoggedInUserModel.dart';
import '../../../../../models/RespondModel.dart';
import '../../../../../utils/AppConfig.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/CartItem.dart';
import '../../../models/OrderOnline.dart';
import '../../../models/Product.dart';
import '../orders/MyOrdersScreen.dart';

class CheckoutScreen extends StatefulWidget {
  OrderOnline order;

  CheckoutScreen(this.order, {Key? key}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  late ThemeData theme;

  @override
  void initState() {
    super.initState();

    doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 0,
        systemOverlayStyle: Utils.overlay(),
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
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CustomTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                FeatherIcons.creditCard,
                color: CustomTheme.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FxText.bodyLarge(
                  "Checkout",
                  fontWeight: 700,
                  color: CustomTheme.colorLight,
                ),
                FxText.bodySmall(
                  "Review your order",
                  color: CustomTheme.color2,
                  fontWeight: 500,
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(child: mainWidget2()),
    );
  }

  String error_message = "";
  bool is_loading = false;

  submitOrder() async {
    setState(() {
      error_message = "";
      is_loading = true;
    });

    // Ensure user information is set
    if (widget.order.user.isEmpty || mainController.userModel.id <= 0) {
      await LoggedInUserModel.getLoggedInUser();
      await mainController.getLoggedInUser();

      // Get the actual logged in user as fallback
      LoggedInUserModel loggedUser = await LoggedInUserModel.getLoggedInUser();
      LoggedInUserModel userToUse =
          mainController.userModel.id > 0
              ? mainController.userModel
              : loggedUser;

      // Re-set user info if it was missing
      if (userToUse.id > 0) {
        widget.order.user = userToUse.id.toString();
        widget.order.mail = userToUse.email;
        widget.order.customer_name =
            '${userToUse.first_name} ${userToUse.last_name}';
        widget.order.customer_phone_number_1 = userToUse.phone_number;
        widget.order.customer_phone_number_2 = userToUse.phone_number_2;

        print(
          'DEBUG submitOrder: Re-set user info - ID: ${widget.order.user}, Name: ${widget.order.customer_name}',
        );
      }
    }

    // Final validation
    if (widget.order.user.isEmpty) {
      setState(() {
        error_message =
            "Unable to identify user. Please login again to submit your order.";
        is_loading = false;
      });

      Get.snackbar(
        'Authentication Error',
        'Unable to identify user. Please login again.',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
        icon: Icon(FeatherIcons.userX, color: Colors.white),
      );
      return;
    }

    Map<String, dynamic> delivery = widget.order.toJson();
    delivery['phone_number_2'] =
        widget.order.customer_phone_number_2.isEmpty
            ? widget.order.customer_phone_number_1
            : mainController.userModel.phone_number;

    widget.order.customer_phone_number_2;

    delivery['phone_number_1'] =
        widget.order.customer_phone_number_1.isEmpty
            ? mainController.userModel.phone_number
            : widget.order.customer_phone_number_1;
    delivery['phone_number'] = delivery['phone_number_1'];

    // Ensure user_id is properly set for API
    delivery['user_id'] = widget.order.user;

    /*print({
      'items': jsonEncode(mainController.cartItems),
      'delivery': jsonEncode(delivery),
    }.toString());*/

    // Debug: Print user info to help debug
    print('DEBUG: User ID: ${widget.order.user}');
    print('DEBUG: Customer Name: ${widget.order.customer_name}');
    print('DEBUG: MainController User ID: ${mainController.userModel.id}');
    print('DEBUG: Delivery JSON: ${jsonEncode(delivery)}');

    setState(() {
      error_message = "";
    });

    RespondModel resp = RespondModel(
      await Utils.http_post('orders-create', {
        'items': jsonEncode(mainController.cartItems),
        'delivery': jsonEncode(delivery),
      }),
    );

    if (resp.code != 1) {
      setState(() {
        error_message = resp.message;
        is_loading = false;
      });

      // Show professional error feedback
      Get.snackbar(
        'Order Submission Failed',
        resp.message.isNotEmpty
            ? resp.message
            : 'Please check your details and try again.',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: Icon(FeatherIcons.alertCircle, color: Colors.white),
      );
      return;
    }

    setState(() {
      error_message = "";
      is_loading = false;
    });

    widget.order = OrderOnline.fromJson(resp.data);
    if (widget.order.id < 1) {
      setState(() {
        error_message = resp.message;
        is_loading = false;
      });

      Get.snackbar(
        'Order Processing Error',
        'Unable to process your order. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: Icon(FeatherIcons.xCircle, color: Colors.white),
      );
      return;
    }

    // await widget.order.save();

    await CartItem.deleteAll();

    // Show professional success feedback
    Get.snackbar(
      'Order Submitted Successfully!',
      'Your order #${widget.order.id} has been received. You can now view and pay for your order.',
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 5),
      icon: Icon(FeatherIcons.checkCircle, color: Colors.white),
    );

    // Navigate after a brief delay to show the success message
    await Future.delayed(const Duration(milliseconds: 1500));

    // Navigate to My Orders screen so user can see their order and pay
    Get.offAll(() => const MyOrdersScreen());

    //dispose
    dispose();
    //   Navigator.pop(context);
    return;
  }

  Widget mainWidget2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CustomTheme.accent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CustomTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FeatherIcons.info,
                          color: CustomTheme.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FxText.bodyMedium(
                          "Please confirm your order details below before proceeding to payment.",
                          color: CustomTheme.colorLight,
                          fontWeight: 500,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Order Summary Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CustomTheme.color4.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CustomTheme.color4.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CustomTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                FeatherIcons.fileText,
                                color: CustomTheme.primary,
                                size: 18,
                              ),
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

                      // Divider
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: CustomTheme.color4.withOpacity(0.3),
                      ),

                      // Summary Items
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Order Items Total',
                              'Total amount of all items in your cart',
                              '${AppConfig.CURRENCY}${Utils.moneyFormat('${mainController.tot}')}',
                              FeatherIcons.shoppingCart,
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow(
                              'Tax',
                              '13% VAT',
                              '${AppConfig.CURRENCY}${Utils.moneyFormat(widget.order.getTax(mainController.tot.toString()))}',
                              FeatherIcons.percent,
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow(
                              widget.order.delivery_method.toLowerCase() ==
                                      "pickup"
                                  ? "Pickup Cost"
                                  : "Delivery Cost",
                              widget.order.delivery_method.toLowerCase() ==
                                      "pickup"
                                  ? "You will pick up the items yourself."
                                  : '${widget.order.delivery_address_text}, ${widget.order.delivery_address_details}.',
                              widget.order.delivery_method.toLowerCase() ==
                                      "pickup"
                                  ? "${AppConfig.CURRENCY}0.00"
                                  : "${AppConfig.CURRENCY}${Utils.moneyFormat(widget.order.delivery_amount)}",
                              widget.order.delivery_method.toLowerCase() ==
                                      "pickup"
                                  ? FeatherIcons.mapPin
                                  : FeatherIcons.truck,
                            ),

                            const SizedBox(height: 20),

                            // Total Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CustomTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: CustomTheme.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    "${AppConfig.CURRENCY}${Utils.moneyFormat((Utils.int_parse(widget.order.payable_amount) + Utils.int_parse(widget.order.getTax(mainController.tot.toString()))).toString())}",
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
              ],
            ),
          ),
        ),

        // Error Message
        if (error_message.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(FeatherIcons.alertCircle, color: Colors.red, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: FxText.bodyMedium(
                    error_message,
                    color: Colors.red,
                    fontWeight: 600,
                    maxLines: 5,
                  ),
                ),
              ],
            ),
          ),

        // Submit Button Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CustomTheme.color4.withOpacity(0.05),
            border: Border(
              top: BorderSide(
                color: CustomTheme.color4.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child:
              is_loading
                  ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              CustomTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FxText.bodyMedium(
                          "Processing order...",
                          color: CustomTheme.primary,
                          fontWeight: 600,
                        ),
                      ],
                    ),
                  )
                  : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CustomTheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _showConfirmationDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(FeatherIcons.creditCard, size: 18),
                      label: FxText.bodyLarge(
                        'SUBMIT ORDER',
                        fontWeight: 700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  // Helper method to build modern summary rows
  Widget _buildSummaryRow(
    String title,
    String subtitle,
    String amount,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CustomTheme.color4.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CustomTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: CustomTheme.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  title,
                  color: CustomTheme.colorLight,
                  fontWeight: 700,
                ),
                const SizedBox(height: 2),
                FxText.bodySmall(
                  subtitle,
                  color: CustomTheme.color2,
                  fontWeight: 500,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          FxText.bodyLarge(amount, color: CustomTheme.primary, fontWeight: 800),
        ],
      ),
    );
  }

  // Modern confirmation dialog
  void _showConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: CustomTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CustomTheme.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  FeatherIcons.checkCircle,
                  color: CustomTheme.accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              FxText.titleMedium(
                "Confirm Order Submission",
                fontWeight: 700,
                color: CustomTheme.colorLight,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FxText.bodyMedium(
                "Are you sure you want to submit this order? This action cannot be undone.",
                color: CustomTheme.color2,
                fontWeight: 500,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: CustomTheme.color4, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: FxText.bodyMedium(
                        'CANCEL',
                        color: CustomTheme.color2,
                        fontWeight: 600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        submitOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: FxText.bodyMedium(
                        'SUBMIT ORDER',
                        color: Colors.white,
                        fontWeight: 700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  MainController mainController = MainController();

  Future<dynamic> doRefresh() async {
    await mainController.getLoggedInUser();
    await LoggedInUserModel.getLoggedInUser();
    await mainController.getCartItems();

    // Calculate total from cart items directly
    double cartTotal = 0.0;
    for (var item in mainController.cartItems) {
      double itemPrice = Utils.double_parse(item.product_price_1);
      int itemQuantity = Utils.int_parse(item.product_quantity);
      cartTotal += (itemQuantity * itemPrice);
    }

    // Update mainController.tot with calculated total
    mainController.tot = cartTotal;

    widget.order.payable_amount =
        (mainController.tot + Utils.int_parse(widget.order.delivery_amount))
            .toString();
    myInit();
    setState(() {});
  }

  List<Product> items = [];

  Future<dynamic> myInit() async {
    await mainController.getLoggedInUser();
    await LoggedInUserModel.getLoggedInUser();
    await mainController.getCartItems();

    // Get the actual logged in user
    LoggedInUserModel loggedUser = await LoggedInUserModel.getLoggedInUser();

    // Debug: Check if user is loaded
    print(
      'DEBUG myInit: MainController User ID: ${mainController.userModel.id}',
    );
    print('DEBUG myInit: LoggedUser ID: ${loggedUser.id}');
    print(
      'DEBUG myInit: User Name: ${loggedUser.first_name} ${loggedUser.last_name}',
    );

    // Set user details in order - Use the logged user if mainController user is not set
    LoggedInUserModel userToUse =
        mainController.userModel.id > 0 ? mainController.userModel : loggedUser;

    if (userToUse.id > 0) {
      widget.order.user = userToUse.id.toString();
    }

    if (userToUse.email.length > 3) {
      widget.order.mail = userToUse.email;
    }

    widget.order.customer_name =
        '${userToUse.first_name} ${userToUse.last_name}';
    widget.order.customer_phone_number_1 = userToUse.phone_number;
    widget.order.customer_phone_number_2 = userToUse.phone_number_2;

    print('DEBUG myInit: Order user field set to: ${widget.order.user}');
    print(
      'DEBUG myInit: Order customer name set to: ${widget.order.customer_name}',
    );

    return "Done";
  }

  menuItemWidget(String title, String subTitle, Function screen) {
    return InkWell(
      onTap: () => {screen()},
      child: Container(
        padding: const EdgeInsets.only(left: 0, bottom: 5, top: 20),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CustomTheme.primary, width: 2),
          ),
        ),
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.titleLarge(
                    title,
                    color: CustomTheme.color,
                    fontWeight: 900,
                  ),
                  FxText.bodyLarge(
                    subTitle,
                    height: 1,
                    fontWeight: 600,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 35),
          ],
        ),
      ),
    );
  }
}
