import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_provider.dart';
import '../../providers/seller_provider.dart';

class SellerOrderScreen extends ConsumerWidget {
  const SellerOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F1),
      appBar: AppBar(
        title: const Text('Pesanan Masuk', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        backgroundColor: Colors.white, elevation: 0,
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) return const Center(child: Text('Belum ada pesanan', style: TextStyle(color: Colors.black54)));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              final isSuccess = order.status == 'success';
              final isSent = order.status == 'dikirim';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ID: ${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSent ? const Color(0xFFE3F2FD) : (isSuccess ? const Color(0xFFEAF3DE) : const Color(0xFFFCEBEB)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSent ? 'Sedang Dikirim' : (isSuccess ? 'Perlu Dikirim' : 'Gagal/Pending'),
                            style: TextStyle(
                                color: isSent ? Colors.blue.shade700 : (isSuccess ? const Color(0xFF3B6D11) : const Color(0xFFA32D2D)),
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${item.name} x${item.qty}'),
                        )),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total: Rp${order.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (isSuccess) // Tombol Kirim hanya muncul jika statusnya success (sudah dibayar)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE85D2C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            onPressed: () async {
                              await ref.read(orderRepositoryProvider).updateOrderStatus(order.id, 'dikirim');
                              ref.invalidate(sellerOrdersProvider); // Refresh data
                            },
                            child: const Text('Kirim Barang', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Gagal memuat: $e')),
      ),
    );
  }
}