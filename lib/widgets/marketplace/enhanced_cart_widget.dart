import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import '../../services/enhanced_cart_service.dart';
import '../../screens/shop/models/Product.dart';
import '../../utils/CustomTheme.dart';

class EnhancedCartWidget extends StatefulWidget {
  const EnhancedCartWidget({Key? key}) : super(key: key);

  @override
  _EnhancedCartWidgetState createState() => _EnhancedCartWidgetState();
}

class _EnhancedCartWidgetState extends State<EnhancedCartWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final EnhancedCartService _cartService = EnhancedCartService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cartService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: ValueListenableBuilder<List<EnhancedCartItem>>(
          valueListenable: _cartService.cartItems,
          builder: (context, cartItems, _) {
            return Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                const SizedBox(width: 8),
                FxText.titleMedium(
                  'Shopping Cart',
                  color: Colors.white,
                  fontWeight: 700,
                ),
                if (cartItems.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FxText.bodySmall(
                      '${_cartService.totalItems}',
                      color: Colors.white,
                      fontWeight: 600,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart),
                  const SizedBox(width: 4),
                  ValueListenableBuilder<List<EnhancedCartItem>>(
                    valueListenable: _cartService.cartItems,
                    builder: (context, items, _) {
                      return items.isNotEmpty
                          ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: FxText.bodySmall(
                              '${items.length}',
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          )
                          : SizedBox.shrink();
                    },
                  ),
                ],
              ),
              text: 'Cart',
            ),
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark),
                  const SizedBox(width: 4),
                  ValueListenableBuilder<List<Product>>(
                    valueListenable: _cartService.wishlistItems,
                    builder: (context, items, _) {
                      return items.isNotEmpty
                          ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: FxText.bodySmall(
                              '${items.length}',
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          )
                          : SizedBox.shrink();
                    },
                  ),
                ],
              ),
              text: 'Wishlist',
            ),
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite),
                  const SizedBox(width: 4),
                  ValueListenableBuilder<List<Product>>(
                    valueListenable: _cartService.favoriteItems,
                    builder: (context, items, _) {
                      return items.isNotEmpty
                          ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              shape: BoxShape.circle,
                            ),
                            child: FxText.bodySmall(
                              '${items.length}',
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          )
                          : SizedBox.shrink();
                    },
                  ),
                ],
              ),
              text: 'Favorites',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCartTab(), _buildWishlistTab(), _buildFavoritesTab()],
      ),
    );
  }

  Widget _buildCartTab() {
    return ValueListenableBuilder<List<EnhancedCartItem>>(
      valueListenable: _cartService.cartItems,
      builder: (context, cartItems, _) {
        if (cartItems.isEmpty) {
          return _buildEmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Your Cart is Empty',
            subtitle: 'Add some items to get started!',
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return _buildCartItemCard(item);
                },
              ),
            ),
            _buildCartSummary(),
          ],
        );
      },
    );
  }

  Widget _buildCartItemCard(EnhancedCartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: CustomTheme.color3,
                child:
                    item.product.imageUrl != null
                        ? Image.network(
                          item.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.shopping_bag,
                              color: CustomTheme.color,
                            );
                          },
                        )
                        : Icon(Icons.shopping_bag, color: CustomTheme.color),
              ),
            ),
            title: FxText.bodyMedium(
              item.product.name,
              color: CustomTheme.color,
              fontWeight: 600,
              maxLines: 2,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.selectedSize != null ||
                    item.selectedColor != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.selectedSize != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CustomTheme.color3.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FxText.bodySmall(
                            'Size: ${item.selectedSize}',
                            color: CustomTheme.color2,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (item.selectedColor != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CustomTheme.color3.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FxText.bodySmall(
                            'Color: ${item.selectedColor}',
                            color: CustomTheme.color2,
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FxText.bodyMedium(
                      'CAD \$${item.product.cost.toStringAsFixed(2)}',
                      color: CustomTheme.primary,
                      fontWeight: 700,
                    ),
                    FxText.bodyMedium(
                      'Total: CAD \$${item.itemTotal.toStringAsFixed(2)}',
                      color: CustomTheme.color,
                      fontWeight: 600,
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () => _cartService.removeFromCart(item.id),
              icon: Icon(Icons.delete, color: Colors.red),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    FxText.bodyMedium('Quantity:', color: CustomTheme.color2),
                    const SizedBox(width: 8),
                    _buildQuantitySelector(item),
                  ],
                ),
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.message,
                      label: 'Contact Seller',
                      onPressed: () => _showContactSellerDialog(item.product),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.shopping_bag,
                      label: 'Buy Now',
                      onPressed: () => _handleBuyNow(item),
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(EnhancedCartItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CustomTheme.color3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed:
                () => _cartService.updateQuantity(item.id, item.quantity - 1),
            icon: Icon(Icons.remove, size: 18),
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FxText.bodyMedium(
              '${item.quantity}',
              color: CustomTheme.color,
              fontWeight: 600,
            ),
          ),
          IconButton(
            onPressed:
                () => _cartService.updateQuantity(item.id, item.quantity + 1),
            icon: Icon(Icons.add, size: 18),
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: FxText.bodySmall(label, color: Colors.white),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? CustomTheme.primary : CustomTheme.color2,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyMedium('Subtotal:', color: CustomTheme.color2),
              FxText.bodyMedium(
                'CAD \$${_cartService.subtotal.toStringAsFixed(2)}',
                color: CustomTheme.color,
                fontWeight: 600,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyMedium('Tax (13% HST):', color: CustomTheme.color2),
              FxText.bodyMedium(
                'CAD \$${_cartService.tax.toStringAsFixed(2)}',
                color: CustomTheme.color,
                fontWeight: 600,
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.titleMedium(
                'Total:',
                color: CustomTheme.color,
                fontWeight: 700,
              ),
              FxText.titleMedium(
                'CAD \$${_cartService.total.toStringAsFixed(2)}',
                color: CustomTheme.primary,
                fontWeight: 700,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleCheckout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: FxText.titleMedium(
                'Proceed to Checkout',
                color: Colors.white,
                fontWeight: 600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistTab() {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: _cartService.wishlistItems,
      builder: (context, wishlistItems, _) {
        if (wishlistItems.isEmpty) {
          return _buildEmptyState(
            icon: Icons.bookmark_border,
            title: 'Your Wishlist is Empty',
            subtitle: 'Save items for later by adding them to your wishlist!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: wishlistItems.length,
          itemBuilder: (context, index) {
            final product = wishlistItems[index];
            return _buildWishlistItemCard(product);
          },
        );
      },
    );
  }

  Widget _buildWishlistItemCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: CustomTheme.color3,
            child:
                product.imageUrl != null
                    ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.shopping_bag,
                          color: CustomTheme.color,
                        );
                      },
                    )
                    : Icon(Icons.shopping_bag, color: CustomTheme.color),
          ),
        ),
        title: FxText.bodyMedium(
          product.name,
          color: CustomTheme.color,
          fontWeight: 600,
          maxLines: 2,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            FxText.bodyMedium(
              'CAD \$${product.cost.toStringAsFixed(2)}',
              color: CustomTheme.primary,
              fontWeight: 700,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => _cartService.moveWishlistItemToCart(product.id),
                    icon: Icon(Icons.shopping_cart, size: 16),
                    label: FxText.bodySmall('Add to Cart', color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _cartService.removeFromWishlist(product.id),
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: _cartService.favoriteItems,
      builder: (context, favoriteItems, _) {
        if (favoriteItems.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border,
            title: 'No Favorites Yet',
            subtitle: 'Mark items as favorites to see them here!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteItems.length,
          itemBuilder: (context, index) {
            final product = favoriteItems[index];
            return _buildFavoriteItemCard(product);
          },
        );
      },
    );
  }

  Widget _buildFavoriteItemCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: CustomTheme.color3,
            child:
                product.imageUrl != null
                    ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.shopping_bag,
                          color: CustomTheme.color,
                        );
                      },
                    )
                    : Icon(Icons.shopping_bag, color: CustomTheme.color),
          ),
        ),
        title: FxText.bodyMedium(
          product.name,
          color: CustomTheme.color,
          fontWeight: 600,
          maxLines: 2,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            FxText.bodyMedium(
              'CAD \$${product.cost.toStringAsFixed(2)}',
              color: CustomTheme.primary,
              fontWeight: 700,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _cartService.addToCart(product: product),
                    icon: Icon(Icons.shopping_cart, size: 16),
                    label: FxText.bodySmall('Add to Cart', color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _cartService.removeFromFavorites(product.id),
                  icon: Icon(Icons.favorite, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: CustomTheme.color2),
          const SizedBox(height: 16),
          FxText.titleMedium(title, color: CustomTheme.color, fontWeight: 600),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            subtitle,
            color: CustomTheme.color2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showContactSellerDialog(Product product) {
    final messageController = TextEditingController();
    ContactReason selectedReason = ContactReason.productQuestion;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: FxText.titleMedium(
                    'Contact Seller',
                    color: CustomTheme.color,
                    fontWeight: 600,
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FxText.bodyMedium(
                          'Product: ${product.name}',
                          color: CustomTheme.color2,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ContactReason>(
                          value: selectedReason,
                          decoration: InputDecoration(
                            labelText: 'Reason for Contact',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items:
                              ContactReason.values.map((reason) {
                                return DropdownMenuItem(
                                  value: reason,
                                  child: FxText.bodyMedium(reason.displayName),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedReason = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: messageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Your Message',
                            hintText: 'Type your message here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: FxText.bodyMedium(
                        'Cancel',
                        color: CustomTheme.color2,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (messageController.text.trim().isNotEmpty) {
                          Navigator.pop(context);
                          await _handleContactSeller(
                            product,
                            messageController.text.trim(),
                            selectedReason,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: FxText.bodyMedium(
                        'Send Message',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _handleContactSeller(
    Product product,
    String message,
    ContactReason reason,
  ) async {
    try {
      final response = await _cartService.contactSeller(
        productId: product.id,
        message: message,
        reason: reason,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleBuyNow(EnhancedCartItem item) async {
    try {
      final response = await _cartService.buyNow(
        product: item.product,
        quantity: item.quantity,
        selectedSize: item.selectedSize,
        selectedColor: item.selectedColor,
        customOptions: item.customOptions,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed! Order ID: ${response.orderId}'),
            backgroundColor: Colors.green,
          ),
        );

        // Remove item from cart after successful purchase
        await _cartService.removeFromCart(item.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCheckout() {
    // Navigate to checkout screen or show checkout dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proceeding to checkout...'),
        backgroundColor: CustomTheme.primary,
      ),
    );
  }
}
