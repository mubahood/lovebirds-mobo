import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../controllers/MainController.dart';
import '../../../../../utils/AppConfig.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/CartItem.dart';
import '../orders/MyOrdersScreen.dart';

class CheckoutScreenHambren extends StatefulWidget {
  final List<CartItem>? cartItems;

  const CheckoutScreenHambren({Key? key, this.cartItems}) : super(key: key);

  @override
  _CheckoutScreenHambrenState createState() => _CheckoutScreenHambrenState();
}

class _CheckoutScreenHambrenState extends State<CheckoutScreenHambren> {
  bool _isProcessing = false;
  final mainController = Get.find<MainController>();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _selectedShippingMethod = 'standard';

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    if (mainController.userModel.id > 0) {
      final user = mainController.userModel;
      _firstNameController.text = user.first_name;
      _lastNameController.text = user.last_name;
      _emailController.text = user.email;
      _phoneController.text = user.phone_number;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(),
                const SizedBox(height: 24),
                _buildShippingForm(),
                const SizedBox(height: 24),
                _buildShippingOptions(),
                const SizedBox(height: 24),
                _buildTotalSummary(),
                const SizedBox(height: 100), // Space for button
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: CustomTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(FeatherIcons.arrowLeft, color: CustomTheme.accent),
        onPressed: () => Navigator.pop(context),
      ),
      title: FxText.titleLarge(
        "${AppConfig.MARKETPLACE_NAME} Checkout",
        color: CustomTheme.color,
        fontWeight: 700,
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
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
          FxText.titleMedium(
            'Order Summary',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
          const SizedBox(height: 16),
          ...mainController.cartItems.map((item) => _buildOrderItem(item)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(Utils.img(item.product_feature_photo)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  item.product_name,
                  color: CustomTheme.color,
                  fontWeight: 500,
                  maxLines: 2,
                ),
                FxText.bodySmall(
                  'Qty: ${item.product_quantity}',
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          FxText.bodyMedium(
            '${AppConfig.CURRENCY} \$${(double.parse(item.product_price_1.replaceAll(',', '')) * int.parse(item.product_quantity)).toStringAsFixed(2)}',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
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
          FxText.titleMedium(
            'Shipping Address',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  validator:
                      (value) => value?.isEmpty == true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  validator:
                      (value) => value?.isEmpty == true ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Street Address',
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  validator:
                      (value) => value?.isEmpty == true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _provinceController,
                  label: 'Province',
                  validator:
                      (value) => value?.isEmpty == true ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _postalCodeController,
            label: 'Postal Code',
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: CustomTheme.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: CustomTheme.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: CustomTheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildShippingOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
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
          FxText.titleMedium(
            'Shipping Method',
            color: CustomTheme.color,
            fontWeight: 600,
          ),
          const SizedBox(height: 16),
          _buildShippingOption(
            'standard',
            'Standard Shipping',
            '5-7 business days',
            9.99,
          ),
          const SizedBox(height: 12),
          _buildShippingOption(
            'express',
            'Express Shipping',
            '2-3 business days',
            19.99,
          ),
          const SizedBox(height: 12),
          _buildShippingOption(
            'overnight',
            'Overnight Shipping',
            'Next business day',
            39.99,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption(
    String value,
    String title,
    String description,
    double price,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _selectedShippingMethod = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              _selectedShippingMethod == value
                  ? CustomTheme.primary.withValues(alpha: 0.1)
                  : CustomTheme.cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                _selectedShippingMethod == value
                    ? CustomTheme.primary
                    : Colors.grey[600]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _selectedShippingMethod == value
                  ? FeatherIcons.checkCircle
                  : FeatherIcons.circle,
              color:
                  _selectedShippingMethod == value
                      ? CustomTheme.primary
                      : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.bodyMedium(
                    title,
                    color: CustomTheme.color,
                    fontWeight: 500,
                  ),
                  FxText.bodySmall(description, color: Colors.grey[600]),
                ],
              ),
            ),
            FxText.bodyMedium(
              '${AppConfig.CURRENCY} \$${price.toStringAsFixed(2)}',
              color: CustomTheme.color,
              fontWeight: 600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummary() {
    final subtotal = double.parse(mainController.tot.toString());
    final shipping = _getShippingCost();
    final taxes = subtotal * 0.13; // 13% HST for Canada
    final total = subtotal + shipping + taxes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
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
        children: [
          _buildSummaryRow('Subtotal', subtotal),
          _buildSummaryRow('Shipping', shipping),
          _buildSummaryRow('Taxes (HST)', taxes),
          const Divider(height: 24),
          _buildSummaryRow('Total', total, isTotal: true),
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
          FxText.bodyMedium(
            label,
            color: CustomTheme.color,
            fontWeight: isTotal ? 700 : 400,
          ),
          FxText.bodyMedium(
            '${AppConfig.CURRENCY} \$${amount.toStringAsFixed(2)}',
            color: isTotal ? CustomTheme.primary : CustomTheme.color,
            fontWeight: isTotal ? 700 : 600,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _submitOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                _isProcessing
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        FxText.titleMedium('Processing...', fontWeight: 700),
                      ],
                    )
                    : FxText.titleMedium('Submit Order', fontWeight: 700),
          ),
        ),
      ),
    );
  }

  double _getShippingCost() {
    switch (_selectedShippingMethod) {
      case 'express':
        return 19.99;
      case 'overnight':
        return 39.99;
      default:
        return 9.99;
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      Utils.toast('Please fill in all required fields');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Prepare order data
      final orderData = {
        'items':
            mainController.cartItems
                .map(
                  (item) => {
                    'product_id': item.product!.id,
                    'quantity': item.quantity,
                    'price': item.product!.price,
                    'name': item.product!.name,
                  },
                )
                .toList(),
        'shipping_address': {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'province': _provinceController.text.trim(),
          'postal_code': _postalCodeController.text.trim(),
        },
        'shipping_method': _selectedShippingMethod,
        'subtotal': double.parse(mainController.tot.toString()),
        'shipping_cost': _getShippingCost(),
        'tax_amount': double.parse(mainController.tot.toString()) * 0.13,
        'total_amount':
            double.parse(mainController.tot.toString()) +
            _getShippingCost() +
            (double.parse(mainController.tot.toString()) * 0.13),
      };

      // Submit order to backend
      final response = await Utils.http_post('cart/submit-order', orderData);

      if (response != null && response['success'] == true) {
        final order = response['data']['order'];
        final paymentUrl = order['stripe_payment_url'];

        // Clear cart
        mainController.cartItems.clear();
        mainController.update();

        // Show success message
        Utils.toast('Order submitted successfully!');

        // Redirect to Stripe payment
        if (paymentUrl != null) {
          final Uri paymentUri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(paymentUri)) {
            await launchUrl(paymentUri, mode: LaunchMode.externalApplication);

            // Navigate to My Orders screen after payment redirect
            await Future.delayed(const Duration(milliseconds: 500));
            Get.offAll(() => const MyOrdersScreen());
          } else {
            Utils.toast('Could not open payment page. Please try again.');
            // Navigate to orders screen even if payment fails
            Get.offAll(() => const MyOrdersScreen());
          }
        } else {
          // Navigate to orders screen to allow payment later
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offAll(() => const MyOrdersScreen());
        }
      } else {
        Utils.toast(response?['message'] ?? 'Failed to submit order');
      }
    } catch (e) {
      Utils.toast('Error submitting order: \$e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
