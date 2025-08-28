/// Payment Configuration for Lovebirds Shop
/// Contains configuration constants and API key management for payment processing
///
/// IMPORTANT: Never commit real API keys to version control!
/// Use environment variables or secure key management in production.

class PaymentConfig {
  // =============================================
  // STRIPE CONFIGURATION
  // =============================================

  /// Stripe publishable key (safe to include in client code)
  /// Test key for development - replace with live key for production
  static const String stripePublishableKey =
      'pk_test_51234...'; // Replace with your actual test key

  /// Stripe API version
  static const String stripeApiVersion = '2023-10-16';

  /// Base URL for Stripe API
  static const String stripeBaseUrl = 'https://api.stripe.com/v1';

  // =============================================
  // CANADIAN MARKET SETTINGS
  // =============================================

  /// Default currency for Canadian market
  static const String defaultCurrency = 'cad';

  /// Canadian HST tax rate (13%)
  static const double hstRate = 0.13;

  /// Free shipping threshold in CAD
  static const double freeShippingThreshold = 50.0;

  /// Default shipping rates
  static const Map<String, Map<String, dynamic>> shippingRates = {
    'standard': {
      'name': 'Standard Shipping',
      'description': '5-7 business days',
      'rate': 9.99,
      'currency': 'cad',
    },
    'express': {
      'name': 'Express Shipping',
      'description': '2-3 business days',
      'rate': 19.99,
      'currency': 'cad',
    },
    'overnight': {
      'name': 'Overnight Shipping',
      'description': 'Next business day',
      'rate': 39.99,
      'currency': 'cad',
    },
  };

  // =============================================
  // PAYMENT METHOD SETTINGS
  // =============================================

  /// Supported payment methods
  static const List<String> supportedPaymentMethods = [
    'card',
    'apple_pay',
    'google_pay',
    'paypal',
  ];

  /// Card types accepted
  static const List<String> acceptedCardTypes = [
    'visa',
    'mastercard',
    'amex',
    'discover',
  ];

  /// Minimum payment amount in CAD cents (e.g., 50 cents)
  static const int minimumPaymentAmount = 50;

  /// Maximum payment amount in CAD cents (e.g., $10,000)
  static const int maximumPaymentAmount = 1000000;

  // =============================================
  // SECURITY SETTINGS
  // =============================================

  /// Enable 3D Secure authentication
  static const bool enable3DSecure = true;

  /// Enable Stripe Radar fraud detection
  static const bool enableRadar = true;

  /// Payment timeout in seconds
  static const int paymentTimeoutSeconds = 300; // 5 minutes

  /// Maximum retry attempts for failed payments
  static const int maxRetryAttempts = 3;

  // =============================================
  // DEVELOPMENT SETTINGS
  // =============================================

  /// Enable debug logging for payments
  static const bool debugMode = true; // Set to false in production

  /// Test payment amount for development (in CAD)
  static const double testPaymentAmount = 10.00;

  /// Mock payment success rate (0.0 to 1.0) for testing
  static const double mockSuccessRate = 0.9;

  // =============================================
  // HELPER METHODS
  // =============================================

  /// Get Stripe secret key (should be loaded from secure storage)
  static String getStripeSecretKey() {
    // TODO: Implement secure key retrieval
    // In production, load from environment variables or secure key store
    return 'sk_test_51234...'; // Replace with your actual secret key
  }

  /// Check if we're in production mode
  static bool get isProduction {
    // TODO: Implement proper environment detection
    return false; // Always false for now - implement based on your setup
  }

  /// Get appropriate API keys based on environment
  static Map<String, String> getApiKeys() {
    if (isProduction) {
      return {
        'publishable': 'pk_live_...', // Your live publishable key
        'secret': 'sk_live_...', // Your live secret key
      };
    } else {
      return {
        'publishable': stripePublishableKey,
        'secret': getStripeSecretKey(),
      };
    }
  }

  /// Validate payment amount
  static bool isValidPaymentAmount(double amount) {
    final amountInCents = (amount * 100).round();
    return amountInCents >= minimumPaymentAmount &&
        amountInCents <= maximumPaymentAmount;
  }

  /// Get shipping cost based on method and order total
  static double getShippingCost(String method, double orderTotal) {
    if (orderTotal >= freeShippingThreshold) {
      return 0.0; // Free shipping
    }

    final rate = shippingRates[method];
    return rate?['rate']?.toDouble() ??
        shippingRates['standard']!['rate']!.toDouble();
  }

  /// Calculate HST for given amount
  static double calculateHST(double amount) {
    return amount * hstRate;
  }

  /// Calculate total with HST
  static double calculateTotalWithHST(double subtotal) {
    return subtotal + calculateHST(subtotal);
  }

  /// Format amount as CAD currency
  static String formatCAD(double amount) {
    return '\$${amount.toStringAsFixed(2)} CAD';
  }

  /// Validate Canadian postal code
  static bool isValidCanadianPostalCode(String postalCode) {
    // Canadian postal code pattern: A1A 1A1
    final regex = RegExp(r'^[A-Za-z]\d[A-Za-z] \d[A-Za-z]\d$');
    return regex.hasMatch(postalCode.toUpperCase());
  }

  /// Get test card numbers for development
  static Map<String, String> get testCardNumbers {
    return {
      'visa_success': '4242424242424242',
      'visa_decline': '4000000000000002',
      'mastercard_success': '5555555555554444',
      'amex_success': '378282246310005',
      'require_3ds': '4000002500003155',
    };
  }
}
