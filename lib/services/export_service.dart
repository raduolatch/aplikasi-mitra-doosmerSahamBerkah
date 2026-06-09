import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../models/expense_model.dart';
import '../models/kasir_log_model.dart';
import '../models/transaction_model.dart';
import '../utils/formatter.dart';

class ExportService {
  static Future<void> exportTransactions({
    required List<TransactionModel> transactions,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.name = 'Histori Transaksi';

    sheet.getRangeByName('A1').setText('Invoice');
    sheet.getRangeByName('B1').setText('Tanggal');
    sheet.getRangeByName('C1').setText('Kasir');
    sheet.getRangeByName('D1').setText('Metode');
    sheet.getRangeByName('E1').setText('Total Item');
    sheet.getRangeByName('F1').setText('Subtotal');
    sheet.getRangeByName('G1').setText('Diskon');
    sheet.getRangeByName('H1').setText('Total');
    sheet.getRangeByName('I1').setText('Bayar');
    sheet.getRangeByName('J1').setText('Kembalian');
    sheet.getRangeByName('K1').setText('Keuntungan');

    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final row = i + 2;

      sheet.getRangeByIndex(row, 1).setText(tx.id);
      sheet.getRangeByIndex(row, 2).setText(Formatter.dateTime(tx.tanggal));
      sheet.getRangeByIndex(row, 3).setText(tx.kasir);
      sheet.getRangeByIndex(row, 4).setText(tx.metode);
      sheet.getRangeByIndex(row, 5).setNumber(tx.totalItem.toDouble());
      sheet.getRangeByIndex(row, 6).setNumber(tx.subtotal.toDouble());
      sheet.getRangeByIndex(row, 7).setNumber(tx.diskon.toDouble());
      sheet.getRangeByIndex(row, 8).setNumber(tx.total.toDouble());
      sheet.getRangeByIndex(row, 9).setNumber(tx.bayar.toDouble());
      sheet.getRangeByIndex(row, 10).setNumber(tx.kembalian.toDouble());
      sheet.getRangeByIndex(row, 11).setNumber(tx.keuntungan.toDouble());
    }

    _styleHeader(sheet, 11);
    _autoFitColumns(sheet, 11);

    await _saveAndOpen(
      workbook: workbook,
      fileName: 'histori_transaksi.xlsx',
    );
  }

  static Future<void> exportExpenses({
    required List<ExpenseModel> expenses,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.name = 'Pengeluaran';

    sheet.getRangeByName('A1').setText('Tanggal');
    sheet.getRangeByName('B1').setText('Tipe');
    sheet.getRangeByName('C1').setText('Keterangan');
    sheet.getRangeByName('D1').setText('Jumlah');

    for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      final row = i + 2;

      sheet.getRangeByIndex(row, 1).setText(
            Formatter.dateTime(expense.tanggal),
          );
      sheet.getRangeByIndex(row, 2).setText(expense.label);
      sheet.getRangeByIndex(row, 3).setText(expense.desc);
      sheet.getRangeByIndex(row, 4).setNumber(expense.jumlah.toDouble());
    }

    _styleHeader(sheet, 4);
    _autoFitColumns(sheet, 4);

    await _saveAndOpen(
      workbook: workbook,
      fileName: 'pengeluaran.xlsx',
    );
  }

  static Future<void> exportKasirLogs({
    required List<KasirLogModel> logs,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.name = 'Catatan Kasir';

    sheet.getRangeByName('A1').setText('Tanggal');
    sheet.getRangeByName('B1').setText('Kasir');
    sheet.getRangeByName('C1').setText('Tipe');
    sheet.getRangeByName('D1').setText('Keterangan');
    sheet.getRangeByName('E1').setText('Jumlah');

    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final row = i + 2;

      sheet.getRangeByIndex(row, 1).setText(Formatter.dateTime(log.tanggal));
      sheet.getRangeByIndex(row, 2).setText(log.kasir);
      sheet.getRangeByIndex(row, 3).setText(log.tipeLabel);
      sheet.getRangeByIndex(row, 4).setText(log.desc);
      sheet.getRangeByIndex(row, 5).setNumber(log.jumlah.toDouble());
    }

    _styleHeader(sheet, 5);
    _autoFitColumns(sheet, 5);

    await _saveAndOpen(
      workbook: workbook,
      fileName: 'catatan_kasir.xlsx',
    );
  }

