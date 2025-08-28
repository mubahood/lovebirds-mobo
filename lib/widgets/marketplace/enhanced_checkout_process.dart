import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../../utils/dating_theme.dart';
import 'comprehensive_cart_widget.dart';

/// Multi-step checkout process with address, shipping, payment, and confirmation
/// Provides comprehensive e-commerce checkout experience with Canadian features
class EnhancedCheckoutProcess extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(Map<String, dynamic>) onOrderComplete;

  const EnhancedCheckoutProcess({
    Key? key,
    required this.cartItems,
    required this.onOrderComplete,
  }) : super(key: key);

  @override
  State<EnhancedCheckoutProcess> createState() =>
      _EnhancedCheckoutProcessState();
}

class _EnhancedCheckoutProcessState extends State<EnhancedCheckoutProcess>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _isProcessing = false;

  // Checkout data
  CheckoutData _checkoutData = CheckoutData();

  final List<String> _stepTitles = [
    'Shipping Address',
    'Shipping Method',
    'Payment Info',
    'Review & Confirm',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _updateProgress();
  }

  void _updateProgress() {
    final progress = (_currentStep + 1) / _totalSteps;
    _progressController.animateTo(progress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildShippingAddressStep(),
                _buildShippingMethodStep(),
                _buildPaymentStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(FeatherIcons.arrowLeft, color: DatingTheme.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Checkout',
        style: const TextStyle(
          color: DatingTheme.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(FeatherIcons.helpCircle, color: DatingTheme.primaryPink),
          onPressed: _showHelpDialog,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(_totalSteps, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? Colors.green
                                : isActive
                                ? DatingTheme.primaryPink
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child:
                            isCompleted
                                ? Icon(
                                  FeatherIcons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                                : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color:
                                        isActive
                                            ? Colors.white
                                            : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                      ),
                    ),

                    // Connecting line
                    if (index < _totalSteps - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color:
                                index < _currentStep
                                    ? Colors.green
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Current step title
          Text(
            _stepTitles[_currentStep],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DatingTheme.primaryText,
            ),
          ),

          const SizedBox(height: 8),

          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(DatingTheme.primaryPink),
                minHeight: 4,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guest checkout option
          if (!_checkoutData.isLoggedIn) _buildGuestCheckoutCard(),

          const SizedBox(height: 20),

          // Shipping address form
          _buildSectionCard(
            title: 'Shipping Address',
            icon: FeatherIcons.mapPin,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'First Name',
                        _checkoutData.firstName,
                        (value) => _checkoutData.firstName = value,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        'Last Name',
                        _checkoutData.lastName,
                        (value) => _checkoutData.lastName = value,
                        required: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Email Address',
                  _checkoutData.email,
                  (value) => _checkoutData.email = value,
                  keyboardType: TextInputType.emailAddress,
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Phone Number',
                  _checkoutData.phone,
                  (value) => _checkoutData.phone = value,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Street Address',
                  _checkoutData.streetAddress,
                  (value) => _checkoutData.streetAddress = value,
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Apartment, suite, etc. (optional)',
                  _checkoutData.apartment,
                  (value) => _checkoutData.apartment = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        'City',
                        _checkoutData.city,
                        (value) => _checkoutData.city = value,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildProvinceDropdown()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Postal Code',
                        _checkoutData.postalCode,
                        (value) => _checkoutData.postalCode = value,
                        required: true,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: const Text(
                          'Canada',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Billing address option
          _buildBillingAddressOption(),

          const SizedBox(height: 20),

          // Save address option
          if (_checkoutData.isLoggedIn) _buildSaveAddressOption(),
        ],
      ),
    );
  }

  Widget _buildShippingMethodStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Shipping Methods',
            icon: FeatherIcons.truck,
            child: Column(
              children: [
                _buildShippingOption(
                  'Standard Shipping',
                  'Delivered in 5-7 business days',
                  9.99,
                  'standard',
                  true,
                ),
                const SizedBox(height: 12),
                _buildShippingOption(
                  'Express Shipping',
                  'Delivered in 2-3 business days',
                  19.99,
                  'express',
                  false,
                ),
                const SizedBox(height: 12),
                _buildShippingOption(
                  'Overnight Shipping',
                  'Delivered next business day',
                  39.99,
                  'overnight',
                  false,
                ),
                const SizedBox(height: 12),
                _buildShippingOption(
                  'Free Shipping',
                  'Delivered in 7-10 business days (Orders over \$50)',
                  0.00,
                  'free',
                  false,
                  enabled: _calculateSubtotal() >= 50.0,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Delivery instructions
          _buildSectionCard(
            title: 'Delivery Instructions',
            icon: FeatherIcons.fileText,
            child: _buildTextField(
              'Special delivery instructions (optional)',
              _checkoutData.deliveryInstructions,
              (value) => _checkoutData.deliveryInstructions = value,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment methods
          _buildSectionCard(
            title: 'Payment Method',
            icon: FeatherIcons.creditCard,
            child: Column(
              children: [
                _buildPaymentMethodOption(
                  'Credit Card',
                  'Visa, Mastercard, Amex',
                  FeatherIcons.creditCard,
                  'card',
                ),
                const SizedBox(height: 12),
                _buildPaymentMethodOption(
                  'PayPal',
                  'Pay with your PayPal account',
                  FeatherIcons.dollarSign,
                  'paypal',
                ),
                const SizedBox(height: 12),
                _buildPaymentMethodOption(
                  'Apple Pay',
                  'Touch ID or Face ID',
                  FeatherIcons.smartphone,
                  'apple_pay',
                ),
                const SizedBox(height: 12),
                _buildPaymentMethodOption(
                  'Google Pay',
                  'Pay with Google',
                  FeatherIcons.smartphone,
                  'google_pay',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Credit card form (if card is selected)
          if (_checkoutData.paymentMethod == 'card') _buildCreditCardForm(),

          const SizedBox(height: 20),

          // Order summary
          _buildOrderSummary(),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order items
          _buildSectionCard(
            title: 'Order Items',
            icon: FeatherIcons.package,
            child: Column(
              children:
                  widget.cartItems
                      .map((item) => _buildOrderItemCard(item))
                      .toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Shipping info
          _buildSectionCard(
            title: 'Shipping Information',
            icon: FeatherIcons.mapPin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_checkoutData.firstName} ${_checkoutData.lastName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_checkoutData.streetAddress ?? ''),
                if (_checkoutData.apartment?.isNotEmpty == true)
                  Text(_checkoutData.apartment!),
                Text(
                  '${_checkoutData.city}, ${_checkoutData.province} ${_checkoutData.postalCode}',
                ),
                Text('Canada'),
                if (_checkoutData.phone?.isNotEmpty == true)
                  Text('Phone: ${_checkoutData.phone}'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Payment info
          _buildSectionCard(
            title: 'Payment Information',
            icon: FeatherIcons.creditCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPaymentMethodDisplayName(_checkoutData.paymentMethod),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_checkoutData.paymentMethod == 'card' &&
                    _checkoutData.cardNumber?.isNotEmpty == true)
                  Text(
                    '**** **** **** ${_checkoutData.cardNumber!.substring(_checkoutData.cardNumber!.length - 4)}',
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Final order summary
          _buildFinalOrderSummary(),

          const SizedBox(height: 20),

          // Terms and conditions
          _buildTermsAndConditions(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessing ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DatingTheme.primaryPink,
                  side: BorderSide(color: DatingTheme.primaryPink),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: DatingTheme.primaryPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isProcessing
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                      : Text(
                        _currentStep == _totalSteps - 1
                            ? 'Place Order'
                            : 'Continue',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DatingTheme.primaryPink, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DatingTheme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String? value,
    Function(String) onChanged, {
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    final provinces = [
      'AB',
      'BC',
      'MB',
      'NB',
      'NL',
      'NS',
      'ON',
      'PE',
      'QC',
      'SK',
      'NT',
      'NU',
      'YT',
    ];

    return DropdownButtonFormField<String>(
      value: _checkoutData.province,
      decoration: InputDecoration(
        labelText: 'Province *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      items:
          provinces
              .map(
                (province) =>
                    DropdownMenuItem(value: province, child: Text(province)),
              )
              .toList(),
      onChanged: (value) => setState(() => _checkoutData.province = value),
    );
  }

  Widget _buildShippingOption(
    String title,
    String description,
    double price,
    String value,
    bool isDefault, {
    bool enabled = true,
  }) {
    final isSelected =
        _checkoutData.shippingMethod == value ||
        (_checkoutData.shippingMethod == null && isDefault);

    return GestureDetector(
      onTap:
          enabled
              ? () => setState(() => _checkoutData.shippingMethod = value)
              : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? DatingTheme.primaryPink : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? Colors.white : Colors.grey[100],
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue:
                  _checkoutData.shippingMethod ?? (isDefault ? value : null),
              onChanged:
                  enabled
                      ? (val) =>
                          setState(() => _checkoutData.shippingMethod = val)
                      : null,
              activeColor: DatingTheme.primaryPink,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: enabled ? DatingTheme.primaryText : Colors.grey,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled ? Colors.grey[600] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price == 0 ? 'FREE' : '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: enabled ? DatingTheme.primaryPink : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    String title,
    String description,
    IconData icon,
    String value,
  ) {
    final isSelected = _checkoutData.paymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _checkoutData.paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? DatingTheme.primaryPink : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _checkoutData.paymentMethod,
              onChanged:
                  (val) => setState(() => _checkoutData.paymentMethod = val),
              activeColor: DatingTheme.primaryPink,
            ),
            Icon(icon, color: DatingTheme.primaryPink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return _buildSectionCard(
      title: 'Credit Card Information',
      icon: FeatherIcons.creditCard,
      child: Column(
        children: [
          _buildTextField(
            'Card Number',
            _checkoutData.cardNumber,
            (value) => _checkoutData.cardNumber = value,
            keyboardType: TextInputType.number,
            required: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'MM/YY',
                  _checkoutData.expiryDate,
                  (value) => _checkoutData.expiryDate = value,
                  keyboardType: TextInputType.number,
                  required: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'CVV',
                  _checkoutData.cvv,
                  (value) => _checkoutData.cvv = value,
                  keyboardType: TextInputType.number,
                  required: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Cardholder Name',
            _checkoutData.cardholderName,
            (value) => _checkoutData.cardholderName = value,
            required: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = _calculateSubtotal();
    final shipping = _calculateShipping();
    final tax = _calculateTax(subtotal);
    final total = subtotal + shipping + tax;

    return _buildSectionCard(
      title: 'Order Summary',
      icon: FeatherIcons.fileText,
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', subtotal),
          _buildSummaryRow('Shipping', shipping),
          _buildSummaryRow('Tax (HST)', tax),
          const Divider(),
          _buildSummaryRow('Total', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? DatingTheme.primaryText : Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            '\$${amount.toStringAsFixed(2)} CAD',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color:
                  isTotal ? DatingTheme.primaryPink : DatingTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCheckoutCard() {
    return Container(
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
              Icon(FeatherIcons.info, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Guest Checkout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Continue as guest or create an account for faster checkout and order tracking.',
            style: TextStyle(color: Colors.blue[700]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to login/register
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                    side: BorderSide(color: Colors.blue[700]!),
                  ),
                  child: const Text('Create Account'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _checkoutData.isLoggedIn = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continue as Guest'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAddressOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _checkoutData.billingAddressSameAsShipping,
            onChanged:
                (value) => setState(
                  () =>
                      _checkoutData.billingAddressSameAsShipping =
                          value ?? true,
                ),
            activeColor: DatingTheme.primaryPink,
          ),
          const Expanded(
            child: Text('Billing address is the same as shipping address'),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveAddressOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _checkoutData.saveAddress,
            onChanged:
                (value) =>
                    setState(() => _checkoutData.saveAddress = value ?? false),
            activeColor: DatingTheme.primaryPink,
          ),
          const Expanded(child: Text('Save this address for future orders')),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 50,
              height: 50,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalOrderSummary() {
    final subtotal = _calculateSubtotal();
    final shipping = _calculateShipping();
    final tax = _calculateTax(subtotal);
    final total = subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.primaryPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DatingTheme.primaryPink.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(FeatherIcons.dollarSign, color: DatingTheme.primaryPink),
              const SizedBox(width: 8),
              const Text(
                'Order Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DatingTheme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', subtotal),
          _buildSummaryRow('Shipping', shipping),
          _buildSummaryRow('Tax (HST)', tax),
          const Divider(),
          _buildSummaryRow('Total', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _checkoutData.agreeToTerms,
                onChanged:
                    (value) => setState(
                      () => _checkoutData.agreeToTerms = value ?? false,
                    ),
                activeColor: DatingTheme.primaryPink,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'I agree to the Terms and Conditions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _showTermsDialog,
                      child: Text(
                        'Read Terms and Conditions',
                        style: TextStyle(
                          color: DatingTheme.primaryPink,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _checkoutData.subscribeToNewsletter,
                onChanged:
                    (value) => setState(
                      () =>
                          _checkoutData.subscribeToNewsletter = value ?? false,
                    ),
                activeColor: DatingTheme.primaryPink,
              ),
              const Expanded(
                child: Text(
                  'Subscribe to our newsletter for updates and exclusive offers',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _updateProgress();
      } else {
        _placeOrder();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Shipping address
        return _checkoutData.firstName?.isNotEmpty == true &&
            _checkoutData.lastName?.isNotEmpty == true &&
            _checkoutData.email?.isNotEmpty == true &&
            _checkoutData.streetAddress?.isNotEmpty == true &&
            _checkoutData.city?.isNotEmpty == true &&
            _checkoutData.province?.isNotEmpty == true &&
            _checkoutData.postalCode?.isNotEmpty == true;

      case 1: // Shipping method
        return _checkoutData.shippingMethod?.isNotEmpty == true;

      case 2: // Payment
        if (_checkoutData.paymentMethod == 'card') {
          return _checkoutData.cardNumber?.isNotEmpty == true &&
              _checkoutData.expiryDate?.isNotEmpty == true &&
              _checkoutData.cvv?.isNotEmpty == true &&
              _checkoutData.cardholderName?.isNotEmpty == true;
        }
        return _checkoutData.paymentMethod?.isNotEmpty == true;

      case 3: // Review
        return _checkoutData.agreeToTerms;

      default:
        return true;
    }
  }

  Future<void> _placeOrder() async {
    if (!_checkoutData.agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate order processing
      await Future.delayed(const Duration(seconds: 3));

      final orderData = {
        'order_id': 'LB${DateTime.now().millisecondsSinceEpoch}',
        'items':
            widget.cartItems
                .map(
                  (item) => {
                    'product_id': item.product.id,
                    'product_name': item.product.name,
                    'quantity': item.quantity,
                    'price': item.price,
                  },
                )
                .toList(),
        'shipping_address': {
          'name': '${_checkoutData.firstName} ${_checkoutData.lastName}',
          'street': _checkoutData.streetAddress,
          'apartment': _checkoutData.apartment,
          'city': _checkoutData.city,
          'province': _checkoutData.province,
          'postal_code': _checkoutData.postalCode,
          'country': 'Canada',
          'phone': _checkoutData.phone,
        },
        'shipping_method': _checkoutData.shippingMethod,
        'payment_method': _checkoutData.paymentMethod,
        'totals': {
          'subtotal': _calculateSubtotal(),
          'shipping': _calculateShipping(),
          'tax': _calculateTax(_calculateSubtotal()),
          'total':
              _calculateSubtotal() +
              _calculateShipping() +
              _calculateTax(_calculateSubtotal()),
        },
        'created_at': DateTime.now().toIso8601String(),
      };

      widget.onOrderComplete(orderData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // Helper methods
  double _calculateSubtotal() {
    return widget.cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  double _calculateShipping() {
    if (_checkoutData.shippingMethod == 'free') return 0.0;
    if (_checkoutData.shippingMethod == 'express') return 19.99;
    if (_checkoutData.shippingMethod == 'overnight') return 39.99;
    return 9.99; // standard shipping
  }

  double _calculateTax(double subtotal) {
    return subtotal * 0.13; // 13% HST for Ontario
  }

  String _getPaymentMethodDisplayName(String? method) {
    switch (method) {
      case 'card':
        return 'Credit Card';
      case 'paypal':
        return 'PayPal';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      default:
        return 'Not selected';
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Need Help?'),
            content: const Text(
              'If you need assistance with your order, please contact our customer support team:\n\n'
              '📧 support@lovebirds.ca\n'
              '📞 1-800-LOVEBIRDS\n\n'
              'We\'re here to help 24/7!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Terms and Conditions'),
            content: const SingleChildScrollView(
              child: Text(
                'By placing this order, you agree to our terms and conditions:\n\n'
                '1. All sales are final unless items are defective\n'
                '2. Returns accepted within 30 days of delivery\n'
                '3. Customer is responsible for return shipping costs\n'
                '4. Refunds processed within 5-7 business days\n'
                '5. We reserve the right to cancel orders\n\n'
                'For full terms and conditions, visit our website.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}

// Checkout data model
class CheckoutData {
  // User info
  bool isLoggedIn = false;

  // Shipping address
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? streetAddress;
  String? apartment;
  String? city;
  String? province;
  String? postalCode;

  // Billing address
  bool billingAddressSameAsShipping = true;
  bool saveAddress = false;

  // Shipping
  String? shippingMethod;
  String? deliveryInstructions;

  // Payment
  String? paymentMethod;
  String? cardNumber;
  String? expiryDate;
  String? cvv;
  String? cardholderName;

  // Confirmation
  bool agreeToTerms = false;
  bool subscribeToNewsletter = false;
}
