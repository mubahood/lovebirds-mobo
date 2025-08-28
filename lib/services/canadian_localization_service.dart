/// Canadian Market Localization Service
/// Handles Canadian-specific features: currency, shipping, taxes, payments
library canadian_localization_service;

import 'dart:math';

/// Canadian provincial tax data and calculations
class CanadianTaxService {
  static CanadianTaxService? _instance;
  static CanadianTaxService get instance =>
      _instance ??= CanadianTaxService._();
  CanadianTaxService._();

  /// Canadian provinces and territories with their tax rates
  static const Map<String, ProvinceData> provinces = {
    'AB': ProvinceData('Alberta', 0.05, 0.00, 0.05, 'GST'),
    'BC': ProvinceData('British Columbia', 0.05, 0.07, 0.12, 'GST + PST'),
    'MB': ProvinceData('Manitoba', 0.05, 0.07, 0.12, 'GST + PST'),
    'NB': ProvinceData('New Brunswick', 0.15, 0.00, 0.15, 'HST'),
    'NL': ProvinceData('Newfoundland and Labrador', 0.15, 0.00, 0.15, 'HST'),
    'NT': ProvinceData('Northwest Territories', 0.05, 0.00, 0.05, 'GST'),
    'NS': ProvinceData('Nova Scotia', 0.15, 0.00, 0.15, 'HST'),
    'NU': ProvinceData('Nunavut', 0.05, 0.00, 0.05, 'GST'),
    'ON': ProvinceData('Ontario', 0.13, 0.00, 0.13, 'HST'),
    'PE': ProvinceData('Prince Edward Island', 0.15, 0.00, 0.15, 'HST'),
    'QC': ProvinceData('Quebec', 0.05, 0.09975, 0.14975, 'GST + QST'),
    'SK': ProvinceData('Saskatchewan', 0.05, 0.06, 0.11, 'GST + PST'),
    'YT': ProvinceData('Yukon', 0.05, 0.00, 0.05, 'GST'),
  };

  /// Calculate taxes for a given amount and province
  TaxCalculation calculateTax(double amount, String provinceCode) {
    final province = provinces[provinceCode.toUpperCase()];
    if (province == null) {
      throw ArgumentError('Invalid province code: $provinceCode');
    }

    final gst = amount * province.gstRate;
    final pst = amount * province.pstRate;
    final total = gst + pst;

    return TaxCalculation(
      subtotal: amount,
      gstAmount: gst,
      pstAmount: pst,
      totalTax: total,
      totalWithTax: amount + total,
      province: province,
    );
  }

  /// Get formatted tax breakdown
  String getTaxBreakdown(double amount, String provinceCode) {
    final calculation = calculateTax(amount, provinceCode);
    final province = calculation.province;

    if (province.pstRate > 0) {
      return '''
Subtotal: \$${_formatMoney(calculation.subtotal)}
GST (${(province.gstRate * 100).toStringAsFixed(1)}%): \$${_formatMoney(calculation.gstAmount)}
${province.taxType.contains('QST') ? 'QST' : 'PST'} (${(province.pstRate * 100).toStringAsFixed(2)}%): \$${_formatMoney(calculation.pstAmount)}
Total: \$${_formatMoney(calculation.totalWithTax)}''';
    } else {
      return '''
Subtotal: \$${_formatMoney(calculation.subtotal)}
${province.taxType} (${(province.totalRate * 100).toStringAsFixed(1)}%): \$${_formatMoney(calculation.totalTax)}
Total: \$${_formatMoney(calculation.totalWithTax)}''';
    }
  }

  String _formatMoney(double amount) {
    return amount.toStringAsFixed(2);
  }
}

/// Canadian shipping service with realistic rates and zones
class CanadianShippingService {
  static CanadianShippingService? _instance;
  static CanadianShippingService get instance =>
      _instance ??= CanadianShippingService._();
  CanadianShippingService._();

