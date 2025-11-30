import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/repositories/firebase_auth_repository.dart';
import '../../pos/data/models/sale.dart';

class ReportsRepository {
  final FirebaseFirestore _firestore;
  final String? _userId;

  ReportsRepository(this._firestore, this._userId);

  Stream<List<Sale>> getSales({DateTime? start, DateTime? end}) {
    if (_userId == null) return Stream.value([]);

    Query query = _firestore
        .collection('shops')
        .doc(_userId)
        .collection('sales')
        .orderBy('timestamp', descending: true);

    if (start != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start));
    }
    if (end != null) {
      // Add one day to end date to include the full day
      final endOfDay = end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
      query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Sale.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final userProfile = ref.watch(userProfileProvider).value;
  return ReportsRepository(FirebaseFirestore.instance, userProfile?.shopId);
});

// Define a record for the filter arguments
typedef DateRangeFilter = ({DateTime? start, DateTime? end});

final salesReportProvider = StreamProvider.family<List<Sale>, DateRangeFilter>((ref, filter) {
  return ref.watch(reportsRepositoryProvider).getSales(start: filter.start, end: filter.end);
});
