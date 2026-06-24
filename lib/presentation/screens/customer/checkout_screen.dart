import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _method = 'Transfer Bank';

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);
    final total = ref.read(cartProvider.notifier).total;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ringkasan pesanan', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ...cart.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [Expanded(child: Text('${item.product.name} x${item.qty}')), Text('Rp${item.subtotal.toStringAsFixed(0)}')]),
                )),
            const Divider(height: 24),
            Row(
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text('Rp${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFE85D2C))),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Metode pembayaran', style: TextStyle(fontWeight: FontWeight.w500)),
            ...['Transfer Bank', 'QRIS', 'Bayar di Tempat (COD)'].map(
              (method) => RadioListTile(
                value: method,
                groupValue: _method,
                onChanged: (value) => setState(() => _method = value!),
                title: Text(method),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Spacer(),
            if (checkoutState.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(checkoutState.error.toString().replaceFirst('Exception: ', ''), style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85D2C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: checkoutState.isLoading
                    ? null
                    : () async {
                        final success = await ref.read(checkoutControllerProvider.notifier).checkout(_method);
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(success ? 'Pembayaran berhasil' : 'Pembayaran gagal'),
                            content: Text(success ? 'Pesananmu sedang diproses oleh DoMart.' : 'Simulasi gateway gagal, coba lagi ya.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (success) Navigator.popUntil(context, (route) => route.isFirst);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                child: checkoutState.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Bayar sekarang', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}