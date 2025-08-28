import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../services/stripe_payment_service.dart';
import '../../utils/CustomTheme.dart';

/// Enhanced payment widget with Stripe integration
/// Provides secure payment processing for Canadian market
class EnhancedPaymentWidget extends StatefulWidget {
  final double amount;
  final Map<String, dynamic> orderData;
  final Function(Map<String, dynamic>) onPaymentSuccess;
  final Function(String) onPaymentError;
  final VoidCallback? onCancel;

  const EnhancedPaymentWidget({
    Key? key,
    required this.amount,
    required this.orderData,
    required this.onPaymentSuccess,
    required this.onPaymentError,
    this.onCancel,
  }) : super(key: key);

  @override
  State<EnhancedPaymentWidget> createState() => _EnhancedPaymentWidgetState();
}

class _EnhancedPaymentWidgetState extends State<EnhancedPaymentWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _emailController = TextEditingController();

  // State
  bool _isProcessing = false;
  bool _savePaymentMethod = false;
  String _cardType = 'unknown';
  String? _customerId;
  Map<String, double>? _totals;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _calculateTotals();
    _initializeStripe();
  }

  void _calculateTotals() {
    _totals = StripePaymentService.calculateCanadianTotals(widget.amount);
  }

  Future<void> _initializeStripe() async {
    try {
      await StripePaymentService.initialize();
    } catch (e) {
      widget.onPaymentError('Failed to initialize payment system: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildTotalSummary(),
          _buildPaymentTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCreditCardForm(),
                _buildApplePayForm(),
                _buildGooglePayForm(),
                _buildPayPalForm(),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(FeatherIcons.creditCard, color: CustomTheme.primary, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Secure Payment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          if (widget.onCancel != null)
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(FeatherIcons.x, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary() {
    if (_totals == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', _totals!['subtotal']!),
          _buildSummaryRow('HST (13%)', _totals!['hst']!),
          const Divider(),
          _buildSummaryRow('Total', _totals!['total']!, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
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

  Widget _buildPaymentTabs() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: CustomTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Card'),
          Tab(text: 'Apple Pay'),
          Tab(text: 'Google Pay'),
          Tab(text: 'PayPal'),
        ],
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card number
            _buildCardNumberField(),
            const SizedBox(height: 16),

            // Cardholder name
            _buildTextFormField(
              controller: _cardHolderController,
              label: 'Cardholder Name',
              icon: FeatherIcons.user,
              textCapitalization: TextCapitalization.words,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Expiry and CVV
            Row(
              children: [
                Expanded(child: _buildExpiryField()),
                const SizedBox(width: 12),
                Expanded(child: _buildCVVField()),
              ],
            ),
            const SizedBox(height: 16),

            // Email (for receipt)
            _buildTextFormField(
              controller: _emailController,
              label: 'Email for Receipt',
              icon: FeatherIcons.mail,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty == true) return 'Required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                  return 'Invalid email format';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Save payment method
            CheckboxListTile(
              value: _savePaymentMethod,
              onChanged:
                  (value) =>
                      setState(() => _savePaymentMethod = value ?? false),
              title: const Text('Save payment method for future orders'),
              subtitle: const Text('Your card details will be securely stored'),
              contentPadding: EdgeInsets.zero,
              activeColor: CustomTheme.primary,
            ),

            const SizedBox(height: 16),

            // Security notice
            _buildSecurityNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      decoration: InputDecoration(
        labelText: 'Card Number',
        prefixIcon: Icon(FeatherIcons.creditCard, color: CustomTheme.primary),
        suffixIcon:
            _cardType != 'unknown'
                ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildCardTypeIcon(),
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CustomTheme.primary),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CardNumberInputFormatter(),
      ],
      onChanged: (value) {
        setState(() {
          _cardType = StripePaymentService.getCardType(value);
        });
      },
      validator: (value) {
        if (value?.isEmpty == true) return 'Required';
        if (!StripePaymentService.validateCreditCard(value!)) {
          return 'Invalid card number';
        }
        return null;
      },
    );
  }

  Widget _buildExpiryField() {
    return TextFormField(
      controller: _expiryController,
      decoration: InputDecoration(
        labelText: 'MM/YY',
        prefixIcon: Icon(FeatherIcons.calendar, color: CustomTheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CustomTheme.primary),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ExpiryDateInputFormatter(),
      ],
      validator: (value) {
        if (value?.isEmpty == true) return 'Required';
        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) return 'Invalid format';

        final parts = value.split('/');
        final month = int.tryParse(parts[0]);
        final year = int.tryParse(parts[1]);

        if (month == null || year == null || month < 1 || month > 12) {
          return 'Invalid date';
        }

        final currentYear = DateTime.now().year % 100;
        final currentMonth = DateTime.now().month;

        if (year < currentYear ||
            (year == currentYear && month < currentMonth)) {
          return 'Card expired';
        }

        return null;
      },
    );
  }

  Widget _buildCVVField() {
    return TextFormField(
      controller: _cvvController,
      decoration: InputDecoration(
        labelText: 'CVV',
        prefixIcon: Icon(FeatherIcons.shield, color: CustomTheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CustomTheme.primary),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      obscureText: true,
      validator: (value) {
        if (value?.isEmpty == true) return 'Required';
        if (value!.length < 3) return 'Invalid CVV';
        return null;
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: CustomTheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CustomTheme.primary),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      textCapitalization: textCapitalization,
    );
  }

  Widget _buildCardTypeIcon() {
    switch (_cardType) {
      case 'visa':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'mastercard':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red[600],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'MC',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'amex':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.green[600],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'AMEX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(FeatherIcons.shield, color: Colors.green[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your payment information is encrypted and secure. We use Stripe for processing.',
              style: TextStyle(color: Colors.green[700], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplePayForm() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FeatherIcons.smartphone, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Apple Pay',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Use Touch ID or Face ID to pay securely',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _processApplePay(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Pay with Apple Pay',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGooglePayForm() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FeatherIcons.smartphone, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Google Pay',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pay quickly and securely with Google Pay',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _processGooglePay(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Pay with Google Pay',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayPalForm() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FeatherIcons.dollarSign, size: 64, color: Colors.blue[600]),
          const SizedBox(height: 24),
          Text(
            'PayPal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You will be redirected to PayPal to complete your payment',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _processPayPal(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue to PayPal',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          if (widget.onCancel != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessing ? null : widget.onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: CustomTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: CustomTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isProcessing
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        'Pay ${StripePaymentService.formatCAD(_totals?['total'] ?? 0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_tabController.index == 0 && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create customer if needed for saving payment method
      if (_savePaymentMethod && _customerId == null) {
        final customerResult = await StripePaymentService.createCustomer(
          email: _emailController.text,
          name: _cardHolderController.text,
          metadata: {
            'source': 'lovebirds_shop',
            'user_id': widget.orderData['user_id']?.toString() ?? '',
          },
        );

        if (customerResult['success']) {
          _customerId = customerResult['customer_id'];
        }
      }

      // Create payment intent
      final paymentResult = await StripePaymentService.createPaymentIntent(
        amount: _totals!['total']!,
        currency: 'cad',
        metadata: {
          'order_id': widget.orderData['order_id']?.toString() ?? '',
          'user_id': widget.orderData['user_id']?.toString() ?? '',
          'items_count': widget.orderData['items_count']?.toString() ?? '',
        },
        customerId: _customerId,
      );

      if (paymentResult['success']) {
        // For demo purposes, simulate successful payment
        // In real implementation, you would handle the payment confirmation here

        await Future.delayed(const Duration(seconds: 2)); // Simulate processing

        widget.onPaymentSuccess({
          'payment_intent_id': paymentResult['payment_intent']['id'],
          'amount': _totals!['total']!,
          'currency': 'cad',
          'status': 'succeeded',
          'payment_method': _getSelectedPaymentMethod(),
        });
      } else {
        widget.onPaymentError(paymentResult['error'] ?? 'Payment failed');
      }
    } catch (e) {
      widget.onPaymentError('Payment processing error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processApplePay() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate Apple Pay processing
      await Future.delayed(const Duration(seconds: 2));

      widget.onPaymentSuccess({
        'payment_method': 'apple_pay',
        'amount': _totals!['total']!,
        'currency': 'cad',
        'status': 'succeeded',
      });
    } catch (e) {
      widget.onPaymentError('Apple Pay error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processGooglePay() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate Google Pay processing
      await Future.delayed(const Duration(seconds: 2));

      widget.onPaymentSuccess({
        'payment_method': 'google_pay',
        'amount': _totals!['total']!,
        'currency': 'cad',
        'status': 'succeeded',
      });
    } catch (e) {
      widget.onPaymentError('Google Pay error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processPayPal() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate PayPal processing
      await Future.delayed(const Duration(seconds: 2));

      widget.onPaymentSuccess({
        'payment_method': 'paypal',
        'amount': _totals!['total']!,
        'currency': 'cad',
        'status': 'succeeded',
      });
    } catch (e) {
      widget.onPaymentError('PayPal error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _getSelectedPaymentMethod() {
    switch (_tabController.index) {
      case 0:
        return 'card';
      case 1:
        return 'apple_pay';
      case 2:
        return 'google_pay';
      case 3:
        return 'paypal';
      default:
        return 'card';
    }
  }
}

/// Custom input formatter for card numbers
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Custom input formatter for expiry dates
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
