import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../controllers/MainController.dart';
import '../../../../../utils/AppConfig.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/CartItem.dart';
import '../../../models/OrderOnline.dart';
import 'CheckoutScreen.dart';
import 'DeliveryAddressScreen.dart';
import 'cartItemWidget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late ThemeData theme;

  OrderOnline order = OrderOnline();

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
        systemOverlayStyle: Utils.overlay(),
        elevation: .5,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const FxContainer(
              width: 10,
              height: 20,
              color: Colors.white,
              borderRadiusAll: 2,
            ),
            FxSpacing.width(8),
            FxText.titleLarge(
              "Shopping Cart",
              fontWeight: 900,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: SafeArea(child: Obx(() => mainWidget())),
    );
  }

  Widget mainWidget() {
    if (mainController.cartItems.isEmpty) {
      return Center(child: FxText.titleLarge("You shopping cart is empty."));
    } else {
      return Container(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          onRefresh: doRefresh,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          CartItem m = mainController.cartItems[index];
                          return cartItemWidget(m, mainController, index);
                        },
                        childCount:
                            mainController.cartItems.length, // 1000 list items
                      ),
                    ),
                  ],
                ),
              ),
              true
                  ? SizedBox()
                  : FxDashedDivider(color: Colors.grey.shade300, height: 2),
              true
                  ? SizedBox()
                  : Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: FxText.titleLarge(
                            'Select Shipping Method',
                            fontWeight: 500,
                            color: CustomTheme.color2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: FxButton(
                                borderRadiusAll: 0,
                                onPressed: () {
                                  order.delivery_method = "pickup";
                                  setState(() {});
                                },
                                backgroundColor:
                                    order.delivery_method == "pickup"
                                        ? CustomTheme.primary
                                        : Colors.white,
                                borderColor: CustomTheme.primary,
                                child: FxText.titleMedium(
                                  'Pickup',
                                  fontWeight: 800,
                                  color:
                                      order.delivery_method == "pickup"
                                          ? Colors.white
                                          : CustomTheme.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: FxButton(
                                borderRadiusAll: 0,
                                onPressed: () {
                                  order.delivery_method = "delivery";
                                  setState(() {});
                                },
                                backgroundColor:
                                    order.delivery_method == "delivery"
                                        ? CustomTheme.primary
                                        : Colors.white,
                                borderColor: CustomTheme.primary,
                                child: FxText.titleMedium(
                                  'Delivery',
                                  fontWeight: 800,
                                  color:
                                      order.delivery_method == "delivery"
                                          ? Colors.white
                                          : CustomTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
              Column(
                children: [
                  FxDashedDivider(color: Colors.grey.shade300, height: 2),
                  ListTile(
                    onTap: () async {
                      await Get.to(() => DeliveryAddressScreen(order));
                      setState(() {});
                    },
                    leading: const Icon(
                      Icons.location_on,
                      color: CustomTheme.primary,
                      size: 45,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    title: FxText.titleMedium(
                      'Delivery Information',
                      fontWeight: 800,
                      color: CustomTheme.primary,
                    ),
                    subtitle: FxText.bodyMedium(
                      order.delivery_amount.isEmpty
                          ? 'Select delivery address'
                          : '${AppConfig.CURRENCY}${Utils.moneyFormat(order.delivery_amount)}',
                      color: Colors.grey.shade600,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: CustomTheme.primary,
                      size: 45,
                    ),
                  ),
                ],
              ),
              FxDashedDivider(color: Colors.grey.shade300, height: 2),
              FxContainer(
                borderRadiusAll: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                color: CustomTheme.background,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FxText.bodySmall(
                          'TOTAL',
                          height: .8,
                          color: CustomTheme.primary,
                          fontWeight: 800,
                        ),
                        FxText.titleLarge(
                          '${AppConfig.CURRENCY}${Utils.moneyFormat('${mainController.tot}')}',
                          fontWeight: 800,
                          color: CustomTheme.color2,
                        ),
                      ],
                    ),
                    FxButton(
                      backgroundColor: CustomTheme.primary,
                      borderRadiusAll: 2,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      borderColor: CustomTheme.primary,
                      onPressed: () {
                        if (mainController.userModel.id < 1) {
                          Utils.toast(
                            'Please login to continue',
                            color: Colors.red,
                          );
                          return;
                        }

                        //check if cart is not empty
                        if (mainController.cartItems.isEmpty) {
                          Utils.toast(
                            'Your cart is empty, Please add items to your cart',
                            color: Colors.red,
                          );
                          return;
                        }
                        order.delivery_method = "delivery";
                        //check if delivery method is selected
                        if (order.delivery_method.isEmpty) {
                          Utils.toast(
                            'Please select a delivery method',
                            color: Colors.red,
                          );
                          return;
                        }
                        //check if delivery address is selected
                        if (order.delivery_method == 'delivery' &&
                            order.delivery_amount.isEmpty) {
                          Utils.toast(
                            'Please select a delivery address',
                            color: Colors.red,
                          );
                          return;
                        }
                        //chec if customer name is not empty
                        if (order.customer_name.isEmpty) {
                          Utils.toast(
                            'Please enter your name',
                            color: Colors.red,
                          );
                          return;
                        }

                        Get.to(() => CheckoutScreen(order));
                      },
                      child: Row(
                        children: [
                          FxText.titleMedium(
                            'CHECKOUT',
                            fontWeight: 900,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 25,
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
      );
    }
  }

  MainController mainController = MainController();

  Future<dynamic> doRefresh() async {
    order.delivery_method = "delivery";
    myInit();
    setState(() {});
  }

  Future<dynamic> myInit() async {
    //  await mainController.init();
    await mainController.getLoggedInUser();
    await mainController.getCartItems();
    //loop through cart items
    for (var element in mainController.cartItems) {
      if (element.pro.id < 1) {
        await element.getPro();
      }
    }
    if (mainController.userModel.email.length > 3) {
      order.mail = mainController.userModel.email;
    }
    order.customer_name =
        '${mainController.userModel.first_name} ${mainController.userModel.last_name}';
    order.customer_phone_number_1 = mainController.userModel.phone_number;
    order.customer_phone_number_2 = mainController.userModel.phone_number_2;
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
                    color: CustomTheme.color2,
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
