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

  // Collapsible summary state
  bool isSummaryExpanded = true;

  @override
  void initState() {
    super.initState();
    cartController.loadCartItems();
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
              onPressed: () => _doRefresh(),
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

        // Order Summary (Collapsible)
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
                onPressed: () => Get.back(),
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
      margin: const EdgeInsets.all(16),
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
          // Summary Header (Always Visible & Clickable)
          InkWell(
            onTap: () {
              setState(() {
                isSummaryExpanded = !isSummaryExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    isSummaryExpanded
                        ? Border(
                          bottom: BorderSide(
                            color: CustomTheme.color4.withOpacity(0.3),
                            width: 0.5,
                          ),
                        )
                        : null,
                borderRadius:
                    isSummaryExpanded
                        ? const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        )
                        : BorderRadius.circular(12),
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
                  const Spacer(),
                  FxText.titleMedium(
                    'UGX ${Utils.moneyFormat((total + (selectedDeliveryMethod == 'pickup' ? 0 : 5000)).toString())}',
                    color: CustomTheme.primary,
                    fontWeight: 800,
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isSummaryExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      FeatherIcons.chevronDown,
                      color: CustomTheme.color3,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                isSummaryExpanded
                    ? _buildExpandedSummaryContent(total)
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedSummaryContent(double total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Summary Details
          _buildSummaryRow(
            'Subtotal',
            'UGX ${Utils.moneyFormat(total.toString())}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            selectedDeliveryMethod == 'pickup' ? 'Pickup Fee' : 'Delivery Fee',
            selectedDeliveryMethod == 'pickup' ? 'FREE' : 'UGX 5,000',
          ),
          const SizedBox(height: 8),
          Container(height: 0.5, color: CustomTheme.color4.withOpacity(0.3)),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Total',
            'UGX ${Utils.moneyFormat((total + (selectedDeliveryMethod == 'pickup' ? 0 : 5000)).toString())}',
            isTotal: true,
          ),

          const SizedBox(height: 20),

          // Delivery Method Section
          _buildDeliveryMethodSection(),

          const SizedBox(height: 20),

          // Checkout Button
          _buildCheckoutButton(),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodSection() {
    return Container(
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

          // Delivery Method Options
          Row(
            children: [
              Expanded(
                child: _buildDeliveryOption(
                  'pickup',
                  FeatherIcons.mapPin,
                  'Pickup',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeliveryOption(
                  'delivery',
                  FeatherIcons.truck,
                  'Delivery',
                ),
              ),
            ],
          ),

          // Address Selection (for delivery)
          if (selectedDeliveryMethod == 'delivery') ...[
            const SizedBox(height: 16),
            _buildAddressSelector(),
          ],

          // Pickup Info (for pickup)
          if (selectedDeliveryMethod == 'pickup') ...[
            const SizedBox(height: 12),
            _buildPickupInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryOption(String method, IconData icon, String label) {
    bool isSelected = selectedDeliveryMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDeliveryMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? CustomTheme.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? CustomTheme.primary
                    : CustomTheme.color4.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? CustomTheme.primary : CustomTheme.color2,
            ),
            const SizedBox(width: 8),
            FxText.bodySmall(
              label,
              color: isSelected ? CustomTheme.primary : CustomTheme.color2,
              fontWeight: isSelected ? 600 : 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelector() {
    return GestureDetector(
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
                selectedAddress ?? "Select delivery address",
                color:
                    selectedAddress != null
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
    );
  }

  Widget _buildPickupInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CustomTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(FeatherIcons.info, size: 16, color: CustomTheme.accent),
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
        onPressed: _handleCheckout,
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

  // Method to handle checkout with improved validation
  void _handleCheckout() async {
    try {
      // Validate cart is not empty
      if (cartController.isEmpty) {
        _showErrorMessage(
          'Cart is empty',
          'Please add items to your cart before proceeding',
        );
        return;
      }

      // Validate delivery address if delivery method is selected
      if (selectedDeliveryMethod == 'delivery' && selectedAddress == null) {
        _showErrorMessage(
          'Address Required',
          'Please select a delivery address to continue with delivery',
        );
        return;
      }

      // Validate user is logged in
      if (mainController.userModel.id <= 0) {
        _showErrorMessage(
          'Login Required',
          'Please login to proceed with checkout',
        );
        return;
      }

      // Show loading
      Utils.showLoading(message: "Preparing checkout...");

      // Set delivery information in order
      order.delivery_method = selectedDeliveryMethod;
      order.delivery_amount = selectedDeliveryMethod == 'pickup' ? '0' : '5000';

      if (selectedDeliveryMethod == 'delivery' && selectedAddressId != null) {
        order.delivery_address_id = selectedAddressId!.toString();
        order.delivery_address_text = selectedAddress ?? '';
      }

      // Calculate and set order totals
      double subtotal = 0.0;
      for (var item in cartController.cartItems) {
        double itemPrice = Utils.double_parse(item.product_price_1);
        int itemQuantity = Utils.int_parse(item.product_quantity);
        subtotal += (itemQuantity * itemPrice);
      }

      double deliveryFee = selectedDeliveryMethod == 'pickup' ? 0 : 5000;
      double total = subtotal + deliveryFee;

      order.order_total = subtotal.toString();
      order.payable_amount = total.toString();

      // Hide loading
      Utils.hideLoading();

      // Show success and proceed to checkout
      _showSuccessMessage(
        'Ready for Checkout',
        'Order total: UGX ${Utils.moneyFormat(total.toString())}',
      );

      // Navigate to checkout
      final result = await Get.to(() => CheckoutScreen(order));

      // Handle checkout result
      if (result != null && result['success'] == true) {
        // Clear cart on successful checkout
        await cartController.clearCart();
        Get.back(); // Return to previous screen
      }
    } catch (e) {
      Utils.hideLoading();
      _showErrorMessage(
        'Checkout Error',
        'Failed to prepare checkout: ${e.toString()}',
      );
    }
  }

  // Helper method to show error messages
  void _showErrorMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: Icon(FeatherIcons.alertCircle, color: Colors.white),
    );
  }

  // Helper method to show success messages
  void _showSuccessMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: CustomTheme.primary.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(FeatherIcons.checkCircle, color: Colors.white),
    );
  }

  Future<void> _doRefresh() async {
    order.delivery_method = "delivery";
    await _myInit();
    // Sync cartController with mainController data after refresh
    List<CartItem> items = mainController.cartItems.cast<CartItem>();
    cartController.cartItems.assignAll(items);
    setState(() {});
  }

  Future<String> _myInit() async {
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
}
