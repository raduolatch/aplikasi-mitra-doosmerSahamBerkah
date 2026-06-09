import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../models/settings_model.dart';
import '../services/pdf_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';

class ReceiptDialog extends StatelessWidget {
  final TransactionModel transaction;
  final SettingsModel settings;

  const ReceiptDialog({
    super.key,
    required this.transaction,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Struk Transaksi'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: AppTheme.radius,
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  settings.namaToko,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 4),

                if (settings.alamat.isNotEmpty)
                  Text(
                    settings.alamat,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.text2,
                    ),
                  ),

                if (settings.telp.isNotEmpty)
                  Text(
                    settings.telp,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.text2,
                    ),
                  ),

                const SizedBox(height: 12),
                const Divider(),

                _InfoRow(
                  label: 'Invoice',
                  value: transaction.id,
                ),
                _InfoRow(
                  label: 'Tanggal',
                  value: Formatter.dateTime(transaction.tanggal),
                ),
                _InfoRow(
                  label: 'Kasir',
                  value: transaction.kasir,
                ),
                _InfoRow(
                  label: 'Metode',
                  value: transaction.metode,
                ),

                const Divider(height: 24),

                ...transaction.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${item.qty} x ${Formatter.rupiah(item.harga)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.text2,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              Formatter.rupiah(item.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.text,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 24),

                _InfoRow(
                  label: 'Subtotal',
                  value: Formatter.rupiah(transaction.subtotal),
                ),
                _InfoRow(
                  label: 'Diskon',
                  value: '- ${Formatter.rupiah(transaction.diskon)}',
                ),
                _InfoRow(
                  label: 'Total',
                  value: Formatter.rupiah(transaction.total),
                  bold: true,
                ),
                _InfoRow(
                  label: 'Bayar',
                  value: Formatter.rupiah(transaction.bayar),
                ),
                _InfoRow(
                  label: 'Kembalian',
                  value: Formatter.rupiah(transaction.kembalian),
                ),

                const Divider(height: 24),

                if (settings.note.isNotEmpty)
                  Text(
                    settings.note,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.text2,
                    ),
                  ),

                const SizedBox(height: 8),

                Text(
                  settings.footer.isNotEmpty
                      ? settings.footer
                      : 'Terima kasih sudah berbelanja',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            PdfService.printReceipt(
              transaction: transaction,
              settings: settings,
            );
          },
          icon: const Icon(Icons.print),
          label: const Text('Cetak'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.text,
            foregroundColor: AppTheme.surface,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.text2,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 10),
          const Spacer(),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppTheme.text,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                fontSize: bold ? 16 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}