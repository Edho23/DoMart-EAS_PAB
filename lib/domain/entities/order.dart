class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int qty;

  OrderItem({required this.productId, required this.name, required this.price, required this.qty});

  Map<String, dynamic> toMap() => {'productId': productId, 'name': name, 'price': price, 'qty': qty};
}

class AppOrder {
  final String id; // <-- Variabel baru untuk melacak pesanan
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String status;
  final String paymentMethod;
  final String createdAt;

  AppOrder({
    this.id = '', // Default kosong untuk pesanan baru dari customer
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'items': items.map((e) => e.toMap()).toList(),
        'total': total,
        'status': status,
        'paymentMethod': paymentMethod,
        'createdAt': createdAt,
      };
}