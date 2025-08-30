// lib/screens/products/MyProductsScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../controllers/MainController.dart';
import '../../../../models/LoggedInUserModel.dart';
import '../../../../utils/CustomTheme.dart';
import '../../../../utils/Utilities.dart';
import '../../models/Product.dart';
import 'ProductCreateScreen.dart';
import 'ProductScreen.dart';

class MyProductsScreen extends StatefulWidget {
  final MainController mainController;

  const MyProductsScreen(this.mainController, {Key? key}) : super(key: key);

  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  late Future<void> futureInit;
  bool is_loading = false;
  LoggedInUserModel currentUser = LoggedInUserModel();

  @override
  void initState() {
    super.initState();
    futureInit = my_init();
  }

  Future<void> my_init() async {
    currentUser = await LoggedInUserModel.getLoggedInUser();
    await widget.mainController.getMyProducts();
  }

  Future<void> doRefresh() async {
    await widget.mainController.getMyProducts();
    setState(() {});
  }

  void _showNewProductSheet() {
    // Check if user is admin (ID = 1)
    if (currentUser.id != 1) {
      _showAdminOnlyDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: BoxDecoration(
              color: CustomTheme.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
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
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CustomTheme.color3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await Get.to(() => const ProductCreateScreen({}));
                      await doRefresh();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CustomTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CustomTheme.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
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
                                FxText.bodyLarge(
                                  "Add New Product",
                                  fontWeight: 600,
                                  color: CustomTheme.colorLight,
                                ),
                                const SizedBox(height: 2),
                                FxText.bodySmall(
                                  "Create a new product listing",
                                  color: CustomTheme.color2,
                                  fontSize: 11,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            FeatherIcons.chevronRight,
                            color: CustomTheme.color3,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showAdminOnlyDialog() {
    Get.defaultDialog(
      title: "Admin Access Required",
      titleStyle: TextStyle(
        color: CustomTheme.colorLight,
        fontWeight: FontWeight.bold,
      ),
      middleText:
          "Only administrators can post products.\n\nContact support for seller verification.",
      middleTextStyle: TextStyle(color: CustomTheme.color2, fontSize: 14),
      backgroundColor: CustomTheme.card,
      radius: 12,
      actions: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CustomTheme.primary, CustomTheme.primaryDark],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FxText.bodyMedium(
                "Understood",
                color: Colors.white,
                fontWeight: 600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showProductOptions(Product m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: BoxDecoration(
              color: CustomTheme.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
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
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CustomTheme.color3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        FeatherIcons.package,
                        color: CustomTheme.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      FxText.titleMedium(
                        'Product Options',
                        color: CustomTheme.colorLight,
                        fontWeight: 600,
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 0.5,
                  color: CustomTheme.color4.withOpacity(0.3),
                ),

                const SizedBox(height: 8),

                // Options
                _buildOptionItem(
                  icon: FeatherIcons.eye,
                  title: "View Product",
                  subtitle: "See product details",
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => ProductScreen(m));
                  },
                ),

                if (currentUser.id == 1) ...[
                  _buildOptionItem(
                    icon: FeatherIcons.edit2,
                    title: "Edit Product",
                    subtitle: "Update product information",
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => ProductCreateScreen({'item': m}));
                    },
                  ),
                  _buildOptionItem(
                    icon: FeatherIcons.trash2,
                    title: "Delete Product",
                    subtitle: "Remove from your shop",
                    color: Colors.redAccent,
                    onTap: () async {
                      Navigator.pop(context);
                      final confirm = await _showDeleteConfirmation();
                      if (confirm == true) {
                        await _deleteProduct(m);
                      }
                    },
                  ),
                ] else ...[
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CustomTheme.card.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CustomTheme.color4.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FeatherIcons.lock,
                          color: CustomTheme.color3,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FxText.bodyMedium(
                                "Admin Access Required",
                                color: CustomTheme.color2,
                                fontWeight: 600,
                              ),
                              FxText.bodySmall(
                                "Only administrators can edit or delete products",
                                color: CustomTheme.color3,
                                fontSize: 11,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? CustomTheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: itemColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: itemColor, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.bodyMedium(
                      title,
                      color: CustomTheme.colorLight,
                      fontWeight: 600,
                    ),
                    FxText.bodySmall(
                      subtitle,
                      color: CustomTheme.color2,
                      fontSize: 11,
                    ),
                  ],
                ),
              ),
              Icon(
                FeatherIcons.chevronRight,
                color: CustomTheme.color3,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation() {
    return Get.defaultDialog<bool>(
      title: "Delete Product",
      titleStyle: TextStyle(
        color: CustomTheme.colorLight,
        fontWeight: FontWeight.bold,
      ),
      middleText:
          "Are you sure you want to delete this product? This action cannot be undone.",
      middleTextStyle: TextStyle(color: CustomTheme.color2, fontSize: 14),
      backgroundColor: CustomTheme.card,
      radius: 12,
      actions: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CustomTheme.color4.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () => Get.back(result: false),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: FxText.bodyMedium(
                      "Cancel",
                      color: CustomTheme.color2,
                      fontWeight: 600,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () => Get.back(result: true),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: FxText.bodyMedium(
                      "Delete",
                      color: Colors.white,
                      fontWeight: 600,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _deleteProduct(Product m) async {
    setState(() => is_loading = true);
    try {
      await Product.deleteProduct(m.id);
      Utils.toast("Product deleted successfully.", color: Colors.green);
      await doRefresh();
    } catch (e) {
      Utils.toast("Failed to delete product: $e", color: Colors.red);
    }
    setState(() => is_loading = false);
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showProductOptions(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
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

              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    FxText.titleMedium(
                      product.name,
                      maxLines: 2,
                      fontWeight: 700,
                      color: CustomTheme.colorLight,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Price
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

                    const SizedBox(height: 8),

                    // Category and Date Row
                    Row(
                      children: [
                        Icon(
                          FeatherIcons.tag,
                          size: 12,
                          color: CustomTheme.color3,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: FxText.bodySmall(
                            product.category.toUpperCase(),
                            color: CustomTheme.color2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 10,
                            fontWeight: 600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          FeatherIcons.clock,
                          size: 12,
                          color: CustomTheme.color3,
                        ),
                        const SizedBox(width: 4),
                        FxText.bodySmall(
                          Utils.to_date_1(product.date_added),
                          color: CustomTheme.color2,
                          fontSize: 10,
                          fontWeight: 500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Indicator
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CustomTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  FeatherIcons.moreVertical,
                  size: 16,
                  color: CustomTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mainWidget() {
    final products = widget.mainController.myProducts;
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FxText.titleLarge(
              "You have no products yet.",
              color: CustomTheme.color2,
            ),
            const SizedBox(height: 16),
            FxButton(
              backgroundColor: CustomTheme.primary,
              borderRadiusAll: 100,
              onPressed: doRefresh,
              child: FxText.titleSmall(
                "REFRESH",
                color: Colors.white,
                fontWeight: 800,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      backgroundColor: CustomTheme.background,
      color: CustomTheme.primary,
      onRefresh: doRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final m = products[i];
          return _buildProductCard(m);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 1,
        systemOverlayStyle: Utils.overlay(),
        title: FxText.titleLarge(
          "My Shop",
          color: CustomTheme.accent,
          fontWeight: 900,
        ),
        iconTheme: const IconThemeData(color: CustomTheme.accent),
      ),
      floatingActionButton:
          currentUser.id == 1
              ? Container(
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
                  onPressed: _showNewProductSheet,
                  child: const Icon(
                    FeatherIcons.plus,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )
              : null,
      body: FutureBuilder<void>(
        future: futureInit,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done || is_loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Obx(() => mainWidget());
        },
      ),
    );
  }
}
