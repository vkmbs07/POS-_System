import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/data/repositories/firebase_auth_repository.dart';
import '../controllers/scanner_controller.dart';
import '../widgets/usb_scanner_listener.dart';
import '../widgets/camera_scanner_widget.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_widget.dart';

class PosPage extends ConsumerWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerMode = ref.watch(scannerModeProvider);

    return UsbScannerListener(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('POS Terminal'),
          actions: [
            // Scanner Toggle
            Switch(
              value: scannerMode == ScannerMode.camera,
              onChanged: (value) {
                ref.read(scannerModeProvider.notifier).state = 
                    value ? ScannerMode.camera : ScannerMode.usb;
              },
              activeColor: Colors.black,
              activeTrackColor: Colors.grey,
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: Text('Camera Mode', style: TextStyle(color: Colors.black))),
            ),
            IconButton(
              icon: const Icon(Icons.inventory),
              onPressed: () {
                context.push('/inventory');
              },
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                context.push('/reports');
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.push('/settings');
              },
            ),
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                context.push('/employees');
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authRepositoryProvider).signOut();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (scannerMode == ScannerMode.camera)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CameraScannerWidget()),
              ),
            Expanded(
              child: Row(
                children: [
                  // Left: Product Grid
                  const Expanded(
                    flex: 3,
                    child: ProductGrid(),
                  ),
                  // Right: Cart
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.black12)),
                      ),
                      child: const CartWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _ManualEntryDialog(ref: ref),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      ),
    );
  }
}

class _ManualEntryDialog extends StatefulWidget {
  final WidgetRef ref;
  const _ManualEntryDialog({required this.ref});

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manual Entry'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Enter Barcode',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('ADD'),
        ),
      ],
    );
  }

  void _submit() {
    final barcode = _controller.text.trim();
    if (barcode.isNotEmpty) {
      widget.ref.read(scannerControllerProvider.notifier).onScan(barcode);
      Navigator.pop(context);
    }
  }
}
