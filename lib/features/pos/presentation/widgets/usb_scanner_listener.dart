import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/scanner_controller.dart';

class UsbScannerListener extends ConsumerStatefulWidget {
  final Widget child;
  const UsbScannerListener({super.key, required this.child});

  @override
  ConsumerState<UsbScannerListener> createState() => _UsbScannerListenerState();
}

class _UsbScannerListenerState extends ConsumerState<UsbScannerListener> {
  final FocusNode _focusNode = FocusNode();
  final StringBuffer _buffer = StringBuffer();
  DateTime? _lastKeystrokeTime;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final String? char = event.character;
      
      // Check for Enter key to submit
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_buffer.isNotEmpty) {
          ref.read(scannerControllerProvider.notifier).onScan(_buffer.toString());
          _buffer.clear();
        }
        return;
      }

      if (char != null) {
        // Check for rapid input (typical of scanners)
        // If too much time passed, reset buffer (manual typing vs scan)
        final now = DateTime.now();
        if (_lastKeystrokeTime != null && 
            now.difference(_lastKeystrokeTime!).inMilliseconds > 100) {
          _buffer.clear();
        }
        
        _buffer.write(char);
        _lastKeystrokeTime = now;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure focus is kept for listening
    if (!_focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
