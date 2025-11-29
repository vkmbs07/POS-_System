import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pos/data/models/product.dart';
import '../../pos/data/repositories/product_repository.dart';

class ProductController extends StateNotifier<AsyncValue<void>> {
  final ProductRepository _productRepository;

  ProductController(this._productRepository) : super(const AsyncData(null));

  Future<void> addProduct(Product product) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _productRepository.addProduct(product));
  }

  Future<void> updateProduct(Product product) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _productRepository.updateProduct(product));
  }

  Future<void> deleteProduct(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _productRepository.deleteProduct(id));
  }
}

final productControllerProvider = StateNotifierProvider<ProductController, AsyncValue<void>>((ref) {
  return ProductController(ref.watch(productRepositoryProvider));
});
