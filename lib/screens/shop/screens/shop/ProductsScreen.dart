import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../controllers/MainController.dart';
import '../../../../utils/AppConfig.dart';
import '../../../../utils/CustomTheme.dart';
import '../../../../utils/Utilities.dart';
import '../../models/Product.dart';
import '../../models/ProductCategory.dart';
import 'MyProductsScreen.dart';
import 'ProductScreen.dart';
import 'ProductSearchScreen.dart';

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
  String _sortBy = 'newest'; // newest, price_low, price_high
  List<Product> _filteredProducts = [];
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    final p = widget.params["category"];
    if (p is ProductCategory) category = p;
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomTheme.accent,
        icon: const Icon(FeatherIcons.tag, color: Colors.black),
        label: FxText.bodySmall(
          'My Shop',
          color: Colors.black,
          fontWeight: 700,
        ),
        onPressed: () async {
          await Get.to(() => MyProductsScreen(mainController));
          _refresh();
          _refresh();
        },
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomTheme.background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Align(
          alignment: Alignment.centerLeft,
          child: FxText.titleLarge(
            category.id > 0
                ? category.category
                : "${AppConfig.MARKETPLACE_NAME}",
            color: CustomTheme.accent,
            maxLines: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? FeatherIcons.list : FeatherIcons.grid,
              color: CustomTheme.accent,
              size: 24,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              FeatherIcons.moreVertical,
              color: CustomTheme.accent,
              size: 24,
            ),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _applySortAndFilter();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'newest', child: Text('Newest')),
                  const PopupMenuItem(
                    value: 'price_low',
                    child: Text('Price: Low to High'),
                  ),
                  const PopupMenuItem(
                    value: 'price_high',
                    child: Text('Price: High to Low'),
                  ),
                ],
          ),
          IconButton(
            icon: const Icon(
              FeatherIcons.alignRight,
              color: CustomTheme.accent,
              size: 24,
            ),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(
              FeatherIcons.search,
              color: CustomTheme.accent,
              size: 24,
            ),
            onPressed: () => Get.to(() => const ProductSearchScreen2()),
          ),
          const SizedBox(width: 8),
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
      onRefresh: _refresh,
      child:
          _filteredProducts.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FeatherIcons.shoppingBag,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    FxText.bodyLarge(
                      'No products in this category.',
                      color: CustomTheme.color,
                      fontWeight: 700,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FxButton.text(
                      onPressed: _showFilterSheet,
                      backgroundColor: CustomTheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: FxText.bodyMedium(
                        'CHANGE FILTER',
                        color: CustomTheme.primary,
                        fontWeight: 700,
                      ),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(12),
                child: _isGridView ? _buildStaggeredGrid() : _buildListView(),
              ),
    );
  }

  Widget _buildStaggeredGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildEnhancedProductCard(_filteredProducts[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _filteredProducts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
        160.0 + (pro.id % 3) * 20; // Varied heights for staggered effect

    return GestureDetector(
      onTap: () => Get.to(() => ProductScreen(pro)),
      child: Container(
        decoration: BoxDecoration(
          color: CustomTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CustomTheme.color4.withValues(alpha: 0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with discount badge
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
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
                            child: const Center(
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
                              size: 40,
                            ),
                          ),
                    ),
                  ),

                  // Discount badge (replaces wishlist)
                  if (hasDiscount)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CustomTheme.primary,
                              CustomTheme.primaryDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: CustomTheme.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FxText.bodySmall(
                          '$discountPercentage% OFF',
                          color: Colors.white,
                          fontWeight: 700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product information
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  FxText.bodyMedium(
                    pro.name,
                    fontWeight: 700,
                    color: CustomTheme.colorLight,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 15,
                  ),

                  const SizedBox(height: 12),

                  // Price section with crossed out original price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current price
                      FxText.bodyLarge(
                        '${AppConfig.CURRENCY} \$${Utils.moneyFormat(discountedPrice.toStringAsFixed(0))}',
                        color: CustomTheme.primary,
                        fontWeight: 700,
                        fontSize: 18,
                      ),

                      if (hasDiscount) ...[
                        const SizedBox(height: 3),
                        // Original price (crossed out)
                        FxText.bodySmall(
                          '${AppConfig.CURRENCY} \$${originalPrice.toStringAsFixed(0)}',
                          color: CustomTheme.color3,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 13,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomTheme.color4.withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => ProductScreen(pro)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image with discount badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CachedNetworkImage(
                        imageUrl: Utils.img(pro.feature_photo),
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => Container(
                              color: CustomTheme.cardDark,
                              child: const Center(
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
                                size: 30,
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
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CustomTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: CustomTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: FxText.bodySmall(
                          '$discountPercentage%',
                          color: Colors.white,
                          fontWeight: 700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    FxText.bodyMedium(
                      pro.name,
                      fontWeight: 700,
                      color: CustomTheme.colorLight,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 15,
                    ),

                    const SizedBox(height: 8),

                    // Price section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current price
                        FxText.bodyLarge(
                          '${AppConfig.CURRENCY} \$${discountedPrice.toStringAsFixed(0)}',
                          color: CustomTheme.primary,
                          fontWeight: 700,
                          fontSize: 16,
                        ),

                        if (hasDiscount) ...[
                          const SizedBox(height: 2),
                          // Original price (crossed out)
                          FxText.bodySmall(
                            '${AppConfig.CURRENCY} \$${originalPrice.toStringAsFixed(0)}',
                            color: CustomTheme.color3,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
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
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: CustomTheme.primary.withValues(alpha: .3),
      backgroundColor: CustomTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollCtrl) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 0,
                ),
                child: Column(
                  children: [
                    FxText.titleMedium('Filter by Category', fontWeight: 700),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        controller: scrollCtrl,
                        children:
                            mainController.categories.map((cat) {
                              final selected = cat.id == category.id;
                              return ListTile(
                                title: FxText.bodyLarge(
                                  cat.category,
                                  color:
                                      selected
                                          ? CustomTheme.primary
                                          : CustomTheme.color,
                                ),
                                trailing:
                                    selected
                                        ? Icon(
                                          Icons.check_circle,
                                          color: CustomTheme.primary,
                                        )
                                        : null,
                                onTap: () {
                                  category = cat;
                                  Navigator.pop(context);
                                  _refresh();
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
