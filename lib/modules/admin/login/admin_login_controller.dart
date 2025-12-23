import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class AdminLoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final usernameError = ''.obs;
  final passwordError = ''.obs;

  // Static credentials map
  static const Map<String, String> validCredentials = {
    'admin': 'admin123',
    'manager': 'manager123',
    'staff': 'staff123',
  };

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void clearErrors() {
    usernameError.value = '';
    passwordError.value = '';
  }

  void login() {
    clearErrors();
    
    final username = usernameController.text.trim();
    final password = passwordController.text;

    // Validate empty fields
    if (username.isEmpty) {
      usernameError.value = 'Username tidak boleh kosong';
    }
    if (password.isEmpty) {
      passwordError.value = 'Password tidak boleh kosong';
    }
    
    if (username.isEmpty || password.isEmpty) {
      return;
    }

    isLoading.value = true;

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 800), () {
      isLoading.value = false;

      // Validate credentials
      if (!validCredentials.containsKey(username)) {
        usernameError.value = 'Username tidak ditemukan';
        return;
      }

      if (validCredentials[username] != password) {
        passwordError.value = 'Password salah';
        return;
      }

      // Success - navigate to dashboard
      Get.offAllNamed(AppRoutes.adminDashboard);
    });
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
