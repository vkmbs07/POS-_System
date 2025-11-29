import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/providers/cart_provider.dart';
import '../../../../core/services/bluetooth_service.dart';
import '../../../../core/utils/receipt_generator.dart';
import '../../data/repositories/sales_repository.dart';
import '../../data/models/sale.dart';

class CartWidget extends ConsumerWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black,
          width: double.infinity,
          child: const Text(
            'Current Bill',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        
        // List
        Expanded(
          child: cartItems.isEmpty
              ? const Center(child: Text('Cart is empty'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  separatorBuilder: (ctx, i) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => cartNotifier.decrementProduct(item.product),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('${item.quantity}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => cartNotifier.addProduct(item.product),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('x \$${item.product.price.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${item.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => cartNotifier.removeProduct(item.product),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Total & Actions
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: const Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 24)),
                  Text(
                    '\$${cartNotifier.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => cartNotifier.clearCart(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: cartItems.isEmpty ? null : () async {
                        final bluetooth = ref.read(bluetoothServiceProvider);
                        final salesRepo = ref.read(salesRepositoryProvider);
                        final generator = ReceiptGenerator();
                        
                        // Create Sale Object
                        final saleId = const Uuid().v4();
                        final sale = Sale(
                          id: saleId,
                          timestamp: DateTime.now(),
                          items: cartItems.map((item) => SaleItem(
                            productId: item.product.id,
                            productName: item.product.name,
                            quantity: item.quantity,
                            price: item.product.price,
                            total: item.total,
                          )).toList(),
                          totalAmount: cartNotifier.totalAmount,
                          paymentMethod: 'CASH', // Default for now
                        );

                        // Save to Firestore
                        try {
                          await salesRepo.addSale(sale);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error saving sale: $e')),
                            );
                          }
                          return;
                        }

                        // Try to connect & Print
                        // Note: In a real app, we might want to separate printing from saving
                        // or handle print failures more gracefully without blocking the flow.
                        try {
                          final connected = await bluetooth.connect();
                          if (connected) {
                            final bytes = generator.generateReceipt(cartItems, cartNotifier.totalAmount);
                            await bluetooth.printData(bytes);
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sale Saved & Receipt Sent')),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sale Saved. Printer Connection Failed')),
                              );
                            }
                          }
                        } catch (e) {
                           if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Printer Error: $e')),
                              );
                            }
                        }
                        
                        // Clear cart
                        cartNotifier.clearCart();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('CHECKOUT & PRINT'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
