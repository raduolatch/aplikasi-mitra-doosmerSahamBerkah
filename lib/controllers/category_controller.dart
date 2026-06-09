import 'package:get/get.dart';

import '../models/category_model.dart';
import '../services/storage_service.dart';

class CategoryController extends GetxController {
  final String keyCategories = 'tk_categories';

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void loadCategories() {
    final data = StorageService.read<List>(keyCategories, []);

    if (data.isEmpty) {
      categories.assignAll([
        CategoryModel(id: 1, nama: 'Minuman', emoji: '🥤'),
        CategoryModel(id: 2, nama: 'Makanan', emoji: '🍔'),
        CategoryModel(id: 3, nama: 'Snack', emoji: '🍿'),
        CategoryModel(id: 4, nama: 'Rokok', emoji: '🚬'),
        CategoryModel(id: 5, nama: 'Lainnya', emoji: '📦'),
      ]);
      saveCategories();
    } else {
      categories.assignAll(
        data.map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    }
  }

  void saveCategories() {
    StorageService.write(
      keyCategories,
      categories.map((e) => e.toJson()).toList(),
    );
  }

  void addCategory(String nama, String emoji) {
    if (nama.isEmpty) {
      Get.snackbar('Gagal', 'Nama kategori wajib diisi');
      return;
    }

    categories.add(
      CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch,
        nama: nama,
        emoji: emoji.isEmpty ? '📦' : emoji,
      ),
    );

    saveCategories();
    Get.snackbar('Berhasil', 'Kategori berhasil ditambahkan');
  }

  void updateCategory(CategoryModel category) {
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      saveCategories();
    }
  }

  void deleteCategory(int id) {
    categories.removeWhere((c) => c.id == id);
    saveCategories();
  }
}