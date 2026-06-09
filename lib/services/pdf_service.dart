import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/settings_model.dart';
import '../models/transaction_model.dart';
import '../utils/formatter.dart';

class PdfService {
  static Future<void> printReceipt({
    required TransactionModel transaction,
    required SettingsModel settings,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(16),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                settings.namaToko,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              if (settings.alamat.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  settings.alamat,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],

              if (settings.telp.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  settings.telp,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],

              pw.SizedBox(height: 10),
              pw.Divider(),

              _row('Invoice', transaction.id),
              _row('Tanggal', Formatter.dateTime(transaction.tanggal)),
              _row('Kasir', transaction.kasir),
              _row('Metode', transaction.metode),

              pw.Divider(),

              ...transaction.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item.product.nama,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      _row(
                        '${item.qty} x ${Formatter.rupiah(item.harga)}',
                        Formatter.rupiah(item.total),
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(),

              _row('Subtotal', Formatter.rupiah(transaction.subtotal)),
              _row('Diskon', '- ${Formatter.rupiah(transaction.diskon)}'),
              _row(
                'Total',
                Formatter.rupiah(transaction.total),
                bold: true,
              ),
              _row('Bayar', Formatter.rupiah(transaction.bayar)),
              _row('Kembalian', Formatter.rupiah(transaction.kembalian)),

              pw.Divider(),

              if (settings.note.isNotEmpty) ...[
                pw.Text(
                  settings.note,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.SizedBox(height: 8),
              ],

              pw.Text(
                settings.footer.isNotEmpty
                    ? settings.footer
                    : 'Terima kasih sudah berbelanja',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.Widget _row(
    String label,
    String value, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: bold ? 11 : 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}