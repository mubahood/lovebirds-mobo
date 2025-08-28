// lib/screens/products/MyProductsScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/screens/shop/screens/shop/widgets.dart';

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
      barrierColor: CustomTheme.background.withValues(alpha: .5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CustomTheme.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: ListTile(
              leading: Icon(FeatherIcons.plus, color: CustomTheme.primary),
              title: FxText.titleMedium(
                "Post new product",
                fontWeight: 800,
                color: CustomTheme.accent,
              ),
              onTap: () async {
                Navigator.pop(context);
                await Get.to(() => const ProductCreateScreen({}));
                await doRefresh();
                doRefresh();
              },
            ),
          ),
    );
  }

  void _showAdminOnlyDialog() {
    Get.defaultDialog(
      title: "Admin Access Required",
      titleStyle: TextStyle(
        color: CustomTheme.primary,
        fontWeight: FontWeight.bold,
      ),
      middleText:
          "Only administrators can post products.\n\nContact support for seller verification.",
      middleTextStyle: TextStyle(color: CustomTheme.color, fontSize: 16),
      backgroundColor: CustomTheme.card,
      radius: 16,
      actions: [
        FxButton(
          backgroundColor: CustomTheme.primary,
          onPressed: () => Get.back(),
          child: FxText.bodyMedium(
            "Understood",
            color: Colors.white,
            fontWeight: 600,
          ),
        ),
      ],
    );
  }

  void _showProductOptions(Product m) {
    showModalBottomSheet(
      context: context,
      barrierColor: CustomTheme.background.withValues(alpha: .5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: CustomTheme.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(FeatherIcons.eye, color: CustomTheme.primary),
                  title: FxText.bodyLarge("View Product"),
                  trailing: Icon(
                    FeatherIcons.chevronRight,
                    color: CustomTheme.primary,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => ProductScreen(m));
                  },
                ),
                if (currentUser.id == 1) ...[
                  ListTile(
                    leading: Icon(
                      FeatherIcons.edit2,
                      color: CustomTheme.primary,
                    ),
                    title: FxText.bodyLarge("Edit Product"),
                    trailing: Icon(
                      FeatherIcons.chevronRight,
                      color: CustomTheme.primary,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => ProductCreateScreen({'item': m}));
                    },
                  ),
                  ListTile(
                    leading: Icon(FeatherIcons.trash2, color: Colors.redAccent),
                    title: FxText.bodyLarge("Delete Product"),
                    trailing: Icon(
                      FeatherIcons.chevronRight,
                      color: Colors.redAccent,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final confirm = await Get.defaultDialog<bool>(
                        title: "Delete this product?",
                        middleText: "Are you sure?",
                        actions: [
                          FxButton.outlined(
                            onPressed: () => Get.back(result: false),
                            borderColor: CustomTheme.primary,
                            child: FxText.bodySmall(
                              "CANCEL",
                              color: CustomTheme.primary,
                            ),
                          ),
                          FxButton(
                            backgroundColor: Colors.redAccent,
                            onPressed: () => Get.back(result: true),
                            child: FxText.bodySmall(
                              "DELETE",
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );

                      if (confirm == true) {
                        setState(() => is_loading = true);
                        try {
                          await Product.deleteProduct(m.id);
                          Utils.toast(
                            "Product deleted successfully.",
                            color: Colors.green,
                          );
                          await doRefresh();
                        } catch (e) {
                          Utils.toast(
                            "Failed to delete product: $e",
                            color: Colors.red,
                          );
                        }
                        setState(() => is_loading = false);
                      }
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: Icon(FeatherIcons.lock, color: Colors.grey),
                    title: FxText.bodyLarge(
                      "Admin Access Required",
                      color: Colors.grey,
                    ),
                    subtitle: FxText.bodySmall(
                      "Only administrators can edit or delete products",
                      color: Colors.grey[600],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showAdminOnlyDialog();
                    },
                  ),
                ],
              ],
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
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
        itemCount: products.length,
        separatorBuilder:
            (_, __) => Divider(color: CustomTheme.color4, height: 0),
        itemBuilder: (_, i) {
          final m = products[i];
          return InkWell(
            onTap: () => _showProductOptions(m),
            child: productWidget2(m),
          );
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
              ? FloatingActionButton(
                backgroundColor: CustomTheme.primary,
                onPressed: _showNewProductSheet,
                child: const Icon(FeatherIcons.plus),
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
