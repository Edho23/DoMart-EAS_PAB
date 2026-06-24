import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black, title: const Text('Detail produk')),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 260,
                      width: double.infinity,
                      color: const Color(0xFFF1EFE8),
                      child: product.imageBase64 != null
                          ? Image.memory(base64Decode(product.imageBase64!), fit: BoxFit.cover)
                          : const Icon(Icons.image_outlined, size: 60, color: Colors.black26),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Rp${product.finalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE85D2C))),
                              if (product.hasDiscount) ...[
                                const SizedBox(width: 8),
                                Text('Rp${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black38)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.isOutOfStock ? 'Stok habis' : 'Stok tersedia: ${product.stock}',
                            style: TextStyle(color: product.isOutOfStock ? Colors.red : Colors.black54),
                          ),
                          const Divider(height: 32),
                          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          Text(product.description.isEmpty ? 'Tidak ada deskripsi' : product.description,
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!product.isOutOfStock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          IconButton(onPressed: () => setState(() => qty = qty > 1 ? qty - 1 : 1), icon: const Icon(Icons.remove, size: 18)),
                          Text('$qty', style: const TextStyle(fontWeight: FontWeight.w500)),
                          IconButton(
                              onPressed: () => setState(() => qty = qty < product.stock ? qty + 1 : qty),
                              icon: const Icon(Icons.add, size: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE85D2C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          for (var i = 0; i < qty; i++) {
                            ref.read(cartProvider.notifier).addProduct(product);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} ditambahkan ke keranjang')));
                          Navigator.pop(context);
                        },
                        child: const Text('Tambah ke keranjang', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}