import 'package:flutter/material.dart';
import 'package:prj_akhir/pages/main/main_page.dart';
// import booking pages
import '../pages/booking/booking_pesawat_page.dart';
import '../pages/booking/booking_kereta_page.dart';
import '../pages/booking/booking_bus_page.dart';
import '../pages/booking/booking_hotel_page.dart';
import '../pages/history/history_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/splash/splash_page.dart';
import '../pages/login/login_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    // splash page
    '/': (context) => const SplashPage(),
    // home page
    '/main': (context) => const MainPage(),

    // booking page
    '/booking_pesawat': (context) => const BookingPesawatPage(),
    '/booking_bus': (context) => const BookingBusPage(),
    '/booking_kereta': (context) => const BookingKeretaPage(),
    '/booking_hotel': (context) => const BookingHotelPage(),

    // history page
    '/history': (context) => const HistoryPage(),

    // profile page
    '/profile': (context) => const ProfilePage(),

    // login page
    '/login': (context) => const LoginPage(),
  };
}
