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
      appBar: AppBar(
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: authAsync.when(
        data: (user) {
          if (user == null) return const SizedBox();
          final ordersAsync = ref.watch(userOrdersProvider(user.uid));

          return RefreshIndicator(
            color: const Color(0xFFE85D2C),
            // Fitur untuk menarik layar ke bawah agar data pesanan terbaru dari seller muncul
            onRefresh: () async => ref.invalidate(userOrdersProvider(user.uid)),
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text(
                          'Belum ada pesanan',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    // Logika penentuan warna dan teks status
                    String statusText = 'Pending';
                    Color statusColor = Colors.grey;
                    Color statusBg = Colors.grey.shade200;

                    if (order.status == 'success') {
                      statusText = 'Dikemas';
                      statusColor = const Color(0xFFD68B00);
                      statusBg = const Color(0xFFFFF4E5);
                    } else if (order.status == 'dikirim') {
                      statusText = 'Sedang Dikirim';
                      statusColor = Colors.blue.shade700;
                      statusBg = const Color(0xFFE3F2FD);
                    } else if (order.status == 'selesai') {
                      statusText = 'Selesai';
                      statusColor = const Color(0xFF3B6D11);
                      statusBg = const Color(0xFFEAF3DE);
                    } else {
                      statusText = 'Gagal';
                      statusColor = const Color(0xFFA32D2D);
                      statusBg = const Color(0xFFFCEBEB);
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.createdAt
                                      .substring(0, 16)
                                      .replaceFirst('T', ' '),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ...order.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('${item.name} x${item.qty}'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total: Rp${order.total.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Metode: ${order.paymentMethod}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              // Tombol ini HANYA MUNCUL jika seller sudah menekan "Kirim Barang"
                              if (order.status == 'dikirim')
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE85D2C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  onPressed: () async {
                                    // Mengubah status pesanan menjadi selesai
                                    await ref
                                        .read(orderRepositoryProvider)
                                        .updateOrderStatus(order.id, 'selesai');
                                    // Me-refresh layar otomatis
                                    ref.invalidate(
                                      userOrdersProvider(user.uid),
                                    );
                                  },
                                  child: const Text(
                                    'Pesanan Diterima',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
