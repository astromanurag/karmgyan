import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import '../../../services/cart_service.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _cartItems = [];
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    setState(() {
      _cartItems = CartService.getCartItems();
      _total = CartService.getCartTotal();
    });
  }

  Future<void> _updateQuantity(String itemId, int quantity) async {
    await CartService.updateQuantity(itemId, quantity);
    _loadCart();
  }

  Future<void> _removeItem(String itemId) async {
    await CartService.removeFromCart(itemId);
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(item['name'] ?? 'Item'),
                          subtitle: Text('₹${item['price'] ?? 0}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  final qty = (item['quantity'] ?? 1) - 1;
                                  _updateQuantity(item['id'], qty);
                                },
                              ),
                              Text('${item['quantity'] ?? 1}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  final qty = (item['quantity'] ?? 1) + 1;
                                  _updateQuantity(item['id'], qty);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeItem(item['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '₹${_total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/checkout'),
                          child: const Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

