/**
 * Enhanced Error Handling for Network Requests - BUG-3
 *
 * This file provides enhanced error handling utilities that can be
 * integrated into the existing Utils class.
 */

import 'dart:async';

import 'package:flutter/material.dart';

import 'Utilities.dart';

class ErrorHandlingUtils {
  // Enhanced error handling for the existing Utils.http_post method
  static Future<dynamic> http_post_with_retry(
    String path,
    Map<String, dynamic> body, {
    int maxRetries = 3,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final result = await Utils.http_post(path, body);

        // Check if request was successful
        if (result != null && result['code'] == 1) {
          return result;
        }

        // If not successful but not a network error, don't retry
        if (result != null && result['message'] != null) {
          String message = result['message'].toString().toLowerCase();
          if (!message.contains('network') &&
              !message.contains('timeout') &&
              !message.contains('connection')) {
            return result;
          }
        }

        attempts++;
        if (attempts >= maxRetries) {
          return result;
        }

        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          return {
            'code': 0,
            'message': 'Network request failed after $maxRetries attempts',
            'data': null,
          };
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }

    return {
      'code': 0,
      'message': 'Request failed after maximum retry attempts',
      'data': null,
    };
  }

  // Enhanced error handling for the existing Utils.http_get method
  static Future<dynamic> http_get_with_retry(
    String path,
    Map<String, dynamic> body, {
    bool addBase = true,
    int maxRetries = 3,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final result = await Utils.http_get(path, body, addBase: addBase);

        // Check if request was successful
        if (result != null && (result['code'] == 1 || result['status'] == 1)) {
          return result;
        }

        // If not successful but not a network error, don't retry
        if (result != null && result['message'] != null) {
          String message = result['message'].toString().toLowerCase();
          if (!message.contains('network') &&
              !message.contains('timeout') &&
              !message.contains('connection')) {
            return result;
          }
        }

        attempts++;
        if (attempts >= maxRetries) {
          return result;
        }

        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          return {
            'code': 0,
            'message': 'Network request failed after $maxRetries attempts',
            'data': null,
          };
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }

    return {
      'code': 0,
      'message': 'Request failed after maximum retry attempts',
      'data': null,
    };
  }

  // Enhanced error message mapping
  static String getErrorMessage(dynamic error) {
    if (error == null) return 'Unknown error occurred';

    String message = error.toString().toLowerCase();

    if (message.contains('timeout') || message.contains('timed out')) {
      return 'Connection timed out. Please check your internet connection and try again.';
    }

    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }

    if (message.contains('server') || message.contains('500')) {
      return 'Server error. Please try again later.';
    }

    if (message.contains('unauthorized') || message.contains('401')) {
      return 'Please log in again to continue.';
    }

    if (message.contains('forbidden') || message.contains('403')) {
      return 'You do not have permission to perform this action.';
    }

    if (message.contains('not found') || message.contains('404')) {
      return 'The requested resource was not found.';
    }

    // Return original message if no pattern matches
    return error.toString();
  }
}

// Enhanced loading state management
class LoadingState {
  static final Map<String, bool> _states = {};

  static bool isLoading(String key) => _states[key] ?? false;

  static void setLoading(String key, bool loading) {
    _states[key] = loading;
  }

  static void clearLoading(String key) {
    _states.remove(key);
  }

  static void clearAll() {
    _states.clear();
  }
}

// Enhanced error handling for common operations
class ErrorHandler {
  // Show user-friendly error message
  static void showError(String message, {bool isLong = true}) {
    String userMessage = (message);
    Utils.toast(userMessage, color: Colors.red, isLong: isLong);
  }

  // Show success message
  static void showSuccess(String message) {
    Utils.toast(message, color: Colors.green, isLong: false);
  }

  // Show warning message
  static void showWarning(String message) {
    Utils.toast(message, color: Colors.orange, isLong: true);
  }

  // Handle API response with standard format
  static bool handleApiResponse(
    dynamic response, {
    Function? onSuccess,
    Function? onError,
    bool showMessages = true,
  }) {
    if (response == null) {
      if (showMessages) showError('No response from server');
      if (onError != null) onError('No response from server');
      return false;
    }

    // Handle successful response
    if (response['code'] == 1 || response['status'] == 1) {
      if (showMessages && response['message'] != null) {
        showSuccess(response['message']);
      }
      if (onSuccess != null) onSuccess(response);
      return true;
    }

    // Handle error response
    String errorMessage = response['message'] ?? 'An error occurred';
    if (showMessages) showError(errorMessage);
    if (onError != null) onError(errorMessage);
    return false;
  }

  // Wrap async operations with error handling
  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (showError) {
        String message = errorMessage ?? e.toString();
        ErrorHandler.showError(message);
      }
      return null;
    }
  }

  // Check if error is network related
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;
    String message = error.toString().toLowerCase();
    return message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('internet');
  }

  // Check if error requires authentication
  static bool isAuthError(dynamic error) {
    if (error == null) return false;
    String message = error.toString().toLowerCase();
    return message.contains('unauthorized') ||
        message.contains('401') ||
        message.contains('token') ||
        message.contains('authentication');
  }
}
