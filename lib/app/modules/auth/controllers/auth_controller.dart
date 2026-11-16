import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/session_service.dart';

class AuthController extends GetxController {
  final SessionService _sessionService;

  AuthController(this._sessionService);

  final RxBool isLoggedIn = false.obs;
  final RxString username = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  void checkSession() {
    final user = _sessionService.getUser();
    if (user != null && user.trim().isNotEmpty) {
      isLoggedIn.value = true;
      username.value = user.trim();
    } else {
      isLoggedIn.value = false;
      username.value = '';
    }
  }

  Future<void> login(String user, String password) async {
    final cleanUser = user.trim();
    final cleanPass = password.trim();

    if (cleanUser.isEmpty) {
      Get.snackbar(
        'Gagal Masuk',
        'Username tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (cleanPass.isEmpty) {
      Get.snackbar(
        'Gagal Masuk',
        'Password (NIM) tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    await _sessionService.saveUser(cleanUser);
    username.value = cleanUser;
    isLoggedIn.value = true;

    Get.snackbar(
      'Berhasil Masuk',
      'Selamat datang di Toko Awikwok, $cleanUser!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );

    Get.offAllNamed(AppRoutes.main);
  }

  Future<void> logout() async {
    await _sessionService.logout();
    username.value = '';
    isLoggedIn.value = false;

    Get.snackbar(
      'Logout Berhasil',
      'Sesi Anda telah berakhir.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF757575),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );

    Get.offAllNamed(AppRoutes.login);
  }
}

