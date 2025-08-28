import 'package:flutter/material.dart';
import '../../services/couple_shopping_service.dart';
import '../../theme/dating_theme.dart';

class CoupleShoppingWidget extends StatefulWidget {
  final String partnerId;
  final String partnerName;

  const CoupleShoppingWidget({
    Key? key,
    required this.partnerId,
    required this.partnerName,
  }) : super(key: key);

  @override
  State<CoupleShoppingWidget> createState() => _CoupleShoppingWidgetState();
}

class _CoupleShoppingWidgetState extends State<CoupleShoppingWidget>
    with TickerProviderStateMixin {
  final CoupleShoppingService _shoppingService = CoupleShoppingService();

  late TabController _tabController;
  late TabController _categoryController;

  List<ShoppingSession> _activeSessions = [];
  List<DateShoppingItem> _currentItems = [];
  List<DateShoppingItem> _recommendations = [];
  CoupleShoppingAnalytics? _analytics;

  bool _isLoading = false;
  String _selectedCategory = 'date_essentials';
  ShoppingSession? _activeSession;

  final List<String> _categories = [
    'date_essentials',
    'experience_gifts',
    'fashion_accessories',
    'home_date',
  ];

  final Map<String, String> _categoryNames = {
    'date_essentials': 'Date Essentials',
    'experience_gifts': 'Experience Gifts',
    'fashion_accessories': 'Fashion & Accessories',
    'home_date': 'Home Date Ideas',
  };

  final Map<String, IconData> _categoryIcons = {
    'date_essentials': Icons.favorite,
    'experience_gifts': Icons.card_giftcard,
    'fashion_accessories': Icons.style,
    'home_date': Icons.home,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _categoryController = TabController(
      length: _categories.length,
      vsync: this,
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Load all initial data concurrently
      final results = await Future.wait([
        _shoppingService.getActiveShoppingSessions(),
        _shoppingService.getDateShoppingItems(_selectedCategory),
        _shoppingService.getPersonalizedRecommendations(widget.partnerId),
        _shoppingService.getShoppingAnalytics(widget.partnerId),
      ]);

      setState(() {
        _activeSessions = results[0] as List<ShoppingSession>;
        _currentItems = results[1] as List<DateShoppingItem>;
        _recommendations = results[2] as List<DateShoppingItem>;
        _analytics = results[3] as CoupleShoppingAnalytics;

        // Set active session if available
        if (_activeSessions.isNotEmpty) {
          _activeSession = _activeSessions.first;
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load shopping data: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategoryItems(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });

    try {
      final items = await _shoppingService.getDateShoppingItems(category);
      setState(() {
        _currentItems = items;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load items: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewSession(String sessionType) async {
    try {
      final session = await _shoppingService.createShoppingSession(
        widget.partnerId,
        sessionType,
      );

      setState(() {
        _activeSessions.insert(0, session);
        _activeSession = session;
      });

      _showSuccessSnackBar(
        'New shopping session created with ${widget.partnerName}!',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to create session: ${e.toString()}');
    }
  }

  Future<void> _addItemToSession(DateShoppingItem item) async {
    if (_activeSession == null) {
      _showErrorSnackBar('Please create a shopping session first');
      return;
    }

    try {
      final success = await _shoppingService.addItemToSession(
        _activeSession!.sessionId,
        item.itemId,
        'current_user',
      );

      if (success) {
        _showSuccessSnackBar('${item.name} added to shared cart!');
        _loadInitialData(); // Refresh data
      } else {
        _showErrorSnackBar('Failed to add item to cart');
      }
    } catch (e) {
      _showErrorSnackBar('Error adding item: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DatingTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DatingTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping with ${widget.partnerName}',
          style: DatingTheme.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: DatingTheme.primaryPink,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_cart), text: 'Browse'),
            Tab(icon: Icon(Icons.recommend), text: 'For You'),
            Tab(icon: Icon(Icons.favorite), text: 'Sessions'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrowseTab(),
          _buildRecommendationsTab(),
          _buildSessionsTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton:
          _activeSession == null
              ? FloatingActionButton.extended(
                onPressed: () => _createNewSession('date_planning'),
                backgroundColor: DatingTheme.primaryPink,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Start Shopping'),
              )
              : null,
    );
  }

  Widget _buildBrowseTab() {
    return Column(
      children: [
        // Category Selector
        Container(
          height: 50,
          color: DatingTheme.cardBackground,
          child: TabBar(
            controller: _categoryController,
            isScrollable: true,
            indicatorColor: DatingTheme.primaryPink,
            labelColor: DatingTheme.primaryPink,
            unselectedLabelColor: DatingTheme.textSecondary,
            onTap: (index) => _loadCategoryItems(_categories[index]),
            tabs:
                _categories
                    .map(
                      (category) => Tab(
                        icon: Icon(_categoryIcons[category]),
                        text: _categoryNames[category],
                      ),
                    )
                    .toList(),
          ),
        ),

        // Items Grid
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _currentItems.isEmpty
                  ? _buildEmptyState()
                  : _buildItemsGrid(),
        ),
      ],
    );
  }

  Widget _buildItemsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _currentItems.length,
        itemBuilder: (context, index) {
          final item = _currentItems[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(DateShoppingItem item) {
    return Container(
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: DatingTheme.surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child:
                  item.imageUrl.isNotEmpty
                      ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildImagePlaceholder(item),
                        ),
                      )
                      : _buildImagePlaceholder(item),
            ),
          ),

          // Item Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: DatingTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: DatingTheme.accentGold,
                          ),
                          Text(
                            ' ${item.rating} (${item.reviewCount})',
                            style: DatingTheme.captionStyle,
                          ),
                        ],
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.originalPrice != null &&
                              item.discount != null)
                            Text(
                              '\$${item.originalPrice!.toStringAsFixed(2)}',
                              style: DatingTheme.captionStyle.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: DatingTheme.textSecondary,
                              ),
                            ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)} CAD',
                            style: DatingTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: DatingTheme.primaryPink,
                            ),
                          ),
                        ],
                      ),

                      IconButton(
                        onPressed: () => _addItemToSession(item),
                        icon: Icon(
                          Icons.add_shopping_cart,
                          color: DatingTheme.primaryPink,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: DatingTheme.primaryPink.withOpacity(
                            0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
    );
  }

  Widget _buildImagePlaceholder(DateShoppingItem item) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: DatingTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _categoryIcons[item.category] ?? Icons.shopping_bag,
            size: 40,
            color: DatingTheme.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            item.category.toUpperCase(),
            style: DatingTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _recommendations.isEmpty
        ? _buildEmptyRecommendationsState()
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _recommendations.length,
          itemBuilder: (context, index) {
            final item = _recommendations[index];
            return _buildRecommendationCard(item);
          },
        );
  }

  Widget _buildRecommendationCard(DateShoppingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: DatingTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      item.imageUrl.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildImagePlaceholder(item),
                            ),
                          )
                          : _buildImagePlaceholder(item),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: DatingTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: DatingTheme.captionStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: DatingTheme.primaryPink,
                          ),
                          Text(
                            ' ${item.coupleApprovalRating}% couples love this',
                            style: DatingTheme.captionStyle.copyWith(
                              color: DatingTheme.primaryPink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (item.personalizedReason != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DatingTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: DatingTheme.primaryPink,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.personalizedReason!,
                        style: DatingTheme.captionStyle.copyWith(
                          color: DatingTheme.primaryPink,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${item.price.toStringAsFixed(2)} CAD',
                  style: DatingTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DatingTheme.primaryPink,
                    fontSize: 18,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addItemToSession(item),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DatingTheme.primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsTab() {
    return _activeSessions.isEmpty
        ? _buildEmptySessionsState()
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _activeSessions.length,
          itemBuilder: (context, index) {
            final session = _activeSessions[index];
            return _buildSessionCard(session);
          },
        );
  }

  Widget _buildSessionCard(ShoppingSession session) {
    final isActive = session.sessionId == _activeSession?.sessionId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border:
            isActive
                ? Border.all(color: DatingTheme.primaryPink, width: 2)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: DatingTheme.primaryPink,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Shopping Session',
                          style: DatingTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: DatingTheme.primaryPink,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: DatingTheme.captionStyle.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      'Created ${_formatRelativeTime(session.createdAt)}',
                      style: DatingTheme.captionStyle,
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${session.totalCost.toStringAsFixed(2)} CAD',
                      style: DatingTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DatingTheme.primaryPink,
                      ),
                    ),
                    Text(
                      '${session.items.length} items',
                      style: DatingTheme.captionStyle,
                    ),
                  ],
                ),
              ],
            ),

            if (session.items.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 12),
                  ...session.items
                      .take(3)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: DatingTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: DatingTheme.captionStyle,
                                ),
                              ),
                              Text(
                                '\$${item.price.toStringAsFixed(2)}',
                                style: DatingTheme.captionStyle.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (session.items.length > 3)
                    Text(
                      '... and ${session.items.length - 3} more items',
                      style: DatingTheme.captionStyle.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 12),
            Row(
              children: [
                if (!isActive)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _activeSession = session;
                        });
                      },
                      child: const Text('Set Active'),
                    ),
                  ),
                if (!isActive) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        session.items.isNotEmpty
                            ? () => _showCheckoutDialog(session)
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DatingTheme.primaryPink,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_analytics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shopping Analytics', style: DatingTheme.headingStyle),
          const SizedBox(height: 16),

          // Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Purchases',
                  _analytics!.totalPurchases.toString(),
                  Icons.shopping_bag,
                  DatingTheme.primaryPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Spent',
                  '\$${_analytics!.totalSpent.toStringAsFixed(2)}',
                  Icons.attach_money,
                  DatingTheme.accentGold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Agreement Rate',
                  '${_analytics!.partnerAgreementRate}%',
                  Icons.favorite,
                  DatingTheme.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Avg. Purchase',
                  '\$${_analytics!.averagePurchaseValue.toStringAsFixed(2)}',
                  Icons.trending_up,
                  DatingTheme.secondaryPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Favorite Category
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DatingTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favorite Category',
                  style: DatingTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _categoryIcons[_analytics!.favoriteCategory],
                      color: DatingTheme.primaryPink,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _categoryNames[_analytics!.favoriteCategory] ??
                          _analytics!.favoriteCategory,
                      style: DatingTheme.bodyStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Most Popular Items
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DatingTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Most Popular Items',
                  style: DatingTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._analytics!.mostPopularItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: DatingTheme.accentGold,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item, style: DatingTheme.bodyStyle),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: DatingTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            title,
            style: DatingTheme.captionStyle,
            textAlign: TextAlign.center,
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
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: DatingTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No items in this category yet',
            style: DatingTheme.bodyStyle.copyWith(
              color: DatingTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for new arrivals!',
            style: DatingTheme.captionStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecommendationsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: DatingTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Building your recommendations...',
            style: DatingTheme.bodyStyle.copyWith(
              color: DatingTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Shop together to get personalized suggestions!',
            style: DatingTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySessionsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: DatingTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No shopping sessions yet',
            style: DatingTheme.bodyStyle.copyWith(
              color: DatingTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping together to create your first session!',
            style: DatingTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNewSession('date_planning'),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DatingTheme.primaryPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(ShoppingSession session) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checkout Confirmation', style: DatingTheme.headingStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready to complete your purchase with ${widget.partnerName}?',
                style: DatingTheme.bodyStyle,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DatingTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary:',
                      style: DatingTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${session.items.length} items',
                      style: DatingTheme.bodyStyle,
                    ),
                    Text(
                      'Subtotal: \$${session.totalCost.toStringAsFixed(2)} CAD',
                      style: DatingTheme.bodyStyle,
                    ),
                    Text(
                      'Tax (HST): \$${(session.totalCost * 0.13).toStringAsFixed(2)} CAD',
                      style: DatingTheme.bodyStyle,
                    ),
                    const Divider(),
                    Text(
                      'Total: \$${(session.totalCost * 1.13).toStringAsFixed(2)} CAD',
                      style: DatingTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DatingTheme.primaryPink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processCheckout(session);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DatingTheme.primaryPink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Complete Purchase'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processCheckout(ShoppingSession session) async {
    try {
      final paymentInfo = PaymentInfo(
        subtotal: session.totalCost,
        splitPayment: true, // Default to split payment for couples
        paymentMethod: 'credit_card',
        partnerPaymentMethod: 'credit_card',
      );

      final result = await _shoppingService.completeCouplesPurchase(
        session.sessionId,
        paymentInfo,
      );

      _showSuccessSnackBar(
        'Purchase completed! Confirmation: ${result.confirmationNumber}',
      );

      _loadInitialData(); // Refresh data
    } catch (e) {
      _showErrorSnackBar('Checkout failed: ${e.toString()}');
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
