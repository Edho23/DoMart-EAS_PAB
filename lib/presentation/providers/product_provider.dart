import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/product_local_cache.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'auth_provider.dart';

final productLocalCacheProvider = Provider((ref) => ProductLocalCache());

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    ref.watch(realtimeApiClientProvider),
    ref.watch(productLocalCacheProvider),
  );
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(productRepositoryProvider).getProducts();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  return productsAsync.maybeWhen(
    data: (products) =>
        query.isEmpty ? products : products.where((p) => p.name.toLowerCase().contains(query)).toList(),
    orElse: () => [],
  );
});