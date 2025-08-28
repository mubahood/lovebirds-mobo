/// Debug configuration for development and testing
class DebugConfig {
  /// Set to true to bypass subscription paywall during development
  /// ⚠️ IMPORTANT: Set to false before production release!
  static const bool bypassSubscription = false;

  /// Set to true to enable detailed debug logging
  static const bool enableDebugLogging = false;

  /// Set to true to enable test mode features
  static const bool isTestMode = false;

  /// Development API endpoint (if different from production)
  static const String? devApiEndpoint = null;

  /// Show debug information overlay
  static const bool showDebugOverlay = false;
}
