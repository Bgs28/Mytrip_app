// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/bus_provider.dart';
import 'providers/train_provider.dart';
import 'providers/hotel_provider.dart';
import 'providers/booking_provider.dart';
import 'utils/theme.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/main_screen.dart';
import 'views/trips/bus_detail_screen.dart';
import 'views/trips/train_detail_screen.dart';
import 'views/trips/hotel_detail_screen.dart';
import 'views/trips/bus_list_screen.dart';
import 'views/trips/train_list_screen.dart';
import 'views/trips/hotel_list_screen.dart';
import 'views/payments/checkout_screen.dart';

void main() {
  runApp(const MyTripApp());
}

class MyTripApp extends StatelessWidget {
  const MyTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusProvider()),
        ChangeNotifierProvider(create: (_) => TrainProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'MyTrip - Booking Tiket',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/bus-detail':
              final args = settings.arguments as int;
              return MaterialPageRoute(
                builder: (context) => BusDetailScreen(busId: args),
              );
            case '/train-detail':
              final args = settings.arguments as int;
              return MaterialPageRoute(
                builder: (context) => TrainDetailScreen(trainId: args),
              );
            case '/hotel-detail':
              final args = settings.arguments as int;
              return MaterialPageRoute(
                builder: (context) => HotelDetailScreen(hotelId: args),
              );
            case '/checkout':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => CheckoutScreen(args: args),
              );
            default:
              return null;
          }
        },
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainScreen(),
          '/bus-list': (context) => const BusListScreen(),
          '/train-list': (context) => const TrainListScreen(),
          '/hotel-list': (context) => const HotelListScreen(),
        },
      ),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.buttonShadow,
              ),
              child: const Icon(
                Icons.flight_takeoff,
                color: AppTheme.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text('MyTrip', style: AppTheme.heading1),
            const SizedBox(height: 8),
            Text(
              'Booking Tiket Perjalanan',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.grey),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}
