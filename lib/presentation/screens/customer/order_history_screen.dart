import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F1),
      appBar: AppBar(title: const Text('Riwayat pesanan')),
      body: authAsync.when(
        data: (user) {
          if (user == null) return const SizedBox();
          final ordersAsync = ref.watch(userOrdersProvider(user.uid));
          return ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) return const Center(child: Text('Belum ada pesanan'));
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final isSuccess = order.status == 'success';
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(order.createdAt.substring(0, 16).replaceFirst('T', ' '))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSuccess ? const Color(0xFFEAF3DE) : const Color(0xFFFCEBEB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(isSuccess ? 'Sukses' : 'Gagal',
                                  style: TextStyle(color: isSuccess ? const Color(0xFF3B6D11) : const Color(0xFFA32D2D), fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const Divider(),
                        ...order.items.map((item) => Text('${item.name} x${item.qty}')),
                        const SizedBox(height: 6),
                        Text('Total: Rp${order.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Metode: ${order.paymentMethod}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Gagal memuat: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}