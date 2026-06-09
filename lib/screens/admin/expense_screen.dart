import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/expense_controller.dart';
import '../../models/expense_model.dart';
import '../../services/export_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/admin_scaffold.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseController expenseC = Get.find<ExpenseController>();

  String selectedFilter = 'Semua';
  DateTime? startDate;
  DateTime? endDate;

  List<ExpenseModel> get filteredExpenses {
    final expenses = expenseC.expenses.toList();
    final now = DateTime.now();

    if (selectedFilter == 'Semua') {
      return expenses;
    }

    if (selectedFilter == 'Hari Ini') {
      return expenses.where((e) => _isSameDay(e.tanggal, now)).toList();
    }

    if (selectedFilter == 'Minggu Ini') {
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day - (now.weekday - 1),
      );

      final endOfWeek = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + 6,
        23,
        59,
        59,
      );

      return expenses.where((e) {
        return _isBetween(e.tanggal, startOfWeek, endOfWeek);
      }).toList();
    }

    if (selectedFilter == 'Bulan Ini') {
      return expenses.where((e) {
        return e.tanggal.year == now.year && e.tanggal.month == now.month;
      }).toList();
    }

    if (selectedFilter == 'Custom') {
      if (startDate == null || endDate == null) {
        return expenses;
      }

      final start = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
      );

      final end = DateTime(
        endDate!.year,
        endDate!.month,
        endDate!.day,
        23,
        59,
        59,
      );

      return expenses.where((e) {
        return _isBetween(e.tanggal, start, end);
      }).toList();
    }

    return expenses;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isBetween(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
        date.isBefore(end.add(const Duration(seconds: 1)));
  }

  Future<void> pickStartDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        startDate = result;
        selectedFilter = 'Custom';

        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = startDate;
        }
      });
    }
  }

  Future<void> pickEndDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        endDate = result;
        selectedFilter = 'Custom';

        if (startDate != null && endDate!.isBefore(startDate!)) {
          startDate = endDate;
        }
      });
    }
  }

  void changeFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      if (filter != 'Custom') {
        startDate = null;
        endDate = null;
      }
    });
  }

  int totalExpense(List<ExpenseModel> expenses) {
    return expenses.fold(0, (sum, e) => sum + e.jumlah);
  }

  int totalByType(List<ExpenseModel> expenses, String type) {
    return expenses
        .where((e) => e.tipe == type)
        .fold(0, (sum, e) => sum + e.jumlah);
  }

  void confirmDelete(ExpenseModel expense) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Pengeluaran'),
        content: Text(
          'Yakin ingin menghapus "${expense.desc}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              expenseC.deleteExpense(expense.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: AppTheme.surface,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Pengeluaran',
      body: Obx(() {
        final expenses = filteredExpenses;
        final total = totalExpense(expenses);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _ExpenseForm(),
              const SizedBox(height: 16),

              _FilterCard(
                selectedFilter: selectedFilter,
                startDate: startDate,
                endDate: endDate,
                filteredCount: expenses.length,
                totalCount: expenseC.expenses.length,
                onFilterChanged: changeFilter,
                onPickStart: pickStartDate,
                onPickEnd: pickEndDate,
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: expenses.isEmpty
                      ? null
                      : () {
                          ExportService.exportExpenses(
                            expenses: expenses,
                          );
                        },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export Pengeluaran ke Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.text,
                    foregroundColor: AppTheme.surface,
                    disabledBackgroundColor: AppTheme.border,
                    disabledForegroundColor: AppTheme.text3,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.9,
                children: [
                  _StatCard(
                    title: 'Total Pengeluaran',
                    value: Formatter.rupiah(total),
                    icon: Icons.money_off_csred_outlined,
                    color: AppTheme.red,
                    bgColor: AppTheme.redBg,
                  ),
                  _StatCard(
                    title: 'Modal',
                    value: Formatter.rupiah(totalByType(expenses, 'modal')),
                    icon: Icons.storefront_outlined,
                    color: AppTheme.blue,
                    bgColor: AppTheme.blueBg,
                  ),
                  _StatCard(
                    title: 'Operasional',
                    value: Formatter.rupiah(
                      totalByType(expenses, 'operasional'),
                    ),
                    icon: Icons.settings_outlined,
                    color: AppTheme.amber,
                    bgColor: AppTheme.amberBg,
                  ),
                  _StatCard(
                    title: 'Kasbon',
                    value: Formatter.rupiah(totalByType(expenses, 'kasbon')),
                    icon: Icons.credit_card,
                    color: AppTheme.purple,
                    bgColor: AppTheme.purpleBg,
                  ),
                  _StatCard(
                    title: 'Bonus',
                    value: Formatter.rupiah(totalByType(expenses, 'bonus')),
                    icon: Icons.card_giftcard,
                    color: AppTheme.green,
                    bgColor: AppTheme.greenBg,
                  ),
                  _StatCard(
                    title: 'Lainnya',
                    value: Formatter.rupiah(totalByType(expenses, 'lain')),
                    icon: Icons.more_horiz,
                    color: AppTheme.purple,
                    bgColor: AppTheme.purpleBg,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: AppTheme.radiusLarge,
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Pengeluaran',
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (expenses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'Belum ada pengeluaran pada filter ini',
                            style: TextStyle(color: AppTheme.text2),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        itemCount: expenses.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final expense = expenses[index];

                          return _ExpenseItem(
                            expense: expense,
                            onDelete: () => confirmDelete(expense),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm();

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final ExpenseController expenseC = Get.find<ExpenseController>();

  final TextEditingController descC = TextEditingController();
  final TextEditingController jumlahC = TextEditingController();

  @override
  void dispose() {
    descC.dispose();
    jumlahC.dispose();
    super.dispose();
  }

  void saveExpense() {
    expenseC.addExpense(
      desc: descC.text,
      jumlahText: jumlahC.text,
    );

    descC.clear();
    jumlahC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tambah Pengeluaran',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Catat biaya modal, operasional, kasbon, bonus, atau lainnya.',
            style: TextStyle(
              color: AppTheme.text2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _ExpenseTypeChip(label: '🏪 Modal', type: 'modal'),
              _ExpenseTypeChip(label: '⚙️ Operasional', type: 'operasional'),
              _ExpenseTypeChip(label: '💳 Kasbon', type: 'kasbon'),
              _ExpenseTypeChip(label: '🎁 Bonus', type: 'bonus'),
              _ExpenseTypeChip(label: '📋 Lain', type: 'lain'),
            ],
          ),

          const SizedBox(height: 12),

          Obx(() {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: AppTheme.radius,
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                'Tipe dipilih: ${expenseC.getTypeEmoji(expenseC.selectedType.value)} ${expenseC.getTypeLabel(expenseC.selectedType.value)}',
                style: const TextStyle(
                  color: AppTheme.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: descC,
                        decoration: const InputDecoration(
                          labelText: 'Keterangan',
                          hintText:
                              'Misal: Beli plastik, bayar listrik, kasbon',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: jumlahC,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah (Rp)',
                          hintText: 'Contoh: 10000 atau 10.000',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: saveExpense,
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.text,
                          foregroundColor: AppTheme.surface,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  TextField(
                    controller: descC,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan',
                      hintText: 'Misal: Beli plastik, bayar listrik, kasbon',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: jumlahC,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      hintText: 'Contoh: 10000 atau 10.000',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: saveExpense,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Pengeluaran'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.text,
                        foregroundColor: AppTheme.surface,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExpenseTypeChip extends StatelessWidget {
  final String label;
  final String type;

  const _ExpenseTypeChip({
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final expenseC = Get.find<ExpenseController>();

    return Obx(() {
      final active = expenseC.selectedType.value == type;

      return ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => expenseC.selectType(type),
        selectedColor: AppTheme.text,
        backgroundColor: AppTheme.surface,
        side: const BorderSide(color: AppTheme.border),
        labelStyle: TextStyle(
          color: active ? AppTheme.surface : AppTheme.text2,
          fontWeight: FontWeight.w600,
        ),
      );
    });
  }
}

class _FilterCard extends StatelessWidget {
  final String selectedFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final int filteredCount;
  final int totalCount;
  final void Function(String filter) onFilterChanged;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  const _FilterCard({
    required this.selectedFilter,
    required this.startDate,
    required this.endDate,
    required this.filteredCount,
    required this.totalCount,
    required this.onFilterChanged,
    required this.onPickStart,
    required this.onPickEnd,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['Semua', 'Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Custom'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined, color: AppTheme.text2),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Filter Pengeluaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
              ),
              Text(
                '$filteredCount / $totalCount data',
                style: const TextStyle(
                  color: AppTheme.text2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters.map((filter) {
              final active = selectedFilter == filter;

              return ChoiceChip(
                label: Text(filter),
                selected: active,
                onSelected: (_) => onFilterChanged(filter),
                selectedColor: AppTheme.text,
                backgroundColor: AppTheme.surface,
                side: const BorderSide(color: AppTheme.border),
                labelStyle: TextStyle(
                  color: active ? AppTheme.surface : AppTheme.text2,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          if (selectedFilter == 'Custom') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickStart,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      startDate == null
                          ? 'Tanggal Awal'
                          : Formatter.date(startDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickEnd,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      endDate == null
                          ? 'Tanggal Akhir'
                          : Formatter.date(endDate!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: bgColor,
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.text2,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onDelete;

  const _ExpenseItem({
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final expenseC = Get.find<ExpenseController>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: AppTheme.radius,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.redBg,
            child: Text(
              expenseC.getTypeEmoji(expense.tipe),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${Formatter.dateTime(expense.tanggal)} • ${expenseC.getTypeLabel(expense.tipe)}',
                  style: const TextStyle(
                    color: AppTheme.text2,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatter.rupiah(expense.jumlah),
            style: const TextStyle(
              color: AppTheme.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.red,
            tooltip: 'Hapus',
          ),
        ],
      ),
    );
  }
}