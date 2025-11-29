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
    bytes += _text('123 Market Street\n');
    bytes += _text('Tel: 555-0123\n\n');

    // Left Align
    bytes += [_esc, 97, 0];
    bytes += _text('Date: ${DateTime.now().toString().substring(0, 16)}\n');
    bytes += _text('--------------------------------\n');
    bytes += _text('Item              Qty    Total\n');
    bytes += _text('--------------------------------\n');

    // Items
    for (var item in items) {
      // Name line
      bytes += _text('${item.product.name}\n');
      
      // Qty x Price line with Total aligned right
      String qtyPrice = '${item.quantity} x ${item.product.price.toStringAsFixed(2)}';
      String totalStr = item.total.toStringAsFixed(2);
      
      // Simple padding logic (assuming 32 chars width)
      // This is a naive implementation, real printers vary.
      // We'll just put spaces between.
      int padding = 32 - qtyPrice.length - totalStr.length;
      if (padding < 1) padding = 1;
      
      bytes += _text(qtyPrice + (' ' * padding) + totalStr + '\n');
    }

    bytes += _text('--------------------------------\n');
    
    // Total (Bold)
    bytes += [_esc, 69, 1];
    String totalLabel = 'TOTAL';
    String totalValue = '\$${total.toStringAsFixed(2)}';
    int totalPadding = 32 - totalLabel.length - totalValue.length;
    if (totalPadding < 1) totalPadding = 1;
    
    bytes += _text(totalLabel + (' ' * totalPadding) + totalValue + '\n');
    bytes += [_esc, 69, 0];

    // Footer
    bytes += [_esc, 97, 1];
    bytes += _text('\nThank you for shopping!\n');
    bytes += _text('Please come again\n');
    bytes += _text('\n\n\n'); // Feed

    // Cut
    bytes += [_gs, 86, 66, 0];

    return bytes;
  }

  List<int> _text(String text) {
    return text.codeUnits;
  }
}
