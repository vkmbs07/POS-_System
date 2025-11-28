import 'dart:typed_data';
import '../../features/pos/domain/providers/cart_provider.dart';

class ReceiptGenerator {
  // ESC/POS Commands
  static const int _esc = 27;
  static const int _gs = 29;
  static const int _lf = 10;

  List<int> generateReceipt(List<CartItem> items, double total) {
    List<int> bytes = [];

    // Init
    bytes += [_esc, 64];

    // Center Align
    bytes += [_esc, 97, 1];
    bytes += _text('RETAIL SHOP\n');
    bytes += _text('123 Market Street\n\n');

    // Left Align
    bytes += [_esc, 97, 0];
    bytes += _text('Date: ${DateTime.now().toString().substring(0, 16)}\n');
    bytes += _text('--------------------------------\n');

    // Items
    for (var item in items) {
      bytes += _text('${item.product.name}\n');
      bytes += _text('${item.quantity} x ${item.product.price} = ${item.total}\n');
    }

    bytes += _text('--------------------------------\n');
    
    // Total (Bold)
    bytes += [_esc, 69, 1];
    bytes += _text('TOTAL: \$${total.toStringAsFixed(2)}\n');
    bytes += [_esc, 69, 0];

    // Footer
    bytes += [_esc, 97, 1];
    bytes += _text('\nThank you for shopping!\n');
    bytes += _text('\n\n\n'); // Feed

    // Cut
    bytes += [_gs, 86, 66, 0];

    return bytes;
  }

  List<int> _text(String text) {
    return text.codeUnits;
  }
}
