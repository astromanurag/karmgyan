import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../config/env_config.dart';
import 'dart:async';

class CashfreePaymentService {
  // Process payment using Cashfree
  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? description,
  }) async {
    if (AppConfig.useMockData || !AppConfig.hasCashfreeConfig) {
      // Mock payment
      await Future.delayed(const Duration(seconds: 2));
      return {
        'success': true,
        'payment_id': 'mock_payment_${DateTime.now().millisecondsSinceEpoch}',
        'order_id': orderId,
        'amount': amount,
      };
    }

    try {
      // Step 1: Create order on backend
      final orderResponse = await http.post(
        Uri.parse('${EnvConfig.backendUrl}/api/payment/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'orderId': orderId,
          'customerName': customerName,
          'customerEmail': customerEmail,
          'customerPhone': customerPhone,
          'description': description ?? 'Payment for services',
        }),
      );

      if (orderResponse.statusCode != 200) {
        throw Exception('Failed to create order: ${orderResponse.body}');
      }

      final orderData = jsonDecode(orderResponse.body) as Map<String, dynamic>;
      final paymentSessionId = orderData['payment_session_id'] as String;
      final paymentUrl = orderData['payment_url'] as String;

      // Step 2: Open payment URL (web-based flow)
      if (await canLaunchUrl(Uri.parse(paymentUrl))) {
        await launchUrl(
          Uri.parse(paymentUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Could not launch payment URL');
      }

      // Step 3: Poll for payment status (or use webhook)
      // In production, this should be handled via webhook
      // For now, return the session ID for status checking
      return {
        'success': true,
        'payment_session_id': paymentSessionId,
        'order_id': orderId,
        'amount': amount,
        'status': 'pending', // Will be updated via webhook
      };
    } catch (e) {
      throw Exception('Payment failed: ${e.toString()}');
    }
  }

  // Check payment status
  static Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    if (AppConfig.useMockData) {
      return {
        'status': 'success',
        'order_id': orderId,
      };
    }

    try {
      final response = await http.get(
        Uri.parse('${EnvConfig.backendUrl}/api/payment/status/$orderId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to check payment status');
      }
    } catch (e) {
      throw Exception('Error checking payment status: ${e.toString()}');
    }
  }
}

