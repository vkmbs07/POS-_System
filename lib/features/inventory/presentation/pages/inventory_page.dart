import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pos/data/repositories/product_repository.dart';
import '../../../pos/data/models/product.dart';
import 'package:uuid/uuid.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body: productsAsync.when(
        data: (products) => ListView.separated(
          itemCount: products.length,
          separatorBuilder: (ctx, i) => const Divider(),
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                color: Colors.grey[200],
                child: product.imageUrl != null
                    ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.image),
              ),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Barcode: ${product.barcode} | Stock: ${product.stockQty}'),
              trailing: Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              onTap: () => _showProductDialog(context, ref, product: product),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProductDialog(BuildContext context, WidgetRef ref, {Product? product}) {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(ref: ref, product: product),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final WidgetRef ref;
  final Product? product;

  const _ProductDialog({required this.ref, this.product});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _barcodeCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _categoryCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _barcodeCtrl = TextEditingController(text: widget.product?.barcode ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockCtrl = TextEditingController(text: widget.product?.stockQty.toString() ?? '');
    _categoryCtrl = TextEditingController(text: widget.product?.category ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _barcodeCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _barcodeCtrl,
                decoration: const InputDecoration(labelText: 'Barcode'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(labelText: 'Stock Qty'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final id = widget.product?.id ?? const Uuid().v4();
      final product = Product(
        id: id,
        name: _nameCtrl.text,
        barcode: _barcodeCtrl.text,
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        stockQty: int.tryParse(_stockCtrl.text) ?? 0,
        category: _categoryCtrl.text,
        imageUrl: widget.product?.imageUrl, // Keep existing or null
      );

      widget.ref.read(productRepositoryProvider).addProduct(product);
      Navigator.pop(context);
    }
  }
}
