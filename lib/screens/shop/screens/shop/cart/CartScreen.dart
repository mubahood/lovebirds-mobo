import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../controllers/CartController.dart';
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
  final CartController cartController = Get.put(CartController());
  final MainController mainController = Get.put(MainController());

  // State variables for delivery and checkout
  String selectedDeliveryMethod = 'pickup';
  String? selectedAddress;
  int? selectedAddressId;
  OrderOnline order = OrderOnline();

  @override
  void initState() {
    super.initState();
    cartController.loadCartItems();
    // Initialize order with user details
    _initializeOrder();
  }

  Future<void> _initializeOrder() async {
    await mainController.getLoggedInUser();
    await mainController.getCartItems();
    // Sync cartController with mainController data
    List<CartItem> items = mainController.cartItems.cast<CartItem>();
    cartController.cartItems.assignAll(items);

    // Set user details in order
    if (mainController.userModel.email.isNotEmpty) {
      order.mail = mainController.userModel.email;
    }
    order.customer_name =
        '${mainController.userModel.first_name} ${mainController.userModel.last_name}';
    order.customer_phone_number_1 = mainController.userModel.phone_number;
    order.customer_phone_number_2 = mainController.userModel.phone_number_2;
    order.user = mainController.userModel.id.toString();

    setState(() {});
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
              onPressed: () => doRefresh(),
              icon: Icon(
                FeatherIcons.refreshCw,
                color: CustomTheme.color3,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: Obx(() => _buildMainWidget())),
    );
  }

  Widget _buildMainWidget() {
    return cartController.isEmpty ? _buildEmptyCart() : _buildCartWithItems();
  }

  Widget _buildCartWithItems() {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => cartController.loadCartItems(),
            backgroundColor: CustomTheme.background,
            color: CustomTheme.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartController.cartItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildCartItemCard(
                  cartController.cartItems[index],
                  index,
                );
              },
            ),
          ),
        ),

        // Order Summary
        _buildCartSummary(),
      ],
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
                color: CustomTheme.color4.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CustomTheme.color4.withOpacity(0.3),
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

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CustomTheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate back to products screen
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(FeatherIcons.shoppingBag, size: 18),
                label: FxText.bodyMedium(
                  "Start Shopping",
                  fontWeight: 600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: cartItemWidget(item, mainController, index),
    );
  }

  Widget _buildCartSummary() {
    // Calculate total from cart items directly
    double total = 0.0;
    for (var item in cartController.cartItems) {
      double itemPrice = Utils.double_parse(item.product_price_1);
      int itemQuantity = Utils.int_parse(item.product_quantity);
      total += (itemQuantity * itemPrice);
    }

    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.3),
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
                  color: CustomTheme.color4.withOpacity(0.3),
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
                  'Order Summary',
                  color: CustomTheme.colorLight,
                  fontWeight: 700,
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
                  'UGX ${Utils.moneyFormat(total.toString())}',
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  selectedDeliveryMethod == 'pickup'
                      ? 'Pickup Fee'
                      : 'Delivery Fee',
                  selectedDeliveryMethod == 'pickup' ? 'FREE' : 'UGX 5,000',
                ),
                const SizedBox(height: 8),
                Container(
                  height: 0.5,
                  color: CustomTheme.color4.withOpacity(0.3),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Total',
                  'UGX ${Utils.moneyFormat((total + (selectedDeliveryMethod == 'pickup' ? 0 : 5000)).toString())}',
                  isTotal: true,
                ),

                const SizedBox(height: 20),

                // Delivery Method Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomTheme.color4.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CustomTheme.color4.withOpacity(0.1),
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
                              onTap: () {
                                setState(() {
                                  selectedDeliveryMethod = 'pickup';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      selectedDeliveryMethod == 'pickup'
                                          ? CustomTheme.primary.withOpacity(0.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        selectedDeliveryMethod == 'pickup'
                                            ? CustomTheme.primary
                                            : CustomTheme.color4.withOpacity(
                                              0.3,
                                            ),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      FeatherIcons.mapPin,
                                      size: 16,
                                      color:
                                          selectedDeliveryMethod == 'pickup'
                                              ? CustomTheme.primary
                                              : CustomTheme.color2,
                                    ),
                                    const SizedBox(width: 8),
                                    FxText.bodySmall(
                                      "Pickup",
                                      color:
                                          selectedDeliveryMethod == 'pickup'
                                              ? CustomTheme.primary
                                              : CustomTheme.color2,
                                      fontWeight:
                                          selectedDeliveryMethod == 'pickup'
                                              ? 600
                                              : 500,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDeliveryMethod = 'delivery';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      selectedDeliveryMethod == 'delivery'
                                          ? CustomTheme.primary.withOpacity(0.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        selectedDeliveryMethod == 'delivery'
                                            ? CustomTheme.primary
                                            : CustomTheme.color4.withOpacity(
                                              0.3,
                                            ),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      FeatherIcons.truck,
                                      size: 16,
                                      color:
                                          selectedDeliveryMethod == 'delivery'
                                              ? CustomTheme.primary
                                              : CustomTheme.color2,
                                    ),
                                    const SizedBox(width: 8),
                                    FxText.bodySmall(
                                      "Delivery",
                                      color:
                                          selectedDeliveryMethod == 'delivery'
                                              ? CustomTheme.primary
                                              : CustomTheme.color2,
                                      fontWeight:
                                          selectedDeliveryMethod == 'delivery'
                                              ? 600
                                              : 500,
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
                          onTap: () => _selectDeliveryAddress(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  selectedAddress != null
                                      ? CustomTheme.accent.withOpacity(0.1)
                                      : CustomTheme.color4.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    selectedAddress != null
                                        ? CustomTheme.accent.withOpacity(0.3)
                                        : CustomTheme.color4.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  FeatherIcons.home,
                                  size: 16,
                                  color:
                                      selectedAddress != null
                                          ? CustomTheme.accent
                                          : CustomTheme.color2,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FxText.bodySmall(
                                    selectedAddress ??
                                        "Select delivery address",
                                    color:
                                        selectedAddress != null
                                            ? CustomTheme.colorLight
                                            : CustomTheme.color2,
                                    fontWeight:
                                        selectedAddress != null ? 500 : 400,
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

                      // Pickup Location Info (shown only when pickup is selected)
                      if (selectedDeliveryMethod == 'pickup') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CustomTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                FeatherIcons.info,
                                size: 16,
                                color: CustomTheme.accent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FxText.bodySmall(
                                  "Pickup at ${AppConfig.APP_NAME} Store, Kampala",
                                  color: CustomTheme.colorLight,
                                  fontWeight: 500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Checkout Button
                Container(
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
                    onPressed: () {
                      _handleCheckout();
                    },
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
                    label: FxText.bodyMedium(
                      "Proceed to Checkout",
                      fontWeight: 600,
                      color: Colors.white,
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
          fontWeight: isTotal ? 700 : 500,
        ),
        FxText.bodyMedium(
          value,
          color: isTotal ? CustomTheme.primary : CustomTheme.colorLight,
          fontWeight: isTotal ? 700 : 600,
        ),
      ],
    );
  }

  Future<dynamic> doRefresh() async {
    order.delivery_method = "delivery";
    await myInit();
    // Sync cartController with mainController data after refresh
    List<CartItem> items = mainController.cartItems.cast<CartItem>();
    cartController.cartItems.assignAll(items);
    setState(() {});
  }

  Future<dynamic> myInit() async {
    await mainController.getLoggedInUser();
    await mainController.getCartItems();

    // Loop through cart items to get product details
    for (var element in mainController.cartItems) {
      if (element.pro.id < 1) {
        await element.getPro();
      }
    }

    // Set user details in order
    if (mainController.userModel.email.length > 3) {
      order.mail = mainController.userModel.email;
    }
    order.customer_name =
        '${mainController.userModel.first_name} ${mainController.userModel.last_name}';
    order.customer_phone_number_1 = mainController.userModel.phone_number;
    order.customer_phone_number_2 = mainController.userModel.phone_number_2;

    return "Done";
  }

  // Method to handle delivery address selection
  void _selectDeliveryAddress() async {
    final result = await Get.to(() => DeliveryAddressScreen(order));
    if (result != null) {
      setState(() {
        selectedAddress = result['address'];
        selectedAddressId = result['id'];
      });
    }
  }

  // Method to handle checkout with validation
  void _handleCheckout() {
    // Validate delivery address if delivery method is selected
    if (selectedDeliveryMethod == 'delivery' && selectedAddress == null) {
      Get.snackbar(
        'Address Required',
        'Please select a delivery address to continue',
        backgroundColor: CustomTheme.primary.withOpacity(0.9),
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
    order.delivery_amount = selectedDeliveryMethod == 'pickup' ? '0' : '5000';
    if (selectedDeliveryMethod == 'delivery' && selectedAddressId != null) {
      order.delivery_address_id = selectedAddressId!.toString();
      order.delivery_address_text = selectedAddress ?? '';
    }

    // Proceed to checkout
    Get.to(() => CheckoutScreen(order));
  }
}
