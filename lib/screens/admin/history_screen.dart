import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';
import '../../services/export_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/admin_scaffold.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TransactionController txC = Get.find<TransactionController>();

  String selectedFilter = 'Semua';
  DateTime? startDate;
  DateTime? endDate;

  List<TransactionModel> get filteredTransactions {
    final transactions = txC.transactions.toList();
    final now = DateTime.now();

    if (selectedFilter == 'Semua') {
      return transactions;
    }

    if (selectedFilter == 'Hari Ini') {
      return transactions.where((tx) {
        return _isSameDay(tx.tanggal, now);
      }).toList();
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

      return transactions.where((tx) {
        return _isBetween(tx.tanggal, startOfWeek, endOfWeek);
      }).toList();
    }

    if (selectedFilter == 'Bulan Ini') {
      return transactions.where((tx) {
        return tx.tanggal.year == now.year && tx.tanggal.month == now.month;
      }).toList();
    }

    if (selectedFilter == 'Custom') {
      if (startDate == null || endDate == null) {
        return transactions;
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

      return transactions.where((tx) {
        return _isBetween(tx.tanggal, start, end);
      }).toList();
    }

    return transactions;
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

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Histori Transaksi',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final filtered = filteredTransactions;

          return Column(
            children: [
              _FilterCard(
                selectedFilter: selectedFilter,
                startDate: startDate,
                endDate: endDate,
                filteredCount: filtered.length,
                totalCount: txC.transactions.length,
                onFilterChanged: changeFilter,
                onPickStart: pickStartDate,
                onPickEnd: pickEndDate,
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: filtered.isEmpty
                      ? null
                      : () {
                          ExportService.exportTransactions(
                            transactions: filtered,
                          );
                        },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export Histori ke Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.text,
                    foregroundColor: AppTheme.surface,
                    disabledBackgroundColor: AppTheme.border,
                    disabledForegroundColor: AppTheme.text3,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada transaksi pada filter ini',
                          style: TextStyle(color: AppTheme.text2),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tx = filtered[index];

                          return Container(
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
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppTheme.greenBg,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Icon(
                                        Icons.receipt_long,
                                        color: AppTheme.green,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.id,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.text,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${Formatter.dateTime(tx.tanggal)} • ${tx.kasir} • ${tx.metode}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.text2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      Formatter.rupiah(tx.total),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: 'Hapus transaksi',
                                      onPressed: () {
                                        Get.dialog(
                                          AlertDialog(
                                            title:
                                                const Text('Hapus Transaksi'),
                                            content: Text(
                                              'Yakin ingin menghapus transaksi ${tx.id}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Get.back(),
                                                child: const Text('Batal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  txC.deleteTransaction(tx.id);
                                                  Get.back();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.red,
                                                  foregroundColor:
                                                      AppTheme.surface,
                                                ),
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppTheme.red,
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(height: 24),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: tx.items.map((item) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.bg,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: AppTheme.border,
                                        ),
                                      ),
                                      child: Text(
                                        '${item.product.nama} x${item.qty}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.text2,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    _MiniInfo(
                                      label: 'Item',
                                      value: '${tx.totalItem}',
                                    ),
                                    _MiniInfo(
                                      label: 'Subtotal',
                                      value: Formatter.rupiah(tx.subtotal),
                                    ),
                                    _MiniInfo(
                                      label: 'Diskon',
                                      value: Formatter.rupiah(tx.diskon),
                                    ),
                                    _MiniInfo(
                                      label: 'Untung',
                                      value: Formatter.rupiah(tx.keuntungan),
                                      valueColor: AppTheme.green,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
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
                  'Filter Tanggal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
              ),
              Text(
                '$filteredCount / $totalCount transaksi',
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
                onSelected: (_) {
                  onFilterChanged(filter);
                },
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

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MiniInfo({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: AppTheme.radius,
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.text2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppTheme.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}