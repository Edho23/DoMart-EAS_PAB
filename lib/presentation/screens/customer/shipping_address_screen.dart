import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class ShippingAddressScreen extends ConsumerStatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  ConsumerState<ShippingAddressScreen> createState() =>
      _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends ConsumerState<ShippingAddressScreen> {
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
      final user = await ref.read(authStateProvider.future);
      if (user != null) {
        // Gunakan instanceFor dan masukkan URL dari AppConstants
        final snapshot = await FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: AppConstants.databaseUrl)
            .ref()
            .child('users')
            .child(user.uid)
            .child('address')
            .get();
        if (snapshot.exists) {
          _addressController.text = snapshot.value.toString();
        }
      }
    }

  Future<void> _saveAddress() async {
      setState(() => _isLoading = true);
      try {
        final user = await ref.read(authStateProvider.future);
        if (user != null) {
          // Gunakan instanceFor dan masukkan URL dari AppConstants
          await FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: AppConstants.databaseUrl)
              .ref()
              .child('users')
              .child(user.uid)
              .update({'address': _addressController.text.trim()});
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat berhasil disimpan')));
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan alamat')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Alamat Pengiriman',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Detail Alamat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Contoh: Kos, Jl. Semolowaru Utara No. 12, RT 01/RW 02...',
                filled: true,
                fillColor: const Color(0xFFF6F5F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D2C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan Alamat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
