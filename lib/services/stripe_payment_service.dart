import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/payment_config.dart';

/// Enhanced Stripe Payment Service for Canadian market
/// Handles secure payment processing with multiple payment methods
class StripePaymentService {
  static String get _baseUrl => PaymentConfig.stripeBaseUrl;
  static String get _publishableKey =>
      PaymentConfig.getApiKeys()['publishable']!;
  static String get _secretKey => PaymentConfig.getApiKeys()['secret']!;

  // Canadian specific settings
  static const String _currency = 'cad';
  static double get _hstRate => PaymentConfig.hstRate;
  static const String _countryCode = 'CA';

  /// Initialize Stripe SDK
  static Future<void> initialize() async {
    try {
      // Initialize Stripe with publishable key
      if (kDebugMode) {
        print('🔧 Initializing Stripe Payment Service for Canadian market...');
      }
      // Stripe initialization would go here
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize Stripe: $e');
      }
      throw Exception('Failed to initialize payment service');
    }
  }

  /// Create a payment intent for the checkout process
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required Map<String, dynamic> metadata,
    String? customerId,
    String? paymentMethodId,
    bool enableTax = true,
  }) async {
    try {
      // Convert amount to cents (Stripe uses smallest currency unit)
      final int amountInCents = (amount * 100).round();

      final Map<String, dynamic> paymentData = {
        'amount': amountInCents.toString(),
        'currency': currency.toLowerCase(),
        'payment_method_types[]': 'card',
        'metadata[source]': 'lovebirds_shop',
        'metadata[platform]': 'mobile',
        'automatic_payment_methods[enabled]': 'true',
        'setup_future_usage': 'on_session', // For saving payment methods
      };

      // Add customer ID if provided
      if (customerId != null) {
        paymentData['customer'] = customerId;
      }

      // Add payment method if provided
      if (paymentMethodId != null) {
        paymentData['payment_method'] = paymentMethodId;
        paymentData['confirmation_method'] = 'manual';
        paymentData['confirm'] = 'true';
      }

      // Add metadata
      metadata.forEach((key, value) {
        paymentData['metadata[$key]'] = value.toString();
      });

      // Calculate and add tax if enabled
      if (enableTax && currency.toLowerCase() == 'cad') {
        final taxAmount = (amount * _hstRate * 100).round();
        paymentData['metadata[tax_amount]'] = taxAmount.toString();
        paymentData['metadata[tax_rate]'] =
            '${(_hstRate * 100).toStringAsFixed(1)}%';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: _encodeForm(paymentData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (kDebugMode) {
          print('✅ Payment intent created: ${responseData['id']}');
        }

        return {
          'success': true,
          'payment_intent': responseData,
          'client_secret': responseData['client_secret'],
        };
      } else {
        final error = json.decode(response.body);
        throw Exception('Stripe API Error: ${error['error']['message']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to create payment intent: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Confirm a payment intent
  static Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
    Map<String, String>? billingDetails,
  }) async {
    try {
      final Map<String, dynamic> confirmData = {
        'payment_method': paymentMethodId,
        'return_url':
            'https://your-app.com/return', // Replace with actual return URL
      };

      // Add billing details if provided
      if (billingDetails != null) {
        billingDetails.forEach((key, value) {
          confirmData['payment_method_data[billing_details][$key]'] = value;
        });
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents/$paymentIntentId/confirm'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: _encodeForm(confirmData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (kDebugMode) {
          print('✅ Payment confirmed: ${responseData['status']}');
        }

        return {
          'success': true,
          'payment_intent': responseData,
          'status': responseData['status'],
        };
      } else {
        final error = json.decode(response.body);
        throw Exception(
          'Payment confirmation failed: ${error['error']['message']}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to confirm payment: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Create a customer for saving payment methods
  static Future<Map<String, dynamic>> createCustomer({
    required String email,
    required String name,
    String? phone,
    Map<String, String>? address,
    Map<String, String>? metadata,
  }) async {
    try {
      final Map<String, dynamic> customerData = {
        'email': email,
        'name': name,
        'metadata[source]': 'lovebirds_shop',
      };

      if (phone != null) {
        customerData['phone'] = phone;
      }

      // Add address if provided
      if (address != null) {
        address.forEach((key, value) {
          customerData['address[$key]'] = value;
        });
      }

      // Add metadata if provided
      if (metadata != null) {
        metadata.forEach((key, value) {
          customerData['metadata[$key]'] = value;
        });
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: _encodeForm(customerData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (kDebugMode) {
          print('✅ Customer created: ${responseData['id']}');
        }

        return {
          'success': true,
          'customer': responseData,
          'customer_id': responseData['id'],
        };
      } else {
        final error = json.decode(response.body);
        throw Exception(
          'Customer creation failed: ${error['error']['message']}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to create customer: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Save a payment method to a customer
  static Future<Map<String, dynamic>> savePaymentMethod({
    required String paymentMethodId,
    required String customerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_methods/$paymentMethodId/attach'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'customer=$customerId',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (kDebugMode) {
          print('✅ Payment method saved to customer');
        }

        return {'success': true, 'payment_method': responseData};
      } else {
        final error = json.decode(response.body);
        throw Exception(
          'Failed to save payment method: ${error['error']['message']}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save payment method: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Process a refund
  static Future<Map<String, dynamic>> processRefund({
    required String paymentIntentId,
    double? amount,
    String? reason,
    Map<String, String>? metadata,
  }) async {
    try {
      final Map<String, dynamic> refundData = {
        'payment_intent': paymentIntentId,
      };

      if (amount != null) {
        refundData['amount'] = (amount * 100).round().toString();
      }

      if (reason != null) {
        refundData['reason'] = reason;
      }

      if (metadata != null) {
        metadata.forEach((key, value) {
          refundData['metadata[$key]'] = value;
        });
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/refunds'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: _encodeForm(refundData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (kDebugMode) {
          print('✅ Refund processed: ${responseData['id']}');
        }

        return {
          'success': true,
          'refund': responseData,
          'status': responseData['status'],
        };
      } else {
        final error = json.decode(response.body);
        throw Exception('Refund failed: ${error['error']['message']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to process refund: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Calculate total amount including taxes for Canadian market
  static Map<String, double> calculateCanadianTotals(double subtotal) {
    final double hstAmount = subtotal * _hstRate;
    final double total = subtotal + hstAmount;

    return {
      'subtotal': _roundToTwoDecimals(subtotal),
      'hst': _roundToTwoDecimals(hstAmount),
      'total': _roundToTwoDecimals(total),
    };
  }

  /// Validate Canadian postal code
  static bool validateCanadianPostalCode(String postalCode) {
    // Canadian postal code format: A1A 1A1
    final RegExp postalCodeRegex = RegExp(
      r'^[A-Za-z]\d[A-Za-z]\s?\d[A-Za-z]\d$',
    );
    return postalCodeRegex.hasMatch(postalCode.trim());
  }

  /// Format amount for display in CAD
  static String formatCAD(double amount) {
    return '\$${amount.toStringAsFixed(2)} CAD';
  }

  /// Helper method to encode form data
  static String _encodeForm(Map<String, dynamic> data) {
    return data.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}',
        )
        .join('&');
  }

  /// Helper method to round to two decimal places
  static double _roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  /// Get payment method types available in Canada
  static List<String> getAvailablePaymentMethods() {
    return [
      'card',
      'apple_pay',
      'google_pay',
      // Add more payment methods as needed
    ];
  }

  /// Validate credit card number using Luhn algorithm
  static bool validateCreditCard(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return false;
    }

    int sum = 0;
    bool alternate = false;

    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Get card type from card number
  static String getCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.startsWith('4')) {
      return 'visa';
    } else if (cleanNumber.startsWith(RegExp(r'5[1-5]')) ||
        cleanNumber.startsWith(RegExp(r'2[2-7]'))) {
      return 'mastercard';
    } else if (cleanNumber.startsWith(RegExp(r'3[47]'))) {
      return 'amex';
    } else if (cleanNumber.startsWith('6011') ||
        cleanNumber.startsWith('65') ||
        cleanNumber.startsWith(RegExp(r'64[4-9]'))) {
      return 'discover';
    }

    return 'unknown';
  }
}
