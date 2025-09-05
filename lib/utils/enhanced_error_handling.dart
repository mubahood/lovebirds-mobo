/**
 * Enhanced Error Handling Implementation - BUG-3
 * 
 * This file implements comprehensive error handling improvements throughout
 * the Lovebirds app to enhance user experience and provide better feedback
 * for network failures, API errors, and other issues.
 */

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dioPackage;
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/LoggedInUserModel.dart';
import '../utils/AppConfig.dart';
import '../utils/CustomTheme.dart';
import '../utils/Utilities.dart';

// Enhanced error types - moved to top level
enum NetworkErrorType {
  networkTimeout,
  noConnection,
  serverError,
  authenticationError,
  validationError,
  unknownError,
}

// Error type enum for internal use
enum ErrorType {
  networkTimeout,
  noConnection,
  serverError,
  authenticationError,
  validationError,
  unknownError,
}

// Enhanced Network Error Handling Service
class NetworkErrorService {
  static const int MAX_RETRIES = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 2);

  // User-friendly error messages
  static String getErrorMessage(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.networkTimeout:
        return "Connection timed out. Please check your internet connection and try again.";
      case NetworkErrorType.noConnection:
        return "No internet connection. Please check your network settings.";
      case NetworkErrorType.serverError:
        return "Server is temporarily unavailable. Please try again later.";
      case NetworkErrorType.authenticationError:
        return "Your session has expired. Please log in again.";
      case NetworkErrorType.validationError:
        return "Please check your input and try again.";
      default:
        return "Something went wrong. Please try again.";
    }
  }

  // Retry mechanism for failed requests
  static Future<dynamic> retryRequest(
    Future<dynamic> Function() request, {
    int maxRetries = MAX_RETRIES,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          throw e;
        }
        await Future.delayed(RETRY_DELAY * attempts);
      }
    }
  }
}

