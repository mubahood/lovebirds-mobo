import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';

import '../../../../../controllers/MainController.dart';
import '../../../../../models/LoggedInUserModel.dart';
import '../../../../../models/RespondModel.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/CartItem.dart';
import '../../../models/Product.dart';
import '../widgets.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem>? cartItems;

  const CheckoutScreen({Key? key, this.cartItems}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;

  int _currentStep = 0;
  final int _totalSteps = 4;
  bool is_loading = false;
  String error_message = "";

  // Form key for validation
  final GlobalKey<FormBuilderState> _fKey = GlobalKey<FormBuilderState>();

  // Controllers for form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // Form keys
  final _contactFormKey = GlobalKey<FormBuilderState>();

  // Data
  String _selectedShippingMethod = 'standard';
  String _selectedPaymentMethod = 'card';

  LoggedInUserModel item = LoggedInUserModel();
  MainController mainController = MainController();
  List<CartItem> checkoutItems = [];

  double totalShipping = 12.99;
  double totalTax = 0;

  final List<Map<String, dynamic>> _shippingOptions = [
    {
      'id': 'standard',
      'name': 'Standard Shipping',
      'description': '5-7 business days',
      'price': 0.00,
      'icon': FeatherIcons.truck,
    },
    {
      'id': 'express',
      'name': 'Express Shipping',
      'description': '2-3 business days',
      'price': 15.99,
      'icon': FeatherIcons.zap,
    },
    {
      'id': 'overnight',
      'name': 'Overnight Delivery',
      'description': 'Next business day',
      'price': 29.99,
      'icon': FeatherIcons.clock,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _updateProgress();
    futureInit = myInit();
  }

  void _updateProgress() {
    final progress = (_currentStep + 1) / _totalSteps;
    _progressController.animateTo(progress);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FutureBuilder(
        future: futureInit,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return mainWidget();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(FeatherIcons.arrowLeft, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Checkout',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(FeatherIcons.helpCircle, color: CustomTheme.primary),
          onPressed: _showHelpDialog,
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Checkout Help'),
            content: const Text(
              'Fill in your shipping information, select a shipping method, and complete your payment to place your order.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // Main submit order function
  Future<void> submitOrder() async {
    item = await LoggedInUserModel.getLoggedInUser();

    if (!_fKey.currentState!.validate()) {
      Utils.toast('Fix some errors first.', color: Colors.red.shade700);
      return;
    }
    setState(() {
      error_message = "";
      is_loading = true;
    });

    RespondModel resp = RespondModel(
      await Utils.http_post('orders', {
        'items': jsonEncode(mainController.cartItems),
        'delivery': jsonEncode(item),
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

    await CartItem.deleteAll();

    setState(() {
      error_message = "";
      is_loading = false;
    });
    Utils.toast('Order submitted successfully!', isLong: true);

    Navigator.pop(context);
    return;
  }

  Widget mainWidget() {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: RefreshIndicator(
        backgroundColor: Colors.white,
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
                        child: Column(
                          children: [
                            FormBuilderTextField(
                              decoration: CustomTheme.in_3(label: "First name"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                return null;
                              },
                              initialValue: item.name,
                              textCapitalization: TextCapitalization.words,
                              name: "first_name",
                              onChanged: (x) {
                                item.name = x.toString();
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 15),
                            FormBuilderTextField(
                              decoration: CustomTheme.in_3(label: "Last name"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                return null;
                              },
                              initialValue: item.name,
                              textCapitalization: TextCapitalization.words,
                              name: "last_name",
                              onChanged: (x) {
                                item.name = x.toString();
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 15),
                            FormBuilderTextField(
                              decoration: CustomTheme.in_3(
                                label: "Phone number",
                              ),
                              initialValue: item.phone_number,
                              textCapitalization: TextCapitalization.words,
                              name: "phone_number_1",
                              onChanged: (x) {
                                item.phone_number = x.toString();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 15),
                            FormBuilderTextField(
                              decoration: CustomTheme.in_3(
                                label: "Alternative Phone number",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                return null;
                              },
                              initialValue: item.phone_number_2,
                              textCapitalization: TextCapitalization.words,
                              name: "phone_number_2",
                              onChanged: (x) {
                                item.phone_number_2 = x.toString();
                              },
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 15),
                            FormBuilderTextField(
                              decoration: CustomTheme.in_3(label: "Address"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                return null;
                              },
                              initialValue: item.address,
                              textCapitalization: TextCapitalization.words,
                              name: "address",
                              onChanged: (x) {
                                item.address = x.toString();
                              },
                              keyboardType: TextInputType.streetAddress,
                              textInputAction: TextInputAction.done,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FxContainer(
              borderRadiusAll: 0,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              color: CustomTheme.primary.withAlpha(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodySmall('TOTAL', height: .8),
                      Obx(
                        () => (FxText.titleLarge(
                          '\$ ${Utils.moneyFormat('${mainController.tot}')}',
                          fontWeight: 800,
                          color: Colors.black,
                        )),
                      ),
                    ],
                  ),
                  is_loading
                      ? const CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CustomTheme.primary,
                        ),
                      )
                      : FxButton(
                        borderRadiusAll: 200,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        borderColor: CustomTheme.primary,
                        onPressed: () {
                          Get.defaultDialog(
                            middleText: "Confirm order submission",
                            titleStyle: const TextStyle(color: Colors.black),
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
                                child: FxText(
                                  'CANCEL',
                                  color: CustomTheme.primary,
                                ),
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
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                        child: FxText.titleLarge(
                          'SUBMIT ORDER',
                          fontWeight: 800,
                          color: Colors.white,
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

  late Future<dynamic> futureInit;

  Future<dynamic> doRefresh() async {
    futureInit = myInit();
    setState(() {});
  }

  List<Product> items = [];

  Future<dynamic> myInit() async {
    item = await LoggedInUserModel.getLoggedInUser();
    await mainController.getCartItems();
    return "Done";
  }

  /// Shows order success dialog and clears cart
  void _showOrderSuccessDialog(Map<String, dynamic> paymentResult) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 48, color: Colors.green[600]),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Thank you for your order. You will receive a confirmation email shortly.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Amount: \$${paymentResult['amount']?.toStringAsFixed(2) ?? '0.00'} CAD',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _clearCartAndGoHome();
                },
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
    );
  }

  /// Clears cart and navigates back to shop
  void _clearCartAndGoHome() async {
    try {
      await CartItem.deleteAll();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print('Error clearing cart: $e');
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
