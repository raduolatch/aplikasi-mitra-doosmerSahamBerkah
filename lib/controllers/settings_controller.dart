import 'package:get/get.dart';

import '../models/settings_model.dart';
import '../services/storage_service.dart';

class SettingsController extends GetxController {
  final String keySettings = 'tk_settings';

  final Rx<SettingsModel> settings = SettingsModel.defaultValue().obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    final data = StorageService.read<Map?>(keySettings, null);

    if (data == null) {
      settings.value = SettingsModel.defaultValue();
      saveSettings();
    } else {
      settings.value = SettingsModel.fromJson(Map<String, dynamic>.from(data));
    }
  }

  void saveSettings() {
    StorageService.write(keySettings, settings.value.toJson());
  }

  void updateSettings(SettingsModel newSettings) {
    settings.value = newSettings;
    saveSettings();
    Get.snackbar('Berhasil', 'Pengaturan berhasil disimpan');
  }
}