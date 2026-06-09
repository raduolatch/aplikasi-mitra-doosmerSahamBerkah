import 'package:get/get.dart';

import '../models/kasir_log_model.dart';
import '../services/storage_service.dart';
import '../utils/formatter.dart';
import 'auth_controller.dart';

class KasirLogController extends GetxController {
  final String keyKasirLog = 'tk_kasir_log';

  final RxList<KasirLogModel> logs = <KasirLogModel>[].obs;
  final RxString selectedType = 'modal'.obs;

  @override
  void onInit() {
    super.onInit();
    loadLogs();
  }

  void loadLogs() {
    final data = StorageService.read<List>(keyKasirLog, []);

    logs.assignAll(
      data
          .map((e) => KasirLogModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  void saveLogs() {
    StorageService.write(
      keyKasirLog,
      logs.map((e) => e.toJson()).toList(),
    );
  }

  void selectType(String type) {
    selectedType.value = type;
  }

  String getTypeLabel(String type) {
    switch (type) {
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

  String getTypeEmoji(String type) {
    switch (type) {
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

  bool addLog({
    required String desc,
    required String jumlahText,
    DateTime? tanggal,
  }) {
    final jumlah = Formatter.parseNumber(jumlahText);

    if (desc.trim().isEmpty) {
      Get.snackbar('Gagal', 'Keterangan wajib diisi');
      return false;
    }

    if (jumlah <= 0) {
      Get.snackbar('Gagal', 'Jumlah wajib diisi dengan angka');
      return false;
    }

    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;

    if (user == null) {
      Get.snackbar('Gagal', 'User belum login');
      return false;
    }

    final log = KasirLogModel(
      id: DateTime.now().millisecondsSinceEpoch,
      kasir: user.username,
      tipe: selectedType.value,
      tipeLabel: getTypeLabel(selectedType.value),
      desc: desc.trim(),
      jumlah: jumlah,
      tanggal: tanggal ?? DateTime.now(),
    );

    logs.insert(0, log);
    saveLogs();

    return true;
  }

  void deleteLog(int id) {
    logs.removeWhere((e) => e.id == id);
    saveLogs();
  }

  void resetLogs() {
    logs.clear();
    saveLogs();
  }

  int totalByType(String type) {
    return logs
        .where((e) => e.tipe == type)
        .fold(0, (sum, e) => sum + e.jumlah);
  }

  int totalByKasirAndType(String kasir, String type) {
    return logs
        .where((e) => e.kasir == kasir && e.tipe == type)
        .fold(0, (sum, e) => sum + e.jumlah);
  }

  int get totalAll {
    return logs.fold(0, (sum, e) => sum + e.jumlah);
  }
}