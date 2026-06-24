class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int discountPercent;
  final String? imageBase64;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.discountPercent = 0,
    this.imageBase64,
  });

  double get finalPrice => price - (price * discountPercent / 100);
  bool get isOutOfStock => stock <= 0;
  bool get hasDiscount => discountPercent > 0;

  factory Product.fromMap(String id, Map map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0,
      stock: (map['stock'] is num) ? (map['stock'] as num).toInt() : 0,
      discountPercent: (map['discountPercent'] is num) ? (map['discountPercent'] as num).toInt() : 0,
      imageBase64: map['imageBase64'],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'discountPercent': discountPercent,
        'imageBase64': imageBase64,
      };
}