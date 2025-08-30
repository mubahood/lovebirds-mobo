import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../controllers/MainController.dart';
import '../../../../controllers/SimpleCartManager.dart';
import '../../../../utils/AppConfig.dart';
import '../../../../utils/CustomTheme.dart';
import '../../../../utils/Utilities.dart';
import '../../models/Product.dart';
import '../../models/ProductCategory.dart';
import 'MyProductsScreen.dart';
import 'ProductScreen.dart';
import 'ProductSearchScreen.dart';
import 'cart/SimpleCartScreen.dart';
import 'orders/MyOrdersScreen.dart';

class ProductsScreen extends StatefulWidget {
  final Map<String, dynamic> params;

  const ProductsScreen(this.params, {Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<dynamic> futureInit;
  List<Product> products = [];
  ProductCategory category = ProductCategory();
  final MainController mainController = Get.find<MainController>();
  final SimpleCartManager cartManager = Get.put(SimpleCartManager());
  String _sortBy = 'newest'; // newest, price_low, price_high
  List<Product> _filteredProducts = [];
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    final p = widget.params["category"];
    if (p is ProductCategory) category = p;
    cartManager.loadCartItems(); // Load cart items
    _refresh();
  }

  Future<void> _refresh() async {
    futureInit = _load();
    setState(() {});
    await futureInit;
  }

  Future<String> _load() async {
    await mainController.getCategories();
    if (category.id > 0) {
      products = await Product.getItems(where: 'category = ${category.id}');
    } else {
      products = await Product.getItems();
    }
    _applySortAndFilter();
    return "OK";
  }

  void _applySortAndFilter() {
    _filteredProducts = List.from(products);

    // Apply sorting
    switch (_sortBy) {
      case 'price_low':
        _filteredProducts.sort(
          (a, b) => double.parse(
            a.price_1.replaceAll(',', ''),
          ).compareTo(double.parse(b.price_1.replaceAll(',', ''))),
        );
        break;
      case 'price_high':
        _filteredProducts.sort(
          (a, b) => double.parse(
            b.price_1.replaceAll(',', ''),
          ).compareTo(double.parse(a.price_1.replaceAll(',', ''))),
        );
        break;
      case 'rating':
        _filteredProducts.sort(
          (a, b) => (b.id).compareTo(a.id),
        ); // Placeholder for rating
        break;
      case 'newest':
      default:
        _filteredProducts.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [CustomTheme.primary, CustomTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: CustomTheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () async {
            // Show different options based on user ID
            if (mainController.loggedInUser.id == 1) {
              await Get.to(() => MyProductsScreen(mainController));
              _refresh();
            } else {
              // Navigate to My Orders screen for other users
              await Get.to(() => MyOrdersScreen());
              // No need to refresh as orders are handled separately
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  mainController.loggedInUser.id == 1
                      ? FeatherIcons.plus
                      : FeatherIcons.shoppingBag,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                FxText.bodySmall(
                  mainController.loggedInUser.id == 1 ? 'My Shop' : 'My Orders',
                  color: Colors.white,
                  fontWeight: 600,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomTheme.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white, size: 22),
        title: Container(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FxText.titleMedium(
                category.id > 0
                    ? category.category
                    : "${AppConfig.MARKETPLACE_NAME}",
                color: Colors.white,
                fontWeight: 600,
                maxLines: 1,
              ),
              if (_filteredProducts.isNotEmpty)
                FxText.bodySmall(
                  '${_filteredProducts.length} products',
                  color: CustomTheme.color3,
                  fontSize: 11,
                ),
            ],
          ),
        ),
        actions: [
          // View Toggle
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: CustomTheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CustomTheme.color4.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: IconButton(
              icon: Icon(
                _isGridView ? FeatherIcons.list : FeatherIcons.grid,
                color: CustomTheme.accent,
                size: 20,
              ),
              onPressed: () => setState(() => _isGridView = !_isGridView),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),

          // Sort Menu
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: CustomTheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CustomTheme.color4.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                FeatherIcons.filter,
                color: CustomTheme.accent,
                size: 20,
              ),
              color: CustomTheme.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                setState(() => _sortBy = value);
                _applySortAndFilter();
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'newest',
                      child: Row(
                        children: [
                          Icon(
                            FeatherIcons.clock,
                            size: 16,
                            color: CustomTheme.color2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Newest',
                            style: TextStyle(color: CustomTheme.colorLight),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'price_low',
                      child: Row(
                        children: [
                          Icon(
                            FeatherIcons.trendingUp,
                            size: 16,
                            color: CustomTheme.color2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Price: Low to High',
                            style: TextStyle(color: CustomTheme.colorLight),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'price_high',
                      child: Row(
                        children: [
                          Icon(
                            FeatherIcons.trendingDown,
                            size: 16,
                            color: CustomTheme.color2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Price: High to Low',
                            style: TextStyle(color: CustomTheme.colorLight),
                          ),
                        ],
                      ),
                    ),
                  ],
              padding: const EdgeInsets.all(8),
            ),
          ),

          // Filter Categories
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: CustomTheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CustomTheme.color4.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: IconButton(
              icon: Icon(
                FeatherIcons.layers,
                color: CustomTheme.accent,
                size: 20,
              ),
              onPressed: _showFilterSheet,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),

          // Search
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: CustomTheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CustomTheme.color4.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: IconButton(
              icon: Icon(
                FeatherIcons.search,
                color: CustomTheme.accent,
                size: 20,
              ),
              onPressed: () => Get.to(() => const ProductSearchScreen2()),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),

          // Cart
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: CustomTheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CustomTheme.color4.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    FeatherIcons.shoppingCart,
                    color: CustomTheme.accent,
                    size: 20,
                  ),
                  onPressed: () => Get.to(() => const SimpleCartScreen()),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                // Cart Badge
                Obx(() {
                  if (cartManager.cartItems.isEmpty) return const SizedBox();
                  return Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CustomTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: CustomTheme.background,
                          width: 1,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: FxText.bodySmall(
                        '${cartManager.cartItems.length}',
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: 700,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: futureInit,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildGrid();
        },
      ),
    );
  }

  Widget _buildGrid() {
    return RefreshIndicator(
      color: CustomTheme.primary,
      backgroundColor: CustomTheme.card,
      onRefresh: _refresh,
      child:
          _filteredProducts.isEmpty
              ? Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CustomTheme.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: CustomTheme.color4.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          FeatherIcons.shoppingBag,
                          size: 48,
                          color: CustomTheme.color3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FxText.titleMedium(
                        'No Products Found',
                        color: CustomTheme.colorLight,
                        fontWeight: 600,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      FxText.bodyMedium(
                        category.id > 0
                            ? 'No products available in this category yet.'
                            : 'No products available at the moment.',
                        color: CustomTheme.color2,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CustomTheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: InkWell(
                          onTap: _showFilterSheet,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FeatherIcons.layers,
                                  color: CustomTheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                FxText.bodyMedium(
                                  'Browse Categories',
                                  color: CustomTheme.primary,
                                  fontWeight: 600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.fromLTRB(6, 60, 6, 6),
                child: _isGridView ? _buildStaggeredGrid() : _buildListView(),
              ),
    );
  }

  Widget _buildStaggeredGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildEnhancedProductCard(_filteredProducts[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _filteredProducts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        return _buildListProductCard(_filteredProducts[index]);
      },
    );
  }

  Widget _buildEnhancedProductCard(Product pro) {
    // Calculate discount percentage for certain products
    final hasDiscount = pro.id % 4 == 0;
    final discountPercentage =
        hasDiscount ? (10 + (pro.id % 5) * 5) : 0; // 10%, 15%, 20%, etc.
    final originalPrice = double.parse(pro.price_1.replaceAll(',', ''));
    final discountedPrice =
        hasDiscount
            ? originalPrice * (1 - discountPercentage / 100)
            : originalPrice;
    final imageHeight =
        180.0 + (pro.id % 3) * 20; // Taller heights for portrait aspect ratio

    return InkWell(
      onTap: () => Get.to(() => ProductScreen(pro)),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: CustomTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: CustomTheme.color4.withOpacity(0.2),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with discount badge
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: Utils.img(pro.feature_photo),
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: CustomTheme.cardDark,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: CustomTheme.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: CustomTheme.cardDark,
                            child: Icon(
                              FeatherIcons.image,
                              color: CustomTheme.color3,
                              size: 32,
                            ),
                          ),
                    ),
                  ),

                  // Discount badge
                  if (hasDiscount)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CustomTheme.primary,
                              CustomTheme.primaryDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: CustomTheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: FxText.bodySmall(
                          '${discountPercentage}% OFF',
                          color: Colors.white,
                          fontWeight: 600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product information
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name - Single line only
                  FxText.bodyMedium(
                    pro.name,
                    fontWeight: 600,
                    color: CustomTheme.colorLight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 13,
                    height: 1.2,
                  ),

                  const SizedBox(height: 6),

                  // Price section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current price
                      FxText.bodyLarge(
                        '${AppConfig.CURRENCY} ${Utils.moneyFormat(discountedPrice.toStringAsFixed(0))}',
                        color: CustomTheme.primary,
                        fontWeight: 700,
                        fontSize: 15,
                      ),

                      if (hasDiscount) ...[
                        const SizedBox(height: 1),
                        // Original price (crossed out)
                        FxText.bodySmall(
                          '${AppConfig.CURRENCY} ${originalPrice.toStringAsFixed(0)}',
                          color: CustomTheme.color3,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 10,
                        ),
                      ],
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

  Widget _buildListProductCard(Product pro) {
    // Calculate discount percentage for certain products
    final hasDiscount = pro.id % 4 == 0;
    final discountPercentage =
        hasDiscount ? (10 + (pro.id % 5) * 5) : 0; // 10%, 15%, 20%, etc.
    final originalPrice = double.parse(pro.price_1.replaceAll(',', ''));
    final discountedPrice =
        hasDiscount
            ? originalPrice * (1 - discountPercentage / 100)
            : originalPrice;

    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => ProductScreen(pro)),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Product image with discount badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: CachedNetworkImage(
                        imageUrl: Utils.img(pro.feature_photo),
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => Container(
                              color: CustomTheme.cardDark,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: CustomTheme.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        errorWidget:
                            (_, __, ___) => Container(
                              color: CustomTheme.cardDark,
                              child: Icon(
                                FeatherIcons.image,
                                color: CustomTheme.color3,
                                size: 24,
                              ),
                            ),
                      ),
                    ),
                  ),

                  // Discount badge
                  if (hasDiscount)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CustomTheme.primary,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: CustomTheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: FxText.bodySmall(
                          '$discountPercentage%',
                          color: Colors.white,
                          fontWeight: 600,
                          fontSize: 8,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 10),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name - Single line only
                    FxText.bodyMedium(
                      pro.name,
                      fontWeight: 600,
                      color: CustomTheme.colorLight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 13,
                      height: 1.2,
                    ),

                    const SizedBox(height: 6),

                    // Price section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current price
                        FxText.bodyLarge(
                          '${AppConfig.CURRENCY} ${Utils.moneyFormat(discountedPrice.toStringAsFixed(0))}',
                          color: CustomTheme.primary,
                          fontWeight: 700,
                          fontSize: 14,
                        ),

                        if (hasDiscount) ...[
                          const SizedBox(height: 1),
                          // Original price (crossed out)
                          FxText.bodySmall(
                            '${AppConfig.CURRENCY} ${originalPrice.toStringAsFixed(0)}',
                            color: CustomTheme.color3,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 10,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow indicator
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
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
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              builder: (context, scrollCtrl) {
                return Column(
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
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            FeatherIcons.layers,
                            color: CustomTheme.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          FxText.titleMedium(
                            'Browse Categories',
                            color: CustomTheme.colorLight,
                            fontWeight: 600,
                          ),
                          const Spacer(),
                          if (category.id > 0)
                            InkWell(
                              onTap: () {
                                category = ProductCategory();
                                Navigator.pop(context);
                                _refresh();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CustomTheme.color4.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FxText.bodySmall(
                                  'Clear',
                                  color: CustomTheme.color2,
                                  fontWeight: 500,
                                ),
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

                    // Categories list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: mainController.categories.length,
                        itemBuilder: (context, index) {
                          final cat = mainController.categories[index];
                          final selected = cat.id == category.id;

                          return InkWell(
                            onTap: () {
                              category = cat;
                              Navigator.pop(context);
                              _refresh();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration:
                                  selected
                                      ? BoxDecoration(
                                        color: CustomTheme.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: CustomTheme.primary
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      )
                                      : null,
                              child: Row(
                                children: [
                                  Icon(
                                    FeatherIcons.tag,
                                    size: 16,
                                    color:
                                        selected
                                            ? CustomTheme.primary
                                            : CustomTheme.color2,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FxText.bodyMedium(
                                      cat.category,
                                      color:
                                          selected
                                              ? CustomTheme.primary
                                              : CustomTheme.colorLight,
                                      fontWeight: selected ? 600 : 500,
                                    ),
                                  ),
                                  if (selected)
                                    Icon(
                                      FeatherIcons.check,
                                      color: CustomTheme.primary,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }
}
