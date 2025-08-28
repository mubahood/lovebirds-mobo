import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../models/LoggedInUserModel.dart';
import '../../../../../models/RespondModel.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../../onboarding/modern_onboarding_screen.dart';
import '../../../models/OrderOnline.dart';
import 'WebViewExample.dart';

class UnpaidOrdersCheckScreen extends StatefulWidget {
  const UnpaidOrdersCheckScreen({Key? key}) : super(key: key);

  @override
  _UnpaidOrdersCheckScreenState createState() =>
      _UnpaidOrdersCheckScreenState();
}

class _UnpaidOrdersCheckScreenState extends State<UnpaidOrdersCheckScreen>
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomTheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              doRefresh();
            },
          ),
        ],
        title: FxText.titleLarge(
          "ORDER PAYMENT",
          color: Colors.white,
          maxLines: 2,
        ),
      ),
      body: SafeArea(
        child:
            is_loading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                  width: double.infinity,
                  child:
                      paymentButtonPressed
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: FxSpacing.y(16),
                                child: Column(
                                  children: [
                                    FxButton(
                                      borderRadiusAll: 8,
                                      onPressed: () {
                                        setState(() {
                                          paymentButtonPressed = false;
                                        });
                                        doRefresh();
                                      },
                                      backgroundColor: Colors.green.shade700,
                                      padding: FxSpacing.xy(24, 15),
                                      child: FxText.titleLarge(
                                        "I HAVE PAID",
                                        color: Colors.white,
                                        fontWeight: 900,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 16),
                                    FxButton.rounded(
                                      borderColor: CustomTheme.primary,
                                      borderRadiusAll: 8,
                                      onPressed: () {
                                        setState(() {
                                          paymentButtonPressed = false;
                                        });
                                      },
                                      padding: FxSpacing.xy(15, 12),
                                      backgroundColor: CustomTheme.primary,
                                      child: FxText.bodySmall(
                                        "SHOW PAYMENT BUTTON AGAIN",
                                        color: Colors.white,
                                        fontWeight: 900,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    paymentButtonPressed
                                        ? const SizedBox()
                                        : FxButton.outlined(
                                          padding: FxSpacing.xy(15, 12),
                                          borderColor: CustomTheme.primary,
                                          onPressed: () {
                                            doRefresh();
                                          },
                                          backgroundColor:
                                              CustomTheme.primary,
                                          child: FxText.bodySmall(
                                            "REFRESH ORDER",
                                            color: CustomTheme.primary,
                                            fontWeight: 600,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ],
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: FxSpacing.y(16),
                                      alignment: Alignment.center,
                                      child: FxText.titleLarge(
                                        "Your order id #${order.id} created on ${Utils.to_date_1(order.created_at)}.",
                                        color:
                                            FxAppTheme
                                                .theme
                                                .colorScheme
                                                .onBackground,
                                        fontWeight: 800,
                                      ),
                                    ),
                                    Container(
                                      margin: FxSpacing.y(16),
                                      child: FxText.bodyMedium(
                                        "Please pay your order to continue.",
                                        color:
                                            FxAppTheme
                                                .theme
                                                .colorScheme
                                                .onBackground,
                                        fontWeight: 600,
                                      ),
                                    ),
                                    Container(
                                      margin: FxSpacing.y(16),
                                      child: FxText.bodyMedium(
                                        "PAYMENT LINK: ${order.stripe_url}",
                                        color:
                                            FxAppTheme
                                                .theme
                                                .colorScheme
                                                .onBackground,
                                        fontWeight: 600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: FxSpacing.y(16),
                                child: Column(
                                  children: [
                                    FxButton(
                                      borderRadiusAll: 8,
                                      onPressed: () async {
                                        setState(() {
                                          paymentButtonPressed = true;
                                        });
                                        await Get.to(
                                          () => WebViewExample(
                                            order.stripe_url,
                                          ),
                                        );
                                        Utils.toast(
                                          "Checking payment status.",
                                        );
                                        //Utils.launchBrowser(order.stripe_url);
                                      },
                                      backgroundColor: Colors.green.shade700,
                                      padding: FxSpacing.xy(24, 15),
                                      child: FxText.titleLarge(
                                        "PAY ORDER NOW",
                                        color: Colors.white,
                                        fontWeight: 900,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 16),
                                    FxButton.rounded(
                                      borderColor: CustomTheme.primary,
                                      borderRadiusAll: 8,
                                      onPressed: () {
                                        cancel_order();
                                      },
                                      padding: FxSpacing.xy(15, 12),
                                      backgroundColor: Colors.red.shade700,
                                      child: FxText.bodySmall(
                                        "CANCEL ORDER",
                                        color: Colors.white,
                                        fontWeight: 900,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    FxButton.outlined(
                                      padding: FxSpacing.xy(15, 12),
                                      borderColor: CustomTheme.primary,
                                      onPressed: () {
                                        doRefresh();
                                      },
                                      backgroundColor: CustomTheme.primary,
                                      child: FxText.bodySmall(
                                        "REFRESH ORDER",
                                        color: CustomTheme.primary,
                                        fontWeight: 600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                ),
      ),
    );
  }

  LoggedInUserModel item = LoggedInUserModel();

  String error_message = "";
  bool is_loading = false;
  bool paymentButtonPressed = false;

  Future<dynamic> myInit() async {
    item = await LoggedInUserModel.getLoggedInUser();
    return "Done";
  }

  List<OrderOnline> orders = [];

  OrderOnline order = OrderOnline();

  Future<void> doRefresh() async {
    setState(() {
      is_loading = !true;
    });

    await OrderOnline.getOnlineItems();
    await Future.delayed(const Duration(seconds: 2));

    orders = await OrderOnline.getItems(where: "stripe_paid = 'No'");

    return;
    order = OrderOnline();
    for (var element in orders) {
      if (element.stripe_id.length > 5) {
        order = element;
        break;
      }
    }
    if (order.id < 1) {
      Utils.toast("No unpaid order found.");
      // Navigator.pushNamedAndRemoveUntil(context, FullApp.tag, (r) => false);
      return;
    } else {
      Utils.toast("Unpaid order found.");
    }

    myInit()
        .then((value) {
          setState(() {
            is_loading = false;
          });
        })
        .catchError((error) {
          setState(() {
            is_loading = false;
            error_message = error.toString();
          });
        });
  }

  void cancel_order() {
    Get.defaultDialog(
      middleText: "Are you sure you want cancel this order?",
      titleStyle: const TextStyle(color: Colors.black),
      actions: <Widget>[
        FxButton.outlined(
          onPressed: () {
            Navigator.pop(context);
          },
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          borderColor: CustomTheme.primary,
          child: FxText('NO', color: CustomTheme.primary),
        ),
        //pay later
        FxButton.small(
          onPressed: () {
            Get.offAll(() => const ModernOnboardingScreen());
            /* Navigator.pushNamedAndRemoveUntil(
                  context, FullApp.tag, (r) => false);*/
          },
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: FxText('PAY LATER', color: Colors.white),
        ),

        FxButton.small(
          onPressed: () {
            Navigator.pop(context);
            do_cancel_oder();
          },
          backgroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: FxText('CANCEL ORDER', color: Colors.white),
        ),
      ],
    );
  }

  Future<void> do_cancel_oder() async {
    setState(() {
      is_loading = true;
    });
    RespondModel resp = RespondModel(
      await Utils.http_post("cancel-order", {"id": order.id}),
    );
    if (resp.code != 1) {
      Utils.toast(resp.message);
      setState(() {
        is_loading = false;
      });
      return;
    }
    Utils.toast(resp.message);
    //await OrderOnline.getOnlineItems();
    //await Future.delayed(const Duration(seconds: 1));
    setState(() {
      is_loading = false;
    });
    doRefresh();
  }
}
