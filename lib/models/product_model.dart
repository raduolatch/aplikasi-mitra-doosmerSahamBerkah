class ProductModel {
  final int id;
  final String kode;
  final String nama;
  final String kategori;
  final int hargaBeli;
  final int hargaJual;
  final int stok;
  final String emoji;
  final int diskon;

  ProductModel({
    required this.id,
    required this.kode,
    required this.nama,
    required this.kategori,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    this.emoji = '📦',
    this.diskon = 0,
  });

  int get hargaSetelahDiskon {
    if (diskon <= 0) return hargaJual;
    return hargaJual - ((hargaJual * diskon) ~/ 100);
  }

  String get status {
    if (stok <= 0) return 'Habis';
    if (stok <= 5) return 'Menipis';
    return 'Aman';
  }

  ProductModel copyWith({
    int? id,
    String? kode,
    String? nama,
    String? kategori,
    int? hargaBeli,
    int? hargaJual,
    int? stok,
    String? emoji,
    int? diskon,
  }) {
    return ProductModel(
      id: id ?? this.id,
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
      stok: stok ?? this.stok,
      emoji: emoji ?? this.emoji,
      diskon: diskon ?? this.diskon,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
      kategori: json['kategori'] ?? 'Lainnya',
      hargaBeli: json['hargaBeli'] ?? 0,
      hargaJual: json['hargaJual'] ?? 0,
      stok: json['stok'] ?? 0,
      emoji: json['emoji'] ?? '📦',
      diskon: json['diskon'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'nama': nama,
      'kategori': kategori,
      'hargaBeli': hargaBeli,
      'hargaJual': hargaJual,
      'stok': stok,
      'emoji': emoji,
      'diskon': diskon,
    };
  }
}