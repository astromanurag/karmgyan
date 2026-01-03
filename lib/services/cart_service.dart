import '../config/app_config.dart';
import '../core/services/local_storage_service.dart';

class CartService {
  static const String _cartKey = 'shopping_cart';

  // Get cart items
  static List<Map<String, dynamic>> getCartItems() {
    final cart = LocalStorageService.get(_cartKey);
    if (cart is List) {
      return List<Map<String, dynamic>>.from(cart);
    }
    return [];
  }

  // Add item to cart
  static Future<void> addToCart(Map<String, dynamic> item) async {
    final cart = getCartItems();
    
    // Check if item already exists
    final existingIndex = cart.indexWhere((i) => i['id'] == item['id']);
    if (existingIndex >= 0) {
      cart[existingIndex]['quantity'] = (cart[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      cart.add({
        ...item,
        'quantity': 1,
      });
    }
    
    await LocalStorageService.save(_cartKey, cart);
  }

  // Remove item from cart
  static Future<void> removeFromCart(String itemId) async {
    final cart = getCartItems();
    cart.removeWhere((item) => item['id'] == itemId);
    await LocalStorageService.save(_cartKey, cart);
  }

  // Update item quantity
  static Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(itemId);
      return;
    }

    final cart = getCartItems();
    final index = cart.indexWhere((item) => item['id'] == itemId);
    if (index >= 0) {
      cart[index]['quantity'] = quantity;
      await LocalStorageService.save(_cartKey, cart);
    }
  }

  // Clear cart
  static Future<void> clearCart() async {
    await LocalStorageService.delete(_cartKey);
  }

  // Get cart total
  static double getCartTotal() {
    final cart = getCartItems();
    double total = 0;
    for (final item in cart) {
      final price = (item['price'] as num?)?.toDouble() ?? 0;
      final quantity = item['quantity'] as int? ?? 1;
      total += price * quantity;
    }
    return total;
  }

  // Get cart item count
  static int getCartItemCount() {
    final cart = getCartItems();
    int count = 0;
    for (final item in cart) {
      count += item['quantity'] as int? ?? 1;
    }
    return count;
  }
}

