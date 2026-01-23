import '../config/app_config.dart';
import '../core/utils/error_handler.dart';
import 'cashfree_payment_service.dart';

class EnhancedPaymentService {
  // Initialize payment service (Cashfree)
  static void initialize() {
    // Cashfree doesn't need initialization like Razorpay
    // It uses web-based payment flow
  }

  // Process payment using Cashfree
  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? description,
  }) async {
    return await CashfreePaymentService.processPayment(
      amount: amount,
      orderId: orderId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      description: description,
    );
  }

  // Check payment status
  static Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    return await CashfreePaymentService.checkPaymentStatus(orderId);
  }

  // Cleanup (no-op for Cashfree)
  static void dispose() {
    // No cleanup needed for Cashfree
  }
}

