import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/repositories/firebase_auth_repository.dart';
import '../../pos/data/models/sale.dart';

class ReportsRepository {
  final FirebaseFirestore _firestore;
  final String? _userId;

  ReportsRepository(this._firestore, this._userId);

  Stream<List<Sale>> getSales() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('shops')
        .doc(_userId)
        .collection('sales')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Sale.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final user = ref.watch(authStateProvider).value;
  return ReportsRepository(FirebaseFirestore.instance, user?.uid);
});

final dailySalesProvider = StreamProvider<List<Sale>>((ref) {
  return ref.watch(reportsRepositoryProvider).getSales();
});
