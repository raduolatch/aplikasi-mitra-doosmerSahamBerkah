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
      data
          .whereType<Map>()
          .map(
            (item) => ProductModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  void saveProducts() {
    StorageService.write(
      keyProducts,
      products.map((product) => product.toJson()).toList(),
    );
  }

  List<ProductModel> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    final category = selectedCategory.value;

    return products.where((product) {
      final matchSearch = query.isEmpty ||
          product.nama.toLowerCase().contains(query) ||
          product.kode.toLowerCase().contains(query);

      final matchCategory =
          category == 'Semua' || product.kategori == category;

      return matchSearch && matchCategory;
    }).toList();
  }

  String? addProduct(ProductModel product) {
    final codeExists = products.any(
      (item) =>
          item.kode.trim().toLowerCase() ==
          product.kode.trim().toLowerCase(),
    );

    if (codeExists) {
      return 'Kode barang sudah digunakan';
    }

    products.add(product);
    saveProducts();

    return null;
  }

  String? updateProduct(ProductModel product) {
    final index = products.indexWhere(
      (item) => item.id == product.id,
    );

    if (index == -1) {
      return 'Barang tidak ditemukan';
    }

    final codeExists = products.any(
      (item) =>
          item.id != product.id &&
          item.kode.trim().toLowerCase() ==
              product.kode.trim().toLowerCase(),
    );

    if (codeExists) {
      return 'Kode barang sudah digunakan barang lain';
    }

    products[index] = product;
    products.refresh();
    saveProducts();

    return null;
  }

  void deleteProduct(int id) {
    products.removeWhere((product) => product.id == id);
    saveProducts();
  }

  void reduceStock(int productId, int qty) {
    if (qty <= 0) return;

    final index = products.indexWhere(
      (product) => product.id == productId,
    );

    if (index == -1) return;

    final product = products[index];
    final newStock = product.stok - qty;

    products[index] = product.copyWith(
      stok: newStock < 0 ? 0 : newStock,
    );

    products.refresh();
    saveProducts();
  }

  void resetStock() {
    products.assignAll(
      products.map(
        (product) => product.copyWith(stok: 0),
      ),
    );

    saveProducts();
  }
}