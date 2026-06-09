import 'package:get/get.dart';

import '../models/product_model.dart';
import '../services/storage_service.dart';

class ProductController extends GetxController {
  final String keyProducts = 'tk_products';

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'Semua'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void loadProducts() {
    final data = StorageService.read<List>(keyProducts, []);

    products.assignAll(
      data.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }

  void saveProducts() {
    StorageService.write(
      keyProducts,
      products.map((e) => e.toJson()).toList(),
    );
  }

  List<ProductModel> get filteredProducts {
    return products.where((p) {
      final matchSearch = p.nama.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          p.kode.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchCategory =
          selectedCategory.value == 'Semua' || p.kategori == selectedCategory.value;

      return matchSearch && matchCategory;
    }).toList();
  }

  void addProduct(ProductModel product) {
    products.add(product);
    saveProducts();
    Get.snackbar('Berhasil', 'Barang berhasil ditambahkan');
  }

  void updateProduct(ProductModel product) {
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      saveProducts();
      Get.snackbar('Berhasil', 'Barang berhasil diperbarui');
    }
  }

  void deleteProduct(int id) {
    products.removeWhere((p) => p.id == id);
    saveProducts();
  }

  void reduceStock(int productId, int qty) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final product = products[index];
    final newStock = product.stok - qty;

    products[index] = product.copyWith(
      stok: newStock < 0 ? 0 : newStock,
    );

    saveProducts();
  }

  void resetStock() {
    products.assignAll(
      products.map((p) => p.copyWith(stok: 0)).toList(),
    );
    saveProducts();
  }
}