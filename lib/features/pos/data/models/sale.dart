import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
    );
  }
}

class Sale {
  final String id;
  final DateTime timestamp;
  final List<SaleItem> items;
  final double totalAmount;
  final String paymentMethod;

  Sale({
    required this.id,
    required this.timestamp,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp),
      'items': items.map((x) => x.toMap()).toList(),
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, String id) {
    return Sale(
      id: id,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      items: List<SaleItem>.from(
        (map['items'] as List<dynamic>).map<SaleItem>(
          (x) => SaleItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
      totalAmount: (map['total_amount'] ?? 0.0).toDouble(),
      paymentMethod: map['payment_method'] ?? 'CASH',
    );
  }
}
