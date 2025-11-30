import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/repositories/firebase_auth_repository.dart';
import '../models/sale.dart';

class SalesRepository {
  final FirebaseFirestore _firestore;
  final String? _userId;

  SalesRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>>? get _salesCollection {
    if (_userId == null) return null;
    return _firestore
        .collection('shops')
        .doc(_userId)
        .collection('sales');
  }

  Future<void> addSale(Sale sale) async {
    final collection = _salesCollection;
    if (collection == null) throw Exception('User not logged in');

    await collection.doc(sale.id).set(sale.toMap());
  }
}

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final userProfile = ref.watch(userProfileProvider).value;
  return SalesRepository(FirebaseFirestore.instance, userProfile?.shopId);
});
