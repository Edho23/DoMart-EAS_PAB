import 'product.dart';

class CartItem {
  final Product product;
  final int qty;

  CartItem({required this.product, required this.qty});

  double get subtotal => product.finalPrice * qty;
  CartItem copyWith({int? qty}) => CartItem(product: product, qty: qty ?? this.qty);
}