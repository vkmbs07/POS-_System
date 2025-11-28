import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pos/data/models/sale.dart';

final reportsRepositoryProvider = Provider((ref) {
  return ReportsRepository();
});

final dailySalesProvider = FutureProvider<List<Sale>>((ref) {
  return ref.read(reportsRepositoryProvider).getDailySales(DateTime.now());
});

class ReportsRepository {
  Future<List<Sale>> getDailySales(DateTime date) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Sale(
        id: '1001',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        items: [],
        totalAmount: 25.50,
        paymentMethod: 'CASH',
      ),
      Sale(
        id: '1002',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        items: [],
        totalAmount: 12.00,
        paymentMethod: 'CASH',
      ),
      Sale(
        id: '1003',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        items: [],
        totalAmount: 105.00,
        paymentMethod: 'CASH',
      ),
    ];
  }
}
