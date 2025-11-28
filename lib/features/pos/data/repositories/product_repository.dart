import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

// Initial Mock Data
final List<Product> _initialMockProducts = [
  Product(id: '1', name: 'Milk 1L', barcode: '123456', price: 2.50, stockQty: 50, category: 'Dairy', imageUrl: 'https://via.placeholder.com/150'),
  Product(id: '2', name: 'Bread', barcode: '234567', price: 1.20, stockQty: 30, category: 'Bakery', imageUrl: 'https://via.placeholder.com/150'),
  Product(id: '3', name: 'Eggs (Dozen)', barcode: '345678', price: 3.00, stockQty: 40, category: 'Dairy', imageUrl: 'https://via.placeholder.com/150'),
  Product(id: '4', name: 'Chocolate Bar', barcode: '456789', price: 1.50, stockQty: 100, category: 'Snacks', imageUrl: 'https://via.placeholder.com/150'),
  Product(id: '5', name: 'Soda Can', barcode: '567890', price: 1.00, stockQty: 200, category: 'Beverages', imageUrl: 'https://via.placeholder.com/150'),
];

final productRepositoryProvider = Provider((ref) {
  return ProductRepository();
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.read(productRepositoryProvider).getProducts();
});

class ProductRepository {
  // Use a broadcast controller to emit updates
  final _controller = StreamController<List<Product>>.broadcast();
  final List<Product> _products = List.from(_initialMockProducts);

  ProductRepository() {
    // Emit initial value
    _controller.add(_products);
  }

  Stream<List<Product>> getProducts() {
    // Return the stream from the controller. 
    // We emit the current list immediately for new listeners if possible, 
    // but StreamController doesn't hold value like BehaviorSubject.
    // So we'll just return the stream and rely on the initial add or subsequent adds.
    // A better way for simple mock is to just return a new stream that starts with current data.
    return _controller.stream.startWith(_products);
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    _controller.add(_products);
  }
}

extension StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T value) => Stream.value(value).concatWith([this]);
}

extension StreamConcatWith<T> on Stream<T> {
  Stream<T> concatWith(Iterable<Stream<T>> other) async* {
    yield* this;
    for (var stream in other) {
      yield* stream;
    }
  }
}
