import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../utils/CustomTheme.dart';
import '../../widgets/marketplace/enhanced_cart_widget.dart';
import '../../services/enhanced_cart_service.dart';
import '../../screens/shop/models/Product.dart';

/// Demo application showcasing all Phase 7.3 Shopping Cart Enhancement features
class Phase73DemoScreen extends StatefulWidget {
  @override
  _Phase73DemoScreenState createState() => _Phase73DemoScreenState();
}

class _Phase73DemoScreenState extends State<Phase73DemoScreen> {
  final EnhancedCartService _cartService = EnhancedCartService();

  @override
  void initState() {
    super.initState();
    _cartService.initialize();
    _addDemoProducts();
  }

  void _addDemoProducts() async {
    // Add some demo products to showcase the cart functionality
    final demoProducts = [
      Product(
        id: 1,
        name: 'Romantic Date Night Outfit',
        description: 'Perfect outfit for a special evening',
        price: 149.99,
        image: 'https://example.com/outfit.jpg',
        categoryId: 1,
        category: 'Fashion',
        sellerId: 101,
        slug: 'romantic-date-night-outfit',
        details: 'Beautiful dress perfect for romantic dinners',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      Product(
        id: 2,
        name: 'Couple\'s Cooking Experience',
        description: 'Learn to cook together with professional chef',
        price: 299.99,
        image: 'https://example.com/cooking.jpg',
        categoryId: 2,
        category: 'Experiences',
        sellerId: 102,
        slug: 'couples-cooking-experience',
        details: 'Private cooking class for two people',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      Product(
        id: 3,
        name: 'Love Letters Journal Set',
        description: 'Beautiful journals for writing love letters',
        price: 79.99,
        image: 'https://example.com/journal.jpg',
        categoryId: 3,
        category: 'Gifts',
        sellerId: 103,
        slug: 'love-letters-journal-set',
        details: 'Matching journals with romantic designs',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];

    // Add to cart with different options
    await _cartService.addToCart(
      product: demoProducts[0],
      quantity: 1,
      selectedSize: 'M',
      selectedColor: 'Red',
    );

    await _cartService.addToCart(product: demoProducts[1], quantity: 2);

    // Add to wishlist
    await _cartService.addToWishlist(demoProducts[2]);
    await _cartService.addToWishlist(demoProducts[0]);

    // Add to favorites
    await _cartService.addToFavorites(demoProducts[1]);
    await _cartService.addToFavorites(demoProducts[2]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: FxText.titleMedium(
          'Phase 7.3 - Shopping Cart Enhancement',
          color: Colors.white,
          fontWeight: 700,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomTheme.primary,
                    CustomTheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FxText.titleLarge(
                              'Shopping Cart Enhancement',
                              color: Colors.white,
                              fontWeight: 700,
                            ),
                            FxText.bodyMedium(
                              'Comprehensive cart system with persistence & features',
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatusChip('IMPLEMENTED ✅', Colors.green),
                      SizedBox(width: 10),
                      _buildStatusChip(
                        'Phase 7.3',
                        Colors.white.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Feature showcase cards
            FxText.titleMedium(
              '🛍️ Enhanced Features',
              color: CustomTheme.color,
              fontWeight: 600,
            ),
            SizedBox(height: 16),

            _buildFeatureCard(
              icon: Icons.shopping_cart,
              title: 'Comprehensive Shopping Cart',
              description:
                  'Item counter, quantity management, size/color options',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showEnhancedCartDemo(),
            ),

            _buildFeatureCard(
              icon: Icons.save,
              title: 'Cart Persistence Across Sessions',
              description: 'Cart items saved locally, restored on app restart',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showPersistenceDemo(),
            ),

            _buildFeatureCard(
              icon: Icons.tune,
              title: 'Quantity Management & Options',
              description:
                  'Size/color selection, quantity controls, custom options',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showOptionsDemo(),
            ),

            _buildFeatureCard(
              icon: Icons.bookmark,
              title: 'Wishlist and Favorites',
              description: 'Save items for later, organize preferences',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showWishlistDemo(),
            ),

            _buildFeatureCard(
              icon: Icons.message,
              title: 'Contact Seller Feature',
              description: 'Direct communication with sellers for inquiries',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showContactDemo(),
            ),

            _buildFeatureCard(
              icon: Icons.flash_on,
              title: 'Buy Now Option',
              description: 'Skip cart, immediate purchase with quick checkout',
              status: 'IMPLEMENTED ✅',
              onTap: () => _showBuyNowDemo(),
            ),

            SizedBox(height: 30),

            // Integration Status
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 28),
                      SizedBox(width: 12),
                      FxText.titleMedium(
                        'Integration Status: COMPLETE ✅',
                        color: Colors.green,
                        fontWeight: 700,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  FxText.bodyMedium(
                    '• Cart persistence with SharedPreferences\n'
                    '• Size and color variant support\n'
                    '• Wishlist and favorites management\n'
                    '• Contact seller functionality\n'
                    '• Buy now quick checkout option\n'
                    '• Canadian tax calculation (13% HST)\n'
                    '• Quantity controls with validation',
                    color: Colors.green.shade700,
                    height: 1.5,
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEnhancedCartDemo(),
                    icon: Icon(Icons.shopping_cart),
                    label: FxText.bodyMedium(
                      'Open Enhanced Cart',
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _resetCartDemo(),
                    icon: Icon(Icons.refresh),
                    label: FxText.bodyMedium(
                      'Reset Demo',
                      color: CustomTheme.primary,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CustomTheme.primary,
                      side: BorderSide(color: CustomTheme.primary),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required String status,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CustomTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: CustomTheme.primary, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FxText.bodyLarge(
                            title,
                            color: CustomTheme.color,
                            fontWeight: 600,
                          ),
                          SizedBox(height: 4),
                          FxText.bodySmall(
                            description,
                            color: CustomTheme.color2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusChip(status, Colors.green),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: CustomTheme.color2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: FxText.bodySmall(
        text,
        color: color == Colors.green ? Colors.green.shade700 : Colors.white,
        fontWeight: 600,
      ),
    );
  }

  void _showEnhancedCartDemo() {
    Get.to(() => EnhancedCartWidget());
  }

  void _showPersistenceDemo() {
    Get.snackbar(
      '💾 Cart Persistence',
      'Items in your cart are automatically saved and will be restored when you restart the app!',
      backgroundColor: Colors.blue.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  void _showOptionsDemo() {
    Get.snackbar(
      '⚙️ Product Options',
      'Each item can have size, color, and custom options. Quantity controls allow easy management!',
      backgroundColor: Colors.purple.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  void _showWishlistDemo() {
    Get.snackbar(
      '🔖 Wishlist & Favorites',
      'Save items for later purchasing or mark as favorites for quick access!',
      backgroundColor: Colors.orange.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  void _showContactDemo() {
    Get.snackbar(
      '💬 Contact Seller',
      'Ask questions about products directly to sellers with categorized inquiry types!',
      backgroundColor: Colors.teal.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  void _showBuyNowDemo() {
    Get.snackbar(
      '⚡ Buy Now',
      'Skip the cart and purchase immediately with expedited checkout process!',
      backgroundColor: Colors.red.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  void _resetCartDemo() async {
    await _cartService.clearCart();
    _cartService.wishlistItems.value = [];
    _cartService.favoriteItems.value = [];

    // Re-add demo products
    _addDemoProducts();

    Get.snackbar(
      '🔄 Demo Reset',
      'Cart demo has been reset with fresh sample products!',
      backgroundColor: CustomTheme.primary.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }
}
