import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../../../../controllers/MainController.dart';
import '../../../../../models/LoggedInUserModel.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/CartItem.dart';

class NewCheckoutScreen extends StatefulWidget {
  final List<CartItem>? cartItems;

  const NewCheckoutScreen({Key? key, this.cartItems}) : super(key: key);

  @override
  _NewCheckoutScreenState createState() => _NewCheckoutScreenState();
}

class _NewCheckoutScreenState extends State<NewCheckoutScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;

  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _isProcessing = false;

  // Controllers for form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // Form keys
  final _shippingFormKey = GlobalKey<FormState>();
  final _paymentFormKey = GlobalKey<FormState>();

  // Data
  String _selectedShippingMethod = 'standard';
  String _selectedPaymentMethod = 'card';

  LoggedInUserModel item = LoggedInUserModel();
  MainController mainController = MainController();
  List<CartItem> checkoutItems = [];

  final List<Map<String, dynamic>> _shippingOptions = [
    {
      'id': 'standard',
      'name': 'Standard Shipping',
      'description': '5-7 business days',
      'price': 0.00,
      'icon': FeatherIcons.truck,
    },
    {
      'id': 'express',
      'name': 'Express Shipping',
      'description': '2-3 business days',
      'price': 15.99,
      'icon': FeatherIcons.zap,
    },
    {
      'id': 'overnight',
      'name': 'Overnight Delivery',
      'description': 'Next business day',
      'price': 29.99,
      'icon': FeatherIcons.clock,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _updateProgress();
    _initializeData();
  }

  void _initializeData() async {
    item = await LoggedInUserModel.getLoggedInUser();
    await mainController.getCartItems();

    // Cast the cartItems properly
    checkoutItems =
        widget.cartItems ??
        (mainController.cartItems is List<CartItem>
            ? mainController.cartItems as List<CartItem>
            : <CartItem>[]);

    if (item.id > 0) {
      _firstNameController.text = item.name;
      _lastNameController.text = item.name;
      _emailController.text = item.email;
      _phoneController.text = item.phone_number;
      _addressController.text = item.address;
    }

    setState(() {});
  }

  void _updateProgress() {
    final progress = (_currentStep + 1) / _totalSteps;
    _progressController.animateTo(progress);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CustomTheme
              .background, // Changed from CustomTheme.primary to match app
      appBar: AppBar(
        backgroundColor:
            CustomTheme.background, // Changed to match app background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: CustomTheme.background, // Changed to match app background
            child: Row(
              children: List.generate(_totalSteps, (index) {
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: index < _totalSteps - 1 ? 8 : 0,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isCompleted || isCurrent
                              ? CustomTheme
                                  .primary // Red progress bar
                              : CustomTheme.color4, // Grey for incomplete
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    CustomTheme.card, // Dark card background instead of white
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                  _updateProgress();
                },
                children: [
                  _buildShippingStep(),
                  _buildShippingMethodStep(),
                  _buildPaymentStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
          ),
          // Bottom navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildShippingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _shippingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text on dark background
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      labelStyle: TextStyle(color: CustomTheme.color2),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.primary),
                      ),
                      filled: true,
                      fillColor: CustomTheme.cardDark,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      labelStyle: TextStyle(color: CustomTheme.color2),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.primary),
                      ),
                      filled: true,
                      fillColor: CustomTheme.cardDark,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: CustomTheme.color2),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
                filled: true,
                fillColor: CustomTheme.cardDark,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your email';
                }
                if (!value!.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: CustomTheme.color2),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
                filled: true,
                fillColor: CustomTheme.cardDark,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Address',
                labelStyle: TextStyle(color: CustomTheme.color2),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
                filled: true,
                fillColor: CustomTheme.cardDark,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'City',
                      labelStyle: TextStyle(color: CustomTheme.color2),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.primary),
                      ),
                      filled: true,
                      fillColor: CustomTheme.cardDark,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _provinceController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Province',
                      labelStyle: TextStyle(color: CustomTheme.color2),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.primary),
                      ),
                      filled: true,
                      fillColor: CustomTheme.cardDark,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your province';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _postalCodeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Postal Code',
                labelStyle: TextStyle(color: CustomTheme.color2),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
                filled: true,
                fillColor: CustomTheme.cardDark,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your postal code';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingMethodStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Method',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text on dark background
            ),
          ),
          const SizedBox(height: 20),
          ..._shippingOptions.map((option) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: CustomTheme.cardDark, // Dark card background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _selectedShippingMethod == option['id']
                          ? CustomTheme.primary
                          : CustomTheme.color4,
                  width: 2,
                ),
              ),
              child: RadioListTile<String>(
                value: option['id'],
                groupValue: _selectedShippingMethod,
                activeColor: CustomTheme.primary, // Red radio button
                onChanged: (value) {
                  setState(() {
                    _selectedShippingMethod = value!;
                  });
                },
                title: Row(
                  children: [
                    Icon(option['icon'], color: CustomTheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // White text
                            ),
                          ),
                          Text(
                            option['description'],
                            style: TextStyle(
                              color: CustomTheme.color2, // Light grey text
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      option['price'] == 0.0
                          ? 'FREE'
                          : '\$${option['price'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CustomTheme.accent, // Yellow accent color
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _paymentFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text on dark background
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _cardNumberController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Card Number',
                labelStyle: TextStyle(color: CustomTheme.color2),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
                filled: true,
                fillColor: CustomTheme.cardDark,
                prefixIcon: Icon(
                  FeatherIcons.creditCard,
                  color: CustomTheme.color2,
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'MM/YY',
                      labelStyle: TextStyle(color: CustomTheme.color2),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.primary),
                      ),
                      filled: true,
                      fillColor: CustomTheme.cardDark,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter expiry date';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      labelStyle: TextStyle(color: CustomTheme.color2),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.color4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomTheme.primary),
                      ),
                      filled: true,
                      fillColor: CustomTheme.cardDark,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter CVV';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardHolderController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                labelStyle: TextStyle(color: CustomTheme.color2),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.color4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
                filled: true,
                fillColor: CustomTheme.cardDark,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter cardholder name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    final subtotal = _calculateSubtotal();
    final shipping = _calculateShippingCost();
    final taxes = _calculateTaxes(subtotal);
    final total = subtotal + shipping + taxes;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text on dark background
            ),
          ),
          const SizedBox(height: 20),
          // Order items
          ...checkoutItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomTheme.cardDark, // Dark card background
                border: Border.all(color: CustomTheme.color4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: CustomTheme.color4, // Dark placeholder color
                      child:
                          item.product_feature_photo.isNotEmpty
                              ? Image.network(
                                item.product_feature_photo,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      FeatherIcons.image,
                                      color: CustomTheme.color2,
                                    ),
                              )
                              : Icon(
                                FeatherIcons.image,
                                color: CustomTheme.color2,
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product_name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text
                          ),
                        ),
                        Text(
                          'Qty: ${item.product_quantity}',
                          style: TextStyle(
                            color: CustomTheme.color2, // Light grey text
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${(double.tryParse(item.product_price_1) ?? 0.0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CustomTheme.accent, // Yellow accent for price
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          // Pricing breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CustomTheme.cardDark, // Dark card background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CustomTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '\$${subtotal.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Shipping:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '\$${shipping.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HST (13%):',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '\$${taxes.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Divider(color: CustomTheme.color4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: CustomTheme.accent, // Yellow accent for total
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

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.background, // Dark background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: CustomTheme.color4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
                        _currentStep == _totalSteps - 1
                            ? 'Place Order'
                            : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      if (_shippingFormKey.currentState?.validate() ?? false) {
        _nextStep();
      }
    } else if (_currentStep == 1) {
      _nextStep();
    } else if (_currentStep == 2) {
      if (_paymentFormKey.currentState?.validate() ?? false) {
        _nextStep();
      }
    } else if (_currentStep == 3) {
      _placeOrder();
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _placeOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Prepare order data
      final orderData = {
        'items': jsonEncode(
          checkoutItems
              .map(
                (item) => {
                  'product_id': item.product_id,
                  'quantity': int.tryParse(item.product_quantity) ?? 1,
                  'price': double.tryParse(item.product_price_1) ?? 0.0,
                  'name': item.product_name,
                },
              )
              .toList(),
        ),
        'delivery_info': jsonEncode({
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'province': _provinceController.text,
          'postal_code': _postalCodeController.text,
          'shipping_method': _selectedShippingMethod,
        }),
        'payment_info': jsonEncode({
          'method': _selectedPaymentMethod,
          'card_holder_name': _cardHolderController.text,
          'card_number': _cardNumberController.text,
          'expiry': _expiryController.text,
          'cvv': _cvvController.text,
        }),
        'total_amount':
            _calculateSubtotal() +
            _calculateShippingCost() +
            _calculateTaxes(_calculateSubtotal()),
        'user_id': item.id,
      };

      // Submit order
      final resp = await Utils.http_post('cart/submit-order', orderData);

      setState(() {
        _isProcessing = false;
      });

      if (resp['code'] == 1) {
        // Success
        if (mounted) {
          Utils.toast('Order placed successfully!', color: Colors.green);
          Navigator.of(context).pop();
        }
      } else {
        // Error
        if (mounted) {
          Utils.toast(
            resp['message'] ?? 'Failed to place order',
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        Utils.toast(
          'Failed to place order. Please try again.',
          color: Colors.red,
        );
      }
    }
  }

  double _calculateSubtotal() {
    return checkoutItems.fold(
      0.0,
      (sum, item) =>
          sum +
          ((double.tryParse(item.product_price_1) ?? 0.0) *
              (int.tryParse(item.product_quantity) ?? 1)),
    );
  }

  double _calculateShippingCost() {
    final selectedOption = _shippingOptions.firstWhere(
      (option) => option['id'] == _selectedShippingMethod,
      orElse: () => _shippingOptions.first,
    );

    return selectedOption['price'].toDouble();
  }

  double _calculateTaxes(double subtotal) {
    // 13% HST for Canada
    return subtotal * 0.13;
  }
}
