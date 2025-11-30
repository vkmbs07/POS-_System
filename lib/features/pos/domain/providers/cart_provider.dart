import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  double get total => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      // Item exists, increment quantity
      final oldItem = state[index];
      final newItem = oldItem.copyWith(quantity: oldItem.quantity + 1);
      state = [
        ...state.sublist(0, index),
        newItem,
        ...state.sublist(index + 1),
      ];
    } else {
      // New item
      state = [
        ...state,
        CartItem(product: product, quantity: 1),
      ];
    }
  }

  void removeProduct(Product product) {
    state = state.where((item) => item.product.id != product.id).toList();
  }

  void decrementProduct(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      final oldItem = state[index];
      if (oldItem.quantity > 1) {
        final newItem = oldItem.copyWith(quantity: oldItem.quantity - 1);
        state = [
          ...state.sublist(0, index),
          newItem,
          ...state.sublist(index + 1),
        ];
      } else {
        // Remove if quantity becomes 0
        removeProduct(product);
      }
    }
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount => state.fold(0, (sum, item) => sum + item.total);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
