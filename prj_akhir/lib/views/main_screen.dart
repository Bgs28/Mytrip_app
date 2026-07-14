// lib/views/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bus_provider.dart';
import '../providers/train_provider.dart';
import '../providers/hotel_provider.dart';
import '../providers/booking_provider.dart';
import '../utils/theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'trips/hotel_list_screen.dart';
import 'trips/train_list_screen.dart';
import 'trips/bus_list_screen.dart';
import 'bookings/booking_list_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Method untuk mengubah tab dari luar
  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            DashboardScreen(),
            BusListScreen(),
            TrainListScreen(),
            HotelListScreen(),
            BookingListScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined),
              activeIcon: Icon(Icons.directions_bus),
              label: 'Bus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.train_outlined),
              activeIcon: Icon(Icons.train),
              label: 'Kereta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hotel_outlined),
              activeIcon: Icon(Icons.hotel),
              label: 'Hotel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: AppTheme.grey,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 8,
          backgroundColor: AppTheme.white,
        ),
      ),
    );
  }
}
