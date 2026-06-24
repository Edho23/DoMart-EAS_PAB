import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  static const _boxName = 'cart_box';

  @override
  List<CartItem> build() {
    _loadFromHive();
    return [];
  }

  Future<void> _loadFromHive() async {
    final box = await Hive.openBox(_boxName);
    final saved = box.get('items');
    if (saved == null) return;
    state = (saved as List).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final product = Product.fromMap(map['productId'], Map<String, dynamic>.from(map['product']));
      return CartItem(product: product, qty: map['qty']);
    }).toList();
  }

  Future<void> _persist() async {
    final box = await Hive.openBox(_boxName);
    await box.put('items', state.map((item) => {
          'productId': item.product.id,
          'product': item.product.toMap(),
          'qty': item.qty,
        }).toList());
  }

  void addProduct(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(qty: updated[index].qty + 1);
      state = updated;
    } else {
      state = [...state, CartItem(product: product, qty: 1)];
    }
    _persist();
  }

  void updateQty(String productId, int qty) {
    if (qty <= 0) return removeProduct(productId);
    state = state.map((item) => item.product.id == productId ? item.copyWith(qty: qty) : item).toList();
    _persist();
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
    _persist();
  }

  void clear() {
    state = [];
    _persist();
  }

  double get total => state.fold(0, (sum, item) => sum + item.subtotal);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);