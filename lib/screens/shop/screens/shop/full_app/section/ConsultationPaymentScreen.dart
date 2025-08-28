import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../../../../../controllers/MainController.dart';
import '../../../../../../models/RespondModel.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/Utilities.dart';
import '../../../../../../utils/my_colors.dart';

class ConsultationPaymentScreen extends StatefulWidget {
  Map<String, dynamic> params = {};

  ConsultationPaymentScreen(this.params, {super.key});

  @override
  State<ConsultationPaymentScreen> createState() =>
      ConsultationPaymentScreenState();
}

class ConsultationPaymentScreenState extends State<ConsultationPaymentScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initScreen();
  }

  Future<void> initScreen() async {
    setState(() {});
  }

  final MainController mainController = Get.find<MainController>();

  final _formKey = GlobalKey<FormBuilderState>();
  bool _keyboardVisible = false;

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    confirm_payment() async {
      consultation_card_payment();
      consultation_flutterwave_payment();
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
              onTap: () {
                confirm_payment();
                return;
                initScreen();
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 15),
                child: isLoading
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
              )),
        ],
        title: FxText.titleLarge(
          "Payment for invoice ",
          color: Colors.white,
        ),
        backgroundColor: MyColors.primary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: FormBuilder(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        const SizedBox(
                          height: 15,
                        ),
                        FxText.bodyLarge(
                          'Select Invoice',
                          fontSize: 20,
                          color: MyColors.primary,
                          fontWeight: 900,
                          height: 1,
                        ),
                        FormBuilderTextField(
                          name: 'consultation_id',
                          autofocus: false,
                          enableSuggestions: true,
                          readOnly: true,
                          onTap: () async {
                            setState(() {});
                          },
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: " , (UGX ${Utils.moneyFormat('1000')})",
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: "This field is required.",
                            ),
                          ]),
                          decoration: const InputDecoration.collapsed(
                            hintText: null,
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(),

                        const SizedBox(
                          height: 15,
                        ),
                        FxText.bodyLarge(
                          'Enter amount to pay',
                          fontSize: 20,
                          color: MyColors.primary,
                          fontWeight: 900,
                          height: 1,
                        ),
                        FormBuilderTextField(
                          name: 'amount_paid',
                          autofocus: false,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {});
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: "This field is required.",
                            ),
                          ]),
                          decoration: const InputDecoration.collapsed(
                            hintText: null,
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(),

                        const SizedBox(
                          height: 10,
                        ),
                        FxText.bodyLarge(
                          'Select Payment Method',
                          fontSize: 20,
                          color: MyColors.primary,
                          fontWeight: 800,
                          height: 1,
                        ), //paymentRecord
                        FormBuilderRadioGroup(
                          name: 'payment_method',
                          decoration: const InputDecoration.collapsed(
                            hintText: null,
                            border: InputBorder.none,
                          ),
                          wrapDirection: Axis.vertical,
                          orientation: OptionsOrientation.vertical,
                          options: [
                            'Card',
                            'Mobile Money',
                            'Visa Card or MasterCard',
                          ]
                              .map((e) => FormBuilderFieldOption(
                                    value: e,
                                    child: FxText.bodyLarge(
                                      e,
                                      color: Colors.black,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {});
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: "This field is required.",
                            ),
                          ]),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(
                              height: 10,
                            ),
                            FxText.bodyLarge(
                              'Enter phone number',
                              fontSize: 20,
                              color: MyColors.primary,
                              fontWeight: 900,
                              height: 1,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FormBuilderTextField(
                              name: 'payment_phone_number',
                              autofocus: false,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.phone,
                              onChanged: (value) {
                                setState(() {});
                              },
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                  errorText: "This field is required.",
                                ),
                              ]),
                              decoration: const InputDecoration.collapsed(
                                hintText: null,
                                border: InputBorder.none,
                              ),
                            ),
                            const Divider(),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        error_message.isEmpty
                            ? const SizedBox()
                            : FxText.bodyMedium(error_message,
                                color: Colors.red.shade700),
                      ],
                    ),
                  ),
                ),
                _keyboardVisible
                    ? const SizedBox()
                    : isLoading
                        ? const Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                child: FxButton.block(
                                  onPressed: () {
                                    if (_formKey.currentState!
                                        .saveAndValidate()) {
                                      confirm_payment();
                                    }
                                  },
                                  backgroundColor: CustomTheme.primary,
                                  borderRadiusAll: 8,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: FxText.titleLarge(
                                    "PAY NOW",
                                    color: Colors.white,
                                    fontWeight: 700,
                                  ),
                                ),
                              ),
                            ],
                          ),
              ],
            ),
          )),
    );
  }

  bool isLoading = false;
  String error_message = "";

  void consultation_card_payment() async {
    setState(() {
      isLoading = true;
    });
    RespondModel resp = RespondModel(await Utils.http_post(
      'consultation-card-payment',
      {},
    ));

    setState(() {
      isLoading = false;
    });
    if (resp.code != 1) {
      error_message = resp.message;
      Utils.toast(resp.message);
      setState(() {});
      return;
    }

    Utils.toast("Payment successful!");
    Get.back();
    return;
  }

  void consultation_flutterwave_payment() async {}
}
