import 'dart:convert';

import 'package:flutter/material.dart';
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
import 'UnpaidOrdersCheckScreen.dart';

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
        backgroundColor: CustomTheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: CustomTheme.background),
        titleSpacing: 0,
        title: FxText.titleLarge(
          "CHECKOUT",
          color: CustomTheme.background,
          fontWeight: 800,
          maxLines: 2,
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

    /*print({
      'items': jsonEncode(mainController.cartItems),
      'delivery': jsonEncode(delivery),
    }.toString());*/

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
        error_message = "";
        is_loading = false;
      });
      is_loading = false;
      error_message = resp.message;
      setState(() {});
      Utils.toast('Failed $error_message', color: Colors.red.shade700);
      return;
    }

    setState(() {
      error_message = "";
      is_loading = false;
    });

    widget.order = OrderOnline.fromJson(resp.data);
    if (widget.order.id < 1) {
      error_message = resp.message;
      Utils.toast('Failed to submit order', color: Colors.red.shade700);
      setState(() {});
      return;
    }

    // await widget.order.save();

    await CartItem.deleteAll();

    Utils.toast('Order submitted successfully!', isLong: true);

    // Get.to(() => const UnpaidOrdersCheckScreen());
    Get.offAll(() => const ModernOnboardingScreen());

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
            padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Column(
              children: [
                FxText.bodyMedium(
                  "Please confirm your order details below before proceeding to payment.",
                  color: CustomTheme.color,
                ),
                const SizedBox(height: 15),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: FxText.titleLarge(
                    "Order Items Total",
                    color: CustomTheme.color,
                    fontWeight: 800,
                  ),
                  dense: true,
                  subtitle: FxText.bodySmall(
                    "Total amount of all items in your cart",
                    fontWeight: 400,
                    color: CustomTheme.color2,
                  ),
                  trailing: FxText.titleLarge(
                    "${AppConfig.CURRENCY}${Utils.moneyFormat('${mainController.tot}')}",
                    color: CustomTheme.primary,
                    fontWeight: 800,
                  ),
                ),
                const FxDashedDivider(color: Colors.grey),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: FxText.titleLarge(
                    "Tax",
                    color: CustomTheme.color,
                    fontWeight: 800,
                  ),
                  dense: true,
                  subtitle: FxText.bodySmall(
                    '13% VAT',
                    color: CustomTheme.color2,
                    fontWeight: 400,
                  ),
                  trailing: FxText.titleLarge(
                    "${AppConfig.CURRENCY}${Utils.moneyFormat(widget.order.getTax(mainController.tot.toString()))}",
                    color: CustomTheme.primary,
                    fontWeight: 800,
                  ),
                ),
                const FxDashedDivider(color: Colors.grey),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: FxText.titleLarge(
                    "Delivery Cost",
                    color: CustomTheme.color,
                    fontWeight: 800,
                  ),
                  dense: true,
                  subtitle: FxText.bodySmall(
                    widget.order.delivery_method.toLowerCase() == "pickup"
                        ? "You will pick up the items yourself."
                        : '${widget.order.delivery_address_text}, ${widget.order.delivery_address_details}.',
                    fontWeight: 400,
                    color: CustomTheme.color2,
                  ),
                  trailing: FxText.titleLarge(
                    widget.order.delivery_method.toLowerCase() == "pickup"
                        ? "${AppConfig.CURRENCY}0.00"
                        : "${AppConfig.CURRENCY}${Utils.moneyFormat(widget.order.delivery_amount)}",
                    color: CustomTheme.primary,
                    fontWeight: 800,
                  ),
                ),
                const FxDashedDivider(color: Colors.grey),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: FxText.titleLarge(
                    "Total",
                    color: CustomTheme.color,
                    fontWeight: 800,
                  ),
                  dense: true,
                  subtitle: FxText.bodySmall(
                    "Total amount of all items in your cart",
                    fontWeight: 400,
                    color: CustomTheme.color2,
                  ),
                  trailing: FxText.titleLarge(
                    "${AppConfig.CURRENCY}${Utils.moneyFormat((Utils.int_parse(widget.order.payable_amount) + Utils.int_parse(widget.order.getTax(mainController.tot.toString()))).toString())}",
                    color: CustomTheme.primary,
                    fontWeight: 800,
                  ),
                ),
              ],
            ),
          ),
        ),
        /**/
        error_message.isEmpty
            ? const SizedBox()
            : FxContainer(
              color: Colors.red.shade50,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              child: FxText.bodyLarge(
                error_message,
                color: Colors.red,
                fontWeight: 800,
                maxLines: 15,
              ),
            ),
        FxContainer(
          borderRadiusAll: 0,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          color: CustomTheme.primary.withAlpha(30),
          child:
              is_loading
                  ? const CircularProgressIndicator()
                  : FxButton(
                    block: true,
                    borderRadiusAll: 5,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 14,
                    ),
                    borderColor: CustomTheme.primary,
                    onPressed: () {
                      Get.defaultDialog(
                        middleText: "Confirm order submission",
                        titleStyle: TextStyle(color: CustomTheme.color),
                        actions: <Widget>[
                          FxButton.outlined(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            borderColor: CustomTheme.primary,
                            child: FxText('CANCEL', color: CustomTheme.primary),
                          ),
                          FxButton.small(
                            onPressed: () {
                              Navigator.pop(context);
                              submitOrder();
                            },
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            child: FxText(
                              'SUBMIT ORDER',
                              color: CustomTheme.primary,
                            ),
                          ),
                        ],
                      );
                    },
                    child: FxText.titleLarge(
                      'SUBMIT ORDER',
                      fontWeight: 900,
                      color: CustomTheme.background,
                      letterSpacing: 0.5,
                    ),
                  ),
        ),
      ],
    );
  }

  MainController mainController = MainController();

  Future<dynamic> doRefresh() async {
    await mainController.getCartItems();
    widget.order.payable_amount =
        (mainController.tot + Utils.int_parse(widget.order.delivery_amount))
            .toString();
    myInit();
    setState(() {});
  }

  List<Product> items = [];

  Future<dynamic> myInit() async {
    await LoggedInUserModel.getLoggedInUser();
    await mainController.getCartItems();
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
