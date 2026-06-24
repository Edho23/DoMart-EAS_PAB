import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final filtered = ref.watch(filteredProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F1),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(productsProvider);
            await ref.read(productsProvider.future);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFE85D2C), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.storefront, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          const Text('DoMart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Belanja produk UMKM lokal favoritmu', style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (value) => ref.read(searchQueryProvider.notifier).update(value),
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              productsAsync.when(
                data: (_) => filtered.isEmpty
                    ? const SliverFillRemaining(child: Center(child: Text('Produk tidak ditemukan')))
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = filtered[index];
                              return ProductCard(
                                product: product,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                                ),
                                onAddToCart: product.isOutOfStock
                                    ? null
                                    : () {
                                        ref.read(cartProvider.notifier).addProduct(product);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text('${product.name} ditambahkan ke keranjang')));
                                      },
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      ),
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error: (e, st) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off, size: 40, color: Colors.black38),
                        const SizedBox(height: 8),
                        const Text('Gagal memuat produk dari server'),
                        TextButton(onPressed: () => ref.invalidate(productsProvider), child: const Text('Coba lagi')),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}