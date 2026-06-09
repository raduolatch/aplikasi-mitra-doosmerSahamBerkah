import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController usernameController =
      TextEditingController(text: 'admin');
  final TextEditingController passwordController =
      TextEditingController(text: 'admin123');

  String selectedRole = 'admin';

  void setRole(String role) {
    setState(() {
      selectedRole = role;

      if (role == 'admin') {
        usernameController.text = 'admin';
        passwordController.text = 'admin123';
      } else {
        usernameController.text = 'kasir1';
        passwordController.text = 'kasir123';
      }
    });
  }

  void doLogin() {
    authController.login(
      usernameController.text.trim(),
      passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: AppTheme.radiusLarge,
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kasir — TokoKu',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Masuk untuk melanjutkan',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.text2,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _RoleButton(
                        title: 'Admin',
                        active: selectedRole == 'admin',
                        onTap: () => setRole('admin'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RoleButton(
                        title: 'Kasir',
                        active: selectedRole == 'kasir',
                        onTap: () => setRole('kasir'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const _Label('Username'),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan username',
                  ),
                ),

                const SizedBox(height: 14),

                const _Label('Password'),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan password',
                  ),
                  onSubmitted: (_) => doLogin(),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: doLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.text,
                      foregroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radius,
                      ),
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface2,
                    borderRadius: AppTheme.radius,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Text(
                    'Admin: admin / admin123\nKasir: kasir1 / kasir123',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.text2,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _RoleButton({
    required this.title,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppTheme.text : AppTheme.surface2,
      borderRadius: AppTheme.radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radius,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppTheme.radius,
            border: Border.all(
              color: active ? AppTheme.text : AppTheme.border,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: active ? AppTheme.surface : AppTheme.text2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.text2,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}