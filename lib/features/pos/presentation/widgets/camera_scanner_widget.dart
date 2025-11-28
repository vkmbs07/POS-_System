import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/scanner_controller.dart';

class CameraScannerWidget extends ConsumerWidget {
  const CameraScannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 200,
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                ref.read(scannerControllerProvider.notifier).onScan(barcode.rawValue!);
                // Add a small delay or debounce if needed to prevent multiple scans
              }
            }
          },
        ),
      ),
    );
  }
}
