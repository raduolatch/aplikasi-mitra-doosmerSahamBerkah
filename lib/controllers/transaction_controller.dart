import 'package:get/get.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';
import '../utils/formatter.dart';
import 'auth_controller.dart';
import 'product_controller.dart';

class TransactionController extends GetxController {
  final String keyTransactions = 'tk_transactions';

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<CartItemModel> cart = <CartItemModel>[].obs;

  final RxString paymentMethod = 'Tunai'.obs;
  final RxInt discount = 0.obs;
  final RxInt cash = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() {
    final data = StorageService.read<List>(keyTransactions, []);

    transactions.assignAll(
      data
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  void saveTransactions() {
    StorageService.write(
      keyTransactions,
      transactions.map((e) => e.toJson()).toList(),
    );
  }

  int get subtotal {
    return cart.fold(0, (sum, item) => sum + item.total);
  }

  int get total {
    final result = subtotal - discount.value;
    return result < 0 ? 0 : result;
  }

  int get change {
    return cash.value - total;
  }

  int get totalItems {
    return cart.fold(0, (sum, item) => sum + item.qty);
  }

  void setPayment(String value) {
    paymentMethod.value = value;

    if (value != 'Tunai') {
      cash.value = total;
    }
  }

  void setDiscount(String value) {
    discount.value = Formatter.parseNumber(value);
  }

  void setCash(String value) {
    cash.value = Formatter.parseNumber(value);
  }

  void addToCart(ProductModel product) {
    if (product.stok <= 0) {
      Get.snackbar('Stok habis', '${product.nama} sudah habis');
      return;
    }

    final index = cart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      final currentItem = cart[index];

      if (currentItem.qty >= product.stok) {
        Get.snackbar(
          'Stok tidak cukup',
          'Stok ${product.nama} hanya ${product.stok}',
        );
        return;
      }

      cart[index] = currentItem.copyWith(qty: currentItem.qty + 1);
    } else {
      cart.add(
        CartItemModel(
          product: product,
          qty: 1,
        ),
      );
    }

    cart.refresh();
  }

  void decreaseItem(int productId) {
    final index = cart.indexWhere((item) => item.product.id == productId);

    if (index < 0) return;

    final currentItem = cart[index];

    if (currentItem.qty <= 1) {
      cart.removeAt(index);
    } else {
      cart[index] = currentItem.copyWith(qty: currentItem.qty - 1);
    }

    cart.refresh();
  }

  void removeItem(int productId) {
    cart.removeWhere((item) => item.product.id == productId);
  }

  void clearCart() {
    cart.clear();
    discount.value = 0;
    cash.value = 0;
    paymentMethod.value = 'Tunai';
  }

  TransactionModel? processTransaction() {
    if (cart.isEmpty) {
      Get.snackbar('Gagal', 'Keranjang masih kosong');
      return null;
    }

    if (paymentMethod.value == 'Tunai' && cash.value < total) {
      Get.snackbar('Gagal', 'Jumlah bayar kurang');
      return null;
    }

    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;

    if (user == null) {
      Get.snackbar('Gagal', 'User belum login');
      return null;
    }

    final transaction = TransactionModel(
      id: Formatter.invoiceId(),
      tanggal: DateTime.now(),
      kasir: user.username,
      metode: paymentMethod.value,
      items: cart.toList(),
      subtotal: subtotal,
      diskon: discount.value,
      total: total,
      bayar: paymentMethod.value == 'Tunai' ? cash.value : total,
      kembalian: paymentMethod.value == 'Tunai'
          ? (change < 0 ? 0 : change)
          : 0,
    );

    transactions.insert(0, transaction);
    saveTransactions();

    final productC = Get.find<ProductController>();

    for (final item in cart) {
      productC.reduceStock(item.product.id, item.qty);
    }

    clearCart();

    return transaction;
  }

  void deleteTransaction(String id) {
    transactions.removeWhere((e) => e.id == id);
    saveTransactions();
  }

  void resetTransactions() {
    transactions.clear();
    saveTransactions();
  }

  int get totalSales {
    return transactions.fold(0, (sum, tx) => sum + tx.total);
  }

  int get totalProfit {
    return transactions.fold(0, (sum, tx) => sum + tx.keuntungan);
  }

  int get totalTransactionCount {
    return transactions.length;
  }
}