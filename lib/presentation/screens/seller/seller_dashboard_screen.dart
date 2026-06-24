import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../providers/seller_provider.dart';
import 'product_form_screen.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final income = ref.watch(sellerIncomeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F1),
      appBar: AppBar(
        title: const Text('Dasbor UMKM', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        backgroundColor: Colors.white, elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE85D2C),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          ref.invalidate(sellerOrdersProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Kartu Ringkasan Finansial
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFE85D2C), Color(0xFFD64A1A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFFE85D2C).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pendapatan', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Rp${income.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Saldo bisa ditarik', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Etalase Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            productsAsync.when(
              data: (products) => products.isEmpty
                  ? const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text('Belum ada produk, tambahkan sekarang!')))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 60, height: 60,
                                  child: product.imageBase64 != null
                                      ? Image.memory(base64Decode(product.imageBase64!), fit: BoxFit.cover)
                                      : Container(color: const Color(0xFFF1EFE8), child: const Icon(Icons.image_outlined, color: Colors.black26)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Rp${product.price.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFE85D2C), fontSize: 13, fontWeight: FontWeight.w500)),
                                    Text('Stok: ${product.stock}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.black54),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormScreen(existingProduct: product))),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}