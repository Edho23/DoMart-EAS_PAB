import 'package:firebase_auth/firebase_auth.dart';
import '../../core/network/realtime_api_client.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../local/product_local_cache.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RealtimeApiClient _apiClient;
  final ProductLocalCache _cache;

  ProductRepositoryImpl(this._apiClient, this._cache);

  Future<String?> _token() => FirebaseAuth.instance.currentUser?.getIdToken() ?? Future.value(null);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final token = await _token();
      final data = await _apiClient.get('products', idToken: token);
      final products = <Product>[];
      if (data is Map) {
        data.forEach((key, value) => products.add(Product.fromMap(key, value as Map)));
      }
      await _cache.saveProducts(products);
      return products;
    } catch (_) {
      return _cache.getProducts();
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    final token = await _token();
    final data = await _apiClient.get('products/$id', idToken: token);
    if (data == null) return null;
    return Product.fromMap(id, data as Map);
  }

  @override
  Future<void> addProduct(Product product) async {
    final token = await _token();
    await _apiClient.post('products', product.toMap(), idToken: token);
  }

  @override
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final token = await _token();
    await _apiClient.patch('products/$id', data, idToken: token);
  }

  @override
  Future<void> decrementStock(String id, int qty) async {
    final current = await getProductById(id);
    if (current == null) return;
    final newStock = current.stock - qty;
    await updateProduct(id, {'stock': newStock < 0 ? 0 : newStock});
  }

  @override
  Future<void> deleteProduct(String id) async {
    final token = await _token();
    await _apiClient.delete('products/$id', idToken: token);
  }
}