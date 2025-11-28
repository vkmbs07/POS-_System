import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sale.dart';

final salesRepositoryProvider = Provider((ref) {
  return SalesRepository();
});

class SalesRepository {
  Future<void> addSale(Sale sale) async {
    print('--- MOCK: SALE SAVED ---');
    print('ID: ${sale.id}');
    print('Total: \$${sale.totalAmount}');
    print('Items: ${sale.items.length}');
    print('------------------------');
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
