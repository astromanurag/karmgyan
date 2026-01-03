import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/app_config.dart';
import '../core/utils/error_handler.dart';
import 'dart:async';

class EnhancedPaymentService {
  static Razorpay? _razorpay;
  static Completer<Map<String, dynamic>>? _paymentCompleter;

  // Initialize Razorpay
  static void initialize() {
    if (!AppConfig.hasRazorpayConfig) return;

    try {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e) {
      print('Razorpay initialization failed: $e');
    }
  }

  // Process payment
  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? description,
  }) async {
    if (AppConfig.useMockData || !AppConfig.hasRazorpayConfig) {
      // Mock payment
      await Future.delayed(const Duration(seconds: 2));
      return {
        'success': true,
        'payment_id': 'mock_payment_${DateTime.now().millisecondsSinceEpoch}',
        'order_id': orderId,
        'amount': amount,
      };
    }

    if (_razorpay == null) {
      initialize();
    }

    if (_razorpay == null) {
      throw Exception('Payment service not available');
    }

    _paymentCompleter = Completer<Map<String, dynamic>>();

    final options = {
      'key': AppConfig.razorpayKeyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'karmgyan',
      'description': description ?? 'Payment for services',
      'prefill': {
        'contact': customerPhone,
        'email': customerEmail,
        'name': customerName,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay!.open(options);
      return await _paymentCompleter!.future;
    } catch (e) {
      _paymentCompleter = null;
      throw Exception('Payment failed: ${e.toString()}');
    }
  }

  // Handle payment success
  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete({
        'success': true,
        'payment_id': response.paymentId,
        'order_id': response.orderId,
        'signature': response.signature,
      });
      _paymentCompleter = null;
    }
  }

  // Handle payment error
  static void _handlePaymentError(PaymentFailureResponse response) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.completeError(
        Exception('Payment failed: ${response.message}'),
      );
      _paymentCompleter = null;
    }
  }

  // Handle external wallet
  static void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
    print('External wallet selected: ${response.walletName}');
  }

  // Cleanup
  static void dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _paymentCompleter = null;
  }
}

