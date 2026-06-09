import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/expense_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/admin_scaffold.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exC = Get.find<ExpenseController>();

    return AdminScaffold(
      title: 'Pengeluaran',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          if (!isWide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ExpenseForm(),
                  const SizedBox(height: 16),
                  _ExpenseContent(exC: exC, crossAxisCount: 2),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 360,
                  child: _ExpenseForm(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: _ExpenseContent(
                      exC: exC,
                      crossAxisCount: constraints.maxWidth > 1200 ? 5 : 3,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExpenseContent extends StatelessWidget {
  final ExpenseController exC;
  final int crossAxisCount;

  const _ExpenseContent({
    required this.exC,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              _StatCard(
                title: 'Modal',
                value: Formatter.rupiah(exC.totalModal),
                icon: '🏪',
              ),
              _StatCard(
                title: 'Kasbon',
                value: Formatter.rupiah(exC.totalKasbon),
                icon: '💳',
              ),
              _StatCard(
                title: 'Bonus',
                value: Formatter.rupiah(exC.totalBonus),
                icon: '🎁',
              ),
              _StatCard(
                title: 'Lain-lain',
                value: Formatter.rupiah(exC.totalLain),
                icon: '📋',
              ),
              _StatCard(
                title: 'Total',
                value: Formatter.rupiah(exC.totalExpense),
                icon: '💸',
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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Riwayat Pengeluaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Hapus Semua?',
                          middleText: 'Semua data pengeluaran akan dihapus.',
                          textCancel: 'Batal',
                          textConfirm: 'Hapus',
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            exC.resetExpenses();
                            Get.back();
                          },
                        );
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (exC.expenses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Belum ada pengeluaran',
                        style: TextStyle(color: AppTheme.text2),
                      ),
                    ),
                  )
                else
                  ...exC.expenses.map(
                    (e) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: AppTheme.radius,
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Text(
                            e.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.desc,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.text,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${e.label} • ${Formatter.date(e.tanggal)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.text2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            Formatter.rupiah(e.jumlah),
                            style: const TextStyle(
                              color: AppTheme.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              exC.deleteExpense(e.id);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.red,
                            ),
                          ),
                        ],
                      ),
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

class _ExpenseForm extends StatelessWidget {
  _ExpenseForm();

  final TextEditingController descC = TextEditingController();
  final TextEditingController jumlahC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final exC = Get.find<ExpenseController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.border),
      ),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Catat Pengeluaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Rekam modal, kasbon, bonus, atau lain-lain.',
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
                _TypeChip(label: '🏪 Modal', type: 'modal'),
                _TypeChip(label: '💳 Kasbon', type: 'kasbon'),
                _TypeChip(label: '🎁 Bonus', type: 'bonus'),
                _TypeChip(label: '📋 Lain', type: 'lain'),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descC,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                hintText: 'Misal: beli stok, kasbon Budi...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: jumlahC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  exC.addExpense(
                    desc: descC.text,
                    jumlahText: jumlahC.text,
                  );

                  descC.clear();
                  jumlahC.clear();
                },
                icon: const Icon(Icons.add),
                label: const Text('Simpan Pengeluaran'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.text,
                  foregroundColor: AppTheme.surface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: AppTheme.radius,
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                'Est. Laba Bersih:\n${Formatter.rupiah(exC.estimatedNetProfit)}',
                style: TextStyle(
                  color: exC.estimatedNetProfit < 0
                      ? AppTheme.red
                      : AppTheme.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String type;

  const _TypeChip({
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final exC = Get.find<ExpenseController>();

    return Obx(() {
      final active = exC.selectedType.value == type;

      return ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => exC.selectType(type),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 120,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
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
    );
  }
}