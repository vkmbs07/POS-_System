import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/reports_repository.dart';
import '../../pos/data/models/sale.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(dailySalesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Reports')),
      body: salesAsync.when(
        data: (sales) {
          final totalAmount = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
          final totalOrders = sales.length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    _SummaryCard(
                      title: 'Total Sales',
                      value: '\$${totalAmount.toStringAsFixed(2)}',
                      color: Colors.blue,
                      icon: Icons.attach_money,
                    ),
                    const SizedBox(width: 16),
                    _SummaryCard(
                      title: 'Total Orders',
                      value: totalOrders.toString(),
                      color: Colors.orange,
                      icon: Icons.shopping_cart,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Transaction List
                Expanded(
                  child: ListView.builder(
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return Card(
                        child: ListTile(
                          title: Text('Order #${sale.id.substring(0, 8)}...'),
                          subtitle: Text(sale.timestamp.toString().substring(0, 16)),
                          trailing: Text(
                            '\$${sale.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
