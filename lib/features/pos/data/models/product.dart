class Product {
  final String id;
  final String name;
  final String barcode;
  final double price;
  final int stockQty;
  final String category;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stockQty,
    required this.category,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'price': price,
      'stock_qty': stockQty,
      'category': category,
      'image_url': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      barcode: map['barcode'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      stockQty: map['stock_qty'] ?? 0,
      category: map['category'] ?? '',
      imageUrl: map['image_url'],
    );
  }
}
