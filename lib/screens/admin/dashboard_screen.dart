import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/admin_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final txController = Get.find<TransactionController>();

    return AdminScaffold(
      title: 'Dashboard',
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.7,
                children: [
                  _StatCard(
                    title: 'Total Barang',
                    value: '${productController.products.length}',
                    icon: Icons.inventory_2_outlined,
                  ),
                  _StatCard(
                    title: 'Transaksi',
                    value: '${txController.totalTransactionCount}',
                    icon: Icons.receipt_long_outlined,
                  ),
                  _StatCard(
                    title: 'Penjualan',
                    value: Formatter.rupiah(txController.totalSales),
                    icon: Icons.payments_outlined,
                  ),
                  _StatCard(
                    title: 'Keuntungan',
                    value: Formatter.rupiah(txController.totalProfit),
                    icon: Icons.trending_up_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
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
                      'Mulai Kelola POS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan barang terlebih dahulu, lalu gunakan halaman kasir untuk transaksi.',
                      style: TextStyle(color: AppTheme.text2),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.products),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Barang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.text,
                        foregroundColor: AppTheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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