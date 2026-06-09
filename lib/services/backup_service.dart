import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static final GetStorage _box = GetStorage();

  static const List<String> _backupKeys = [
    'tk_products',
    'tk_categories',
    'tk_transactions',
    'tk_users',
    'tk_settings',
    'tk_expenses',
    'tk_kasir_log',
  ];

  static Future<void> backupData() async {
    try {
      final Map<String, dynamic> data = {};

      for (final key in _backupKeys) {
        data[key] = _box.read(key);
      }

      final Map<String, dynamic> backup = {
        'app': 'TokoKu POS',
        'version': '1.0.0',
        'createdAt': DateTime.now().toIso8601String(),
        'data': data,
      };

      final String jsonString = const JsonEncoder.withIndent('  ').convert(
        backup,
      );

      final Directory? downloadsDir = await getDownloadsDirectory();
      final Directory dir = downloadsDir ?? await getTemporaryDirectory();

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'tokoku_pos_backup_$timestamp.json';
      final String path = '${dir.path}${Platform.pathSeparator}$fileName';

      final File file = File(path);
      await file.writeAsString(jsonString, flush: true);

      if (Platform.isWindows) {
        await Process.start(
          'explorer.exe',
          ['/select,', path],
        );
      }

      Get.snackbar(
        'Berhasil',
        'Backup berhasil dibuat di folder Downloads',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Backup',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<void> restoreData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final File file = File(result.files.single.path!);
      final String content = await file.readAsString();

      final dynamic decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        Get.snackbar(
          'Gagal Restore',
          'Format file backup tidak valid',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (decoded['data'] == null || decoded['data'] is! Map<String, dynamic>) {
        Get.snackbar(
          'Gagal Restore',
          'Data backup tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(
        decoded['data'],
      );

      for (final key in _backupKeys) {
        if (data.containsKey(key)) {
          _box.write(key, data[key]);
        }
      }

      Get.snackbar(
        'Restore Berhasil',
        'Data berhasil dipulihkan. Tekan R di terminal untuk restart aplikasi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Restore',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<void> clearAllData() async {
    try {
      for (final key in _backupKeys) {
        _box.remove(key);
      }

      Get.snackbar(
        'Berhasil',
        'Semua data lokal berhasil dihapus. Tekan R untuk restart.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Hapus Data',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}