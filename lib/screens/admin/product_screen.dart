import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/admin_scaffold.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();

    return AdminScaffold(
      title: 'Daftar Barang',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari barang...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      productController.searchQuery.value = value;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showProductDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.text,
                    foregroundColor: AppTheme.surface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final products = productController.filteredProducts;

                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada barang',
                      style: TextStyle(color: AppTheme.text2),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = products[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: AppTheme.radiusLarge,
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Text(
                            p.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.kode} • ${p.kategori}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.text2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Beli: ${Formatter.rupiah(p.hargaBeli)} | Jual: ${Formatter.rupiah(p.hargaJual)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.text2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Stok ${p.stok}',
                                style: TextStyle(
                                  color: p.stok <= 5 ? AppTheme.red : AppTheme.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _showProductDialog(
                                      context,
                                      product: p,
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      productController.deleteProduct(p.id);
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppTheme.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext context, {ProductModel? product}) {
    final productController = Get.find<ProductController>();
    final categoryController = Get.find<CategoryController>();

    final kodeC = TextEditingController(text: product?.kode ?? '');
    final namaC = TextEditingController(text: product?.nama ?? '');
    final emojiC = TextEditingController(text: product?.emoji ?? '📦');
    final beliC = TextEditingController(
      text: product == null ? '' : product.hargaBeli.toString(),
    );
    final jualC = TextEditingController(
      text: product == null ? '' : product.hargaJual.toString(),
    );
    final stokC = TextEditingController(
      text: product == null ? '' : product.stok.toString(),
    );

    final selectedCategory = (product?.kategori ?? 'Lainnya').obs;

    Get.dialog(
      AlertDialog(
        title: Text(product == null ? 'Tambah Barang' : 'Edit Barang'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: kodeC,
                  decoration: const InputDecoration(labelText: 'Kode Barang'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: namaC,
                  decoration: const InputDecoration(labelText: 'Nama Barang'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emojiC,
                  decoration: const InputDecoration(labelText: 'Emoji'),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: selectedCategory.value,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categoryController.categories.map((c) {
                      return DropdownMenuItem(
                        value: c.nama,
                        child: Text('${c.emoji} ${c.nama}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory.value = value;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: beliC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga Beli'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: jualC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga Jual'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stokC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stok'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final kode = kodeC.text.trim();
              final nama = namaC.text.trim();
              final emoji = emojiC.text.trim().isEmpty ? '📦' : emojiC.text.trim();
              final beli = int.tryParse(beliC.text) ?? 0;
              final jual = int.tryParse(jualC.text) ?? 0;
              final stok = int.tryParse(stokC.text) ?? 0;

              if (kode.isEmpty || nama.isEmpty || jual <= 0) {
                Get.snackbar('Gagal', 'Kode, nama, dan harga jual wajib diisi');
                return;
              }

              final newProduct = ProductModel(
                id: product?.id ?? DateTime.now().millisecondsSinceEpoch,
                kode: kode,
                nama: nama,
                kategori: selectedCategory.value,
                hargaBeli: beli,
                hargaJual: jual,
                stok: stok,
                emoji: emoji,
                diskon: product?.diskon ?? 0,
              );

              if (product == null) {
                productController.addProduct(newProduct);
              } else {
                productController.updateProduct(newProduct);
              }

              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.text,
              foregroundColor: AppTheme.surface,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}