// Enhanced Utils class with improved error handling
class EnhancedUtils {
  // Enhanced HTTP POST with comprehensive error handling
  static Future<dynamic> http_post_enhanced(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      // Check internet connectivity first
      if (!await Utils.is_connected()) {
        // return _createErrorResponse(NetworkErrorType.noConnection);
      }

      return await NetworkErrorService.retryRequest(() async {
        return await _performHttpPost(path, body);
      });
    } catch (e) {
      return _handleException(e);
    }
  }

  // Enhanced HTTP GET with comprehensive error handling
  static Future<dynamic> http_get_enhanced(
    String path,
    Map<String, dynamic> body, {
    bool addBase = true,
  }) async {
    try {
      // Check internet connectivity first
      if (!await Utils.is_connected()) {
        // return _createErrorResponse(NetworkErrorType.noConnection);
      }

      return await NetworkErrorService.retryRequest(() async {
        return await _performHttpGet(path, body, addBase: addBase);
      });
    } catch (e) {
      return _handleException(e);
    }
  }

  // Internal method to perform HTTP POST
  static Future<dynamic> _performHttpPost(
    String path,
    Map<String, dynamic> body,
  ) async {
    dynamic response;
    var dio = dioPackage.Dio();

    // Configure Dio with enhanced settings
    _configureDio(dio);

    // Add authentication and platform info
    await _addAuthHeaders(body);

    var formData = dioPackage.FormData.fromMap(body);

    try {
      response = await dio.post(
        "${AppConfig.API_BASE_URL}/$path",
        data: formData,
        options: await _getRequestOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw dioPackage.DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } on dioPackage.DioException catch (e) {
      throw _processDioException(e, path);
    }
  }

  // Internal method to perform HTTP GET
  static Future<dynamic> _performHttpGet(
    String path,
    Map<String, dynamic> body, {
    bool addBase = true,
  }) async {
    var dio = dioPackage.Dio();
    _configureDio(dio);

    LoggedInUserModel u = await LoggedInUserModel.getLoggedInUser();
    body['logged_in_user_id'] = u.id.toString();
    body['platform_type'] = Platform.isIOS ? 'ios' : 'android';

    try {
      final response = await dio.get(
        addBase ? "${AppConfig.API_BASE_URL}/$path" : path,
        queryParameters: body,
        options: await _getRequestOptions(),
      );
      return response.data;
    } on dioPackage.DioException catch (e) {
      throw _processDioException(e, path);
    }
  }

  // Configure Dio with enhanced settings
  static void _configureDio(dioPackage.Dio dio) {
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (
      HttpClient client,
    ) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      client.connectionTimeout = const Duration(seconds: 30);
      client.idleTimeout = const Duration(seconds: 30);
      client.userAgent =
          'Lovebirds-${Platform.operatingSystem}/${Platform.operatingSystemVersion}';
      return client;
    };

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    dio.options.sendTimeout = const Duration(seconds: 30);
  }

  // Get enhanced request options
  static Future<dioPackage.Options> _getRequestOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await LoggedInUserModel.get_token();
    LoggedInUserModel userModel = await LoggedInUserModel.getLoggedInUser();

    String platformType = Platform.isIOS ? 'ios' : 'android';
    String deviceInfo =
        '${Platform.operatingSystem}/${Platform.operatingSystemVersion}';

    return dioPackage.Options(
      headers: <String, String>{
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Tok": "Bearer $token",
        "logged_in_user_id": userModel.id.toString(),
        "User-Agent": "Lovebirds-$deviceInfo",
        "X-Platform": platformType,
        "X-App-Version": "1.0.0",
      },
    );
  }

  // Add authentication headers to body
  static Future<void> _addAuthHeaders(Map<String, dynamic> body) async {
    LoggedInUserModel userModel = await LoggedInUserModel.getLoggedInUser();
    body['logged_in_user_id'] = userModel.id.toString();

    String platformType = Platform.isIOS ? 'ios' : 'android';
    String deviceInfo =
        '${Platform.operatingSystem}/${Platform.operatingSystemVersion}';

    body['platform_type'] = platformType;
    body['device_info'] = deviceInfo;
  }

  // Process Dio exceptions with enhanced error handling
  static Exception _processDioException(
    dioPackage.DioException e,
    String path,
  ) {
    print("============NETWORK ERROR==============");
    print("URL: ${AppConfig.API_BASE_URL}/$path");
    print("Error Type: ${e.type}");
    print("Error Message: ${e.message}");
    if (e.response != null) {
      print("Response Status: ${e.response?.statusCode}");
      print("Response Data: ${e.response?.data}");
    }
    print("=====================================");

    // Map DioException types to our error types
    ErrorType errorType;

    switch (e.type) {
      case dioPackage.DioExceptionType.connectionTimeout:
      case dioPackage.DioExceptionType.receiveTimeout:
      case dioPackage.DioExceptionType.sendTimeout:
        errorType = ErrorType.networkTimeout;
        break;
      case dioPackage.DioExceptionType.connectionError:
        errorType = ErrorType.noConnection;
        break;
      case dioPackage.DioExceptionType.badResponse:
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          errorType = ErrorType.authenticationError;
        } else if (e.response?.statusCode != null &&
            e.response!.statusCode! >= 500) {
          errorType = ErrorType.serverError;
        } else {
          errorType = ErrorType.validationError;
        }
        break;
      default:
        errorType = ErrorType.unknownError;
    }

    return NetworkException(errorType, e.response?.data);
  }

  // Handle general exceptions
  static dynamic _handleException(dynamic e) {
    print("Unexpected error: $e");

    if (e is NetworkException) {
      return _createErrorResponse(e.type, data: e.responseData);
    }

    return _createErrorResponse(ErrorType.unknownError);
  }

  // Create standardized error response
  static Map<String, dynamic> _createErrorResponse(
    ErrorType type, {
    dynamic data,
  }) {
    return {
      'code': 0,
      'success': false,
      // 'message': NetworkErrorService.getErrorMessage(type),
      'error_type': type.toString(),
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

// Custom exception class for network errors
class NetworkException implements Exception {
  final ErrorType type;
  final dynamic responseData;

  NetworkException(this.type, [this.responseData]);

  @override
  String toString() {
    return 'NetworkException: $type, Response Data: $responseData';
  }
}

// Enhanced loading state management
class LoadingStateManager {
  static final Map<String, bool> _loadingStates = {};

  static bool isLoading(String key) => _loadingStates[key] ?? false;

  static void setLoading(String key, bool loading) {
    _loadingStates[key] = loading;
  }

  static void clearLoading(String key) {
    _loadingStates.remove(key);
  }

  static void clearAll() {
    _loadingStates.clear();
  }
}

// Enhanced error dialog service
class ErrorDialogService {
  static void showErrorDialog(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomTheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title ?? "Error",
            style: TextStyle(
              color: CustomTheme.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message, style: TextStyle(color: Colors.grey[300])),
          actions: [
            if (onCancel != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onRetry != null) {
                  onRetry();
                } else {
                  // Default action is to just close
                }
              },
              child: Text(
                onRetry != null ? "Retry" : "OK",
                style: TextStyle(color: CustomTheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showNetworkErrorDialog(
    BuildContext context,
    ErrorType errorType, {
    VoidCallback? onRetry,
  }) {
    String title;
    String message = NetworkErrorService.getErrorMessage(
      _mapToNetworkErrorType(errorType),
    );

    switch (errorType) {
      case ErrorType.noConnection:
        title = "No Internet Connection";
        break;
      case ErrorType.networkTimeout:
        title = "Connection Timeout";
        break;
      case ErrorType.serverError:
        title = "Server Error";
        break;
      case ErrorType.authenticationError:
        title = "Authentication Required";
        break;
      default:
        title = "Error";
    }

    showErrorDialog(context, message, title: title, onRetry: onRetry);
  }

  // Helper method to map ErrorType to NetworkErrorType
  static NetworkErrorType _mapToNetworkErrorType(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.networkTimeout:
        return NetworkErrorType.networkTimeout;
      case ErrorType.noConnection:
        return NetworkErrorType.noConnection;
      case ErrorType.serverError:
        return NetworkErrorType.serverError;
      case ErrorType.authenticationError:
        return NetworkErrorType.authenticationError;
      case ErrorType.validationError:
        return NetworkErrorType.validationError;
      case ErrorType.unknownError:
        return NetworkErrorType.unknownError;
    }
  }
}

// Enhanced toast service with better UX
class ToastService {
  static void showError(String message) {
    Utils.toast(message, color: Colors.red[400]!, isLong: true);
  }

  static void showSuccess(String message) {
    Utils.toast(message, color: Colors.green[400]!, isLong: false);
  }

  static void showWarning(String message) {
    Utils.toast(message, color: Colors.orange[400]!, isLong: true);
  }

  static void showInfo(String message) {
    Utils.toast(message, color: Colors.blue[400]!, isLong: false);
  }
}

// Connection monitoring service
class ConnectionMonitorService {
  static Timer? _connectionTimer;
  static bool _isMonitoring = false;
  static final List<VoidCallback> _connectionCallbacks = [];

  static void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _connectionTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      bool connected = await Utils.is_connected();
      if (!connected) {
        for (var callback in _connectionCallbacks) {
          callback();
        }
      }
    });
  }

  static void stopMonitoring() {
    _connectionTimer?.cancel();
    _isMonitoring = false;
  }

  static void addConnectionCallback(VoidCallback callback) {
    _connectionCallbacks.add(callback);
  }

  static void removeConnectionCallback(VoidCallback callback) {
    _connectionCallbacks.remove(callback);
  }

  static void clearCallbacks() {
    _connectionCallbacks.clear();
  }
}
