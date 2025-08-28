import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';

import '../../services/canadian_localization_service.dart';
import '../../utils/dating_theme.dart';

/// Canadian Checkout Widget with tax calculation and shipping options
class CanadianCheckoutWidget extends StatefulWidget {
  final List<CheckoutItem> items;
  final Function(CheckoutResult) onCheckoutComplete;

  const CanadianCheckoutWidget({
    Key? key,
    required this.items,
    required this.onCheckoutComplete,
  }) : super(key: key);

  @override
  _CanadianCheckoutWidgetState createState() => _CanadianCheckoutWidgetState();
}

class _CanadianCheckoutWidgetState extends State<CanadianCheckoutWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  String _selectedProvince = 'ON'; // Default to Ontario
  String _selectedShippingZone = 'local';
  String _selectedPaymentMethod = 'interac_debit';

  final _shippingFormKey = GlobalKey<FormState>();

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  bool _isProcessing = false;

  double get _subtotal =>
      widget.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  TaxCalculation? _taxCalculation;
  ShippingCalculation? _shippingCalculation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _calculateTotals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _calculateTotals() {
    setState(() {
      _taxCalculation = CanadianTaxService.instance.calculateTax(
        _subtotal,
        _selectedProvince,
      );

      // Calculate shipping (simplified - in real app this would consider actual addresses)
      final avgWeight = widget.items.fold(
        0.0,
        (sum, item) => sum + (item.weight * item.quantity),
      );
      _shippingCalculation = CanadianShippingService.instance.calculateShipping(
        fromProvince: 'ON', // Assume shipping from Ontario
        toProvince: _selectedProvince,
        weight: avgWeight,
        totalValue: _subtotal,
        expressRequested: _selectedShippingZone == 'express',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: DatingTheme.primaryPink,
        title: FxText.titleMedium(
          'Canadian Checkout',
          color: Colors.white,
          fontWeight: 600,
        ),
        leading: IconButton(
          icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: DatingTheme.primaryRose,
          tabs: const [
            Tab(icon: Icon(FeatherIcons.shoppingCart), text: 'Items'),
            Tab(icon: Icon(FeatherIcons.truck), text: 'Shipping'),
            Tab(icon: Icon(FeatherIcons.creditCard), text: 'Payment'),
            Tab(icon: Icon(FeatherIcons.checkCircle), text: 'Review'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemsTab(),
          _buildShippingTab(),
          _buildPaymentTab(),
          _buildReviewTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildItemsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _buildCartItem(item);
            },
          ),
        ),
        _buildSubtotalCard(),
      ],
    );
  }

  Widget _buildCartItem(CheckoutItem item) {
    return FxContainer.bordered(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadiusAll: 12,
      borderColor: Colors.white.withValues(alpha: 0.1),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  item.name,
                  color: Colors.white,
                  fontWeight: 600,
                ),
                const SizedBox(height: 4),
                FxText.bodySmall(
                  'Qty: ${item.quantity}',
                  color: Colors.white70,
                ),
                const SizedBox(height: 4),
                FxText.bodySmall(
                  'CAD \$${(item.price * item.quantity).toStringAsFixed(2)}',
                  color: DatingTheme.primaryPink,
                  fontWeight: 600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtotalCard() {
    return FxContainer.bordered(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      borderRadiusAll: 12,
      color: DatingTheme.cardBackground,
      borderColor: DatingTheme.primaryPink.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FxText.titleSmall('Subtotal', color: Colors.white, fontWeight: 600),
          FxText.titleSmall(
            'CAD \$${_subtotal.toStringAsFixed(2)}',
            color: DatingTheme.primaryPink,
            fontWeight: 600,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingTab() {
    return Form(
      key: _shippingFormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FxText.titleMedium(
            'Shipping Address',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 16),

          _buildProvinceSelector(),
          const SizedBox(height: 16),

          _buildTextField(
            'Street Address',
            _streetController,
            FeatherIcons.home,
          ),
          const SizedBox(height: 16),

          _buildTextField('City', _cityController, FeatherIcons.mapPin),
          const SizedBox(height: 16),

          _buildTextField(
            'Postal Code',
            _postalCodeController,
            FeatherIcons.mail,
            customValidator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter postal code';
              }
              if (!RegExp(
                r'^[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]\d$',
              ).hasMatch(value)) {
                return 'Invalid Canadian postal code format (e.g., K1A 0A6)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          _buildShippingOptions(),
        ],
      ),
    );
  }

  Widget _buildProvinceSelector() {
    return FxContainer.bordered(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadiusAll: 12,
      borderColor: Colors.white.withValues(alpha: 0.2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProvince,
          isExpanded: true,
          dropdownColor: DatingTheme.cardBackground,
          style: TextStyle(color: Colors.white),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedProvince = newValue;
                _calculateTotals();
              });
            }
          },
          items:
              CanadianTaxService.provinces.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: FxText.bodyMedium(
                    '${entry.value.name} (${entry.key})',
                    color: Colors.white,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? Function(String?)? customValidator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      cursorColor: DatingTheme.primaryPink,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DatingTheme.primaryPink),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DatingTheme.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DatingTheme.errorRed),
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
      validator:
          customValidator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
    );
  }

  Widget _buildShippingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.titleMedium(
          'Shipping Options',
          color: Colors.white,
          fontWeight: 600,
        ),
        const SizedBox(height: 12),

        ...CanadianShippingService.shippingZones.entries.map((entry) {
          final zone = entry.value;
          final isSelected = _selectedShippingZone == entry.key;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedShippingZone = entry.key;
                _calculateTotals();
              });
            },
            child: FxContainer.bordered(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              borderRadiusAll: 12,
              borderColor:
                  isSelected
                      ? DatingTheme.primaryPink
                      : Colors.white.withValues(alpha: 0.1),
              color:
                  isSelected
                      ? DatingTheme.primaryPink.withValues(alpha: 0.1)
                      : null,
              child: Row(
                children: [
                  Icon(
                    isSelected ? FeatherIcons.checkCircle : FeatherIcons.circle,
                    color:
                        isSelected ? DatingTheme.primaryPink : Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FxText.bodyMedium(
                          zone.name,
                          color: Colors.white,
                          fontWeight: 600,
                        ),
                        FxText.bodySmall(
                          '${zone.minDays}-${zone.maxDays} business days',
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  FxText.bodyMedium(
                    'CAD \$${zone.baseRate.toStringAsFixed(2)}',
                    color: DatingTheme.primaryPink,
                    fontWeight: 600,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPaymentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FxText.titleMedium(
          'Payment Method',
          color: Colors.white,
          fontWeight: 600,
        ),
        const SizedBox(height: 16),

        ...CanadianPaymentService.paymentMethods.map((method) {
          final isSelected = _selectedPaymentMethod == method.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPaymentMethod = method.id;
              });
            },
            child: FxContainer.bordered(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              borderRadiusAll: 12,
              borderColor:
                  isSelected
                      ? DatingTheme.primaryPink
                      : Colors.white.withValues(alpha: 0.1),
              color:
                  isSelected
                      ? DatingTheme.primaryPink.withValues(alpha: 0.1)
                      : null,
              child: Row(
                children: [
                  Icon(
                    isSelected ? FeatherIcons.checkCircle : FeatherIcons.circle,
                    color:
                        isSelected ? DatingTheme.primaryPink : Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FxText.bodyMedium(
                          method.name,
                          color: Colors.white,
                          fontWeight: 600,
                        ),
                        FxText.bodySmall(
                          method.description,
                          color: Colors.white70,
                        ),
                        if (method.feePercentage > 0)
                          FxText.bodySmall(
                            'Fee: ${method.feePercentage}%',
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ),
                  if (method.isInstant)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FxText.bodySmall(
                        'INSTANT',
                        color: Colors.green,
                        fontWeight: 600,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildReviewTab() {
    if (_taxCalculation == null || _shippingCalculation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final total =
        _taxCalculation!.totalWithTax + _shippingCalculation!.totalCost;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderSummary(),
        const SizedBox(height: 24),
        _buildTaxBreakdown(),
        const SizedBox(height: 24),
        _buildShippingSummary(),
        const SizedBox(height: 24),
        _buildTotalCard(total),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return FxContainer.bordered(
      padding: const EdgeInsets.all(16),
      borderRadiusAll: 12,
      borderColor: Colors.white.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(
            'Order Summary',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 12),
          ...widget.items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FxText.bodyMedium(
                          '${item.name} x${item.quantity}',
                          color: Colors.white70,
                        ),
                      ),
                      FxText.bodyMedium(
                        'CAD \$${(item.price * item.quantity).toStringAsFixed(2)}',
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTaxBreakdown() {
    return FxContainer.bordered(
      padding: const EdgeInsets.all(16),
      borderRadiusAll: 12,
      borderColor: Colors.white.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(
            'Tax Breakdown - ${_taxCalculation!.province.name}',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyMedium('Subtotal', color: Colors.white70),
              FxText.bodyMedium(
                'CAD \$${_taxCalculation!.subtotal.toStringAsFixed(2)}',
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyMedium('GST/HST', color: Colors.white70),
              FxText.bodyMedium(
                'CAD \$${_taxCalculation!.gstAmount.toStringAsFixed(2)}',
                color: Colors.white,
              ),
            ],
          ),
          if (_taxCalculation!.pstAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FxText.bodyMedium('PST/QST', color: Colors.white70),
                FxText.bodyMedium(
                  'CAD \$${_taxCalculation!.pstAmount.toStringAsFixed(2)}',
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShippingSummary() {
    return FxContainer.bordered(
      padding: const EdgeInsets.all(16),
      borderRadiusAll: 12,
      borderColor: Colors.white.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(
            'Shipping Details',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FxText.bodyMedium(
                _shippingCalculation!.zone.name,
                color: Colors.white70,
              ),
              FxText.bodyMedium(
                'CAD \$${_shippingCalculation!.totalCost.toStringAsFixed(2)}',
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          FxText.bodySmall(
            _shippingCalculation!.estimatedDays,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(double total) {
    return FxContainer.bordered(
      padding: const EdgeInsets.all(16),
      borderRadiusAll: 12,
      color: DatingTheme.primaryPink.withValues(alpha: 0.1),
      borderColor: DatingTheme.primaryPink,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FxText.titleLarge('Total', color: Colors.white, fontWeight: 700),
          FxText.titleLarge(
            'CAD \$${total.toStringAsFixed(2)}',
            color: DatingTheme.primaryPink,
            fontWeight: 700,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          if (_tabController.index > 0)
            Expanded(
              child: FxButton.outlined(
                onPressed: () {
                  _tabController.animateTo(_tabController.index - 1);
                },
                borderColor: DatingTheme.primaryPink,
                child: FxText.bodyMedium(
                  'Previous',
                  color: DatingTheme.primaryPink,
                  fontWeight: 600,
                ),
              ),
            ),
          if (_tabController.index > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FxButton(
              onPressed: _isProcessing ? null : _handleNextOrCheckout,
              backgroundColor: DatingTheme.primaryPink,
              child:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : FxText.bodyMedium(
                        _tabController.index == 3
                            ? 'Complete Purchase'
                            : 'Next',
                        color: Colors.white,
                        fontWeight: 600,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextOrCheckout() {
    if (_tabController.index == 3) {
      _processCheckout();
    } else if (_tabController.index == 1) {
      if (_shippingFormKey.currentState!.validate()) {
        _tabController.animateTo(_tabController.index + 1);
      }
    } else {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  void _processCheckout() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final billingAddress = CanadianAddress(
        street: _streetController.text,
        city: _cityController.text,
        province: _selectedProvince,
        postalCode: _postalCodeController.text,
      );

      final paymentRequest = PaymentRequest(
        paymentMethodId: _selectedPaymentMethod,
        amount: _taxCalculation!.totalWithTax + _shippingCalculation!.totalCost,
        currency: 'CAD',
        billingAddress: billingAddress,
      );

      final result = await CanadianPaymentService.instance.processPayment(
        paymentRequest,
      );

      widget.onCheckoutComplete(
        CheckoutResult(
          success: result.success,
          transactionId: result.transactionId,
          message: result.message,
          error: result.error,
          taxCalculation: _taxCalculation!,
          shippingCalculation: _shippingCalculation!,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

// Supporting data classes
class CheckoutItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final double weight;

  CheckoutItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.weight,
  });
}

class CheckoutResult {
  final bool success;
  final String transactionId;
  final String? message;
  final String? error;
  final TaxCalculation taxCalculation;
  final ShippingCalculation shippingCalculation;

  CheckoutResult({
    required this.success,
    required this.transactionId,
    this.message,
    this.error,
    required this.taxCalculation,
    required this.shippingCalculation,
  });
}
