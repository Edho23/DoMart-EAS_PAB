import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import 'auth_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(realtimeApiClientProvider));
});

final userOrdersProvider = FutureProvider.family<List<AppOrder>, String>((ref, userId) async {
  return ref.watch(orderRepositoryProvider).getOrdersByUser(userId);
});