import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../controllers/CartController.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/CartItem.dart';
import 'CheckoutScreen.dart';
import 'DeliveryAddressScreen.dart';

class ImprovedCartScreen extends StatefulWidget {
  const ImprovedCartScreen({Key? key}) : super(key: key);

  @override
  _ImprovedCartScreenState createState() => _ImprovedCartScreenState();
}

class _ImprovedCartScreenState extends State<ImprovedCartScreen> {
  final CartController cartController = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    cartController.loadCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(() => cartController.isLoading.value
            ? _buildLoadingState()
            : cartController.isEmpty
                ? _buildEmptyCart()
                : _buildCartContent()),
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
              FeatherIcons.shoppingCart,
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
                "Shopping Cart",
                fontWeight: 700,
                color: CustomTheme.colorLight,
              ),
              Obx(() => FxText.bodySmall(
                "${cartController.itemCount} ${cartController.itemCount == 1 ? 'item' : 'items'}",
                color: CustomTheme.color2,
                fontWeight: 500,
              )),
            ],
          ),
        ],
      ),
      actions: [
        Obx(() => cartController.isNotEmpty
            ? IconButton(
                onPressed: () => _showClearCartDialog(),
                icon: Icon(
                  FeatherIcons.trash2,
                  color: CustomTheme.color2,
                  size: 20,
                ),
              )
            : const SizedBox()),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
          ),
          const SizedBox(height: 16),
          FxText.bodyMedium(
            "Loading cart...",
            color: CustomTheme.color2,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: CustomTheme.color4.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                FeatherIcons.shoppingCart,
                size: 64,
                color: CustomTheme.color4,
              ),
            ),
            const SizedBox(height: 24),
            FxText.titleLarge(
              "Your cart is empty",
              fontWeight: 700,
              color: CustomTheme.colorLight,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FxText.bodyMedium(
              "Add items to your cart to see them here. Start shopping to find great deals!",
              color: CustomTheme.color2,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: Icon(FeatherIcons.arrowLeft, size: 18),
              label: FxText.bodyMedium(
                "Continue Shopping",
                fontWeight: 600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        // Cart Items
        Expanded(
          child: RefreshIndicator(
            onRefresh: cartController.loadCartItems,
            backgroundColor: CustomTheme.background,
            color: CustomTheme.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartController.cartItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildCartItem(cartController.cartItems[index]);
              },
            ),
          ),
        ),
        
        // Order Summary
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.color4.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: CustomTheme.color4.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                Utils.img(item.product_feature_photo),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: CustomTheme.color4.withOpacity(0.1),
                  child: Icon(
                    FeatherIcons.image,
                    color: CustomTheme.color4,
                    size: 32,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: CustomTheme.color4.withOpacity(0.1),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyLarge(
                  item.product_name,
                  fontWeight: 700,
                  color: CustomTheme.colorLight,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                if (item.color.isNotEmpty || item.size.isNotEmpty) ...[
                  Row(
                    children: [
                      if (item.color.isNotEmpty) ...[
                        FxText.bodySmall(
                          "Color: ${item.color}",
                          color: CustomTheme.color2,
                        ),
                        if (item.size.isNotEmpty) const SizedBox(width: 12),
                      ],
                      if (item.size.isNotEmpty)
                        FxText.bodySmall(
                          "Size: ${item.size}",
                          color: CustomTheme.color2,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    FxText.titleMedium(
                      "UGX ${Utils.moneyFormat(item.product_price_1)}",
                      fontWeight: 700,
                      color: CustomTheme.primary,
                    ),
                    
                    // Quantity Controls
                    Row(
                      children: [
                        _buildQuantityButton(
                          icon: FeatherIcons.minus,
                          onPressed: () {
                            int qty = Utils.int_parse(item.product_quantity);
                            if (qty > 1) {
                              cartController.updateQuantity(item.product_id, qty - 1);
                            }
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CustomTheme.color4.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FxText.bodyMedium(
                            item.product_quantity,
                            fontWeight: 600,
                            color: CustomTheme.colorLight,
                          ),
                        ),
                        _buildQuantityButton(
                          icon: FeatherIcons.plus,
                          onPressed: () {
                            int qty = Utils.int_parse(item.product_quantity);
                            cartController.updateQuantity(item.product_id, qty + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Remove Button
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => cartController.removeFromCart(item.product_id),
            icon: Icon(
              FeatherIcons.x,
              color: Colors.red.withOpacity(0.7),
              size: 18,
            ),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: CustomTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: CustomTheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: CustomTheme.primary,
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
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
      child: Column(
        children: [
          // Summary Details Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CustomTheme.color4.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CustomTheme.color4.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Obx(() {
              return Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: CustomTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          FeatherIcons.fileText,
                          color: CustomTheme.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FxText.titleMedium(
                        "Order Summary",
                        fontWeight: 700,
                        color: CustomTheme.colorLight,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Summary rows
                  _buildSummaryRow(
                    'Subtotal',
                    'UGX ${Utils.moneyFormat(cartController.subtotal.value.toString())}',
                  ),
                  const SizedBox(height: 8),
                  
                  // Delivery Method Section
                  _buildDeliveryMethodSection(),
                  
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    cartController.deliveryMethod.value == 'pickup' ? 'Pickup Fee' : 'Delivery Fee',
                    cartController.deliveryMethod.value == 'pickup' ? 'FREE' : 'UGX ${Utils.moneyFormat(cartController.actualDeliveryFee.toString())}',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Tax (13%)',
                    'UGX ${Utils.moneyFormat(cartController.tax.toString())}',
                  ),
                  
                  const SizedBox(height: 16),
                  Container(
                    height: 0.5,
                    color: CustomTheme.color4.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSummaryRow(
                    'Total',
                    'UGX ${Utils.moneyFormat(cartController.total.toString())}',
                    isTotal: true,
                  ),
                ],
              );
            }),
          ),
          
          // Checkout Button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
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
                label: FxText.bodyLarge(
                  "Proceed to Checkout",
                  fontWeight: 700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.2),
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
          const SizedBox(height: 8),
          
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildDeliveryOption(
                  'pickup',
                  'Pickup',
                  FeatherIcons.mapPin,
                  cartController.deliveryMethod.value == 'pickup',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDeliveryOption(
                  'delivery',
                  'Delivery',
                  FeatherIcons.truck,
                  cartController.deliveryMethod.value == 'delivery',
                ),
              ),
            ],
          )),
          
          // Address Selection (shown only when delivery is selected)
          Obx(() => cartController.deliveryMethod.value == 'delivery'
              ? Column(
                  children: [
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _selectDeliveryAddress,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cartController.selectedAddress.value.isNotEmpty
                              ? CustomTheme.accent.withOpacity(0.1)
                              : CustomTheme.color4.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: cartController.selectedAddress.value.isNotEmpty
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
                              color: cartController.selectedAddress.value.isNotEmpty
                                  ? CustomTheme.accent
                                  : CustomTheme.color2,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FxText.bodySmall(
                                cartController.selectedAddress.value.isEmpty
                                    ? "Select delivery address"
                                    : cartController.selectedAddress.value,
                                color: cartController.selectedAddress.value.isNotEmpty
                                    ? CustomTheme.colorLight
                                    : CustomTheme.color2,
                                fontWeight: cartController.selectedAddress.value.isNotEmpty ? 500 : 400,
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
                )
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption(String value, String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => cartController.setDeliveryMethod(value),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? CustomTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? CustomTheme.primary
                : CustomTheme.color4.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? CustomTheme.primary : CustomTheme.color2,
            ),
            const SizedBox(width: 6),
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
          fontWeight: isTotal ? 800 : 600,
        ),
      ],
    );
  }

  void _selectDeliveryAddress() async {
    try {
      OrderOnline tempOrder = await cartController.createOrder();
      final result = await Get.to(() => DeliveryAddressScreen(tempOrder));
      if (result != null && result is Map<String, dynamic>) {
        cartController.setDeliveryAddress(
          result['address'] ?? '',
          result['id'] ?? '',
        );
      }
    } catch (e) {
      cartController.showMessage('Error opening address selection: ${e.toString()}', isError: true);
    }
  }

  void _handleCheckout() async {
    if (!cartController.validateOrder()) {
      return;
    }

    try {
      OrderOnline order = await cartController.createOrder();
      Get.to(() => CheckoutScreen(order));
    } catch (e) {
      cartController.showMessage('Error creating order: ${e.toString()}', isError: true);
    }
  }

  void _showClearCartDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: CustomTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CustomTheme.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  FeatherIcons.trash2,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              FxText.titleMedium(
                "Clear Cart",
                fontWeight: 700,
                color: CustomTheme.colorLight,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FxText.bodyMedium(
                "Are you sure you want to remove all items from your cart? This action cannot be undone.",
                color: CustomTheme.color2,
                fontWeight: 500,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: CustomTheme.color4, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: FxText.bodyMedium(
                        'Cancel',
                        color: CustomTheme.color2,
                        fontWeight: 600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        cartController.clearCart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: FxText.bodyMedium(
                        'Clear Cart',
                        color: Colors.white,
                        fontWeight: 700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
