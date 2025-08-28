import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import '../../services/shared_wishlist_service.dart';
import '../../utils/CustomTheme.dart';

class SharedWishlistWidget extends StatefulWidget {
  final String partnerId;
  final String partnerName;

  const SharedWishlistWidget({
    Key? key,
    required this.partnerId,
    required this.partnerName,
  }) : super(key: key);

  @override
  _SharedWishlistWidgetState createState() => _SharedWishlistWidgetState();
}

class _SharedWishlistWidgetState extends State<SharedWishlistWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<SharedWishlist> _wishlists = [];
  bool _isLoading = true;
  SharedWishlist? _selectedWishlist;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWishlists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWishlists() async {
    setState(() => _isLoading = true);
    try {
      final wishlists = await SharedWishlistService().getSharedWishlists();
      setState(() {
        _wishlists = wishlists;
        _isLoading = false;
        if (wishlists.isNotEmpty && _selectedWishlist == null) {
          _selectedWishlist = wishlists.first;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWishlistsTab(),
                _buildAnalyticsTab(),
                _buildCreateTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.primary, CustomTheme.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite_border, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.titleMedium(
                  'Shared Wishlists',
                  color: Colors.white,
                  fontWeight: 700,
                ),
                FxText.bodySmall(
                  'Plan your future together with ${widget.partnerName}',
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
          if (_wishlists.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FxText.bodySmall(
                '${_wishlists.length} Lists',
                color: Colors.white,
                fontWeight: 600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: CustomTheme.card,
      child: TabBar(
        controller: _tabController,
        labelColor: CustomTheme.primary,
        unselectedLabelColor: CustomTheme.color2,
        indicatorColor: CustomTheme.primary,
        tabs: [
          Tab(text: 'My Lists'),
          Tab(text: 'Analytics'),
          Tab(text: 'Create'),
        ],
      ),
    );
  }

  Widget _buildWishlistsTab() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_wishlists.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildWishlistSelector(),
        Expanded(
          child:
              _selectedWishlist != null
                  ? _buildWishlistDetails(_selectedWishlist!)
                  : Container(),
        ),
      ],
    );
  }

  Widget _buildWishlistSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _wishlists.length,
        itemBuilder: (context, index) {
          final wishlist = _wishlists[index];
          final isSelected = _selectedWishlist?.id == wishlist.id;

          return GestureDetector(
            onTap: () => setState(() => _selectedWishlist = wishlist),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? CustomTheme.primary : CustomTheme.color3,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? CustomTheme.primary : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    wishlist.isPrivate ? Icons.lock : Icons.public,
                    size: 16,
                    color: isSelected ? Colors.white : CustomTheme.color,
                  ),
                  const SizedBox(width: 6),
                  FxText.bodyMedium(
                    wishlist.name,
                    color: isSelected ? Colors.white : CustomTheme.color,
                    fontWeight: isSelected ? 600 : 400,
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (isSelected ? Colors.white : CustomTheme.primary)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FxText.bodySmall(
                      '${wishlist.totalItems}',
                      color: isSelected ? Colors.white : CustomTheme.primary,
                      fontWeight: 600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWishlistDetails(SharedWishlist wishlist) {
    return Column(
      children: [
        _buildWishlistStats(wishlist),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlist.items.length,
            itemBuilder: (context, index) {
              final item = wishlist.items[index];
              return _buildWishlistItemCard(wishlist, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistStats(SharedWishlist wishlist) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomTheme.color3.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Items',
              '${wishlist.totalItems}',
              Icons.list,
              CustomTheme.primary,
            ),
          ),
          Container(width: 1, height: 40, color: CustomTheme.color3),
          Expanded(
            child: _buildStatItem(
              'Completed',
              '${wishlist.purchasedItems}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          Container(width: 1, height: 40, color: CustomTheme.color3),
          Expanded(
            child: _buildStatItem(
              'Total Value',
              'CAD \$${wishlist.totalValue.toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        FxText.bodySmall(label, color: CustomTheme.color2),
        FxText.bodyMedium(value, color: CustomTheme.color, fontWeight: 600),
      ],
    );
  }

  Widget _buildWishlistItemCard(SharedWishlist wishlist, WishlistItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            item.isPurchased
                ? Colors.green.withValues(alpha: 0.1)
                : CustomTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              item.isPurchased
                  ? Colors.green.withValues(alpha: 0.3)
                  : CustomTheme.color3.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: CustomTheme.color3,
              backgroundImage:
                  item.imageUrl != null ? NetworkImage(item.imageUrl!) : null,
              child:
                  item.imageUrl == null
                      ? Icon(Icons.shopping_bag, color: CustomTheme.color)
                      : null,
            ),
            if (item.isPurchased)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: FxText.bodyMedium(
                item.productName,
                color: CustomTheme.color,
                fontWeight: 600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: item.priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: FxText.bodySmall(
                item.priorityText,
                color: item.priorityColor,
                fontWeight: 600,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.notes != null) ...[
              const SizedBox(height: 4),
              FxText.bodySmall(
                item.notes!,
                color: CustomTheme.color2,
                maxLines: 2,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FxText.bodyMedium(
                  'CAD \$${item.price.toStringAsFixed(2)}',
                  color: CustomTheme.primary,
                  fontWeight: 700,
                ),
                Row(
                  children: [
                    if (!item.isPurchased) ...[
                      GestureDetector(
                        onTap: () => _markAsPurchased(wishlist, item),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_cart,
                            size: 16,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    GestureDetector(
                      onTap: () => _removeItem(wishlist, item),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.delete, size: 16, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_selectedWishlist == null) {
      return Center(
        child: FxText.bodyMedium(
          'Select a wishlist to view analytics',
          color: CustomTheme.color2,
        ),
      );
    }

    return FutureBuilder<WishlistAnalytics>(
      future: SharedWishlistService().getWishlistAnalytics(
        _selectedWishlist!.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData) {
          return Center(
            child: FxText.bodyMedium(
              'No analytics available',
              color: CustomTheme.color2,
            ),
          );
        }

        final analytics = snapshot.data!;
        return _buildAnalyticsContent(analytics);
      },
    );
  }

  Widget _buildAnalyticsContent(WishlistAnalytics analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsCard('Progress Overview', [
            _buildProgressItem(
              'Completion Rate',
              '${analytics.completionPercentage.toStringAsFixed(1)}%',
              analytics.completionPercentage / 100,
              Colors.green,
            ),
            _buildProgressItem(
              'Budget Used',
              'CAD \$${analytics.purchasedValue.toStringAsFixed(2)}',
              analytics.budgetUsedPercentage / 100,
              Colors.blue,
            ),
          ]),
          const SizedBox(height: 16),
          _buildAnalyticsCard('Collaboration Score', [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people, color: CustomTheme.primary),
                          const SizedBox(width: 8),
                          FxText.titleLarge(
                            '${analytics.collaborationScore.toStringAsFixed(1)}/10',
                            color: CustomTheme.primary,
                            fontWeight: 700,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FxText.bodyMedium(
                        'Both partners are actively participating in list building',
                        color: CustomTheme.color2,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CustomTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FxText.titleMedium(
                      '${(analytics.collaborationScore * 10).toInt()}%',
                      color: CustomTheme.primary,
                      fontWeight: 700,
                    ),
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          _buildAnalyticsCard('Top Category', [
            Row(
              children: [
                Icon(Icons.category, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyMedium(
                        analytics.topCategory,
                        color: CustomTheme.color,
                        fontWeight: 600,
                      ),
                      FxText.bodySmall(
                        'Most popular category in your wishlists',
                        color: CustomTheme.color2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomTheme.color3.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(title, color: CustomTheme.color, fontWeight: 600),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyMedium(label, color: CustomTheme.color),
              FxText.bodyMedium(value, color: color, fontWeight: 600),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: CustomTheme.color3.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(
            'Create New Wishlist',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
          const SizedBox(height: 16),
          _buildCreateWishlistForm(),
        ],
      ),
    );
  }

  Widget _buildCreateWishlistForm() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPrivate = false;

    return StatefulBuilder(
      builder: (context, setFormState) {
        return Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Wishlist Name',
                hintText: 'e.g., Our Dream Home, Date Night Ideas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.list_alt),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'What is this wishlist for?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: isPrivate,
                  onChanged: (value) => setFormState(() => isPrivate = value),
                  activeColor: CustomTheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyMedium(
                        'Private Wishlist',
                        color: CustomTheme.color,
                        fontWeight: 600,
                      ),
                      FxText.bodySmall(
                        'Only you and your partner can see this list',
                        color: CustomTheme.color2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => _createWishlist(
                      nameController.text,
                      descriptionController.text,
                      isPrivate,
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: FxText.bodyMedium(
                  'Create Wishlist',
                  color: Colors.white,
                  fontWeight: 600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: CustomTheme.primary),
          const SizedBox(height: 16),
          FxText.bodyMedium('Loading wishlists...', color: CustomTheme.color2),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: CustomTheme.color2),
          const SizedBox(height: 16),
          FxText.titleMedium(
            'No Shared Wishlists',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            'Create your first wishlist together\nto start planning your future',
            color: CustomTheme.color2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _tabController.animateTo(2),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: FxText.bodyMedium(
              'Create Wishlist',
              color: Colors.white,
              fontWeight: 600,
            ),
          ),
        ],
      ),
    );
  }

  void _createWishlist(String name, String description, bool isPrivate) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a wishlist name')));
      return;
    }

    try {
      final wishlist = await SharedWishlistService().createSharedWishlist(
        partnerId: widget.partnerId,
        name: name.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
        isPrivate: isPrivate,
      );

      setState(() {
        _wishlists.add(wishlist);
        _selectedWishlist = wishlist;
      });

      _tabController.animateTo(0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wishlist "${name}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create wishlist. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _markAsPurchased(SharedWishlist wishlist, WishlistItem item) async {
    try {
      await SharedWishlistService().markItemAsPurchased(
        wishlistId: wishlist.id,
        itemId: item.id,
        purchasedBy: 'current_user_id',
      );

      // Update local state
      setState(() {
        final index = wishlist.items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          // For demo purposes, we'll reload the data
          _loadWishlists();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item marked as purchased!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update item. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeItem(SharedWishlist wishlist, WishlistItem item) async {
    try {
      await SharedWishlistService().removeItemFromWishlist(
        wishlist.id,
        item.id,
      );

      // Update local state
      setState(() {
        wishlist.items.removeWhere((i) => i.id == item.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from wishlist'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
