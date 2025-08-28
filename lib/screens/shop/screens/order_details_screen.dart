import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:intl/intl.dart';

import '../../../models/Order.dart';
import '../../../utils/CustomTheme.dart';

/// Detailed order information screen with comprehensive order data
/// Displays complete order details including timeline, items, shipping info
class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _showFullTimeline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Order ${widget.order.orderNumber}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: CustomTheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(FeatherIcons.share2),
            onPressed: _shareOrder,
          ),
          PopupMenuButton<String>(
            icon: const Icon(FeatherIcons.moreVertical),
            onSelected: (value) {
              switch (value) {
                case 'support':
                  _contactSupport();
                  break;
                case 'invoice':
                  _downloadInvoice();
                  break;
                case 'return':
                  _initiateReturn();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'support',
                    child: Row(
                      children: [
                        Icon(FeatherIcons.helpCircle, size: 16),
                        SizedBox(width: 8),
                        Text('Contact Support'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'invoice',
                    child: Row(
                      children: [
                        Icon(FeatherIcons.download, size: 16),
                        SizedBox(width: 8),
                        Text('Download Invoice'),
                      ],
                    ),
                  ),
                  if (widget.order.status == 'delivered')
                    const PopupMenuItem(
                      value: 'return',
                      child: Row(
                        children: [
                          Icon(FeatherIcons.refreshCw, size: 16),
                          SizedBox(width: 8),
                          Text('Return Items'),
                        ],
                      ),
                    ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildOrderHeader(),
            _buildOrderTimeline(),
            _buildOrderItems(),
            _buildShippingInfo(),
            _buildPricingBreakdown(),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      color: CustomTheme.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
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
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                      Text(
                        _getStatusDescription(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${widget.order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
            const SizedBox(height: 16),
            _buildInfoRow(
              'Order Date',
              DateFormat(
                'MMMM dd, yyyy at h:mm a',
              ).format(widget.order.orderDate),
              FeatherIcons.calendar,
            ),
            if (widget.order.estimatedDelivery != null)
              _buildInfoRow(
                'Estimated Delivery',
                DateFormat(
                  'MMMM dd, yyyy',
                ).format(widget.order.estimatedDelivery!),
                FeatherIcons.truck,
              ),
            if (widget.order.deliveryDate != null)
              _buildInfoRow(
                'Delivered On',
                DateFormat(
                  'MMMM dd, yyyy at h:mm a',
                ).format(widget.order.deliveryDate!),
                FeatherIcons.check,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline() {
    final timelineEvents = _getTimelineEvents();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Timeline',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (timelineEvents.length > 3)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showFullTimeline = !_showFullTimeline;
                    });
                  },
                  child: Text(
                    _showFullTimeline ? 'Show Less' : 'Show All',
                    style: TextStyle(color: CustomTheme.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_showFullTimeline ? timelineEvents : timelineEvents.take(3))
              .map((event) => _buildTimelineItem(event))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TimelineEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  event.isCompleted
                      ? CustomTheme.primary.withValues(alpha: 0.1)
                      : Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    event.isCompleted ? CustomTheme.primary : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Icon(
              event.icon,
              size: 18,
              color: event.isCompleted ? CustomTheme.primary : Colors.grey[400],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        event.isCompleted ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                if (event.description != null)
                  Text(
                    event.description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                if (event.timestamp != null)
                  Text(
                    DateFormat('MMM dd, h:mm a').format(event.timestamp!),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${widget.order.items.toString()})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          /*          if (widget.order.items is List)
            ...widget.order.items.map<Widget>((item) => _buildOrderItem(item)).toList(),*/
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(FeatherIcons.image, size: 24),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(FeatherIcons.image, size: 24),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Unit Price: \$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (widget.order.status == 'delivered')
                TextButton(
                  onPressed: () => _reviewProduct(item),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Write Review',
                    style: TextStyle(color: CustomTheme.primary, fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildShippingRow(
            'Shipping Address',
            widget.order.shippingAddress ?? '',
            FeatherIcons.mapPin,
          ),
          if (widget.order.carrier != null)
            _buildShippingRow(
              'Carrier',
              widget.order.carrier!,
              FeatherIcons.truck,
            ),
          if (widget.order.trackingNumber != null)
            _buildShippingRow(
              'Tracking Number',
              widget.order.trackingNumber!,
              FeatherIcons.package,
              isTrackingNumber: true,
            ),
        ],
      ),
    );
  }

  Widget _buildShippingRow(
    String label,
    String value,
    IconData icon, {
    bool isTrackingNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isTrackingNumber)
                      TextButton(
                        onPressed: () => _trackOrder(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          'Track',
                          style: TextStyle(
                            color: CustomTheme.primary,
                            fontSize: 12,
                          ),
                        ),
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

  Widget _buildPricingBreakdown() {
    final subtotal = (widget.order.items as List).fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final hst = subtotal * 0.13; // 13% HST
    final shipping = 0.0; // Free shipping in this example

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Subtotal', subtotal),
          _buildPriceRow('HST (13%)', hst),
          _buildPriceRow('Shipping', shipping, note: 'Free shipping!'),
          const Divider(height: 24),
          _buildPriceRow('Total', widget.order.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isTotal = false,
    String? note,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              if (note != null)
                Text(
                  note,
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
            ],
          ),
          Text(
            '\$${amount.toStringAsFixed(2)} CAD',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? CustomTheme.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (widget.order.trackingNumber != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _trackOrder,
                icon: const Icon(FeatherIcons.truck),
                label: const Text('Track Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reorderItems,
                  icon: const Icon(FeatherIcons.shoppingCart, size: 16),
                  label: const Text('Reorder'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomTheme.primary,
                    side: BorderSide(color: CustomTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _contactSupport,
                  icon: const Icon(FeatherIcons.helpCircle, size: 16),
                  label: const Text('Get Help'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.order.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'returned':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.order.status.toLowerCase()) {
      case 'pending':
        return FeatherIcons.clock;
      case 'confirmed':
        return FeatherIcons.checkCircle;
      case 'shipped':
        return FeatherIcons.truck;
      case 'delivered':
        return FeatherIcons.check;
      case 'cancelled':
        return FeatherIcons.x;
      case 'returned':
        return FeatherIcons.refreshCw;
      default:
        return FeatherIcons.helpCircle;
    }
  }

  String _getStatusDescription() {
    switch (widget.order.status.toLowerCase()) {
      case 'pending':
        return 'Your order is being processed';
      case 'confirmed':
        return 'Order confirmed and preparing for shipment';
      case 'shipped':
        return 'Your order is on its way';
      case 'delivered':
        return 'Order delivered successfully';
      case 'cancelled':
        return 'Order has been cancelled';
      case 'returned':
        return 'Order has been returned';
      default:
        return 'Order status unknown';
    }
  }

  List<TimelineEvent> _getTimelineEvents() {
    final events = <TimelineEvent>[
      TimelineEvent(
        title: 'Order Placed',
        description: 'Your order has been received',
        timestamp: widget.order.orderDate,
        icon: FeatherIcons.shoppingBag,
        isCompleted: true,
      ),
    ];

    if (['confirmed', 'shipped', 'delivered'].contains(widget.order.status)) {
      events.add(
        TimelineEvent(
          title: 'Order Confirmed',
          description: 'Order confirmed and preparing for shipment',
          timestamp: widget.order.orderDate.add(const Duration(hours: 2)),
          icon: FeatherIcons.checkCircle,
          isCompleted: true,
        ),
      );
    }

    if (['shipped', 'delivered'].contains(widget.order.status)) {
      events.add(
        TimelineEvent(
          title: 'Order Shipped',
          description: 'Package is on its way',
          timestamp: widget.order.orderDate.add(const Duration(days: 1)),
          icon: FeatherIcons.truck,
          isCompleted: true,
        ),
      );
    }

    if (widget.order.status == 'delivered') {
      events.add(
        TimelineEvent(
          title: 'Order Delivered',
          description: 'Package delivered successfully',
          timestamp: widget.order.deliveryDate ?? DateTime.now(),
          icon: FeatherIcons.check,
          isCompleted: true,
        ),
      );
    } else if (widget.order.estimatedDelivery != null) {
      events.add(
        TimelineEvent(
          title: 'Estimated Delivery',
          description: 'Expected delivery date',
          timestamp: widget.order.estimatedDelivery,
          icon: FeatherIcons.check,
          isCompleted: false,
        ),
      );
    }

    return events;
  }

  void _shareOrder() {
    // TODO: Implement order sharing
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order details shared')));
  }

  void _contactSupport() {
    // TODO: Implement support contact
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening support chat...')));
  }

  void _downloadInvoice() {
    // TODO: Implement invoice download
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invoice download started')));
  }

  void _initiateReturn() {
    // TODO: Implement return process
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Return process initiated')));
  }

  void _trackOrder() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(order: widget.order),
      ),
    );
  }

  void _reorderItems() {
    // TODO: Implement reorder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.order.items.toString()} items added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }

  void _reviewProduct(OrderItem item) {
    // TODO: Implement product review
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Write review for ${item.name}')));
  }
}

// Timeline event model
class TimelineEvent {
  final String title;
  final String? description;
  final DateTime? timestamp;
  final IconData icon;
  final bool isCompleted;

  TimelineEvent({
    required this.title,
    this.description,
    this.timestamp,
    required this.icon,
    required this.isCompleted,
  });
}

// Order Tracking Screen placeholder
class OrderTrackingScreen extends StatelessWidget {
  final Order order;

  const OrderTrackingScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: CustomTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Order Tracking Screen - To be implemented'),
      ),
    );
  }
}
