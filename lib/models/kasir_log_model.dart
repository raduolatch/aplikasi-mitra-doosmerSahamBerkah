class KasirLogModel {
  final int id;
  final String kasir;
  final String tipe;
  final String tipeLabel;
  final String desc;
  final int jumlah;
  final DateTime tanggal;

  KasirLogModel({
    required this.id,
    required this.kasir,
    required this.tipe,
    required this.tipeLabel,
    required this.desc,
    required this.jumlah,
    required this.tanggal,
  });

  factory KasirLogModel.fromJson(Map<String, dynamic> json) {
    return KasirLogModel(
      id: json['id'] ?? 0,
      kasir: json['kasir'] ?? '',
      tipe: json['tipe'] ?? 'lain',
      tipeLabel: json['tipeLabel'] ?? 'Lain-lain',
      desc: json['desc'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kasir': kasir,
      'tipe': tipe,
      'tipeLabel': tipeLabel,
      'desc': desc,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
    };
  }
}