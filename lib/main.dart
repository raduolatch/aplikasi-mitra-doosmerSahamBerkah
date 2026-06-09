import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'utils/app_theme.dart';
import 'utils/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/expense_controller.dart';
import 'controllers/kasir_log_controller.dart';
import 'controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await initializeDateFormatting('id_ID', null);

  Get.put(AuthController());
  Get.put(CategoryController());
  Get.put(ProductController());
  Get.put(TransactionController());
  Get.put(ExpenseController());
  Get.put(KasirLogController());
  Get.put(SettingsController());

  runApp(const TokoKuApp());
}

class TokoKuApp extends StatelessWidget {
  const TokoKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TokoKu POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
    );
  }
}