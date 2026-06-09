import 'cart_item_model.dart';

class TransactionModel {
  final String id;
  final DateTime tanggal;
  final String kasir;
  final String metode;
  final List<CartItemModel> items;
  final int subtotal;
  final int diskon;
  final int total;
  final int bayar;
  final int kembalian;

  TransactionModel({
    required this.id,
    required this.tanggal,
    required this.kasir,
    required this.metode,
    required this.items,
    required this.subtotal,
    required this.diskon,
    required this.total,
    required this.bayar,
    required this.kembalian,
  });

  int get totalItem {
    return items.fold(0, (sum, item) => sum + item.qty);
  }

  int get keuntungan {
    return items.fold(0, (sum, item) {
      final untungPerItem = item.harga - item.product.hargaBeli;
      return sum + (untungPerItem * item.qty);
    });
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
      kasir: json['kasir'] ?? '',
      metode: json['metode'] ?? 'Tunai',
      items: (json['items'] as List? ?? [])
          .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      subtotal: json['subtotal'] ?? 0,
      diskon: json['diskon'] ?? 0,
      total: json['total'] ?? 0,
      bayar: json['bayar'] ?? 0,
      kembalian: json['kembalian'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'kasir': kasir,
      'metode': metode,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'diskon': diskon,
      'total': total,
      'bayar': bayar,
      'kembalian': kembalian,
    };
  }
}