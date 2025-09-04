import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/screens/onboarding/modern_onboarding_screen.dart';

import '../../../../../controllers/CartController.dart';
import '../../../../../controllers/MainController.dart';
import '../../../../../models/LoggedInUserModel.dart';
import '../../../../../models/RespondModel.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/CartItem.dart';
import '../../../models/OrderOnline.dart';
import '../orders/MyOrdersScreen.dart';

class ImprovedCheckoutScreen extends StatefulWidget {
  final OrderOnline order;

  const ImprovedCheckoutScreen(this.order, {Key? key}) : super(key: key);

  @override
  _ImprovedCheckoutScreenState createState() => _ImprovedCheckoutScreenState();
}

class _ImprovedCheckoutScreenState extends State<ImprovedCheckoutScreen> {
  final CartController cartController = Get.find<CartController>();
  final MainController mainController = Get.put(MainController());

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    _initializeOrder();
  }

  Future<void> _initializeOrder() async {
    try {
      // Ensure user data is loaded
      await mainController.getLoggedInUser();
      await LoggedInUserModel.getLoggedInUser();

      // Update order with latest cart information
      await _updateOrderDetails();
    } catch (e) {
      errorMessage.value = "Error initializing order: ${e.toString()}";
    }
  }

  Future<void> _updateOrderDetails() async {
    try {
      LoggedInUserModel user = await LoggedInUserModel.getLoggedInUser();

      if (user.id > 0) {
        widget.order.user = user.id.toString();
        widget.order.mail = user.email;
        widget.order.customer_name = '${user.first_name} ${user.last_name}';
        widget.order.customer_phone_number_1 = user.phone_number;
        widget.order.customer_phone_number_2 = user.phone_number_2;
      }

      // Update with latest cart totals
      widget.order.order_total = cartController.subtotal.value.toString();
      widget.order.payable_amount = cartController.total.toString();
      widget.order.delivery_method = cartController.deliveryMethod.value;
      widget.order.delivery_amount =
          cartController.actualDeliveryFee.toString();

      if (cartController.deliveryMethod.value == 'delivery') {
        widget.order.delivery_address_id = cartController.selectedAddressId;
        widget.order.delivery_address_text = cartController.selectedAddress;
      }
    } catch (e) {
      print('Error updating order details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildOrderSummaryCard(),
                    const SizedBox(height: 20),
                    _buildCustomerDetailsCard(),
                    const SizedBox(height: 20),
                    _buildDeliveryDetailsCard(),
                  ],
                ),
              ),
            ),

            // Error Message
            Obx(
              () =>
                  errorMessage.value.isNotEmpty
                      ? _buildErrorMessage()
                      : const SizedBox(),
            ),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
                "Review and confirm order",
                color: CustomTheme.color2,
                fontWeight: 500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
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
              color: CustomTheme.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FeatherIcons.info, color: CustomTheme.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FxText.bodyMedium(
              "Please review your order details carefully before proceeding with payment.",
              color: CustomTheme.colorLight,
              fontWeight: 500,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.color4.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
            child: Obx(
              () => Column(
                children: [
                  _buildSummaryRow(
                    'Order Items',
                    'Total amount for ${cartController.itemCount} items',
                    'UGX ${Utils.moneyFormat(cartController.subtotal.value.toString())}',
                    FeatherIcons.shoppingCart,
                  ),
                  const SizedBox(height: 16),

                  _buildSummaryRow(
                    'Tax (13% VAT)',
                    'Value Added Tax',
                    'UGX ${Utils.moneyFormat(cartController.tax.toString())}',
                    FeatherIcons.percent,
                  ),
                  const SizedBox(height: 16),

                  _buildSummaryRow(
                    cartController.deliveryMethod.value == 'pickup'
                        ? 'Pickup Cost'
                        : 'Delivery Cost',
                    cartController.deliveryMethod.value == 'pickup'
                        ? 'Free pickup at store'
                        : 'Home delivery service',
                    cartController.deliveryMethod.value == 'pickup'
                        ? 'FREE'
                        : 'UGX ${Utils.moneyFormat(cartController.actualDeliveryFee.toString())}',
                    cartController.deliveryMethod.value == 'pickup'
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
                          "UGX ${Utils.moneyFormat(cartController.total.toString())}",
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
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.color4.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CustomTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FeatherIcons.user,
                    color: CustomTheme.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                FxText.titleMedium(
                  "Customer Details",
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

          // Customer Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('Name', widget.order.customer_name),
                const SizedBox(height: 12),
                _buildDetailRow('Email', widget.order.mail),
                const SizedBox(height: 12),
                _buildDetailRow('Phone', widget.order.customer_phone_number_1),
                if (widget.order.customer_phone_number_2.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Alt. Phone',
                    widget.order.customer_phone_number_2,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailsCard() {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CustomTheme.color4.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: CustomTheme.color4.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      cartController.deliveryMethod.value == 'pickup'
                          ? FeatherIcons.mapPin
                          : FeatherIcons.truck,
                      color: CustomTheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FxText.titleMedium(
                    cartController.deliveryMethod.value == 'pickup'
                        ? "Pickup Details"
                        : "Delivery Details",
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

            // Delivery Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Method',
                    cartController.deliveryMethod.value == 'pickup'
                        ? 'Store Pickup'
                        : 'Home Delivery',
                  ),
                  const SizedBox(height: 12),

                  if (cartController.deliveryMethod.value == 'pickup') ...[
                    _buildDetailRow(
                      'Pickup Location',
                      'Lovebirds Store, Kampala',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Pickup Fee', 'FREE'),
                  ] else ...[
                    _buildDetailRow(
                      'Delivery Address',
                      cartController.selectedAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Delivery Fee',
                      'UGX ${Utils.moneyFormat(cartController.actualDeliveryFee.toString())}',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    String subtitle,
    String amount,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: FxText.bodyMedium(
            label,
            color: CustomTheme.color2,
            fontWeight: 600,
          ),
        ),
        Expanded(
          child: FxText.bodyMedium(
            value.isNotEmpty ? value : 'Not provided',
            color:
                value.isNotEmpty ? CustomTheme.colorLight : CustomTheme.color2,
            fontWeight: value.isNotEmpty ? 500 : 400,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
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
              errorMessage.value,
              color: Colors.red,
              fontWeight: 600,
              maxLines: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.background,
        border: Border(
          top: BorderSide(
            color: CustomTheme.color4.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.color4.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => isLoading.value ? _buildLoadingButton() : _buildCheckoutButton(),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: CustomTheme.primary.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FxText.bodyMedium(
                "Processing order...",
                color: Colors.white,
                fontWeight: 700,
              ),
              const SizedBox(height: 4),
              FxText.bodySmall(
                "Please wait while we process your order",
                color: Colors.white.withOpacity(0.8),
                fontWeight: 500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
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
        onPressed: _submitOrder,
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
    );
  }

  Future<void> _submitOrder() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Update order details before submission
      await _updateOrderDetails();

      // Validate order
      if (widget.order.user.isEmpty) {
        throw Exception('User authentication required. Please login again.');
      }

      if (cartController.isEmpty) {
        throw Exception('Cart is empty. Please add items to cart.');
      }

      // Prepare order data
      Map<String, dynamic> delivery = widget.order.toJson();

      // Ensure phone numbers are properly set
      delivery['phone_number_2'] =
          widget.order.customer_phone_number_2.isEmpty
              ? widget.order.customer_phone_number_1
              : widget.order.customer_phone_number_2;
      delivery['phone_number_1'] =
          widget.order.customer_phone_number_1.isEmpty
              ? mainController.userModel.phone_number
              : widget.order.customer_phone_number_1;
      delivery['phone_number'] = delivery['phone_number_1'];

      // Submit order to API
      RespondModel resp = RespondModel(
        await Utils.http_post('orders-create', {
          'items': jsonEncode(cartController.cartItems),
          'delivery': jsonEncode(delivery),
        }),
      );

      if (resp.code != 1) {
        throw Exception(
          resp.message.isNotEmpty ? resp.message : 'Order submission failed',
        );
      }

      // Update order with response
      OrderOnline submittedOrder = OrderOnline.fromJson(resp.data);
      if (submittedOrder.id < 1) {
        throw Exception('Order processing failed. Please try again.');
      }

      // Clear cart after successful order
      await CartItem.deleteAll();
      await cartController.loadCartItems();

      // Show success message
      Get.snackbar(
        'Order Submitted Successfully!',
        'Your order #${submittedOrder.id} has been received. You can now view and pay for your order.',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
        icon: Icon(FeatherIcons.checkCircle, color: Colors.white),
      );

      // Navigate to My Orders screen so user can see their order and pay
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.offAll(() => const MyOrdersScreen());
    } catch (e) {
      errorMessage.value = e.toString();

      Get.snackbar(
        'Order Submission Failed',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
        icon: Icon(FeatherIcons.alertCircle, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
