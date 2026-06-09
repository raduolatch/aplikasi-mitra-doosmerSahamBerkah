class ExpenseModel {
  final int id;
  final String tipe;
  final String desc;
  final int jumlah;
  final DateTime tanggal;

  ExpenseModel({
    required this.id,
    required this.tipe,
    required this.desc,
    required this.jumlah,
    required this.tanggal,
  });

  String get label {
    switch (tipe) {
      case 'modal':
        return 'Modal';
      case 'kasbon':
        return 'Kasbon';
      case 'bonus':
        return 'Bonus';
      default:
        return 'Lain-lain';
    }
  }

  String get emoji {
    switch (tipe) {
      case 'modal':
        return '🏪';
      case 'kasbon':
        return '💳';
      case 'bonus':
        return '🎁';
      default:
        return '📋';
    }
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? 0,
      tipe: json['tipe'] ?? 'lain',
      desc: json['desc'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipe': tipe,
      'desc': desc,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
    };
  }
}