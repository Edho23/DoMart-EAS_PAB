import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(String id, Map<String, dynamic> data);
  Future<void> decrementStock(String id, int qty);
  Future<void> deleteProduct(String id);
}