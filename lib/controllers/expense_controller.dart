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
    expenses.assignAll(
      data
          .map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  void saveExpenses() {
    StorageService.write(
      keyExpenses,
      expenses.map((e) => e.toJson()).toList(),
    );
  }

  void selectType(String type) {
    selectedType.value = type;
  }

  void addExpense({
    required String desc,
    required String jumlahText,
    DateTime? tanggal,
  }) {
    final jumlah = Formatter.parseNumber(jumlahText);

    if (desc.trim().isEmpty || jumlah <= 0) {
      Get.snackbar('Gagal', 'Keterangan dan jumlah wajib diisi');
      return;
    }

    final expense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch,
      tipe: selectedType.value,
      desc: desc.trim(),
      jumlah: jumlah,
      tanggal: tanggal ?? DateTime.now(),
    );

    expenses.insert(0, expense);
    saveExpenses();

    Get.snackbar('Berhasil', 'Pengeluaran berhasil disimpan');
  }

  void deleteExpense(int id) {
    expenses.removeWhere((e) => e.id == id);
    saveExpenses();
  }

  void resetExpenses() {
    expenses.clear();
    saveExpenses();
  }

  int totalByType(String type) {
    return expenses
        .where((e) => e.tipe == type)
        .fold(0, (sum, e) => sum + e.jumlah);
  }

  int get totalModal => totalByType('modal');
  int get totalKasbon => totalByType('kasbon');
  int get totalBonus => totalByType('bonus');
  int get totalLain => totalByType('lain');

  int get totalExpense {
    return expenses.fold(0, (sum, e) => sum + e.jumlah);
  }

  int get estimatedNetProfit {
    final tx = Get.find<TransactionController>();
    return tx.totalProfit - totalExpense;
  }
}