import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/kasir_log_controller.dart';
import '../../services/export_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/admin_scaffold.dart';

class KasirLogScreen extends StatelessWidget {
  const KasirLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logC = Get.find<KasirLogController>();

    return AdminScaffold(
      title: 'Catatan Kasir',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: logC.logs.isEmpty
                      ? null
                      : () {
                          ExportService.exportKasirLogs(
                            logs: logC.logs.toList(),
                          );
                        },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export Catatan Kasir ke Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.text,
                    foregroundColor: AppTheme.surface,
                    disabledBackgroundColor: AppTheme.border,
                    disabledForegroundColor: AppTheme.text3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Obx(
              () => GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width >= 1000 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _StatCard(
                    title: 'Modal',
                    value: Formatter.rupiah(logC.totalByType('modal')),
                    icon: Icons.storefront,
                    bgColor: AppTheme.blueBg,
                    iconColor: AppTheme.blue,
                  ),
                  _StatCard(
                    title: 'Kasbon',
                    value: Formatter.rupiah(logC.totalByType('kasbon')),
                    icon: Icons.credit_card,
                    bgColor: AppTheme.amberBg,
                    iconColor: AppTheme.amber,
                  ),
                  _StatCard(
                    title: 'Bonus',
                    value: Formatter.rupiah(logC.totalByType('bonus')),
                    icon: Icons.card_giftcard,
                    bgColor: AppTheme.purpleBg,
                    iconColor: AppTheme.purple,
                  ),
                  _StatCard(
                    title: 'Total Catatan',
                    value: Formatter.rupiah(logC.totalAll),
                    icon: Icons.receipt_long,
                    bgColor: AppTheme.greenBg,
                    iconColor: AppTheme.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                      const Expanded(
                        child: Text(
                          'Riwayat Catatan Kasir',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                          ),
                        ),
                      ),
                      Obx(
                        () => TextButton.icon(
                          onPressed: logC.logs.isEmpty
                              ? null
                              : () {
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Reset Catatan Kasir'),
                                      content: const Text(
                                        'Yakin ingin menghapus semua catatan kasir?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            logC.resetLogs();
                                            Get.back();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.red,
                                            foregroundColor: AppTheme.surface,
                                          ),
                                          child: const Text('Reset'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Obx(() {
                    if (logC.logs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Belum ada catatan kasir',
                            style: TextStyle(color: AppTheme.text2),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: logC.logs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final log = logC.logs[index];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: AppTheme.radius,
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Center(
                                  child: Text(
                                    logC.getTypeEmoji(log.tipe),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.desc,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.text,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${log.tipeLabel} • ${log.kasir} • ${Formatter.dateTime(log.tanggal)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.text2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                Formatter.rupiah(log.jumlah),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.red,
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  logC.deleteLog(log.id);
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppTheme.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: bgColor,
            child: Icon(icon, color: iconColor),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.text2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}