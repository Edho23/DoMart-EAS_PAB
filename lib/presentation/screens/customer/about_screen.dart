import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tentang DoMart', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE85D2C).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_rounded, size: 80, color: Color(0xFFE85D2C)),
              ),
              const SizedBox(height: 24),
              const Text('DoMart', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Versi 1.0.0', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 24),
              const Text(
                'DoMart adalah platform e-commerce yang didedikasikan untuk membantu UMKM lokal mengembangkan jangkauan pasar mereka ke ranah digital. Dibangun dengan fokus pada kemudahan penggunaan dan desain yang minimalis.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}