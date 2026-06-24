import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'edit_profile_screen.dart';
import 'shipping_address_screen.dart';
import 'help_center_screen.dart';
import 'about_screen.dart';

class CustomerShell extends ConsumerStatefulWidget {
  const CustomerShell({super.key});

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  int _index = 0;
  final _screens = const [HomeScreen(), CartScreen(), OrderHistoryScreen(), _ProfileTab()];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider.select((items) => items.fold(0, (s, i) => s + i.qty)));

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Home'),
          NavigationDestination(
            icon: Badge(label: Text('$cartCount'), isLabelVisible: cartCount > 0, child: const Icon(Icons.shopping_cart_outlined)),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Pesanan'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F1),
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: authAsync.when(
        data: (user) => SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFFE85D2C).withValues(alpha: 0.1),
                      child: Text(
                        user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE85D2C)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.name ?? 'Pengguna DoMart', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(user?.email ?? '-', style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.black54),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: user))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: Colors.black54),
                      title: const Text('Alamat Pengiriman'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingAddressScreen())),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: Colors.black54),
                      title: const Text('Pusat Bantuan'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen())),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.black54),
                      title: const Text('Tentang DoMart'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Keluar Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}