  /// Shipping zones based on distance and region
  static const Map<String, ShippingZone> shippingZones = {
    'local': ShippingZone('Local Delivery', 5.99, 12.99, 1, 3, [
      'Same city delivery',
    ]),
    'regional': ShippingZone('Regional', 9.99, 19.99, 2, 5, [
      'Within province',
    ]),
    'national': ShippingZone('Canada-wide', 15.99, 35.99, 3, 7, [
      'Anywhere in Canada',
    ]),
    'express': ShippingZone('Express', 25.99, 49.99, 1, 2, [
      'Next day delivery',
      'Signature required',
    ]),
    'remote': ShippingZone('Remote Areas', 29.99, 65.99, 5, 14, [
      'Northern territories',
      'Remote locations',
    ]),
  };

  /// Calculate shipping cost based on location and package details
  ShippingCalculation calculateShipping({
    required String fromProvince,
    required String toProvince,
    required double weight,
    required double totalValue,
    bool expressRequested = false,
  }) {
    // Determine shipping zone
    String zoneKey;
    if (expressRequested) {
      zoneKey = 'express';
    } else if (_isRemoteProvince(toProvince)) {
      zoneKey = 'remote';
    } else if (fromProvince == toProvince) {
      zoneKey = 'local';
    } else if (_isAdjacentProvince(fromProvince, toProvince)) {
      zoneKey = 'regional';
    } else {
      zoneKey = 'national';
    }

    final zone = shippingZones[zoneKey]!;

    // Calculate base cost considering weight
    double baseCost = weight <= 2.0 ? zone.baseRate : zone.heavyRate;

    // Add weight surcharge for heavy items
    if (weight > 5.0) {
      baseCost += (weight - 5.0) * 3.99;
    }

    // Insurance for valuable items
    double insurance = 0.0;
    if (totalValue > 100.0) {
      insurance = totalValue * 0.01; // 1% insurance
    }

    return ShippingCalculation(
      zone: zone,
      baseCost: baseCost,
      insurance: insurance,
      totalCost: baseCost + insurance,
      estimatedDays: _getEstimatedDays(zone, toProvince),
    );
  }

  bool _isRemoteProvince(String province) {
    return ['NT', 'NU', 'YT'].contains(province.toUpperCase());
  }

  bool _isAdjacentProvince(String from, String to) {
    // Simplified adjacency logic - in real app this would be more comprehensive
    final adjacencyMap = {
      'ON': ['QC', 'MB'],
      'QC': ['ON', 'NB', 'NL'],
      'BC': ['AB', 'YT'],
      'AB': ['BC', 'SK', 'NT'],
      'SK': ['AB', 'MB'],
      'MB': ['SK', 'ON'],
      // Add more as needed
    };

    return adjacencyMap[from.toUpperCase()]?.contains(to.toUpperCase()) ??
        false;
  }

  String _getEstimatedDays(ShippingZone zone, String toProvince) {
    if (_isRemoteProvince(toProvince)) {
      return '${zone.minDays + 2}-${zone.maxDays + 3} business days';
    }
    return '${zone.minDays}-${zone.maxDays} business days';
  }
}

/// Canadian payment methods service
class CanadianPaymentService {
  static CanadianPaymentService? _instance;
  static CanadianPaymentService get instance =>
      _instance ??= CanadianPaymentService._();
  CanadianPaymentService._();

