/*
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../utils/CustomTheme.dart';
import '../../../models/Order.dart';

/// Interactive order tracking screen with real-time shipping updates
/// Provides detailed tracking timeline and carrier integration
class OrderTrackingScreen extends StatefulWidget {
  final Order order;

  const OrderTrackingScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  List<TrackingEvent> _trackingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _loadTrackingData();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _refreshTrackingData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Regenerate tracking events (in real app, fetch from API)
    _trackingEvents = _generateTrackingEvents();

    setState(() {
      _isLoading = false;
    });

  Future<void> _refreshTracking() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tracking information updated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<TrackingEvent> _generateTrackingEvents() {
    final orderDate = widget.order.orderDate;

    return [
      TrackingEvent(
        title: 'Order Placed',
        description: 'Your order has been received and is being processed',
        location: 'Lovebirds Shop',
        timestamp: orderDate,
        status: TrackingStatus.completed,
        icon: FeatherIcons.shoppingBag,
      ),
      TrackingEvent(
        title: 'Order Confirmed',
        description: 'Payment confirmed, preparing items for shipment',
        location: 'Fulfillment Center - Toronto, ON',
        timestamp: orderDate.add(const Duration(hours: 2)),
        status: TrackingStatus.completed,
        icon: FeatherIcons.checkCircle,
      ),
      TrackingEvent(
        title: 'Package Prepared',
        description: 'Items packed and ready for pickup',
        location: 'Fulfillment Center - Toronto, ON',
        timestamp: orderDate.add(const Duration(days: 1)),
        status: TrackingStatus.completed,
        icon: FeatherIcons.package,
      ),
      TrackingEvent(
        title: 'In Transit',
        description: 'Package picked up by carrier and in transit',
        location: 'Toronto Sorting Facility, ON',
        timestamp: orderDate.add(const Duration(days: 1, hours: 6)),
        status:
            widget.order.status == 'shipped'
                ? TrackingStatus.current
                : TrackingStatus.completed,
        icon: FeatherIcons.truck,
      ),
      if (widget.order.status == 'delivered' ||
          widget.order.estimatedDelivery != null)
        TrackingEvent(
          title:
              widget.order.status == 'delivered'
                  ? 'Delivered'
                  : 'Out for Delivery',
          description:
              widget.order.status == 'delivered'
                  ? 'Package delivered successfully'
                  : 'Package is out for delivery',
          location: widget.order.shippingAddress,
          timestamp:
              widget.order.deliveryDate ?? widget.order.estimatedDelivery!,
          status:
              widget.order.status == 'delivered'
                  ? TrackingStatus.completed
                  : TrackingStatus.pending,
          icon: FeatherIcons.check,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Track Order',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: CustomTheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(FeatherIcons.share2),
            onPressed: _shareTracking,
          ),
          IconButton(
            icon: const Icon(FeatherIcons.refreshCw),
            onPressed: _refreshTracking,
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : RefreshIndicator(
                onRefresh: _refreshTracking,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTrackingHeader(),
                      _buildProgressIndicator(),
                      _buildTrackingTimeline(),
                      _buildCarrierInfo(),
                      _buildOrderSummary(),
                      _buildActionButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(CustomTheme.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading tracking information...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingHeader() {
    final currentEvent = _trackingEvents.firstWhere(
      (event) => event.status == TrackingStatus.current,
      orElse: () => _trackingEvents.last,
    );

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
                    color: _getStatusColor(
                      currentEvent.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    currentEvent.icon,
                    color: _getStatusColor(currentEvent.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentEvent.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currentEvent.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(FeatherIcons.package, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Order ${widget.order.orderNumber}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                if (widget.order.trackingNumber != null)
                  GestureDetector(
                    onTap: _copyTrackingNumber,
                    child: Row(
                      children: [
                        Text(
                          widget.order.trackingNumber!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          FeatherIcons.copy,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final completedEvents =
        _trackingEvents
            .where((e) => e.status == TrackingStatus.completed)
            .length;
    final totalEvents = _trackingEvents.length;
    final progress = completedEvents / totalEvents;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: TextStyle(
                  color: CustomTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: progress * _progressAnimation.value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(CustomTheme.primary),
                minHeight: 8,
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Placed',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                widget.order.status == 'delivered' ? 'Delivered' : 'In Transit',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
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
            'Tracking Timeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ..._trackingEvents.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == _trackingEvents.length - 1;

            return _buildTimelineItem(event, isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TrackingEvent event, bool isLast) {
    final statusColor = _getStatusColor(event.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      event.status == TrackingStatus.current
                          ? statusColor
                          : event.status == TrackingStatus.completed
                          ? statusColor
                          : Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor,
                    width: event.status == TrackingStatus.current ? 3 : 2,
                  ),
                ),
                child: Icon(
                  event.icon,
                  size: 18,
                  color:
                      event.status == TrackingStatus.pending
                          ? Colors.grey[400]
                          : Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color:
                      event.status == TrackingStatus.completed
                          ? statusColor
                          : Colors.grey[200],
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Event details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              event.status == TrackingStatus.pending
                                  ? Colors.grey[600]
                                  : Colors.black87,
                        ),
                      ),
                      if (event.timestamp != null)
                        Text(
                          DateFormat('MMM dd, h:mm a').format(event.timestamp!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          FeatherIcons.mapPin,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrierInfo() {
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
            'Carrier Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (widget.order.carrier != null) ...[
            _buildInfoRow('Carrier', widget.order.carrier!, FeatherIcons.truck),
            if (widget.order.trackingNumber != null)
              _buildInfoRow(
                'Tracking Number',
                widget.order.trackingNumber!,
                FeatherIcons.package,
                onTap: _copyTrackingNumber,
              ),
            _buildInfoRow(
              'Service Type',
              'Standard Shipping',
              FeatherIcons.box,
            ),
            if (widget.order.estimatedDelivery != null)
              _buildInfoRow(
                'Estimated Delivery',
                DateFormat(
                  'MMMM dd, yyyy',
                ).format(widget.order.estimatedDelivery!),
                FeatherIcons.calendar,
              ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openCarrierWebsite,
                  icon: const Icon(FeatherIcons.externalLink, size: 16),
                  label: const Text('Track on Carrier Site'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomTheme.primary,
                    side: BorderSide(color: CustomTheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _contactCarrier,
                  icon: const Icon(FeatherIcons.phone, size: 16),
                  label: const Text('Contact Carrier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
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
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(FeatherIcons.copy, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
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
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Item images
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: widget.order.items.take(3).length,
                  itemBuilder: (context, index) {
                    final item = widget.order.items[index];
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
                                child: const Icon(FeatherIcons.image, size: 20),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(FeatherIcons.image, size: 20),
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.order.items.length} item${widget.order.items.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Total: \$${widget.order.total.toStringAsFixed(2)} CAD',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      'To: ${widget.order.shippingAddress}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(FeatherIcons.eye),
              label: const Text('View Order Details'),
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
                  onPressed: _shareTracking,
                  icon: const Icon(FeatherIcons.share2, size: 16),
                  label: const Text('Share Tracking'),
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
                  onPressed: _getHelp,
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

  Color _getStatusColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.completed:
        return CustomTheme.primary;
      case TrackingStatus.current:
        return Colors.blue;
      case TrackingStatus.pending:
        return Colors.grey;
    }
  }

  void _copyTrackingNumber() {
    if (widget.order.trackingNumber != null) {
      // TODO: Implement clipboard copy
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tracking number ${widget.order.trackingNumber} copied',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareTracking() {
    // TODO: Implement tracking sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tracking information shared')),
    );
  }

  void _openCarrierWebsite() {
    // TODO: Implement carrier website opening
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening carrier website...')));
  }

  void _contactCarrier() {
    // TODO: Implement carrier contact
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Contacting carrier...')));
  }

  void _getHelp() {
    // TODO: Implement help/support
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening support...')));
  }
}

// Tracking event model
class TrackingEvent {
  final String title;
  final String description;
  final String? location;
  final DateTime? timestamp;
  final TrackingStatus status;
  final IconData icon;

  TrackingEvent({
    required this.title,
    required this.description,
    this.location,
    this.timestamp,
    required this.status,
    required this.icon,
  });
}

enum TrackingStatus { completed, current, pending }
*/
