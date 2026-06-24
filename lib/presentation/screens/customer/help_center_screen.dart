import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F1),
      appBar: AppBar(
        title: const Text('Pusat Bantuan', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFaqItem('Bagaimana cara melacak pesanan?', 'Anda dapat melihat status pesanan melalui tab "Pesanan" di menu utama. Status akan diperbarui oleh penjual.'),
          const SizedBox(height: 12),
          _buildFaqItem('Metode pembayaran apa saja yang tersedia?', 'Saat ini DoMart mendukung pembayaran melalui Transfer Bank dan QRIS.'),
          const SizedBox(height: 12),
          _buildFaqItem('Bagaimana jika pesanan saya tidak sampai?', 'Anda dapat menghubungi layanan pelanggan kami melalui email di support@domart.com dengan menyertakan nomor pesanan Anda.'),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(answer, style: const TextStyle(color: Colors.black54, height: 1.5)),
          ),
        ],
      ),
    );
  }
}