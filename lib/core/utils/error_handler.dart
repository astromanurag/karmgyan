import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ErrorHandler {
  // Get user-friendly error message
  static String getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return 'No internet connection. Please check your network and try again.';
    }

    // Authentication errors
    if (errorString.contains('unauthorized') || 
        errorString.contains('authentication') ||
        errorString.contains('invalid credentials')) {
      return 'Invalid credentials. Please check your email and password.';
    }

    // Server errors
    if (errorString.contains('500') || 
        errorString.contains('server error') ||
        errorString.contains('internal error')) {
      return 'Server error. Please try again later.';
    }

    // Not found errors
    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Resource not found.';
    }

    // Validation errors
    if (errorString.contains('validation') || 
        errorString.contains('invalid') ||
        errorString.contains('required')) {
      return 'Please check your input and try again.';
    }

    // Default
    return 'Something went wrong. Please try again.';
  }

  // Show error snackbar
  static void showError(BuildContext context, dynamic error, {Duration? duration}) {
    if (!context.mounted) return;

    // Capture the messenger before showing snackbar to avoid context issues
    final messenger = ScaffoldMessenger.of(context);
    
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                getErrorMessage(error),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration ?? const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            // SnackBar is automatically dismissed when action is pressed
            // No need to manually hide it
          },
        ),
      ),
    );
  }

  // Show success message
  static void showSuccess(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  // Check internet connectivity
  static Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Show connectivity error dialog
  static Future<void> showConnectivityError(BuildContext context) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 12),
            Text('No Internet Connection'),
          ],
        ),
        content: const Text(
          'Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

