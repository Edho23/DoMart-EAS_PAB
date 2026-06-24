import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order.dart';
import 'order_provider.dart';

// Mengambil seluruh pesanan yang masuk
final sellerOrdersProvider = FutureProvider.autoDispose<List<AppOrder>>((ref) async {
  return ref.watch(orderRepositoryProvider).getAllOrders();
});

// Menghitung ringkasan pendapatan dari pesanan yang berhasil
final sellerIncomeProvider = Provider.autoDispose<double>((ref) {
  final ordersAsync = ref.watch(sellerOrdersProvider);
  return ordersAsync.maybeWhen(
    data: (orders) {
      return orders
          .where((o) => o.status == 'success' || o.status == 'dikirim' || o.status == 'selesai')
          .fold(0.0, (sum, order) => sum + order.total);
    },
    orElse: () => 0.0,
  );
});