  static Future<void> exportRekap({
    required List<TransactionModel> transactions,
  }) async {
    final Workbook workbook = Workbook();

    final Worksheet summarySheet = workbook.worksheets[0];
    summarySheet.name = 'Rekap Penjualan';

    final totalSales = transactions.fold<int>(
      0,
      (sum, tx) => sum + tx.total,
    );

    final totalProfit = transactions.fold<int>(
      0,
      (sum, tx) => sum + tx.keuntungan,
    );

    final totalItemTerjual = transactions.fold<int>(
      0,
      (sum, tx) => sum + tx.totalItem,
    );

    summarySheet.getRangeByName('A1').setText('Rekap Penjualan TokoKu POS');
    summarySheet.getRangeByName('A1').cellStyle.bold = true;
    summarySheet.getRangeByName('A1').cellStyle.fontSize = 16;

    summarySheet.getRangeByName('A3').setText('Total Penjualan');
    summarySheet.getRangeByName('B3').setNumber(totalSales.toDouble());

    summarySheet.getRangeByName('A4').setText('Total Keuntungan');
    summarySheet.getRangeByName('B4').setNumber(totalProfit.toDouble());

    summarySheet.getRangeByName('A5').setText('Jumlah Transaksi');
    summarySheet.getRangeByName('B5').setNumber(transactions.length.toDouble());

    summarySheet.getRangeByName('A6').setText('Total Item Terjual');
    summarySheet.getRangeByName('B6').setNumber(totalItemTerjual.toDouble());

    summarySheet.getRangeByName('A8').setText('Produk');
    summarySheet.getRangeByName('B8').setText('Qty Terjual');
    summarySheet.getRangeByName('C8').setText('Total Pendapatan');
    summarySheet.getRangeByName('D8').setText('Total Keuntungan');

    final Map<String, int> qtyMap = {};
    final Map<String, int> incomeMap = {};
    final Map<String, int> profitMap = {};

    for (final tx in transactions) {
      for (final item in tx.items) {
        final name = item.product.nama;

        qtyMap[name] = (qtyMap[name] ?? 0) + item.qty;
        incomeMap[name] = (incomeMap[name] ?? 0) + item.total;

        final profitPerItem =
            item.product.hargaSetelahDiskon - item.product.hargaBeli;

        profitMap[name] = (profitMap[name] ?? 0) + (profitPerItem * item.qty);
      }
    }

    final productList = qtyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < productList.length; i++) {
      final product = productList[i];
      final row = i + 9;

      summarySheet.getRangeByIndex(row, 1).setText(product.key);
      summarySheet.getRangeByIndex(row, 2).setNumber(product.value.toDouble());
      summarySheet.getRangeByIndex(row, 3).setNumber(
            (incomeMap[product.key] ?? 0).toDouble(),
          );
      summarySheet.getRangeByIndex(row, 4).setNumber(
            (profitMap[product.key] ?? 0).toDouble(),
          );
    }

    for (int col = 1; col <= 4; col++) {
      final Range cell = summarySheet.getRangeByIndex(8, col);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = '#D9EAD3';
      cell.cellStyle.hAlign = HAlignType.center;
    }

    _autoFitColumns(summarySheet, 4);

    await _saveAndOpen(
      workbook: workbook,
      fileName: 'rekap_penjualan.xlsx',
    );
  }

  static void _styleHeader(Worksheet sheet, int totalColumns) {
    for (int col = 1; col <= totalColumns; col++) {
      final Range cell = sheet.getRangeByIndex(1, col);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = '#D9EAD3';
      cell.cellStyle.hAlign = HAlignType.center;
    }
  }

  static void _autoFitColumns(Worksheet sheet, int totalColumns) {
    for (int col = 1; col <= totalColumns; col++) {
      sheet.autoFitColumn(col);
    }
  }

  static Future<void> _saveAndOpen({
    required Workbook workbook,
    required String fileName,
  }) async {
    try {
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final Directory? downloadsDir = await getDownloadsDirectory();
      final Directory dir = downloadsDir ?? await getTemporaryDirectory();

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fixedFileName = fileName.replaceAll(
        '.xlsx',
        '_$timestamp.xlsx',
      );

      final String path = '${dir.path}${Platform.pathSeparator}$fixedFileName';

      final File file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      if (Platform.isWindows) {
        await Process.start(
          'explorer.exe',
          ['/select,', path],
        );
      }

      Get.snackbar(
        'Berhasil',
        'File Excel berhasil dibuat di folder Downloads',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Export',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}