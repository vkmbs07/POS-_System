import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  double get total => product.price * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    state = [
      ...state,
      CartItem(product: product, quantity: 1),
    ];
    // Note: Logic to merge duplicates can be added here
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount => state.fold(0, (sum, item) => sum + item.total);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
