import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

class ProductLocalCache {
  static const _boxName = 'products_cache';

  Future<void> saveProducts(List<Product> products) async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
    for (final p in products) {
      await box.put(p.id, p.toMap()..['id'] = p.id);
    }
  }

  Future<List<Product>> getProducts() async {
    final box = await Hive.openBox(_boxName);
    return box.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return Product.fromMap(map['id'], map);
    }).toList();
  }
}