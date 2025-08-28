import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../utils/dating_theme.dart';
import '../../screens/shop/models/Product.dart';

/// Comprehensive cart management widget with advanced features
/// Provides full cart functionality with persistence, optimization, and enhanced UX
class ComprehensiveCartWidget extends StatefulWidget {
  final Function(List<CartItem>) onCartUpdated;
  final Function(List<CartItem>) onCheckout;
  final bool showHeader;

  const ComprehensiveCartWidget({
    Key? key,
    required this.onCartUpdated,
    required this.onCheckout,
    this.showHeader = true,
  }) : super(key: key);

  @override
  State<ComprehensiveCartWidget> createState() =>
      _ComprehensiveCartWidgetState();
}

class _ComprehensiveCartWidgetState extends State<ComprehensiveCartWidget>
    with TickerProviderStateMixin {
  List<CartItem> _cartItems = [];
  List<CartItem> _savedForLater = [];
  bool _isLoading = false;
  bool _selectAll = false;
  String? _promoCode;
  double _promoDiscount = 0.0;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadCartData();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeController.forward();
  }

  Future<void> _loadCartData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cart items
      final cartData = prefs.getString('cart_items');
      if (cartData != null) {
        final List<dynamic> cartJson = json.decode(cartData);
        _cartItems = cartJson.map((item) => CartItem.fromJson(item)).toList();
      }

      // Load saved for later items
      final savedData = prefs.getString('saved_for_later');
      if (savedData != null) {
        final List<dynamic> savedJson = json.decode(savedData);
        _savedForLater =
            savedJson.map((item) => CartItem.fromJson(item)).toList();
      }

      // Load promo code
      _promoCode = prefs.getString('current_promo_code');
      _promoDiscount = prefs.getDouble('promo_discount') ?? 0.0;
    } catch (e) {
      debugPrint('Error loading cart data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCartData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save cart items
      final cartJson = _cartItems.map((item) => item.toJson()).toList();
      await prefs.setString('cart_items', json.encode(cartJson));

      // Save saved for later items
      final savedJson = _savedForLater.map((item) => item.toJson()).toList();
      await prefs.setString('saved_for_later', json.encode(savedJson));

      // Save promo code
      if (_promoCode != null) {
        await prefs.setString('current_promo_code', _promoCode!);
        await prefs.setDouble('promo_discount', _promoDiscount);
      }

      widget.onCartUpdated(_cartItems);
    } catch (e) {
      debugPrint('Error saving cart data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          if (widget.showHeader) _buildHeader(),
          if (_isLoading) _buildLoadingState(),
          if (!_isLoading && _cartItems.isEmpty && _savedForLater.isEmpty)
            _buildEmptyState(),
          if (!_isLoading &&
              (_cartItems.isNotEmpty || _savedForLater.isNotEmpty))
            Expanded(child: _buildCartContent()),
          if (!_isLoading && _cartItems.isNotEmpty) _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            FeatherIcons.shoppingCart,
            color: DatingTheme.primaryPink,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Shopping Cart',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DatingTheme.primaryText,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DatingTheme.primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_cartItems.length}',
              style: TextStyle(
                color: DatingTheme.primaryPink,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
          if (_cartItems.isNotEmpty) _buildBulkActions(),
        ],
      ),
    );
  }

  Widget _buildBulkActions() {
    return PopupMenuButton<String>(
      icon: Icon(FeatherIcons.moreVertical, color: DatingTheme.primaryPink),
      onSelected: _handleBulkAction,
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'select_all',
              child: Row(
                children: [
                  Icon(
                    _selectAll ? FeatherIcons.checkSquare : FeatherIcons.square,
                    size: 16,
                    color: DatingTheme.primaryPink,
                  ),
                  const SizedBox(width: 8),
                  Text(_selectAll ? 'Deselect All' : 'Select All'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove_selected',
              child: Row(
                children: [
                  Icon(FeatherIcons.trash2, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove Selected'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'save_selected',
              child: Row(
                children: [
                  Icon(FeatherIcons.heart, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Save Selected for Later'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_cart',
              child: Row(
                children: [
                  Icon(FeatherIcons.x, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Clear Cart'),
                ],
              ),
            ),
          ],
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cart items
          if (_cartItems.isNotEmpty) ...[
            _buildSectionHeader('Cart Items', _cartItems.length),
            const SizedBox(height: 8),
            ..._cartItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _slideController,
                    curve: Interval(
                      index * 0.1,
                      1.0,
                      curve: Curves.easeOutQuart,
                    ),
                  ),
                ),
                child: _buildCartItemCard(item, index),
              );
            }).toList(),
          ],

          // Promo code section
          if (_cartItems.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildPromoCodeSection(),
          ],

          // Saved for later
          if (_savedForLater.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Saved for Later', _savedForLater.length),
            const SizedBox(height: 8),
            ..._savedForLater.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildSavedItemCard(item, index);
            }).toList(),
          ],

          // Related products / Recommendations
          if (_cartItems.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildRecommendationsSection(),
          ],

          const SizedBox(height: 100), // Space for floating checkout button
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DatingTheme.primaryText,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main item content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection checkbox
                GestureDetector(
                  onTap: () => _toggleItemSelection(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                          item.isSelected
                              ? DatingTheme.primaryPink
                              : Colors.transparent,
                      border: Border.all(
                        color:
                            item.isSelected
                                ? DatingTheme.primaryPink
                                : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      FeatherIcons.check,
                      size: 12,
                      color:
                          item.isSelected ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child:
                        item.product.feature_photo.isNotEmpty
                            ? Image.network(
                              item.product.feature_photo,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Icon(
                                    FeatherIcons.image,
                                    color: Colors.grey[400],
                                  ),
                            )
                            : Icon(FeatherIcons.image, color: Colors.grey[400]),
                  ),
                ),

                const SizedBox(width: 16),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DatingTheme.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Variant info
                      if (item.selectedSize != null ||
                          item.selectedColor != null)
                        Wrap(
                          spacing: 8,
                          children: [
                            if (item.selectedSize != null)
                              _buildVariantChip('Size: ${item.selectedSize}'),
                            if (item.selectedColor != null)
                              _buildVariantChip('Color: ${item.selectedColor}'),
                          ],
                        ),

                      const SizedBox(height: 8),

                      // Price and quantity
                      Row(
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: DatingTheme.primaryPink,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CAD',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          _buildQuantityControls(item, index),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                _buildActionButton(
                  'Save for Later',
                  FeatherIcons.heart,
                  () => _saveForLater(index),
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  'Remove',
                  FeatherIcons.trash2,
                  () => _removeItem(index),
                  Colors.red,
                ),
                const Spacer(),
                // Item total
                Text(
                  'Total: \$${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: DatingTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: DatingTheme.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: DatingTheme.primaryPink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _updateQuantity(index, item.quantity - 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(
                FeatherIcons.minus,
                size: 16,
                color:
                    item.quantity > 1 ? DatingTheme.primaryPink : Colors.grey,
              ),
            ),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          GestureDetector(
            onTap: () => _updateQuantity(index, item.quantity + 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(
                FeatherIcons.plus,
                size: 16,
                color: DatingTheme.primaryPink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FeatherIcons.tag, color: DatingTheme.primaryPink, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Promo Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DatingTheme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) => _promoCode = value,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _applyPromoCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DatingTheme.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
          if (_promoDiscount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(FeatherIcons.checkCircle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Promo code applied! You save \$${_promoDiscount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavedItemCard(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child:
                  item.product.feature_photo.isNotEmpty
                      ? Image.network(
                        item.product.feature_photo,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              FeatherIcons.image,
                              color: Colors.grey[400],
                            ),
                      )
                      : Icon(FeatherIcons.image, color: Colors.grey[400]),
            ),
          ),

          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: DatingTheme.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)} CAD',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Action buttons
          Column(
            children: [
              IconButton(
                onPressed: () => _moveToCart(index),
                icon: Icon(
                  FeatherIcons.shoppingCart,
                  color: DatingTheme.primaryPink,
                ),
                iconSize: 20,
              ),
              IconButton(
                onPressed: () => _removeSavedItem(index),
                icon: Icon(FeatherIcons.x, color: Colors.red),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    // Mock recommendations based on cart items
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You might also like',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DatingTheme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) => _buildRecommendationCard(index),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(int index) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(FeatherIcons.image, color: Colors.grey[400]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Product ${index + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${(19.99 + index * 5).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: DatingTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    final subtotal = _calculateSubtotal();
    final shipping = _calculateShipping();
    final tax = _calculateTax(subtotal);
    final total = subtotal + shipping + tax - _promoDiscount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Summary rows
          _buildSummaryRow('Subtotal', subtotal),
          _buildSummaryRow('Shipping', shipping),
          _buildSummaryRow('Tax (HST)', tax),
          if (_promoDiscount > 0)
            _buildSummaryRow(
              'Promo Discount',
              -_promoDiscount,
              isDiscount: true,
            ),

          const Divider(height: 24),

          // Total
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DatingTheme.primaryText,
                ),
              ),
              const Spacer(),
              Text(
                '\$${total.toStringAsFixed(2)} CAD',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DatingTheme.primaryPink,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Checkout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cartItems.isNotEmpty ? _proceedToCheckout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DatingTheme.primaryPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FeatherIcons.creditCard),
                  const SizedBox(width: 8),
                  Text(
                    'Proceed to Checkout (${_cartItems.length} items)',
                    style: const TextStyle(
                      fontSize: 16,
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

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          const Spacer(),
          Text(
            '${isDiscount ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.green : DatingTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(DatingTheme.primaryPink),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your cart...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FeatherIcons.shoppingCart, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some items to get started!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: DatingTheme.primaryPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _handleBulkAction(String action) {
    switch (action) {
      case 'select_all':
        setState(() {
          _selectAll = !_selectAll;
          for (int i = 0; i < _cartItems.length; i++) {
            _cartItems[i].isSelected = _selectAll;
          }
        });
        break;
      case 'remove_selected':
        _removeSelectedItems();
        break;
      case 'save_selected':
        _saveSelectedForLater();
        break;
      case 'clear_cart':
        _clearCart();
        break;
    }
  }

  void _toggleItemSelection(int index) {
    setState(() {
      _cartItems[index].isSelected = !_cartItems[index].isSelected;
      _selectAll = _cartItems.every((item) => item.isSelected);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity < 1) return;

    setState(() {
      _cartItems[index].quantity = newQuantity;
    });
    _saveCartData();
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    _saveCartData();
  }

  void _saveForLater(int index) {
    final item = _cartItems[index];
    setState(() {
      _cartItems.removeAt(index);
      _savedForLater.add(item);
    });
    _saveCartData();
  }

  void _moveToCart(int index) {
    final item = _savedForLater[index];
    setState(() {
      _savedForLater.removeAt(index);
      _cartItems.add(item);
    });
    _saveCartData();
  }

  void _removeSavedItem(int index) {
    setState(() {
      _savedForLater.removeAt(index);
    });
    _saveCartData();
  }

  void _removeSelectedItems() {
    setState(() {
      _cartItems.removeWhere((item) => item.isSelected);
      _selectAll = false;
    });
    _saveCartData();
  }

  void _saveSelectedForLater() {
    final selectedItems = _cartItems.where((item) => item.isSelected).toList();
    setState(() {
      _cartItems.removeWhere((item) => item.isSelected);
      _savedForLater.addAll(selectedItems);
      _selectAll = false;
    });
    _saveCartData();
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cart'),
            content: const Text(
              'Are you sure you want to remove all items from your cart?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _cartItems.clear();
                    _selectAll = false;
                  });
                  _saveCartData();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Clear Cart',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _applyPromoCode() {
    if (_promoCode == null || _promoCode!.isEmpty) return;

    // Mock promo code validation
    final Map<String, double> validCodes = {
      'SAVE10': 10.0,
      'WELCOME20': 20.0,
      'FIRSTORDER': 15.0,
      'STUDENT5': 5.0,
    };

    if (validCodes.containsKey(_promoCode!.toUpperCase())) {
      setState(() {
        _promoDiscount = validCodes[_promoCode!.toUpperCase()]!;
      });
      _saveCartData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Promo code applied! You save \$${_promoDiscount.toStringAsFixed(2)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _proceedToCheckout() {
    final selectedItems = _cartItems.where((item) => item.isSelected).toList();
    final itemsToCheckout =
        selectedItems.isNotEmpty ? selectedItems : _cartItems;

    widget.onCheckout(itemsToCheckout);
  }

  // Calculation methods
  double _calculateSubtotal() {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  double _calculateShipping() {
    final subtotal = _calculateSubtotal();
    return subtotal > 50.0 ? 0.0 : 9.99; // Free shipping over $50
  }

  double _calculateTax(double subtotal) {
    return subtotal * 0.13; // 13% HST for Ontario
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

// Cart item model
class CartItem {
  final Product product;
  int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final double price;
  bool isSelected;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
    required this.price,
    this.isSelected = false,
  });

  Map<String, dynamic> toJson() => {
    'product_id': product.id,
    'product_name': product.name,
    'quantity': quantity,
    'selected_size': selectedSize,
    'selected_color': selectedColor,
    'price': price,
    'is_selected': isSelected,
  };

  static CartItem fromJson(Map<String, dynamic> json) {
    // Create a mock product for loading from storage
    final product = Product();
    product.id = json['product_id'] ?? 0;
    product.name = json['product_name'] ?? '';

    return CartItem(
      product: product,
      quantity: json['quantity'] ?? 1,
      selectedSize: json['selected_size'],
      selectedColor: json['selected_color'],
      price: (json['price'] ?? 0.0).toDouble(),
      isSelected: json['is_selected'] ?? false,
    );
  }
}
