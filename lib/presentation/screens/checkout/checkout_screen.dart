import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../services/cart_service.dart';
import '../../../services/payment_service.dart';
import '../../../services/enhanced_data_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/loading_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    // Check connectivity
    final hasConnection = await ErrorHandler.checkConnectivity();
    if (!hasConnection) {
      await ErrorHandler.showConnectivityError(context);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final cartItems = CartService.getCartItems();
      final total = CartService.getCartTotal();
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

      // Process payment
      final paymentResult = await PaymentService.processPayment(
        amount: total,
        orderId: orderId,
        items: cartItems,
        customerDetails: {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
        },
      );

      // Create order
      final order = await EnhancedDataService().createOrder({
        'id': orderId,
        'items': cartItems,
        'total': total,
        'customer_name': _nameController.text,
        'customer_email': _emailController.text,
        'customer_phone': _phoneController.text,
        'customer_address': _addressController.text,
        'payment_id': paymentResult['payment_id'],
        'status': 'confirmed',
      });

      await CartService.clearCart();

      if (mounted) {
        ErrorHandler.showSuccess(context, 'Payment successful!');
        context.push('/order-confirmation', extra: order);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = CartService.getCartTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('Total: ₹${total.toStringAsFixed(2)}'),
              const SizedBox(height: 24),
              Text(
                'Customer Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (!value!.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Pay ₹${total.toStringAsFixed(2)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

