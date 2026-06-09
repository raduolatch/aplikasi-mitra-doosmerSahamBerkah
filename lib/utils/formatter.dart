import 'package:intl/intl.dart';

class Formatter {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final DateFormat _date = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

  static String rupiah(num value) {
    return _currency.format(value);
  }

  static String date(DateTime date) {
    return _date.format(date);
  }

  static String dateTime(DateTime date) {
    return _dateTime.format(date);
  }

  static String invoiceId() {
    final now = DateTime.now();
    return 'INV${now.millisecondsSinceEpoch}';
  }

  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${_two(now.month)}-${_two(now.day)}';
  }

  static String monthKey(DateTime date) {
    return '${date.year}-${_two(date.month)}';
  }

  static int parseNumber(String value) {
    final cleaned = value
        .replaceAll('Rp', '')
        .replaceAll('rp', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '');

    return int.tryParse(cleaned) ?? 0;
  }

  static String _two(int value) {
    return value.toString().padLeft(2, '0');
  }
}