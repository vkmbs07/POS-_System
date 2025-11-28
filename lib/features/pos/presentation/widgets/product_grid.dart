import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import '../../domain/providers/cart_provider.dart';
import '../../data/models/product.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(child: Text('No products found. Add some in Inventory.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ref.read(cartProvider.notifier).addProduct(product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.shopping_bag, size: 48, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
