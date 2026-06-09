import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';
import '../../services/export_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/admin_scaffold.dart';

class RekapScreen extends StatefulWidget {
  const RekapScreen({super.key});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
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

  int totalSales(List<TransactionModel> transactions) {
    return transactions.fold(0, (sum, tx) => sum + tx.total);
  }

  int totalProfit(List<TransactionModel> transactions) {
    return transactions.fold(0, (sum, tx) => sum + tx.keuntungan);
  }

  int totalItemTerjual(List<TransactionModel> transactions) {
    return transactions.fold(0, (sum, tx) => sum + tx.totalItem);
  }

  Map<String, int> produkTerjual(List<TransactionModel> transactions) {
    final Map<String, int> result = {};

    for (final tx in transactions) {
      for (final item in tx.items) {
        result[item.product.nama] =
            (result[item.product.nama] ?? 0) + item.qty;
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Rekap Penjualan',
      body: Obx(() {
        final transactions = filteredTransactions;

        final produkMap = produkTerjual(transactions);
        final produkList = produkMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _FilterCard(
                selectedFilter: selectedFilter,
                startDate: startDate,
                endDate: endDate,
                filteredCount: transactions.length,
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
                  onPressed: transactions.isEmpty
                      ? null
                      : () {
                          ExportService.exportRekap(
                            transactions: transactions,
                          );
                        },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export Rekap ke Excel'),
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
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: [
                  _StatCard(
                    title: 'Total Penjualan',
                    value: Formatter.rupiah(totalSales(transactions)),
                    icon: Icons.payments_outlined,
                  ),
                  _StatCard(
                    title: 'Keuntungan',
                    value: Formatter.rupiah(totalProfit(transactions)),
                    icon: Icons.trending_up_outlined,
                  ),
                  _StatCard(
                    title: 'Jumlah Transaksi',
                    value: '${transactions.length}',
                    icon: Icons.receipt_long_outlined,
                  ),
                  _StatCard(
                    title: 'Item Terjual',
                    value: '${totalItemTerjual(transactions)}',
                    icon: Icons.shopping_bag_outlined,
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
                      'Produk Terjual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (produkList.isEmpty)
                      const Text(
                        'Belum ada produk terjual pada filter ini',
                        style: TextStyle(color: AppTheme.text2),
                      )
                    else
                      ...produkList.map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                    color: AppTheme.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${e.value} item',
                                style: const TextStyle(
                                  color: AppTheme.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
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
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (transactions.isEmpty)
                      const Text(
                        'Belum ada transaksi pada filter ini',
                        style: TextStyle(color: AppTheme.text2),
                      )
                    else
                      ...transactions.take(5).map(
                        (tx) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${tx.id} • ${Formatter.dateTime(tx.tanggal)}',
                                  style: const TextStyle(
                                    color: AppTheme.text2,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                Formatter.rupiah(tx.total),
                                style: const TextStyle(
                                  color: AppTheme.green,
                                  fontWeight: FontWeight.bold,
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
      }),
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
                  'Filter Rekap Penjualan',
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.text2),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
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