import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard {
  /// Fungsi pengecekan token sebelum masuk ke halaman yang mewajibkan login.
  /// [context] diperlukan untuk proses navigasi perpindahan halaman.
  /// [targetPage] adalah halaman detail tujuan jika user terbukti sudah login.
  /// [loginPage] adalah halaman login aplikasi MyTrip kamu.
  static Future<void> checkAndNavigate({
    required BuildContext context,
    required Widget targetPage,
    required Widget loginPage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // Kondisi A: Token ditemukan -> Langsung ke halaman Detail Tiket
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      );
    } else {
      // Kondisi B: Token kosong -> Alihkan ke Halaman Login dahulu
      // Kita bisa menggunakan .then() untuk mendeteksi apakah setelah dari halaman login,
      // user berhasil login dengan sukses atau tidak.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => loginPage),
      ).then((isLoginSuccess) {
        // Jika halaman login mengembalikan nilai 'true' setelah sukses masuk akun
        if (isLoginSuccess == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        }
      });
    }
  }
}
