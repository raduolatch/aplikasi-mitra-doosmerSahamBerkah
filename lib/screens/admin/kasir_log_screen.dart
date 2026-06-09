import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/kasir_log_controller.dart';
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
      body: Obx(() {
        final logs = logC.logs;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _StatCard(
                    title: 'Modal',
                    value: Formatter.rupiah(logC.totalByType('modal')),
                    icon: '🏪',
                  ),
                  _StatCard(
                    title: 'Kasbon',
                    value: Formatter.rupiah(logC.totalByType('kasbon')),
                    icon: '💳',
                  ),
                  _StatCard(
                    title: 'Bonus',
                    value: Formatter.rupiah(logC.totalByType('bonus')),
                    icon: '🎁',
                  ),
                  _StatCard(
                    title: 'Total Catatan',
                    value: Formatter.rupiah(logC.totalAll),
                    icon: '📝',
                  ),
                ],
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
                            'Detail Catatan Kasir',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.text,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: logs.isEmpty
                              ? null
                              : () {
                                  Get.defaultDialog(
                                    title: 'Hapus Semua?',
                                    middleText:
                                        'Semua catatan kasir akan dihapus.',
                                    textCancel: 'Batal',
                                    textConfirm: 'Hapus',
                                    confirmTextColor: Colors.white,
                                    onConfirm: () {
                                      logC.resetLogs();
                                      Get.back();
                                    },
                                  );
                                },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Hapus Semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (logs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Belum ada catatan kasir',
                            style: TextStyle(color: AppTheme.text2),
                          ),
                        ),
                      )
                    else
                      ...logs.map(
                        (log) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: AppTheme.radius,
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              Text(
                                logC.getTypeEmoji(log.tipe),
                                style: const TextStyle(fontSize: 26),
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
                                      '${log.tipeLabel} • Kasir: ${log.kasir} • ${Formatter.date(log.tanggal)}',
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
                                  color: AppTheme.red,
                                  fontWeight: FontWeight.bold,
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
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.text2,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}