import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../controllers/MainController.dart';
import '../../../../../models/DeliveryAddress.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../../../widget/widgets.dart';
import '../../../models/OrderOnline.dart';
import '../../../models/Product.dart';
import '../widgets.dart';
import 'DeliveryAddressPickerScreen.dart';

class DeliveryAddressScreen extends StatefulWidget {
  final OrderOnline order;

  const DeliveryAddressScreen(this.order, {Key? key}) : super(key: key);

  @override
  _DeliveryAddressScreenState createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen>
    with SingleTickerProviderStateMixin {
  late ThemeData theme;

  @override
  void initState() {
    super.initState();

    doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    is_loading = false;
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: FxText.titleLarge(
          "Delivery Address",
          color: Colors.white,
          maxLines: 2,
          fontWeight: 800,
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: futureInit,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return myListLoaderWidget();
              default:
                return mainWidget();
            }
          },
        ),
      ),
    );
  }

  final _fKey = GlobalKey<FormBuilderState>();
  String error_message = "";
  bool is_loading = false;

  submitOrder() async {
    if (!_fKey.currentState!.validate()) {
      Utils.toast('Fix some errors first.', color: Colors.red.shade700);
      return;
    }
    setState(() {
      error_message = "";
      is_loading = true;
    });

    return;
  }

  Widget mainWidget() {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5),
      color: CustomTheme.background,
      child: RefreshIndicator(
        backgroundColor: CustomTheme.card,
        color: CustomTheme.primary,
        onRefresh: doRefresh,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _fKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 15,
                          top: 10,
                          right: 15,
                        ),
                        decoration: BoxDecoration(
                          color: CustomTheme.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            FormBuilderTextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Select a delivery region",
                                labelStyle: TextStyle(
                                  color: CustomTheme.color2,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor: CustomTheme.cardDark,
                              ),
                              validator: MyWidgets.my_validator_field_required(
                                context,
                                'This field ',
                              ),
                              initialValue: widget.order.delivery_address_text,
                              onTap: () async {
                                /*widget.order.delivery_address_text*/
                                DeliveryAddress? d = await Get.to(
                                  () => const DeliveryAddressPickerScreen(),
                                );
                                if (d == null) {
                                  Utils.toast('Address not selected');
                                  return;
                                }
                                widget.order.delivery_address_text = d.address;
                                widget.order.delivery_amount = d.shipping_cost;
                                widget.order.delivery_address_id =
                                    d.id.toString();

                                _fKey.currentState!.patchValue({
                                  'delivery_address_text':
                                      "${widget.order.delivery_address_text} (ZAR ${Utils.moneyFormat(widget.order.delivery_amount)})",
                                });

                                setState(() {});
                              },
                              readOnly: true,
                              textCapitalization: TextCapitalization.words,
                              name: "delivery_address_text",
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            FormBuilderTextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Postal Code",
                                labelStyle: TextStyle(
                                  color: CustomTheme.color2,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor: CustomTheme.cardDark,
                              ),
                              validator: MyWidgets.my_validator_field_required(
                                context,
                                'This field ',
                              ),
                              initialValue:
                                  widget.order.delivery_address_details,
                              onChanged: (x) {
                                widget.order.delivery_address_details =
                                    x.toString();
                                widget.order.customer_address = x.toString();
                              },
                              textCapitalization: TextCapitalization.words,
                              name: "delivery_address_details",
                              textInputAction: TextInputAction.next,
                            ),

                            /* FormBuilderTextField(
                              decoration: CustomTheme.in_3(
                                label: "Postal code",
                              ),
                              validator: MyWidgets.my_validator_field_required(
                                  context, 'This field '),
                              initialValue: widget.order.description,
                              onChanged: (x) {
                                widget.order.description = x.toString();
                              },
                              textCapitalization: TextCapitalization.words,
                              name: "description",
                              textInputAction: TextInputAction.next,
                            ),*/
                            const SizedBox(height: 20),
                            FormBuilderTextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Name",
                                labelStyle: TextStyle(
                                  color: CustomTheme.color2,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor: CustomTheme.cardDark,
                              ),
                              validator: MyWidgets.my_validator_field_required(
                                context,
                                'This field ',
                              ),
                              initialValue: widget.order.customer_name,
                              onChanged: (x) {
                                widget.order.customer_name = x.toString();
                              },
                              textCapitalization: TextCapitalization.words,
                              name: "customer_name",
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            FormBuilderTextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Email address",
                                labelStyle: TextStyle(
                                  color: CustomTheme.color2,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor: CustomTheme.cardDark,
                              ),
                              validator: MyWidgets.my_validator_field_required(
                                context,
                                'This field ',
                              ),
                              initialValue: widget.order.mail,
                              onChanged: (x) {
                                widget.order.mail = x.toString();
                              },
                              textCapitalization: TextCapitalization.words,
                              name: "mail",
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            FormBuilderTextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Phone number",
                                labelStyle: TextStyle(
                                  color: CustomTheme.color2,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor: CustomTheme.cardDark,
                              ),
                              validator: MyWidgets.my_validator_field_required(
                                context,
                                'This field ',
                              ),
                              initialValue:
                                  widget.order.customer_phone_number_1.trim(),
                              onChanged: (x) {
                                widget.order.customer_phone_number_1 =
                                    x.toString().trim();
                              },
                              textCapitalization: TextCapitalization.words,
                              name: "customer_phone_number_1",
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            FormBuilderTextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Alternate phone number",
                                labelStyle: TextStyle(
                                  color: CustomTheme.color2,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor: CustomTheme.cardDark,
                              ),
                              initialValue:
                                  widget.order.customer_phone_number_2,
                              onChanged: (x) {
                                widget.order.customer_phone_number_2 =
                                    x.toString();
                              },
                              textCapitalization: TextCapitalization.words,
                              name: "customer_phone_number_2",
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            FormBuilderTextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Order details",
                                labelStyle: TextStyle(
                                  color: CustomTheme.color2,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.color4,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: CustomTheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor: CustomTheme.cardDark,
                              ),
                              initialValue: widget.order.order_details,
                              onChanged: (x) {
                                widget.order.order_details = x.toString();
                              },
                              textCapitalization: TextCapitalization.words,
                              name: "order_details",
                              textInputAction: TextInputAction.next,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: CustomTheme.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: FxContainer(
                borderRadiusAll: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                color: CustomTheme.background,
                child: FxButton(
                  block: true,
                  borderRadiusAll: 5,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  backgroundColor: CustomTheme.primary,
                  borderColor: CustomTheme.primary,
                  onPressed: () {
                    if (widget.order.delivery_address_id.length < 1) {
                      Utils.toast(
                        "Please select delivery region",
                        color: CustomTheme.primary,
                      );
                      return;
                    }
                    if (widget.order.delivery_address_details.length < 5) {
                      Utils.toast(
                        "Please enter a clear address.",
                        color: CustomTheme.primary,
                      );
                      return;
                    }

                    //check phone number
                    if (widget.order.customer_phone_number_1.length < 10) {
                      Utils.toast(
                        "Please enter a valid phone number.",
                        color: CustomTheme.primary,
                      );
                      return;
                    }
                    //check for email
                    if (!Utils.isValidMail(widget.order.mail)) {
                      Utils.toast(
                        "Please enter a valid email address.",
                        color: CustomTheme.primary,
                      );
                      return;
                    }
                    //check if phone starts with +
                    if (!widget.order.customer_phone_number_1.startsWith("+")) {
                      Utils.toast(
                        "Phone number should not start with +",
                        color: CustomTheme.primary,
                      );
                      return;
                    }

                    Get.back();
                  },
                  child: FxText.titleLarge(
                    'DONE',
                    fontWeight: 900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  late Future<dynamic> futureInit;
  MainController mainController = MainController();

  Future<dynamic> doRefresh() async {
    futureInit = myInit();
    setState(() {});
  }

  List<Product> items = [];

  Future<dynamic> myInit() async {
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
                    color: Colors.white,
                    fontWeight: 900,
                  ),
                  FxText.bodyLarge(
                    subTitle,
                    height: 1,
                    fontWeight: 600,
                    color: CustomTheme.color2,
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 35, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
