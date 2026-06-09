class SettingsModel {
  final String namaToko;
  final String alamat;
  final String telp;
  final String note;
  final String footer;
  final String googleSheetUrl;
  final String googleClientId;
  final bool autoSync;
  final bool autoPrint;
  final bool ppnAktif;
  final int ppnPersen;

  SettingsModel({
    required this.namaToko,
    required this.alamat,
    required this.telp,
    required this.note,
    required this.footer,
    required this.googleSheetUrl,
    required this.googleClientId,
    required this.autoSync,
    required this.autoPrint,
    required this.ppnAktif,
    required this.ppnPersen,
  });

  factory SettingsModel.defaultValue() {
    return SettingsModel(
      namaToko: 'TokoKu Mart',
      alamat: 'Jl. Merdeka No. 1, Medan',
      telp: '0812-3456-7890',
      note: 'Terima kasih!',
      footer: 'Barang tidak dapat dikembalikan',
      googleSheetUrl: '',
      googleClientId: '',
      autoSync: true,
      autoPrint: false,
      ppnAktif: false,
      ppnPersen: 11,
    );
  }

  SettingsModel copyWith({
    String? namaToko,
    String? alamat,
    String? telp,
    String? note,
    String? footer,
    String? googleSheetUrl,
    String? googleClientId,
    bool? autoSync,
    bool? autoPrint,
    bool? ppnAktif,
    int? ppnPersen,
  }) {
    return SettingsModel(
      namaToko: namaToko ?? this.namaToko,
      alamat: alamat ?? this.alamat,
      telp: telp ?? this.telp,
      note: note ?? this.note,
      footer: footer ?? this.footer,
      googleSheetUrl: googleSheetUrl ?? this.googleSheetUrl,
      googleClientId: googleClientId ?? this.googleClientId,
      autoSync: autoSync ?? this.autoSync,
      autoPrint: autoPrint ?? this.autoPrint,
      ppnAktif: ppnAktif ?? this.ppnAktif,
      ppnPersen: ppnPersen ?? this.ppnPersen,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      namaToko: json['namaToko'] ?? 'TokoKu Mart',
      alamat: json['alamat'] ?? 'Jl. Merdeka No. 1, Medan',
      telp: json['telp'] ?? '0812-3456-7890',
      note: json['note'] ?? 'Terima kasih!',
      footer: json['footer'] ?? 'Barang tidak dapat dikembalikan',
      googleSheetUrl: json['googleSheetUrl'] ?? '',
      googleClientId: json['googleClientId'] ?? '',
      autoSync: json['autoSync'] ?? true,
      autoPrint: json['autoPrint'] ?? false,
      ppnAktif: json['ppnAktif'] ?? false,
      ppnPersen: json['ppnPersen'] ?? 11,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'namaToko': namaToko,
      'alamat': alamat,
      'telp': telp,
      'note': note,
      'footer': footer,
      'googleSheetUrl': googleSheetUrl,
      'googleClientId': googleClientId,
      'autoSync': autoSync,
      'autoPrint': autoPrint,
      'ppnAktif': ppnAktif,
      'ppnPersen': ppnPersen,
    };
  }
}