  /// Available Canadian payment methods
  static const List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      'interac_debit',
      'Interac Debit',
      'assets/icons/interac_debit.png',
      true,
      0.0,
      'Direct debit from your Canadian bank account',
    ),
    PaymentMethod(
      'credit_card',
      'Credit Card',
      'assets/icons/credit_cards.png',
      true,
      2.9,
      'Visa, Mastercard, American Express',
    ),
    PaymentMethod(
      'paypal_ca',
      'PayPal Canada',
      'assets/icons/paypal.png',
      true,
      2.9,
      'Pay with your PayPal account',
    ),
    PaymentMethod(
      'apple_pay',
      'Apple Pay',
      'assets/icons/apple_pay.png',
      true,
      2.9,
      'Quick and secure payment with Touch ID or Face ID',
    ),
    PaymentMethod(
      'google_pay',
      'Google Pay',
      'assets/icons/google_pay.png',
      true,
      2.9,
      'Pay with your Google account',
    ),
    PaymentMethod(
      'interac_online',
      'Interac Online',
      'assets/icons/interac_online.png',
      true,
      1.5,
      'Pay directly from your bank account online',
    ),
    PaymentMethod(
      'canadian_banks',
      'Direct Bank Transfer',
      'assets/icons/bank_transfer.png',
      false,
      0.0,
      'RBC, TD, Scotiabank, BMO, CIBC, and more',
    ),
  ];

  /// Process payment with Canadian-specific validation
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    try {
      // Validate Canadian postal code
      if (!_isValidCanadianPostalCode(request.billingAddress.postalCode)) {
        return PaymentResult(
          success: false,
          error: 'Invalid Canadian postal code format',
          transactionId: '',
        );
      }

      // Mock payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Simulate random success/failure for demo
      final random = Random();
      final success = random.nextDouble() > 0.1; // 90% success rate

      if (success) {
        return PaymentResult(
          success: true,
          transactionId: _generateTransactionId(),
          message: 'Payment processed successfully',
        );
      } else {
        return PaymentResult(
          success: false,
          error: 'Payment declined. Please try another payment method.',
          transactionId: '',
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        error: 'Payment processing error: ${e.toString()}',
        transactionId: '',
      );
    }
  }

  bool _isValidCanadianPostalCode(String postalCode) {
    // Canadian postal code format: A1A 1A1
    final regex = RegExp(r'^[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]\d$');
    return regex.hasMatch(postalCode);
  }

  String _generateTransactionId() {
    final random = Random();
    return 'CA${DateTime.now().millisecondsSinceEpoch}${random.nextInt(9999).toString().padLeft(4, '0')}';
  }
}

/// Data classes for Canadian localization

class ProvinceData {
  final String name;
  final double gstRate;
  final double pstRate;
  final double totalRate;
  final String taxType;

  const ProvinceData(
    this.name,
    this.gstRate,
    this.pstRate,
    this.totalRate,
    this.taxType,
  );
}

class TaxCalculation {
  final double subtotal;
  final double gstAmount;
  final double pstAmount;
  final double totalTax;
  final double totalWithTax;
  final ProvinceData province;

  TaxCalculation({
    required this.subtotal,
    required this.gstAmount,
    required this.pstAmount,
    required this.totalTax,
    required this.totalWithTax,
    required this.province,
  });
}

class ShippingZone {
  final String name;
  final double baseRate;
  final double heavyRate;
  final int minDays;
  final int maxDays;
  final List<String> features;

  const ShippingZone(
    this.name,
    this.baseRate,
    this.heavyRate,
    this.minDays,
    this.maxDays,
    this.features,
  );
}

class ShippingCalculation {
  final ShippingZone zone;
  final double baseCost;
  final double insurance;
  final double totalCost;
  final String estimatedDays;

  ShippingCalculation({
    required this.zone,
    required this.baseCost,
    required this.insurance,
    required this.totalCost,
    required this.estimatedDays,
  });
}

class PaymentMethod {
  final String id;
  final String name;
  final String iconPath;
  final bool isInstant;
  final double feePercentage;
  final String description;

  const PaymentMethod(
    this.id,
    this.name,
    this.iconPath,
    this.isInstant,
    this.feePercentage,
    this.description,
  );
}

class PaymentRequest {
  final String paymentMethodId;
  final double amount;
  final String currency;
  final CanadianAddress billingAddress;
  final Map<String, dynamic> metadata;

  PaymentRequest({
    required this.paymentMethodId,
    required this.amount,
    required this.currency,
    required this.billingAddress,
    this.metadata = const {},
  });
}

class CanadianAddress {
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final String country;

  CanadianAddress({
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
    this.country = 'Canada',
  });
}

class PaymentResult {
  final bool success;
  final String transactionId;
  final String? message;
  final String? error;

  PaymentResult({
    required this.success,
    required this.transactionId,
    this.message,
    this.error,
  });
}
