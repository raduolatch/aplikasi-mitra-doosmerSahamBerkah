import 'package:get/get.dart';

import '../screens/login_screen.dart';
import '../screens/kasir_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/product_screen.dart';
import '../screens/admin/category_screen.dart';
import '../screens/admin/history_screen.dart';
import '../screens/admin/expense_screen.dart';
import '../screens/admin/rekap_screen.dart';
import '../screens/admin/kasir_log_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const kasir = '/kasir';

  static const dashboard = '/admin/dashboard';
  static const products = '/admin/products';
  static const categories = '/admin/categories';
  static const history = '/admin/history';
  static const expenses = '/admin/expenses';
  static const rekap = '/admin/rekap';
  static const kasirLog = '/admin/kasir-log';
  static const settings = '/settings';

  static final pages = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: kasir, page: () => const KasirScreen()),

    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: products, page: () => const ProductScreen()),
    GetPage(name: categories, page: () => const CategoryScreen()),
    GetPage(name: history, page: () => const HistoryScreen()),
    GetPage(name: expenses, page: () => const ExpenseScreen()),
    GetPage(name: rekap, page: () => const RekapScreen()),
    GetPage(name: kasirLog, page: () => const KasirLogScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
  ];
}