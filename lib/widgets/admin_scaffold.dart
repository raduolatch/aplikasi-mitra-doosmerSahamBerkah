import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.text,
        actions: [
          TextButton(
            onPressed: auth.logout,
            child: const Text('Keluar'),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.text,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TokoKu POS',
                      style: TextStyle(
                        color: AppTheme.surface,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Panel Admin',
                      style: TextStyle(
                        color: AppTheme.border,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _MenuTile(
                icon: Icons.dashboard_outlined,
                title: 'Dashboard',
                route: AppRoutes.dashboard,
              ),
              _MenuTile(
                icon: Icons.inventory_2_outlined,
                title: 'Barang',
                route: AppRoutes.products,
              ),
              _MenuTile(
                icon: Icons.category_outlined,
                title: 'Kategori',
                route: AppRoutes.categories,
              ),
              _MenuTile(
                icon: Icons.history_outlined,
                title: 'Histori',
                route: AppRoutes.history,
              ),
              _MenuTile(
                icon: Icons.receipt_long_outlined,
                title: 'Rekap',
                route: AppRoutes.rekap,
              ),
              _MenuTile(
                icon: Icons.money_off_outlined,
                title: 'Pengeluaran',
                route: AppRoutes.expenses,
              ),
              _MenuTile(
                icon: Icons.note_alt_outlined,
                title: 'Catatan Kasir',
                route: AppRoutes.kasirLog,
              ),
              _MenuTile(
                icon: Icons.settings_outlined,
                title: 'Pengaturan',
                route: AppRoutes.settings,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: auth.logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: body,
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final current = Get.currentRoute;
    final active = current == route;

    return ListTile(
      selected: active,
      selectedTileColor: AppTheme.surface2,
      leading: Icon(
        icon,
        color: active ? AppTheme.text : AppTheme.text2,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: active ? AppTheme.text : AppTheme.text2,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (!active) {
          Get.offNamed(route);
        }
      },
    );
  }
}