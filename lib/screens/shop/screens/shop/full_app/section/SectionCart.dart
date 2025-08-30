import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../../controllers/MainController.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/Utilities.dart';
import '../../../../models/Product.dart';
import '../../ProductCreateScreen.dart';

class SectionCart extends StatefulWidget {
  final MainController mainController;

  const SectionCart(this.mainController, {Key? key}) : super(key: key);

  @override
  _SectionCartState createState() => _SectionCartState();
}

class _SectionCartState extends State<SectionCart> {
  late Future<dynamic> futureInit;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureInit = myInit();
  }

  Future<dynamic> myInit() async {
    await widget.mainController.getCartItems();
    return "Done";
  }

  Future<dynamic> doRefresh() async {
    await widget.mainController.getMyProducts();
    setState(() {});
    return "Done";
  }

  void _showAddProductSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: CustomTheme.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(
                color: CustomTheme.color4.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CustomTheme.color3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CustomTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FeatherIcons.plus,
                          color: CustomTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FxText.titleMedium(
                              "Add New Product",
                              fontWeight: 700,
                              color: CustomTheme.colorLight,
                            ),
                            FxText.bodySmall(
                              "Create a new product listing",
                              color: CustomTheme.color2,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 0.5,
                  color: CustomTheme.color4.withOpacity(0.3),
                ),

                // Action Button
                Container(
                  padding: const EdgeInsets.all(20),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const ProductCreateScreen({}));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: CustomTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FeatherIcons.plus,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          FxText.bodyMedium(
                            "Create Product",
                            color: Colors.white,
                            fontWeight: 600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 0,
        systemOverlayStyle: Utils.overlay(),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CustomTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CustomTheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: CustomTheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: _showAddProductSheet,
          child: Icon(FeatherIcons.plus, color: Colors.white, size: 20),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: futureInit,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return _buildLoadingWidget();
              default:
                return Obx(() => _buildMainWidget());
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          FxText.bodyMedium("Loading cart items...", color: CustomTheme.color2),
        ],
      ),
    );
  }

  Widget _buildMainWidget() {
    // Simulating empty cart for now - replace with actual cart logic
    final cartItems = <Product>[];

    if (cartItems.isEmpty) {
      return _buildEmptyCart();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: RefreshIndicator(
        backgroundColor: CustomTheme.background,
        color: CustomTheme.primary,
        onRefresh: () => doRefresh(),
        child: ListView.separated(
          itemCount: cartItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final product = cartItems[index];
            return _buildCartItemCard(product);
          },
        ),
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
                  // Navigate to products screen
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

  Widget _buildCartItemCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CustomTheme.color4.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    product.feature_photo.isNotEmpty
                        ? Image.network(
                          "${Utils.img(product.feature_photo)}",
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: CustomTheme.color4.withOpacity(0.1),
                                child: Icon(
                                  FeatherIcons.package,
                                  color: CustomTheme.color3,
                                  size: 32,
                                ),
                              ),
                        )
                        : Container(
                          color: CustomTheme.color4.withOpacity(0.1),
                          child: Icon(
                            FeatherIcons.package,
                            color: CustomTheme.color3,
                            size: 32,
                          ),
                        ),
              ),
            ),

            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.titleMedium(
                    product.name,
                    maxLines: 2,
                    fontWeight: 700,
                    color: CustomTheme.colorLight,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CustomTheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FxText.bodySmall(
                      "UGX ${Utils.moneyFormat(product.price_1).toString().toUpperCase()}",
                      fontWeight: 700,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Quantity controls
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CustomTheme.color4.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityButton(FeatherIcons.minus, () {}),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: FxText.bodyMedium(
                                "1", // Quantity value
                                fontWeight: 600,
                                color: CustomTheme.colorLight,
                              ),
                            ),
                            _buildQuantityButton(FeatherIcons.plus, () {}),
                          ],
                        ),
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          FeatherIcons.trash2,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: CustomTheme.color2),
      ),
    );
  }
}
