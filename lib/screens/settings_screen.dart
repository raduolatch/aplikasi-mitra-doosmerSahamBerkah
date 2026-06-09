import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../models/settings_model.dart';
import '../services/backup_service.dart';
import '../utils/app_theme.dart';
import '../widgets/admin_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController settingsC = Get.find<SettingsController>();

  late TextEditingController namaTokoC;
  late TextEditingController alamatC;
  late TextEditingController telpC;
  late TextEditingController noteC;
  late TextEditingController footerC;
  late TextEditingController googleSheetUrlC;
  late TextEditingController googleClientIdC;
  late TextEditingController ppnPersenC;

  bool autoSync = false;
  bool autoPrint = false;
  bool ppnAktif = false;

  @override
  void initState() {
    super.initState();

    final s = settingsC.settings.value;

    namaTokoC = TextEditingController(text: s.namaToko);
    alamatC = TextEditingController(text: s.alamat);
    telpC = TextEditingController(text: s.telp);
    noteC = TextEditingController(text: s.note);
    footerC = TextEditingController(text: s.footer);
    googleSheetUrlC = TextEditingController(text: s.googleSheetUrl);
    googleClientIdC = TextEditingController(text: s.googleClientId);
    ppnPersenC = TextEditingController(text: s.ppnPersen.toString());

    autoSync = s.autoSync;
    autoPrint = s.autoPrint;
    ppnAktif = s.ppnAktif;
  }

  @override
  void dispose() {
    namaTokoC.dispose();
    alamatC.dispose();
    telpC.dispose();
    noteC.dispose();
    footerC.dispose();
    googleSheetUrlC.dispose();
    googleClientIdC.dispose();
    ppnPersenC.dispose();
    super.dispose();
  }

  void saveSettings() {
    final ppn = int.tryParse(ppnPersenC.text.trim()) ?? 0;

    final newSettings = SettingsModel(
      namaToko: namaTokoC.text.trim(),
      alamat: alamatC.text.trim(),
      telp: telpC.text.trim(),
      note: noteC.text.trim(),
      footer: footerC.text.trim(),
      googleSheetUrl: googleSheetUrlC.text.trim(),
      googleClientId: googleClientIdC.text.trim(),
      autoSync: autoSync,
      autoPrint: autoPrint,
      ppnAktif: ppnAktif,
      ppnPersen: ppn,
    );

    settingsC.updateSettings(newSettings);

    Get.snackbar(
      'Berhasil',
      'Pengaturan toko berhasil disimpan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void resetSettings() {
    final defaultSettings = SettingsModel.defaultValue();

    settingsC.updateSettings(defaultSettings);

    setState(() {
      namaTokoC.text = defaultSettings.namaToko;
      alamatC.text = defaultSettings.alamat;
      telpC.text = defaultSettings.telp;
      noteC.text = defaultSettings.note;
      footerC.text = defaultSettings.footer;
      googleSheetUrlC.text = defaultSettings.googleSheetUrl;
      googleClientIdC.text = defaultSettings.googleClientId;
      ppnPersenC.text = defaultSettings.ppnPersen.toString();

      autoSync = defaultSettings.autoSync;
      autoPrint = defaultSettings.autoPrint;
      ppnAktif = defaultSettings.ppnAktif;
    });

    Get.snackbar(
      'Reset',
      'Pengaturan dikembalikan ke default',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void confirmRestore() {
    Get.dialog(
      AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'Restore akan menimpa data lokal saat ini dengan data dari file backup. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              BackupService.restoreData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.text,
              foregroundColor: AppTheme.surface,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void confirmClearData() {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Semua Data'),
        content: const Text(
          'Semua produk, kategori, transaksi, pengeluaran, catatan kasir, dan pengaturan akan dihapus dari perangkat ini. Yakin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              BackupService.clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: AppTheme.surface,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Pengaturan',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildStoreCard()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _buildSystemCard(),
                        const SizedBox(height: 16),
                        _buildBackupCard(),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildStoreCard(),
                const SizedBox(height: 16),
                _buildSystemCard(),
                const SizedBox(height: 16),
                _buildBackupCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStoreCard() {
    return _CardBox(
      title: 'Informasi Toko',
      subtitle: 'Data ini dipakai untuk struk dan laporan.',
      icon: Icons.storefront,
      children: [
        TextField(
          controller: namaTokoC,
          decoration: const InputDecoration(
            labelText: 'Nama Toko',
            hintText: 'Contoh: TokoKu POS',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: alamatC,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Alamat Toko',
            hintText: 'Contoh: Jl. Setia Budi No. 10, Medan',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: telpC,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Nomor HP / Telepon',
            hintText: 'Contoh: 081234567890',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteC,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Catatan Struk',
            hintText: 'Contoh: Barang yang sudah dibeli tidak dapat dikembalikan',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: footerC,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Footer Struk',
            hintText: 'Contoh: Terima kasih sudah berbelanja',
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: resetSettings,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.text,
                  foregroundColor: AppTheme.surface,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemCard() {
    return _CardBox(
      title: 'Sistem & Sinkronisasi',
      subtitle: 'Pengaturan fitur tambahan aplikasi.',
      icon: Icons.settings,
      children: [
        SwitchListTile(
          value: autoPrint,
          onChanged: (value) {
            setState(() {
              autoPrint = value;
            });
          },
          title: const Text('Auto Print'),
          subtitle: const Text('Cetak struk otomatis setelah transaksi'),
          activeColor: AppTheme.text,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        SwitchListTile(
          value: ppnAktif,
          onChanged: (value) {
            setState(() {
              ppnAktif = value;
            });
          },
          title: const Text('Aktifkan PPN'),
          subtitle: const Text('Tambahkan pajak pada transaksi'),
          activeColor: AppTheme.text,
          contentPadding: EdgeInsets.zero,
        ),
        if (ppnAktif) ...[
          const SizedBox(height: 8),
          TextField(
            controller: ppnPersenC,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'PPN (%)',
              hintText: 'Contoh: 11',
            ),
          ),
        ],
        const SizedBox(height: 12),
        const Divider(),
        SwitchListTile(
          value: autoSync,
          onChanged: (value) {
            setState(() {
              autoSync = value;
            });
          },
          title: const Text('Auto Sync Google Sheets'),
          subtitle: const Text('Sinkron otomatis ke Google Sheets'),
          activeColor: AppTheme.text,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: googleSheetUrlC,
          decoration: const InputDecoration(
            labelText: 'Google Sheet URL',
            hintText: 'Tempel link Google Sheets di sini',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: googleClientIdC,
          decoration: const InputDecoration(
            labelText: 'Google Client ID',
            hintText: 'Untuk fitur Google Sheets API nanti',
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Simpan Pengaturan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.text,
              foregroundColor: AppTheme.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackupCard() {
    return _CardBox(
      title: 'Backup & Restore',
      subtitle: 'Simpan dan pulihkan data lokal aplikasi.',
      icon: Icons.backup,
      children: [
        const Text(
          'Backup akan membuat file JSON berisi produk, kategori, transaksi, pengeluaran, catatan kasir, user, dan pengaturan.',
          style: TextStyle(
            color: AppTheme.text2,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: BackupService.backupData,
            icon: const Icon(Icons.download),
            label: const Text('Backup Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.text,
              foregroundColor: AppTheme.surface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: confirmRestore,
            icon: const Icon(Icons.upload_file),
            label: const Text('Restore Data'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: confirmClearData,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Hapus Semua Data Lokal'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.red,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  const _CardBox({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.surface2,
                child: Icon(icon, color: AppTheme.text),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.text2,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}