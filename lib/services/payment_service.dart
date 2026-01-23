import '../config/app_config.dart';
import 'enhanced_payment_service.dart';
import '../core/utils/error_handler.dart';

class PaymentService {
  // Process payment with error handling
  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String orderId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> customerDetails,
  }) async {
    try {
      // Initialize payment service if needed
      if (AppConfig.hasCashfreeConfig) {
        EnhancedPaymentService.initialize();
      }

      final result = await EnhancedPaymentService.processPayment(
        amount: amount,
        orderId: orderId,
        customerName: customerDetails['name'] ?? 'Customer',
        customerEmail: customerDetails['email'] ?? '',
        customerPhone: customerDetails['phone'] ?? '',
        description: 'Payment for ${items.length} item(s)',
      );

      return result;
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  // Verify payment (for webhook handling)
  static Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    if (AppConfig.useMockData) {
      return true; // Mock verification
    }

    // In production, verify payment signature with Razorpay
    // This should be done on the backend for security
    return true;
  }
}

