import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../utils/dating_theme.dart';
import '../../screens/shop/models/Product.dart';
import '../../utils/AppConfig.dart';
import '../../utils/Utilities.dart';

/// Modern Pinterest-style product grid with enhanced visual appeal
/// Replaces the basic product listing with engaging card-based design
class ModernProductGrid extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onProductTap;
  final Function(Product) onAddToCart;
  final Function(Product) onToggleWishlist;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const ModernProductGrid({
    Key? key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
    this.isLoading = false,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<ModernProductGrid> createState() => _ModernProductGridState();
}

class _ModernProductGridState extends State<ModernProductGrid>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final Set<int> _favoriteProducts = <int>{};
  final Map<int, AnimationController> _cardAnimations = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _setupCardAnimations();
  }

  void _setupCardAnimations() {
    for (int i = 0; i < widget.products.length; i++) {
      _cardAnimations[i] = AnimationController(
        duration: Duration(milliseconds: 300 + (i * 50)),
        vsync: this,
      );
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _cardAnimations[i]?.forward();
      });
    }
  }

  @override
  void didUpdateWidget(ModernProductGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.products.length != oldWidget.products.length) {
      _setupCardAnimations();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingGrid();
    }

    if (widget.products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh?.call();
      },
      color: DatingTheme.primaryPink,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Featured products banner (if any)
          if (_getFeaturedProducts().isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildFeaturedBanner()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],

          // Main product grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childCount: widget.products.length,
              itemBuilder: (context, index) {
                return _buildEnhancedProductCard(widget.products[index], index);
              },
            ),
          ),

          // Bottom padding for floating action button
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildEnhancedProductCard(Product product, int index) {
    final animation = _cardAnimations[index];
    final isWishlisted = _favoriteProducts.contains(product.id);

    return AnimatedBuilder(
      animation: animation ?? _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - (animation?.value ?? 1)) * 50),
          child: Opacity(
            opacity: animation?.value ?? 1,
            child: GestureDetector(
              onTap: () => widget.onProductTap(product),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image with overlay actions
                    _buildProductImageSection(product, isWishlisted),

                    // Product information
                    _buildProductInfoSection(product),

                    // Action buttons
                    _buildActionButtonsSection(product),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImageSection(Product product, bool isWishlisted) {
    final hasDiscount = _getDiscountPercentage(product) > 0;

    return Stack(
      children: [
        // Main product image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Hero(
              tag: 'product_${product.id}',
              child: CachedNetworkImage(
                imageUrl: Utils.img(product.feature_photo),
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildErrorImage(),
              ),
            ),
          ),
        ),

        // Discount badge
        if (hasDiscount)
          Positioned(
            top: 12,
            left: 12,
            child: _buildDiscountBadge(_getDiscountPercentage(product)),
          ),

        // Wishlist button
        Positioned(
          top: 12,
          right: 12,
          child: _buildWishlistButton(product, isWishlisted),
        ),

        // Quick view button
        Positioned(
          bottom: 12,
          right: 12,
          child: _buildQuickViewButton(product),
        ),

        // Product rating overlay
        if (_getProductRating(product) > 0)
          Positioned(bottom: 12, left: 12, child: _buildRatingBadge(product)),
      ],
    );
  }

  Widget _buildProductInfoSection(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DatingTheme.primaryText,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Seller info with verification
          _buildSellerInfo(product),

          const SizedBox(height: 12),

          // Price section
          _buildPriceSection(product),

          const SizedBox(height: 8),

          // Product tags
          if (_getProductTags(product).isNotEmpty) _buildProductTags(product),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSection(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Add to cart button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => widget.onAddToCart(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: DatingTheme.primaryPink,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(FeatherIcons.shoppingCart, size: 16),
              label: const Text(
                'Add to Cart',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Quick buy button
          Expanded(
            child: OutlinedButton(
              onPressed: () => _quickBuy(product),
              style: OutlinedButton.styleFrom(
                foregroundColor: DatingTheme.primaryPink,
                side: BorderSide(color: DatingTheme.primaryPink),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistButton(Product product, bool isWishlisted) {
    return GestureDetector(
      onTap: () => _toggleWishlist(product),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isWishlisted
                  ? DatingTheme.primaryPink
                  : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          color: isWishlisted ? Colors.white : DatingTheme.primaryPink,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildDiscountBadge(int discountPercentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '-$discountPercentage%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRatingBadge(Product product) {
    final rating = _getProductRating(product);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 12),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo(Product product) {
    return Row(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: DatingTheme.primaryPink.withValues(alpha: 0.2),
          child: Icon(
            FeatherIcons.user,
            size: 8,
            color: DatingTheme.primaryPink,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _getSellerName(product),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (_isVerifiedSeller(product))
          Icon(FeatherIcons.checkCircle, size: 12, color: Colors.green),
      ],
    );
  }

  Widget _buildPriceSection(Product product) {
    final hasDiscount = _getOriginalPrice(product) > product.cost;

    return Row(
      children: [
        Text(
          '\$${product.cost.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DatingTheme.primaryPink,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 8),
          Text(
            '\$${_getOriginalPrice(product).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
        const Spacer(),
        Text(
          'CAD',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProductTags(Product product) {
    final tags = _getProductTags(product);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children:
          tags
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: DatingTheme.primaryPink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      color: DatingTheme.primaryPink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildQuickViewButton(Product product) {
    return GestureDetector(
      onTap: () => _showQuickView(product),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(FeatherIcons.eye, size: 14, color: DatingTheme.primaryPink),
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    final featuredProducts = _getFeaturedProducts();

    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: PageView.builder(
        itemCount: featuredProducts.length,
        itemBuilder: (context, index) {
          final product = featuredProducts[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  DatingTheme.primaryPink.withValues(alpha: 0.8),
                  DatingTheme.primaryPink,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: Utils.img(product.feature_photo),
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.3),
                      colorBlendMode: BlendMode.overlay,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => widget.onProductTap(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: DatingTheme.primaryPink,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Shop Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(DatingTheme.primaryPink),
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: Icon(FeatherIcons.image, color: Colors.grey[400], size: 40),
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: 6,
        itemBuilder: (context, index) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 250 + (index % 2) * 50, // Varied heights
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 100, color: Colors.grey[300]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FeatherIcons.shoppingBag, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: DatingTheme.primaryPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Product> _getFeaturedProducts() {
    // Return products marked as featured (you can add a featured field to Product model)
    return widget.products.take(3).toList();
  }

  int _getDiscountPercentage(Product product) {
    final originalPrice = _getOriginalPrice(product);
    if (originalPrice <= product.cost) return 0;
    return ((originalPrice - product.cost) / originalPrice * 100).round();
  }

  double _getOriginalPrice(Product product) {
    // This would come from the product model - for now return price + 20%
    return product.cost * 1.2;
  }

  double _getProductRating(Product product) {
    // This would come from reviews - for now return a mock rating
    return 4.2 + (product.id % 10) * 0.1;
  }

  String _getSellerName(Product product) {
    // This would come from the seller/user relationship
    return product.sellerName ?? 'LoveBirds Seller';
  }

  bool _isVerifiedSeller(Product product) {
    // Check if seller is verified
    return product.id % 3 == 0; // Mock verification
  }

  List<String> _getProductTags(Product product) {
    // Extract tags from product categories or description
    return ['New', 'Popular'].where((tag) => product.id % 2 == 0).toList();
  }

  void _toggleWishlist(Product product) {
    setState(() {
      if (_favoriteProducts.contains(product.id)) {
        _favoriteProducts.remove(product.id);
      } else {
        _favoriteProducts.add(product.id);
      }
    });
    widget.onToggleWishlist(product);
  }

  void _quickBuy(Product product) {
    // Implement quick buy functionality
    widget.onAddToCart(product);
    // Navigate to checkout
  }

  void _showQuickView(Product product) {
    // Show quick view modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: CachedNetworkImage(
                              imageUrl: Utils.img(product.feature_photo),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${product.cost.toStringAsFixed(2)} CAD',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: DatingTheme.primaryPink,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onAddToCart(product);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DatingTheme.primaryPink,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text('Add to Cart'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onProductTap(product);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: DatingTheme.primaryPink,
                                  side: BorderSide(
                                    color: DatingTheme.primaryPink,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text('View Details'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _cardAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
