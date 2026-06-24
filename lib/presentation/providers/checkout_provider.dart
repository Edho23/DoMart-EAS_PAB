import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';
import 'order_provider.dart';
import 'product_provider.dart';

class CheckoutController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> checkout(String paymentMethod) async {
    state = const AsyncValue.loading();
    try {
      final cart = ref.read(cartProvider);
      if (cart.isEmpty) throw Exception('Keranjang kosong');

      final user = await ref.read(authStateProvider.future);
      if (user == null) throw Exception('Sesi habis, silakan login ulang');

      await Future.delayed(const Duration(seconds: 2)); // simulasi proses gateway
      final isSuccess = DateTime.now().millisecondsSinceEpoch % 10 != 0; // ~90% sukses

      final order = AppOrder(
        userId: user.uid,
        items: cart
            .map((item) => OrderItem(
                  productId: item.product.id,
                  name: item.product.name,
                  price: item.product.finalPrice,
                  qty: item.qty,
                ))
            .toList(),
        total: cart.fold(0.0, (sum, item) => sum + item.subtotal),
        status: isSuccess ? 'success' : 'failed',
        paymentMethod: paymentMethod,
        createdAt: DateTime.now().toIso8601String(),
      );

      await ref.read(orderRepositoryProvider).createOrder(order);

      if (isSuccess) {
        final productRepo = ref.read(productRepositoryProvider);
        for (final item in cart) {
          await productRepo.decrementStock(item.product.id, item.qty);
        }
        ref.read(cartProvider.notifier).clear();
        ref.invalidate(productsProvider);
      }

      state = const AsyncValue.data(null);
      return isSuccess;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, AsyncValue<void>>(CheckoutController.new);