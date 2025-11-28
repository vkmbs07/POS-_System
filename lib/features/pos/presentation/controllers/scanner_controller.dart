import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/cart_provider.dart';
import '../../data/repositories/product_repository.dart';

// State to track scanner mode
enum ScannerMode { camera, usb }

final scannerModeProvider = StateProvider<ScannerMode>((ref) => ScannerMode.usb);

class ScannerController extends StateNotifier<void> {
  final Ref ref;

  ScannerController(this.ref) : super(null);

  Future<void> onScan(String barcode) async {
    if (barcode.isEmpty) return;

    // Find product by barcode
    // Note: In a real app, we might want to optimize this lookup 
    // (e.g., map or specific query) rather than filtering the stream list.
    final productsAsync = ref.read(productsStreamProvider);
    
    productsAsync.whenData((products) {
      try {
        final product = products.firstWhere((p) => p.barcode == barcode);
        ref.read(cartProvider.notifier).addProduct(product);
        // Optional: Play beep sound or show snackbar
      } catch (e) {
        // Product not found
        // Show error or prompt to add new product
        print('Product not found for barcode: $barcode');
      }
    });
  }
}

final scannerControllerProvider = StateNotifierProvider<ScannerController, void>((ref) {
  return ScannerController(ref);
});
