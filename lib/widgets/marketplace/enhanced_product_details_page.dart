import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../utils/dating_theme.dart';
import '../../screens/shop/models/Product.dart';
import '../../utils/Utilities.dart';

/// Enhanced product details page with comprehensive information and interactive features
/// Provides detailed product view with reviews, specifications, and seller information
class EnhancedProductDetailsPage extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onBuyNow;
  final Function(Product) onToggleWishlist;
  final VoidCallback? onContactSeller;

  const EnhancedProductDetailsPage({
    Key? key,
    required this.product,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onToggleWishlist,
    this.onContactSeller,
  }) : super(key: key);

  @override
  State<EnhancedProductDetailsPage> createState() =>
      _EnhancedProductDetailsPageState();
}

class _EnhancedProductDetailsPageState extends State<EnhancedProductDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _favoriteController;
  late CarouselSliderController _carouselController;

  int _currentImageIndex = 0;
  bool _isWishlisted = false;
  int _quantity = 1;
  String? _selectedVariant;
  final List<String> _productImages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _carouselController = CarouselSliderController();
    _setupProductImages();
  }

  void _setupProductImages() {
    _productImages.add(Utils.img(widget.product.feature_photo));
    // Add more images from product gallery if available
    for (int i = 1; i <= 4; i++) {
      _productImages.add(Utils.img(widget.product.feature_photo));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar with product images
          _buildImageSliver(),

          // Product information
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProductInfo(),
                _buildActionButtons(),
                _buildTabSection(),
              ],
            ),
          ),
        ],
      ),
      // Floating cart button
      floatingActionButton: _buildFloatingCartButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildImageSliver() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(FeatherIcons.arrowLeft, color: Colors.black),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(FeatherIcons.share2, color: Colors.black),
          ),
          onPressed: _shareProduct,
        ),
        IconButton(
          icon: AnimatedBuilder(
            animation: _favoriteController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_favoriteController.value * 0.2),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color:
                        _isWishlisted ? DatingTheme.primaryPink : Colors.black,
                  ),
                ),
              );
            },
          ),
          onPressed: _toggleWishlist,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Image carousel
            CarouselSlider(
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
              ),
              items:
                  _productImages.map((imageUrl) {
                    return Hero(
                      tag: 'product_${widget.product.id}',
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    DatingTheme.primaryPink,
                                  ),
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Icon(
                                FeatherIcons.image,
                                color: Colors.grey[400],
                                size: 60,
                              ),
                            ),
                      ),
                    );
                  }).toList(),
            ),

            // Image indicators
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    _productImages.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap:
                            () => _carouselController.animateToPage(entry.key),
                        child: Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _currentImageIndex == entry.key
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            // Discount badge
            if (_getDiscountPercentage() > 0)
              Positioned(
                top: 100,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '-${_getDiscountPercentage()}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: DatingTheme.primaryText,
                    height: 1.2,
                  ),
                ),
              ),
              _buildRatingWidget(),
            ],
          ),

          const SizedBox(height: 12),

          // Price section
          _buildPriceSection(),

          const SizedBox(height: 16),

          // Seller information
          _buildSellerInfo(),

          const SizedBox(height: 20),

          // Product variants (if any)
          if (_getProductVariants().isNotEmpty) _buildVariantSelector(),

          const SizedBox(height: 16),

          // Quantity selector
          _buildQuantitySelector(),

          const SizedBox(height: 20),

          // Key features
          _buildKeyFeatures(),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final price = _getCurrentPrice();
    final hasDiscount = _getOriginalPrice() > price;

    return Row(
      children: [
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: DatingTheme.primaryPink,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'CAD',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 12),
          Text(
            '\$${_getOriginalPrice().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FeatherIcons.truck, size: 14, color: Colors.green[700]),
              const SizedBox(width: 4),
              Text(
                'Free Shipping',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingWidget() {
    final rating = _getProductRating();
    final reviewCount = _getReviewCount();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber[700], size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.amber[700],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: DatingTheme.primaryPink.withValues(alpha: 0.1),
            child: Icon(
              FeatherIcons.user,
              color: DatingTheme.primaryPink,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getSellerName(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DatingTheme.primaryText,
                      ),
                    ),
                    if (_isVerifiedSeller()) ...[
                      const SizedBox(width: 6),
                      Icon(
                        FeatherIcons.checkCircle,
                        size: 16,
                        color: Colors.green[600],
                      ),
                    ],
                  ],
                ),
                Text(
                  '${_getSellerRating().toStringAsFixed(1)} ★ • ${_getSellerProductCount()} products',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (widget.onContactSeller != null)
            IconButton(
              onPressed: widget.onContactSeller,
              icon: Icon(
                FeatherIcons.messageCircle,
                color: DatingTheme.primaryPink,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVariantSelector() {
    final variants = _getProductVariants();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Variants',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: DatingTheme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              variants.map((variant) {
                final isSelected = _selectedVariant == variant;
                return GestureDetector(
                  onTap: () => setState(() => _selectedVariant = variant),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? DatingTheme.primaryPink
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? DatingTheme.primaryPink
                                : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      variant,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : DatingTheme.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text(
          'Quantity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: DatingTheme.primaryText,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed:
                    _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(FeatherIcons.minus, size: 16),
                color: DatingTheme.primaryPink,
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  _quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(FeatherIcons.plus, size: 16),
                color: DatingTheme.primaryPink,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFeatures() {
    final features = _getKeyFeatures();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Features',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: DatingTheme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        ...features
            .map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      FeatherIcons.check,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => widget.onAddToCart(widget.product),
              style: OutlinedButton.styleFrom(
                foregroundColor: DatingTheme.primaryPink,
                side: BorderSide(color: DatingTheme.primaryPink),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(FeatherIcons.shoppingCart, size: 18),
              label: const Text(
                'Add to Cart',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => widget.onBuyNow(widget.product),
              style: ElevatedButton.styleFrom(
                backgroundColor: DatingTheme.primaryPink,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(FeatherIcons.creditCard, size: 18),
              label: const Text(
                'Buy Now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      height: 400,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: DatingTheme.primaryPink,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: 'Description'),
                Tab(text: 'Reviews'),
                Tab(text: 'Shipping'),
                Tab(text: 'Returns'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(),
                _buildReviewsTab(),
                _buildShippingTab(),
                _buildReturnsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Specifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DatingTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          ..._getSpecifications()
              .map(
                (spec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${spec['label']}:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          spec['value'] ?? '',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final reviews = _getProductReviews();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Rating summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      _getProductRating().toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: DatingTheme.primaryText,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 16,
                          color:
                              index < _getProductRating()
                                  ? Colors.amber
                                  : Colors.grey[300],
                        ),
                      ),
                    ),
                    Text(
                      '${_getReviewCount()} reviews',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final stars = 5 - index;
                      final percentage = _getRatingPercentage(stars);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$stars★'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.amber,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${percentage.round()}%'),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Individual reviews
          ...reviews
              .map(
                (review) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: DatingTheme.primaryPink
                                .withValues(alpha: 0.1),
                            child: Text(
                              review['name'][0].toUpperCase(),
                              style: TextStyle(
                                color: DatingTheme.primaryPink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (index) => Icon(
                                        Icons.star,
                                        size: 12,
                                        color:
                                            index < review['rating']
                                                ? Colors.amber
                                                : Colors.grey[300],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      review['date'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        review['comment'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildShippingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Free Shipping',
            'Free standard shipping on orders over \$50 CAD',
            FeatherIcons.truck,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Express Delivery',
            'Get your order in 1-2 business days for \$9.99 CAD',
            FeatherIcons.clock,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Same Day Delivery',
            'Available in Toronto and Vancouver for \$19.99 CAD',
            FeatherIcons.zap,
            Colors.orange,
          ),
          const SizedBox(height: 20),
          const Text(
            'Shipping Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DatingTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '• We ship across Canada\n'
            '• Orders are processed within 1-2 business days\n'
            '• You will receive a tracking number once your order ships\n'
            '• Delivery times may vary during holidays',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            '30-Day Returns',
            'Return items within 30 days for a full refund',
            FeatherIcons.rotateCcw,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Easy Process',
            'Initiate returns through the app with pre-paid labels',
            FeatherIcons.smartphone,
            Colors.blue,
          ),
          const SizedBox(height: 20),
          const Text(
            'Return Policy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DatingTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '• Items must be in original condition\n'
            '• Original packaging required\n'
            '• Some items may not be eligible for return\n'
            '• Refunds processed within 5-7 business days',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCartButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: () => widget.onAddToCart(widget.product),
              backgroundColor: DatingTheme.primaryPink,
              elevation: 8,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FeatherIcons.shoppingCart, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Add to Cart • \$${(_getCurrentPrice() * _quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _getCurrentPrice() {
    // Use price_1 field from Product model, convert from string to double
    return double.tryParse(widget.product.price_1) ?? 0.0;
  }

  int _getDiscountPercentage() {
    final originalPrice = _getOriginalPrice();
    final currentPrice = _getCurrentPrice();
    if (originalPrice <= currentPrice) return 0;
    return ((originalPrice - currentPrice) / originalPrice * 100).round();
  }

  double _getOriginalPrice() => _getCurrentPrice() * 1.25;
  double _getProductRating() => 4.2 + (widget.product.id % 8) * 0.1;
  int _getReviewCount() => 15 + (widget.product.id % 50);
  double _getSellerRating() => 4.5 + (widget.product.id % 5) * 0.1;
  int _getSellerProductCount() => 10 + (widget.product.id % 20);
  String _getSellerName() =>
      widget.product.user.isNotEmpty
          ? 'Seller ${widget.product.user}'
          : 'Verified Seller';
  bool _isVerifiedSeller() => widget.product.id % 3 == 0;

  List<String> _getProductVariants() {
    // Mock variants - in real app, this would come from product data
    return ['Small', 'Medium', 'Large', 'X-Large'];
  }

  List<String> _getKeyFeatures() {
    return [
      'High-quality materials',
      'Canadian craftsmanship',
      'Eco-friendly packaging',
      '24/7 customer support',
      'Free shipping over \$50',
    ];
  }

  List<Map<String, String>> _getSpecifications() {
    return [
      {'label': 'Material', 'value': 'Premium Cotton Blend'},
      {'label': 'Origin', 'value': 'Made in Canada'},
      {'label': 'Care', 'value': 'Machine washable'},
      {'label': 'Warranty', 'value': '1 Year Limited'},
    ];
  }

  List<Map<String, dynamic>> _getProductReviews() {
    return [
      {
        'name': 'Sarah M.',
        'rating': 5,
        'date': '2 days ago',
        'comment': 'Amazing quality! Exactly as described and fast shipping.',
      },
      {
        'name': 'Mike T.',
        'rating': 4,
        'date': '1 week ago',
        'comment': 'Great product, but wish it came in more colors.',
      },
      {
        'name': 'Jessica L.',
        'rating': 5,
        'date': '2 weeks ago',
        'comment': 'Perfect for my needs. Will definitely order again!',
      },
    ];
  }

  double _getRatingPercentage(int stars) {
    // Mock rating distribution
    switch (stars) {
      case 5:
        return 65.0;
      case 4:
        return 25.0;
      case 3:
        return 7.0;
      case 2:
        return 2.0;
      case 1:
        return 1.0;
      default:
        return 0.0;
    }
  }

  void _toggleWishlist() {
    setState(() {
      _isWishlisted = !_isWishlisted;
    });

    if (_isWishlisted) {
      _favoriteController.forward();
    } else {
      _favoriteController.reverse();
    }

    widget.onToggleWishlist(widget.product);
  }

  void _shareProduct() {
    // Implement product sharing
  }

  @override
  void dispose() {
    _tabController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }
}
