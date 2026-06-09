class CategoryModel {
  final int id;
  final String nama;
  final String emoji;

  CategoryModel({
    required this.id,
    required this.nama,
    required this.emoji,
  });

  CategoryModel copyWith({
    int? id,
    String? nama,
    String? emoji,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      emoji: emoji ?? this.emoji,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      emoji: json['emoji'] ?? '📦',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'emoji': emoji,
    };
  }
}