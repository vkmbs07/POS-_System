import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../pos/data/models/product.dart';
import '../controllers/product_controller.dart';

class AddEditProductPage extends ConsumerStatefulWidget {
  final Product? product;

  const AddEditProductPage({super.key, this.product});

  @override
  ConsumerState<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends ConsumerState<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _barcodeController = TextEditingController(text: widget.product?.barcode);
    _priceController = TextEditingController(text: widget.product?.price.toString());
    _stockController = TextEditingController(text: widget.product?.stockQty.toString());
    _categoryController = TextEditingController(text: widget.product?.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final barcode = _barcodeController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;
      final category = _categoryController.text.trim();

      if (widget.product == null) {
        // Add new product
        final newProduct = Product(
          id: const Uuid().v4(),
          name: name,
          barcode: barcode,
          price: price,
          stockQty: stock,
          category: category,
        );
        await ref.read(productControllerProvider.notifier).addProduct(newProduct);
      } else {
        // Update existing product
        final updatedProduct = Product(
          id: widget.product!.id,
          name: name,
          barcode: barcode,
          price: price,
          stockQty: stock,
          category: category,
          imageUrl: widget.product!.imageUrl,
        );
        await ref.read(productControllerProvider.notifier).updateProduct(updatedProduct);
      }

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(productControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    final isLoading = ref.watch(productControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(labelText: 'Barcode'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter barcode' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter price';
                        if (double.tryParse(value) == null) return 'Invalid price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stock Qty'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter stock';
                        if (int.tryParse(value) == null) return 'Invalid stock';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter category' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.product == null ? 'ADD PRODUCT' : 'UPDATE PRODUCT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
