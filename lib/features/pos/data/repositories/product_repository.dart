import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/repositories/firebase_auth_repository.dart';
import '../models/product.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;
  final String? _userId;

  ProductRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>>? get _productsCollection {
    if (_userId == null) return null;
    return _firestore
        .collection('shops')
        .doc(_userId)
        .collection('products');
  }

  Stream<List<Product>> getProducts() {
    final collection = _productsCollection;
    if (collection == null) return Stream.value([]);

    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Product?> getProduct(String id) async {
    final collection = _productsCollection;
    if (collection == null) return null;

    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return Product.fromMap(doc.data()!, doc.id);
  }

  Future<void> addProduct(Product product) async {
    final collection = _productsCollection;
    if (collection == null) throw Exception('User not logged in');

    await collection.add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    final collection = _productsCollection;
    if (collection == null) throw Exception('User not logged in');

    await collection.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    final collection = _productsCollection;
    if (collection == null) throw Exception('User not logged in');

    await collection.doc(id).delete();
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final userProfile = ref.watch(userProfileProvider).value;
  return ProductRepository(FirebaseFirestore.instance, userProfile?.shopId);
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getProducts();
});
