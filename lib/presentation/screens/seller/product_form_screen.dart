import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/product.dart';
import '../../providers/product_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? existingProduct;
  const ProductFormScreen({super.key, this.existingProduct});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.existingProduct?.name);
  late final _descController = TextEditingController(text: widget.existingProduct?.description);
  late final _priceController = TextEditingController(text: widget.existingProduct?.price.toStringAsFixed(0));
  late final _stockController = TextEditingController(text: widget.existingProduct?.stock.toString());
  late final _discountController = TextEditingController(text: widget.existingProduct?.discountPercent.toString() ?? '0');

  String? _imageBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _imageBase64 = widget.existingProduct?.imageBase64;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 800, imageQuality: 70);
    if (picked == null) return;
    final bytes = await File(picked.path).readAsBytes();
    setState(() => _imageBase64 = base64Encode(bytes));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final product = Product(
      id: widget.existingProduct?.id ?? '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      discountPercent: int.tryParse(_discountController.text) ?? 0,
      imageBase64: _imageBase64,
    );

    final repo = ref.read(productRepositoryProvider);
    if (widget.existingProduct == null) {
      await repo.addProduct(product);
    } else {
      await repo.updateProduct(widget.existingProduct!.id, product.toMap());
    }
    ref.invalidate(productsProvider);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingProduct == null ? 'Tambah produk' : 'Edit produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_camera),
                          title: const Text('Ambil foto'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Pilih dari galeri'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(color: const Color(0xFFF1EFE8), borderRadius: BorderRadius.circular(14)),
                  child: _imageBase64 != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.memory(base64Decode(_imageBase64!), fit: BoxFit.cover))
                      : const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.black38),
                              SizedBox(height: 6),
                              Text('Tambah foto produk', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama produk', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder())),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga (Rp)', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(controller: _discountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Diskon (%)', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE85D2C), padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}