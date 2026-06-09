import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/transaction_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/admin_scaffold.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txC = Get.find<TransactionController>();

    return AdminScaffold(
      title: 'Histori Transaksi',
      body: Obx(() {
        final transactions = txC.transactions;

        if (transactions.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada transaksi',
              style: TextStyle(color: AppTheme.text2),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final tx = transactions[index];

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
                      Expanded(
                        child: Text(
                          tx.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                          ),
                        ),
                      ),
                      Text(
                        Formatter.rupiah(tx.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${Formatter.dateTime(tx.tanggal)} • Kasir: ${tx.kasir} • ${tx.metode}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.text2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  ...tx.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.emoji} ${item.product.nama}',
                              style: const TextStyle(color: AppTheme.text),
                            ),
                          ),
                          Text(
                            '${item.qty} x ${Formatter.rupiah(item.harga)}',
                            style: const TextStyle(color: AppTheme.text2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            Formatter.rupiah(item.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Text(
                        'Subtotal: ${Formatter.rupiah(tx.subtotal)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.text2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Diskon: ${Formatter.rupiah(tx.diskon)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.text2,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          txC.deleteTransaction(tx.id);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppTheme.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}