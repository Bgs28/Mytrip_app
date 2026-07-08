import 'package:flutter/material.dart';
import 'routes/app_routes.dart'; // file route

void main() {
  runApp(const MyTripApp());
}

class MyTripApp extends StatelessWidget {
  const MyTripApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTrip Travel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),

      // Menggunakan konfigurasi terpusat dari AppRoutes
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
