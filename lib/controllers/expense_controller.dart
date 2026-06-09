import 'package:get/get.dart';

import '../models/expense_model.dart';
import '../services/storage_service.dart';
import '../utils/formatter.dart';
import 'transaction_controller.dart';

class ExpenseController extends GetxController {
  final String keyExpenses = 'tk_expenses';

  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxString selectedType = 'modal'.obs;

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  void loadExpenses() {
    final data = StorageService.read<List>(keyExpenses, []);

    expenses.value = data
        .map((item) => ExpenseModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    expenses.sort((a, b) => b.tanggal.compareTo(a.tanggal));
  }

  void saveExpenses() {
    final data = expenses.map((e) => e.toJson()).toList();
    StorageService.write(keyExpenses, data);
  }

  void selectType(String type) {
    selectedType.value = type;
  }

  void addExpense({
    required String desc,
    required String jumlahText,
  }) {
    final cleanDesc = desc.trim();
    final jumlah = Formatter.parseNumber(jumlahText);

    if (cleanDesc.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Keterangan pengeluaran tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (jumlah <= 0) {
      Get.snackbar(
        'Gagal',
        'Jumlah pengeluaran harus lebih dari 0',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final expense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch,
      tanggal: DateTime.now(),
      desc: cleanDesc,
      jumlah: jumlah,
      tipe: selectedType.value,
    );

    expenses.insert(0, expense);
    saveExpenses();

    Get.snackbar(
      'Berhasil',
      'Pengeluaran berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deleteExpense(int id) {
    expenses.removeWhere((e) => e.id == id);
    saveExpenses();

    Get.snackbar(
      'Berhasil',
      'Pengeluaran berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void resetExpenses() {
    expenses.clear();
    saveExpenses();

    Get.snackbar(
      'Berhasil',
      'Semua data pengeluaran berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  int get totalExpense {
    return expenses.fold(0, (sum, e) => sum + e.jumlah);
  }

  int get totalModal {
    return expenses
        .where((e) => e.tipe == 'modal')
        .fold(0, (sum, e) => sum + e.jumlah);
  }

  int get totalOperasional {
    return expenses
        .where((e) => e.tipe == 'operasional')
        .fold(0, (sum, e) => sum + e.jumlah);
  }

  int get totalKasbon {
    return expenses
        .where((e) => e.tipe == 'kasbon')
        .fold(0, (sum, e) => sum + e.jumlah);
  }

  int get totalBonus {
    return expenses
        .where((e) => e.tipe == 'bonus')
        .fold(0, (sum, e) => sum + e.jumlah);
  }

  int get totalLain {
    return expenses
        .where((e) => e.tipe == 'lain')
        .fold(0, (sum, e) => sum + e.jumlah);
  }

  int get estimatedNetProfit {
    try {
      final txC = Get.find<TransactionController>();
      return txC.totalProfit - totalExpense;
    } catch (_) {
      return -totalExpense;
    }
  }

  String getTypeEmoji(String type) {
    switch (type) {
      case 'modal':
        return '🏪';
      case 'operasional':
        return '⚙️';
      case 'kasbon':
        return '💳';
      case 'bonus':
        return '🎁';
      case 'lain':
        return '📋';
      default:
        return '📋';
    }
  }

  String getTypeLabel(String type) {
    switch (type) {
      case 'modal':
        return 'Modal';
      case 'operasional':
        return 'Operasional';
      case 'kasbon':
        return 'Kasbon';
      case 'bonus':
        return 'Bonus';
      case 'lain':
        return 'Lainnya';
      default:
        return 'Lainnya';
    }
  }
}