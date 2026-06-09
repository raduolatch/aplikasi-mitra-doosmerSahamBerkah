import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/admin_scaffold.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryC = Get.find<CategoryController>();
    final productC = Get.find<ProductController>();

    return AdminScaffold(
      title: 'Kategori',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showCategoryDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Kategori'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.text,
                  foregroundColor: AppTheme.surface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final categories = categoryC.categories;

                if (categories.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada kategori',
                      style: TextStyle(color: AppTheme.text2),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final c = categories[index];

                    final totalProduk = productC.products
                        .where((p) => p.kategori == c.nama)
                        .length;

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
                            c.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$totalProduk produk',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.text2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showCategoryDialog(category: c),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: () {
                              if (totalProduk > 0) {
                                Get.snackbar(
                                  'Tidak bisa dihapus',
                                  'Kategori masih dipakai oleh produk',
                                );
                                return;
                              }

                              categoryC.deleteCategory(c.id);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.red,
                            ),
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

  void _showCategoryDialog({CategoryModel? category}) {
    final categoryC = Get.find<CategoryController>();

    final namaC = TextEditingController(text: category?.nama ?? '');
    final emojiC = TextEditingController(text: category?.emoji ?? '📦');

    Get.dialog(
      AlertDialog(
        title: Text(category == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaC,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emojiC,
                decoration: const InputDecoration(
                  labelText: 'Emoji',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final nama = namaC.text.trim();
              final emoji = emojiC.text.trim().isEmpty ? '📦' : emojiC.text.trim();

              if (nama.isEmpty) {
                Get.snackbar('Gagal', 'Nama kategori wajib diisi');
                return;
              }

              if (category == null) {
                categoryC.addCategory(nama, emoji);
              } else {
                categoryC.updateCategory(
                  category.copyWith(
                    nama: nama,
                    emoji: emoji,
                  ),
                );
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