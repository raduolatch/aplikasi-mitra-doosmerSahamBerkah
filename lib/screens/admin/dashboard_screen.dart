import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/expense_controller.dart';
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
    final productC = Get.find<ProductController>();
    final txC = Get.find<TransactionController>();
    final expenseC = Get.find<ExpenseController>();

    return AdminScaffold(
      title: 'Dashboard',
      body: Obx(() {
        final products = productC.products;
        final transactions = txC.transactions;

        final now = DateTime.now();

        final todayTransactions = transactions.where((tx) {
          return tx.tanggal.year == now.year &&
              tx.tanggal.month == now.month &&
              tx.tanggal.day == now.day;
        }).toList();

        final todaySales = todayTransactions.fold<int>(
          0,
          (sum, tx) => sum + tx.total,
        );

        final todayProfit = todayTransactions.fold<int>(
          0,
          (sum, tx) => sum + tx.keuntungan,
        );

        final lowStockProducts = products.where((p) => p.stok <= 5).toList()
          ..sort((a, b) => a.stok.compareTo(b.stok));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 1000
                    ? 4
                    : MediaQuery.of(context).size.width > 650
                        ? 2
                        : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.1,
                children: [
                  _StatCard(
                    title: 'Penjualan Hari Ini',
                    value: Formatter.rupiah(todaySales),
                    icon: Icons.payments_outlined,
                    bgColor: AppTheme.greenBg,
                    iconColor: AppTheme.green,
                  ),
                  _StatCard(
                    title: 'Profit Hari Ini',
                    value: Formatter.rupiah(todayProfit),
                    icon: Icons.trending_up_outlined,
                    bgColor: AppTheme.blueBg,
                    iconColor: AppTheme.blue,
                  ),
                  _StatCard(
                    title: 'Transaksi Hari Ini',
                    value: '${todayTransactions.length}',
                    icon: Icons.receipt_long_outlined,
                    bgColor: AppTheme.purpleBg,
                    iconColor: AppTheme.purple,
                  ),
                  _StatCard(
                    title: 'Total Produk',
                    value: '${products.length}',
                    icon: Icons.inventory_2_outlined,
                    bgColor: AppTheme.amberBg,
                    iconColor: AppTheme.amber,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 1000
                    ? 4
                    : MediaQuery.of(context).size.width > 650
                        ? 2
                        : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.1,
                children: [
                  _StatCard(
                    title: 'Total Penjualan',
                    value: Formatter.rupiah(txC.totalSales),
                    icon: Icons.account_balance_wallet_outlined,
                    bgColor: AppTheme.greenBg,
                    iconColor: AppTheme.green,
                  ),
                  _StatCard(
                    title: 'Total Keuntungan',
                    value: Formatter.rupiah(txC.totalProfit),
                    icon: Icons.show_chart,
                    bgColor: AppTheme.blueBg,
                    iconColor: AppTheme.blue,
                  ),
                  _StatCard(
                    title: 'Profit Bersih',
                    value: Formatter.rupiah(expenseC.estimatedNetProfit),
                    icon: Icons.savings_outlined,
                    bgColor: AppTheme.purpleBg,
                    iconColor: AppTheme.purple,
                  ),
                  _StatCard(
                    title: 'Stok Menipis',
                    value: '${lowStockProducts.length}',
                    icon: Icons.warning_amber_rounded,
                    bgColor: AppTheme.redBg,
                    iconColor: AppTheme.red,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _QuickActionCard(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _LowStockCard(
                            lowStockProducts: lowStockProducts,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _QuickActionCard(),
                      const SizedBox(height: 16),
                      _LowStockCard(
                        lowStockProducts: lowStockProducts,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              _RecentTransactionCard(
                transactions: transactions.take(5).toList(),
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
  final Color bgColor;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
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
            radius: 24,
            backgroundColor: bgColor,
            child: Icon(icon, color: iconColor),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardBox(
      title: 'Aksi Cepat',
      subtitle: 'Shortcut untuk menu yang sering dipakai.',
      child: Column(
        children: [
          _ActionButton(
            icon: Icons.add_box_outlined,
            title: 'Kelola Barang',
            subtitle: 'Tambah, edit, dan hapus produk',
            onTap: () => Get.toNamed(AppRoutes.products),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.point_of_sale,
            title: 'Buka Kasir',
            subtitle: 'Masuk ke halaman transaksi kasir',
            onTap: () => Get.toNamed(AppRoutes.kasir),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.receipt_long_outlined,
            title: 'Histori Transaksi',
            subtitle: 'Lihat dan export transaksi',
            onTap: () => Get.toNamed(AppRoutes.history),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.analytics_outlined,
            title: 'Rekap Penjualan',
            subtitle: 'Lihat rekap dan produk terjual',
            onTap: () => Get.toNamed(AppRoutes.rekap),
          ),
        ],
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  final List<dynamic> lowStockProducts;

  const _LowStockCard({
    required this.lowStockProducts,
  });

  @override
  Widget build(BuildContext context) {
    return _CardBox(
      title: 'Stok Menipis',
      subtitle: 'Produk dengan stok 5 atau kurang.',
      child: lowStockProducts.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Tidak ada stok menipis',
                  style: TextStyle(color: AppTheme.text2),
                ),
              ),
            )
          : Column(
              children: lowStockProducts.take(6).map((p) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: AppTheme.radius,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Text(
                        p.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              p.kategori,
                              style: const TextStyle(
                                color: AppTheme.text2,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.redBg,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          'Stok ${p.stok}',
                          style: const TextStyle(
                            color: AppTheme.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _RecentTransactionCard extends StatelessWidget {
  final List<dynamic> transactions;

  const _RecentTransactionCard({
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return _CardBox(
      title: 'Transaksi Terbaru',
      subtitle: '5 transaksi terakhir yang masuk.',
      child: transactions.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada transaksi',
                  style: TextStyle(color: AppTheme.text2),
                ),
              ),
            )
          : Column(
              children: transactions.map((tx) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: AppTheme.radius,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.greenBg,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: AppTheme.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${Formatter.dateTime(tx.tanggal)} • ${tx.kasir}',
                              style: const TextStyle(
                                color: AppTheme.text2,
                                fontSize: 12,
                              ),
                            ),
                          ],
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
                );
              }).toList(),
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.radius,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: AppTheme.radius,
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.surface,
              child: Icon(icon, color: AppTheme.text),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.text2,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.text2,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _CardBox({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.text2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}