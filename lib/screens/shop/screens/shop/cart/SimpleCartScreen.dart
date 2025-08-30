import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../controllers/SimpleCartManager.dart';
import '../../../../../controllers/MainController.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/CartItem.dart';
import '../../../models/OrderOnline.dart';
import 'SimpleCheckoutScreen.dart';
import 'DeliveryAddressScreen.dart';
import 'cartItemWidget.dart';

class SimpleCartScreen extends StatefulWidget {
  const SimpleCartScreen({Key? key}) : super(key: key);

  @override
  _SimpleCartScreenState createState() => _SimpleCartScreenState();
}

class _SimpleCartScreenState extends State<SimpleCartScreen> {
  final SimpleCartManager cartManager = Get.put(SimpleCartManager());
  final MainController mainController = Get.put(MainController());
  
  String selectedDeliveryMethod = 'pickup';
  String? selectedAddress;
  int? selectedAddressId;
  double selectedDeliveryFee = 0.0;
  OrderOnline order = OrderOnline();

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    await cartManager.loadCartItems();
    await _initializeOrder();
  }

  Future<void> _initializeOrder() async {
    await mainController.getLoggedInUser();
    
    // Set user details in order
    order.user = mainController.userModel.id.toString();
    order.mail = mainController.userModel.email;
    order.customer_name = '${mainController.userModel.first_name} ${mainController.userModel.last_name}';
    order.customer_phone_number_1 = mainController.userModel.phone_number;
    order.customer_phone_number_2 = mainController.userModel.phone_number_2;
    order.delivery_method = selectedDeliveryMethod;
    
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
                FeatherIcons.shoppingCart,
                color: CustomTheme.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            FxText.titleLarge(
              "Shopping Cart",
              fontWeight: 900,
              color: CustomTheme.accent,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => _initializeCart(),
              icon: Icon(
                FeatherIcons.refreshCw,
                color: CustomTheme.color3,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() => cartManager.isEmpty ? _buildEmptyCart() : _buildCartWithItems()),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CustomTheme.color4.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CustomTheme.color4.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Icon(
                FeatherIcons.shoppingCart,
                color: CustomTheme.color3,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            FxText.titleLarge(
              "Your Cart is Empty",
              fontWeight: 700,
              color: CustomTheme.colorLight,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FxText.bodyMedium(
              "Start shopping and add products to your cart to see them here",
              color: CustomTheme.color2,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: Icon(FeatherIcons.shoppingBag, size: 20),
              label: FxText.bodyMedium(
                "Continue Shopping",
                color: Colors.white,
                fontWeight: 600,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartWithItems() {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => cartManager.loadCartItems(),
            backgroundColor: CustomTheme.background,
            color: CustomTheme.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartManager.cartItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildCartItemCard(cartManager.cartItems[index], index);
              },
            ),
          ),
        ),
        // Order Summary
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: cartItemWidget(item, mainController, index),
    );
  }

  Widget _buildOrderSummary() {
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
          // Summary Header
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
                _buildSummaryRow(
                  'Subtotal',
                  'UGX ${Utils.moneyFormat(cartManager.subtotal.toString())}',
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Tax (13% VAT)',
                  'UGX ${Utils.moneyFormat(cartManager.tax.toString())}',
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  selectedDeliveryMethod == 'pickup' ? 'Pickup Fee' : 'Delivery Fee',
                  selectedDeliveryMethod == 'pickup' 
                    ? 'FREE' 
                    : 'UGX ${Utils.moneyFormat(selectedDeliveryFee.toString())}',
                ),
                const SizedBox(height: 8),
                Container(
                  height: 0.5,
                  color: CustomTheme.color4.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Total',
                  'UGX ${Utils.moneyFormat(cartManager.totalAmount(selectedDeliveryMethod).toString())}',
                  isTotal: true,
                ),
                const SizedBox(height: 20),

                // Delivery Method Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomTheme.color4.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CustomTheme.color4.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyMedium(
                        "Delivery Method",
                        fontWeight: 600,
                        color: CustomTheme.colorLight,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDeliveryMethod('pickup'),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selectedDeliveryMethod == 'pickup'
                                      ? CustomTheme.primary.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedDeliveryMethod == 'pickup'
                                        ? CustomTheme.primary
                                        : CustomTheme.color4.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      FeatherIcons.mapPin,
                                      size: 16,
                                      color: selectedDeliveryMethod == 'pickup'
                                          ? CustomTheme.primary
                                          : CustomTheme.color2,
                                    ),
                                    const SizedBox(width: 8),
                                    FxText.bodySmall(
                                      "Pickup",
                                      color: selectedDeliveryMethod == 'pickup'
                                          ? CustomTheme.primary
                                          : CustomTheme.color2,
                                      fontWeight: selectedDeliveryMethod == 'pickup' ? 600 : 500,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDeliveryMethod('delivery'),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selectedDeliveryMethod == 'delivery'
                                      ? CustomTheme.primary.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedDeliveryMethod == 'delivery'
                                        ? CustomTheme.primary
                                        : CustomTheme.color4.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      FeatherIcons.truck,
                                      size: 16,
                                      color: selectedDeliveryMethod == 'delivery'
                                          ? CustomTheme.primary
                                          : CustomTheme.color2,
                                    ),
                                    const SizedBox(width: 8),
                                    FxText.bodySmall(
                                      "Delivery",
                                      color: selectedDeliveryMethod == 'delivery'
                                          ? CustomTheme.primary
                                          : CustomTheme.color2,
                                      fontWeight: selectedDeliveryMethod == 'delivery' ? 600 : 500,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Delivery Address Selection (shown only when delivery is selected)
                      if (selectedDeliveryMethod == 'delivery') ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _selectDeliveryAddress,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedAddress != null
                                  ? CustomTheme.accent.withValues(alpha: 0.1)
                                  : CustomTheme.color4.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selectedAddress != null
                                    ? CustomTheme.accent.withValues(alpha: 0.3)
                                    : CustomTheme.color4.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  FeatherIcons.home,
                                  size: 16,
                                  color: selectedAddress != null
                                      ? CustomTheme.accent
                                      : CustomTheme.color2,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FxText.bodySmall(
                                    selectedAddress ?? "Select delivery address",
                                    color: selectedAddress != null
                                        ? CustomTheme.colorLight
                                        : CustomTheme.color2,
                                    fontWeight: selectedAddress != null ? 500 : 400,
                                  ),
                                ),
                                Icon(
                                  FeatherIcons.chevronRight,
                                  size: 16,
                                  color: CustomTheme.color2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FeatherIcons.creditCard,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        FxText.titleMedium(
                          "Proceed to Checkout",
                          color: Colors.white,
                          fontWeight: 700,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FxText.bodyMedium(
          label,
          color: isTotal ? CustomTheme.colorLight : CustomTheme.color2,
          fontWeight: isTotal ? 600 : 500,
        ),
        FxText.bodyMedium(
          value,
          color: isTotal ? CustomTheme.primary : CustomTheme.colorLight,
          fontWeight: isTotal ? 700 : 600,
        ),
      ],
    );
  }

  void _selectDeliveryMethod(String method) {
    setState(() {
      selectedDeliveryMethod = method;
      if (method == 'pickup') {
        selectedDeliveryFee = 0.0;
        selectedAddress = null;
        selectedAddressId = null;
      } else {
        selectedDeliveryFee = 5000.0; // Default delivery fee
      }
      order.delivery_method = method;
    });
  }

  void _selectDeliveryAddress() async {
    final result = await Get.to(() => DeliveryAddressScreen(order));
    if (result != null) {
      setState(() {
        selectedAddress = result['address'];
        selectedAddressId = result['id'];
        if (result['shipping_cost'] != null) {
          selectedDeliveryFee = Utils.double_parse(result['shipping_cost']);
        }
      });
    }
  }

  void _handleCheckout() {
    // Validate delivery address if delivery method is selected
    if (selectedDeliveryMethod == 'delivery' && selectedAddress == null) {
      Get.snackbar(
        'Address Required',
        'Please select a delivery address to continue',
        backgroundColor: CustomTheme.primary.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: Icon(FeatherIcons.alertCircle, color: Colors.white),
      );
      return;
    }

    // Set delivery information in order
    order.delivery_method = selectedDeliveryMethod;
    order.delivery_amount = selectedDeliveryFee.toString();
    if (selectedDeliveryMethod == 'delivery' && selectedAddressId != null) {
      order.delivery_address_id = selectedAddressId!.toString();
      order.delivery_address_text = selectedAddress ?? '';
    }

    // Set calculated amounts
    order.payable_amount = cartManager.totalAmount(selectedDeliveryMethod).toString();

    // Proceed to checkout
    Get.to(() => SimpleCheckoutScreen(order, cartManager));
  }
}
