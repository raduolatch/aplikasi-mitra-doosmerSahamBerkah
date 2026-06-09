import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/transaction_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/admin_scaffold.dart';

class RekapScreen extends StatelessWidget {
  const RekapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txC = Get.find<TransactionController>();

    return AdminScaffold(
      title: 'Rekap Penjualan',
      body: Obx(() {
        final transactions = txC.transactions;

        final totalItemTerjual = transactions.fold<int>(
          0,
          (sum, tx) => sum + tx.totalItem,
        );

        final Map<String, int> produkTerjual = {};

        for (final tx in transactions) {
          for (final item in tx.items) {
            produkTerjual[item.product.nama] =
                (produkTerjual[item.product.nama] ?? 0) + item.qty;
          }
        }

        final produkList = produkTerjual.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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
                    value: Formatter.rupiah(txC.totalSales),
                    icon: Icons.payments_outlined,
                  ),
                  _StatCard(
                    title: 'Keuntungan',
                    value: Formatter.rupiah(txC.totalProfit),
                    icon: Icons.trending_up_outlined,
                  ),
                  _StatCard(
                    title: 'Jumlah Transaksi',
                    value: '${txC.totalTransactionCount}',
                    icon: Icons.receipt_long_outlined,
                  ),
                  _StatCard(
                    title: 'Item Terjual',
                    value: '$totalItemTerjual',
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
                        'Belum ada produk terjual',
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
                        'Belum ada transaksi',
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