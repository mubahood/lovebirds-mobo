import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutx/flutx.dart';

import '../../../utils/AppConfig.dart';
import '../../../utils/CustomTheme.dart';
import '../../../models/Order.dart';

/// Complete order history and tracking screen for customers
/// Provides comprehensive order management with real-time status updates
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final List<String> _filterOptions = [
    'all',
    'pending',
    'confirmed',
    'shipped',
    'delivered',
    'cancelled',
    'returned',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call - replace with actual service
    await Future.delayed(const Duration(seconds: 1));

    // Create demo orders for testing
    _orders = _createDemoOrders();
    _filteredOrders = List.from(_orders);

    setState(() {
      _isLoading = false;
    });
  }

  List<Order> _createDemoOrders() {
    return []; /*[
      Order(
        id: 'LB001',
        orderNumber: 'LB-2025-001',
        status: 'delivered',
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        deliveryDate: DateTime.now().subtract(const Duration(days: 1)),
        total: 129.99,
        items: [
          OrderItem(
            id: '1',
            name: 'Wireless Bluetooth Headphones',
            price: 89.99,
            quantity: 1,
            imageUrl: 'https://via.placeholder.com/300x300?text=Headphones',
          ),
          OrderItem(
            id: '2',
            name: 'USB-C Cable',
            price: 19.99,
            quantity: 2,
            imageUrl: 'https://via.placeholder.com/300x300?text=Cable',
          ),
        ],
        shippingAddress: 'Toronto, ON M5V 2H1',
        trackingNumber: 'CP123456789CA',
        carrier: 'Canada Post',
      ),
      Order(
        id: 'LB002',
        orderNumber: 'LB-2025-002',
        status: 'shipped',
        orderDate: DateTime.now().subtract(const Duration(days: 3)),
        total: 299.99,
        items: [
          OrderItem(
            id: '3',
            name: 'Smart Watch Series 8',
            price: 299.99,
            quantity: 1,
            imageUrl: 'https://via.placeholder.com/300x300?text=Watch',
          ),
        ],
        shippingAddress: 'Vancouver, BC V6B 1A1',
        trackingNumber: 'CP987654321CA',
        carrier: 'Canada Post',
        estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
      ),
      Order(
        id: 'LB003',
        orderNumber: 'LB-2025-003',
        status: 'pending',
        orderDate: DateTime.now().subtract(const Duration(hours: 6)),
        total: 79.99,
        items: [
          OrderItem(
            id: '4',
            name: 'Phone Case Premium',
            price: 39.99,
            quantity: 1,
            imageUrl: 'https://via.placeholder.com/300x300?text=Case',
          ),
          OrderItem(
            id: '5',
            name: 'Screen Protector',
            price: 19.99,
            quantity: 2,
            imageUrl: 'https://via.placeholder.com/300x300?text=Protector',
          ),
        ],
        shippingAddress: 'Calgary, AB T2P 1J9',
      ),
    ];*/
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders =
          _orders.where((order) {
            final matchesFilter =
                _selectedFilter == 'all' || order.status == _selectedFilter;
            final matchesSearch =
                _searchQuery.isEmpty ||
                order.orderNumber.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                order.orderItems.any(
                  (item) => item.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                );

            return matchesFilter && matchesSearch;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        title: FxText.titleLarge(
          '${AppConfig.MARKETPLACE_NAME} Orders',
          fontWeight: 700,
          color: CustomTheme.color,
        ),
        backgroundColor: CustomTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FeatherIcons.arrowLeft, color: CustomTheme.accent),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(FeatherIcons.search, color: CustomTheme.accent),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Icon(FeatherIcons.filter, color: CustomTheme.accent),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: CustomTheme.primary,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty || _selectedFilter != 'all')
            _buildActiveFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_filteredOrders),
                _buildOrderList(
                  _filteredOrders
                      .where(
                        (o) => [
                          'pending',
                          'confirmed',
                          'shipped',
                        ].contains(o.status),
                      )
                      .toList(),
                ),
                _buildOrderList(
                  _filteredOrders
                      .where(
                        (o) => [
                          'delivered',
                          'cancelled',
                          'returned',
                        ].contains(o.status),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          if (_searchQuery.isNotEmpty) ...[
            Chip(
              label: Text('Search: $_searchQuery'),
              onDeleted: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
                _filterOrders();
              },
              deleteIcon: const Icon(FeatherIcons.x, size: 16),
              backgroundColor: Colors.blue[50],
            ),
            const SizedBox(width: 8),
          ],
          if (_selectedFilter != 'all') ...[
            Chip(
              label: Text('Status: ${_selectedFilter.toUpperCase()}'),
              onDeleted: () {
                setState(() {
                  _selectedFilter = 'all';
                });
                _filterOrders();
              },
              deleteIcon: const Icon(FeatherIcons.x, size: 16),
              backgroundColor: Colors.green[50],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              FeatherIcons.package,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to see your orders here',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(order.orderDate),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),

              const SizedBox(height: 12),

              // Order items preview
              Row(
                children: [
                  // Item images
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: order.orderItems.take(3).length,
                      itemBuilder: (context, index) {
                        final item = order.orderItems[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      FeatherIcons.image,
                                      size: 20,
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      FeatherIcons.image,
                                      size: 20,
                                    ),
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderItems.length == 1
                              ? order.orderItems.first.name
                              : '${order.orderItems.first.name} +${order.orderItems.length - 1} more',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${order.orderItems.length} item${order.orderItems.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'CAD',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  if (order.trackingNumber != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _trackOrder(order),
                        icon: const Icon(FeatherIcons.truck, size: 16),
                        label: const Text('Track Order'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomTheme.primary,
                          side: BorderSide(color: CustomTheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _reorderItems(order),
                      icon: const Icon(FeatherIcons.shoppingCart, size: 16),
                      label: const Text('Reorder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = FeatherIcons.clock;
        break;
      case 'confirmed':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        icon = FeatherIcons.checkCircle;
        break;
      case 'shipped':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        icon = FeatherIcons.truck;
        break;
      case 'delivered':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = FeatherIcons.check;
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = FeatherIcons.x;
        break;
      case 'returned':
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = FeatherIcons.refreshCw;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = FeatherIcons.helpCircle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Orders'),
            content: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Order number or product name...',
                prefixIcon: Icon(FeatherIcons.search),
              ),
              autofocus: true,
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterOrders();
                Navigator.of(context).pop();
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = _searchController.text;
                  });
                  _filterOrders();
                  Navigator.of(context).pop();
                },
                child: const Text('Search'),
              ),
            ],
          ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter by Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  _filterOptions.map((filter) {
                    return RadioListTile<String>(
                      title: Text(
                        filter == 'all' ? 'All Orders' : filter.toUpperCase(),
                      ),
                      value: filter,
                      groupValue: _selectedFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                        _filterOrders();
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _showOrderDetails(Order order) {
    /* Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    );*/
  }

  void _trackOrder(Order order) {
    /* Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(order: order),
      ),
    );*/
  }

  void _reorderItems(Order order) {
    // TODO: Implement reorder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${order.orderItems.length} items added to cart for reorder',
        ),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }
}
