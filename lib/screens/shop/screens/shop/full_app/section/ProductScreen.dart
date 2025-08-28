// lib/screens/shop/screens/shop/ProductScreen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../../controllers/MainController.dart';
import '../../../../../../models/RespondModel.dart';
import '../../../../../../utils/AppConfig.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/Utilities.dart';
import '../../../../../../widget/widgets.dart';
import '../../../../models/Product.dart';
import '../../../../models/ProductCategory.dart';
import '../../cart/CartScreen.dart';

class ProductScreen extends StatefulWidget {
  final MainController mainController;

  const ProductScreen(this.mainController, {Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<void> futureInit;
  List<Product> products = [];
  List<ProductCategory> cats = [];
  List<ProductCategory> banners = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    futureInit = _loadData();
    setState(() {});
  }

  Future<void> _loadData() async {
    final tempCats = await ProductCategory.getItems();
    banners.clear();
    cats.clear();
    for (final c in tempCats) {
      if (c.show_in_banner == 'Yes') banners.add(c);
      if (c.show_in_categories == 'Yes') cats.add(c);
    }
    products = await Product.getItems();
  }

  void _showActions(Product p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CustomTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) =>
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetTile(
                icon: FeatherIcons.eye,
                label: 'View Product',
                onTap: () {
                  Get.back();
                  Get.to(() => ProductScreen(widget.mainController));
                },
              ),
              _sheetTile(
                icon: FeatherIcons.edit2,
                label: 'Edit Product',
                onTap: () {
                  Utils.toast('Please use web portal to edit.');
                },
              ),
              _sheetTile(
                icon: FeatherIcons.trash2,
                label: 'Delete Product',
                onTap: () {
                  Get.back();
                  _confirmDelete(p);
                },
              ),
            ],
          ),
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: Icon(icon, color: CustomTheme.primary),
        title: FxText.bodyLarge(label),
        trailing: const Icon(
            FeatherIcons.chevronRight, color: CustomTheme.primary),
        onTap: onTap,
      );

  void _confirmDelete(Product p) {
    Get.defaultDialog(
      title: 'Delete Product?',
      middleText: 'Are you sure you want to delete this product?',
      actions: [
        FxButton.outlined(
          borderColor: CustomTheme.primary,
          onPressed: () => Get.back(),
          child: FxText.bodySmall('CANCEL', color: CustomTheme.primary),
        ),
        FxButton(
          backgroundColor: Colors.redAccent,
          onPressed: () async {
            Get.back();
            final resp = RespondModel(await Utils.http_post(
              'products-delete',
              {'id': p.id},
            ));
            if (resp.code == 1) {
              await Product.deleteProduct(p.id);
              await _refreshData();
              Utils.toast('Deleted successfully.');
            } else {
              Utils.toast('Failed: ${resp.message}');
            }
          },
          child: FxText.bodySmall('DELETE', color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      body: FutureBuilder<void>(
        future: futureInit,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildScreen();
        },
      ),
    );
  }

  Widget _buildScreen() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildContent()),
        Obx(() =>
        widget.mainController.cartItems.isNotEmpty
            ? _buildCartFooter()
            : const SizedBox()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: CustomTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset(AppConfig.logo_1, width: 48),
          const SizedBox(width: 12),
          Expanded(
            child: FxContainer(
              color: CustomTheme.card,
              borderRadiusAll: 12,
              child: Row(
                children: [
                  SizedBox(width: 8),
                  Icon(FeatherIcons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                      child: FxText.bodySmall('Search for products...', color: Colors.grey)),
                  Icon(FeatherIcons.filter, color: Colors.grey),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: CustomTheme.primary,
      backgroundColor: CustomTheme.background,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildCarousel()),
          SliverToBoxAdapter(child: _sectionTitle('Top Categories')),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: .8,
            ),
            delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildCategoryTile(cats[i]),
              childCount: cats.length,
            ),
          ),
          SliverToBoxAdapter(child: _sectionTitle('Top Selling Items')),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .75,
            ),
            delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildProductTile(products[i]),
              childCount: products.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        viewportFraction: 1,
        height: Get.width * .5,
      ),
      items: banners
          .map((b) =>
          CachedNetworkImage(
            imageUrl: Utils.img(b.banner_image),
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (_, __) =>
                ShimmerLoadingWidget(height: Get.width * .5),
            errorWidget: (_, __, ___) =>
                Image.asset(
                  AppConfig.NO_IMAGE,
                  fit: BoxFit.cover,
                ),
          ))
          .toList(),
    );
  }

  Widget _sectionTitle(String text) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: FxText.titleMedium(text.toUpperCase(),
            color: CustomTheme.primary, fontWeight: 700),
      );

  Widget _buildCategoryTile(ProductCategory c) {
    final size = Get.width / 4.5;
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl:
              '${AppConfig.MAIN_SITE_URL}/storage/${c.image}',
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  ShimmerLoadingWidget(height: double.infinity),
              errorWidget: (_, __, ___) => Image.asset(AppConfig.NO_IMAGE),
            ),
          ),
        ),
        const SizedBox(height: 6),
        FxText.bodySmall(c.category.toUpperCase(),
            color: CustomTheme.color, maxLines: 1),
      ],
    );
  }

  Widget _buildProductTile(Product p) {
    return FxContainer(
      color: CustomTheme.card,
      borderRadiusAll: 12,
      onTap: () => _showActions(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl:
              '${AppConfig.MAIN_SITE_URL}/storage/${p.feature_photo}',
              fit: BoxFit.cover,
              width: double.infinity,
              height: Get.width * .4,
              placeholder: (_, __) => ShimmerLoadingWidget(),
              errorWidget: (_, __, ___) => Image.asset(AppConfig.NO_IMAGE),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: FxText.titleSmall(p.name,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: FxText.bodySmall(
                    '${AppConfig.CURRENCY}${Utils.moneyFormat(p.price_1)}',
                    color: CustomTheme.primary,
                    fontWeight: 700,
                  ),
                ),
                FxCard(
                  color: CustomTheme.primary,
                  paddingAll: 6,
                  onTap: () => widget.mainController.addToCart(p),
                  child: const Icon(FeatherIcons.shoppingCart,
                      size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartFooter() {
    return InkWell(
      onTap: () => Get.to(() => const CartScreen()),
      child: Container(
        color: CustomTheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            FxText.bodySmall(
              'You have ${widget.mainController.cartItems
                  .length} items in cart',
              color: Colors.white,
            ),
            const Spacer(),
            FxText.bodySmall('CHECKOUT',
                color: Colors.white, fontWeight: 700),
            const SizedBox(width: 8),
            const Icon(FeatherIcons.chevronRight, color: Colors.white),
          ],
        ),
      ),
    );
  }
}