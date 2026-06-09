import 'package:get/get.dart';

import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../utils/app_routes.dart';

class AuthController extends GetxController {
  final String keyUsers = 'tk_users';
  final String keyCurrentUser = 'tk_current_user';

  final RxList<UserModel> users = <UserModel>[].obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadCurrentUser();
  }

  void loadUsers() {
    final data = StorageService.read<List>(keyUsers, []);

    if (data.isEmpty) {
      users.assignAll([
        UserModel(
          id: 1,
          username: 'admin',
          password: 'admin123',
          nama: 'Administrator',
          role: 'admin',
        ),
        UserModel(
          id: 2,
          username: 'kasir1',
          password: 'kasir123',
          nama: 'Siti Rahayu',
          role: 'kasir',
        ),
      ]);
      saveUsers();
    } else {
      users.assignAll(
        data.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    }
  }

  void saveUsers() {
    StorageService.write(keyUsers, users.map((e) => e.toJson()).toList());
  }

  void loadCurrentUser() {
    final data = StorageService.read<Map?>(keyCurrentUser, null);
    if (data != null) {
      currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(data));
    }
  }

  void login(String username, String password) {
    final user = users.firstWhereOrNull(
      (u) => u.username == username && u.password == password,
    );

    if (user == null) {
      Get.snackbar('Gagal', 'Username atau password salah');
      return;
    }

    final updatedUser = user.copyWith(
      lastLogin: DateTime.now().toString(),
    );

    final index = users.indexWhere((u) => u.id == user.id);
    users[index] = updatedUser;
    saveUsers();

    currentUser.value = updatedUser;
    StorageService.write(keyCurrentUser, updatedUser.toJson());

    if (updatedUser.isAdmin) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.kasir);
    }
  }

  void logout() {
    currentUser.value = null;
    StorageService.remove(keyCurrentUser);
    Get.offAllNamed(AppRoutes.login);
  }

  void addUser({
    required String username,
    required String password,
    required String nama,
    required String role,
  }) {
    if (username.isEmpty || password.isEmpty || nama.isEmpty) {
      Get.snackbar('Gagal', 'Data pengguna belum lengkap');
      return;
    }

    final exists = users.any((u) => u.username == username);
    if (exists) {
      Get.snackbar('Gagal', 'Username sudah digunakan');
      return;
    }

    users.add(
      UserModel(
        id: DateTime.now().millisecondsSinceEpoch,
        username: username,
        password: password,
        nama: nama,
        role: role,
      ),
    );

    saveUsers();
    Get.snackbar('Berhasil', 'Pengguna berhasil ditambahkan');
  }

  void deleteUser(int id) {
    if (id == 1) {
      Get.snackbar('Gagal', 'Admin utama tidak boleh dihapus');
      return;
    }

    users.removeWhere((u) => u.id == id);
    saveUsers();
  }
}