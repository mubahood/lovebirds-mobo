import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../../config/payment_config.dart';
import '../../../services/stripe_payment_service.dart';
import '../../../utils/CustomTheme.dart';
import '../../../widgets/shop/enhanced_payment_widget.dart';
import '../models/CartItem.dart';

/// Standalone payment demo screen for testing payment integration
/// Can be accessed independently to test payment flow without full checkout
class PaymentDemoScreen extends StatefulWidget {
  const PaymentDemoScreen({Key? key}) : super(key: key);

  @override
  State<PaymentDemoScreen> createState() => _PaymentDemoScreenState();
}

class _PaymentDemoScreenState extends State<PaymentDemoScreen> {
  bool _showPaymentWidget = false;
  List<CartItem> _demoItems = [];

  @override
  void initState() {
    super.initState();
    _createDemoItems();
  }

  void _createDemoItems() {
    // Create some demo cart items for testing
    _demoItems = [
      CartItem()
        ..id = 1
        ..product_name = "Wireless Bluetooth Headphones"
        ..product_price_1 = "89.99"
        ..product_quantity = "1"
        ..product_feature_photo =
            "https://via.placeholder.com/300x300?text=Headphones",
      CartItem()
        ..id = 2
        ..product_name = "Smart Watch Series 8"
        ..product_price_1 = "299.99"
        ..product_quantity = "1"
        ..product_feature_photo =
            "https://via.placeholder.com/300x300?text=Watch",
      CartItem()
        ..id = 3
        ..product_name = "USB-C Cable"
        ..product_price_1 = "19.99"
        ..product_quantity = "2"
        ..product_feature_photo =
            "https://via.placeholder.com/300x300?text=Cable",
    ];
  }

  double _calculateDemoTotal() {
    return _demoItems.fold(0.0, (total, item) {
      final price = double.tryParse(item.product_price_1) ?? 0.0;
      final quantity = int.tryParse(item.product_quantity) ?? 1;
      return total + (price * quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Payment Demo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: CustomTheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _showPaymentWidget ? _buildPaymentView() : _buildDemoOrderView(),
    );
  }

  Widget _buildDemoOrderView() {
    final total = _calculateDemoTotal();
    final totals = StripePaymentService.calculateCanadianTotals(total);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FeatherIcons.shoppingCart,
                      color: CustomTheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Demo Order',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Test the payment integration with sample products',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Demo Items
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Order Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._demoItems.map((item) => _buildDemoItem(item)).toList(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Price Breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
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
                _buildPriceRow('Subtotal', totals['subtotal']!),
                _buildPriceRow('HST (13%)', totals['hst']!),
                _buildPriceRow(
                  'Shipping',
                  0.0,
                  note: 'Free shipping over \$50!',
                ),
                const Divider(height: 24),
                _buildPriceRow('Total', totals['total']!, isTotal: true),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Payment Configuration Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(FeatherIcons.info, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Demo Mode Configuration',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Using test Stripe keys\n'
                  '• Canadian market settings (CAD, HST)\n'
                  '• Mock payment processing\n'
                  '• Debug logging enabled',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Proceed to Payment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showPaymentWidget = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FeatherIcons.creditCard, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Proceed to Payment - ${StripePaymentService.formatCAD(totals['total']!)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Test Cards Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FeatherIcons.creditCard,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Test Card Numbers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Success: 4242 4242 4242 4242\n'
                  'Decline: 4000 0000 0000 0002\n'
                  'Expiry: Any future date (e.g., 12/26)\n'
                  'CVV: Any 3-digit number',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoItem(CartItem item) {
    final price = double.tryParse(item.product_price_1) ?? 0.0;
    final quantity = int.tryParse(item.product_quantity) ?? 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Product placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FeatherIcons.package, color: Colors.grey[500]),
          ),

          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product_name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Qty: $quantity',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // Price
          Text(
            '\$${(price * quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          Text(
            StripePaymentService.formatCAD(amount),
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

  Widget _buildPaymentView() {
    return Column(
      children: [
        // Back button
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showPaymentWidget = false;
                  });
                },
                icon: const Icon(FeatherIcons.arrowLeft),
              ),
              const Text('Back to Order', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),

        // Payment widget
        Expanded(
          child: EnhancedPaymentWidget(
            amount: _calculateDemoTotal(),
            orderData: {
              'order_id': 'demo_${DateTime.now().millisecondsSinceEpoch}',
              'user_id': 'demo_user',
              'items_count': _demoItems.length,
              'items':
                  _demoItems
                      .map(
                        (item) => {
                          'id': item.id,
                          'title': item.product_name,
                          'price': double.tryParse(item.product_price_1) ?? 0.0,
                          'quantity': int.tryParse(item.product_quantity) ?? 1,
                          'image_url': item.product_feature_photo,
                        },
                      )
                      .toList(),
            },
            onPaymentSuccess: (paymentResult) {
              _showSuccessDialog(paymentResult);
            },
            onPaymentError: (error) {
              _showErrorDialog(error);
            },
            onCancel: () {
              setState(() {
                _showPaymentWidget = false;
              });
            },
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog(Map<String, dynamic> paymentResult) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FeatherIcons.check,
                    size: 48,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'This was a demo payment. In a real app, the order would be processed now.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Amount: ${StripePaymentService.formatCAD(paymentResult['amount'] ?? 0)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment Method: ${paymentResult['payment_method'] ?? 'Unknown'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  setState(() {
                    _showPaymentWidget = false;
                  });
                },
                child: const Text('Back to Demo'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Return to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primary,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(FeatherIcons.alertTriangle, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Payment Failed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(error),
                const SizedBox(height: 12),
                Text(
                  'This is a demo environment. Try using the test card numbers provided.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Try Again'),
              ),
            ],
          ),
    );
  }
}
