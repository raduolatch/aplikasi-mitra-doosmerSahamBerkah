class UserModel {
  final int id;
  final String username;
  final String password;
  final String nama;
  final String role;
  final String lastLogin;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.nama,
    required this.role,
    this.lastLogin = '—',
  });

  bool get isAdmin => role == 'admin';
  bool get isKasir => role == 'kasir';

  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? nama,
    String? role,
    String? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      nama: json['nama'] ?? '',
      role: json['role'] ?? 'kasir',
      lastLogin: json['lastLogin'] ?? '—',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nama': nama,
      'role': role,
      'lastLogin': lastLogin,
    };
  }
}