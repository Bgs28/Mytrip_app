import 'package:flutter/material.dart';
import '../screens/main_navigator.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';

class AppRoutes {
  // 1. Definisikan Nama-Nama Rute sebagai Konstanta (Mencegah Typo)
  static const String mainNavigator = '/main';
  static const String login = '/login';
  static const String register = '/register';

  // 2. Definisikan Halaman Awal Aplikasi
  static const String initialRoute = mainNavigator;

  // 3. Kumpulan Pemetaan Rute Global
  static Map<String, WidgetBuilder> get routes {
    return {
      mainNavigator: (context) => const MainNavigator(),

      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
    };
  }
}
