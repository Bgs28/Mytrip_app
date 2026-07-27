// lib/views/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/user.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../main_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            color: AppTheme.primaryBlue,
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const LoadingWidget();
          }

          if (authProvider.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: AppTheme.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Data profil tidak ditemukan',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.grey),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Login Ulang',
                    onPressed: () {
                      authProvider.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    isFullWidth: false,
                    width: 150,
                  ),
                ],
              ),
            );
          }

          final user = authProvider.user!;
          final bookingProvider = Provider.of<BookingProvider>(context);
          final totalBookings = bookingProvider.bookings.length;
          final pendingBookings = bookingProvider.bookings
              .where((b) => b.status.toLowerCase() == 'pending')
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 16),
                _buildStatsCard(totalBookings, pendingBookings),
                const SizedBox(height: 16),
                _buildProfileInfo(user),
                const SizedBox(height: 16),
                _buildMenuList(context),
                const SizedBox(height: 16),
                _buildLogoutButton(authProvider),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.buttonShadow,
              ),
              child: user.avatar != null && user.avatar!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 40,
                            color: AppTheme.primaryBlue,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primaryBlue,
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role ?? 'Pengguna',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int totalBookings, int pendingBookings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    totalBookings.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const Text('Total Booking', style: AppTheme.bodySmall),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: AppTheme.lightGrey),
            Expanded(
              child: Column(
                children: [
                  Text(
                    pendingBookings.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warning,
                    ),
                  ),
                  const Text('Pending', style: AppTheme.bodySmall),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: AppTheme.lightGrey),
            Expanded(
              child: Column(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 24)),
                  const Text('Member', style: AppTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Informasi Profil', style: AppTheme.heading4),
            const SizedBox(height: 12),
            _buildInfoRow('Nama Lengkap', user.name),
            _buildInfoRow('Email', user.email),
            if (user.phone != null && user.phone!.isNotEmpty)
              _buildInfoRow('Nomor Telepon', user.phone!),
            _buildInfoRow('Role', user.role ?? 'Pengguna'),
            _buildInfoRow(
              'Bergabung Sejak',
              AppHelpers.formatDate(user.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: AppTheme.bodySmall)),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final menuItems = [
      {'icon': Icons.history, 'title': 'Riwayat Booking', 'route': 'bookings'},
      {'icon': Icons.help_outline, 'title': 'Bantuan', 'route': null},
      {
        'icon': Icons.feedback_outlined,
        'title': 'Kirim Masukan',
        'route': null,
      },
      {'icon': Icons.info_outline, 'title': 'Tentang Aplikasi', 'route': null},
      {
        'icon': Icons.privacy_tip_outlined,
        'title': 'Kebijakan Privasi',
        'route': null,
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: menuItems.map((item) {
          return ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: AppTheme.primaryBlue,
            ),
            title: Text(item['title'] as String),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.grey),
            onTap: () {
              if (item['route'] == 'bookings') {
                // Navigasi ke tab Riwayat Booking di MainScreen
                final mainScreen = context
                    .findAncestorStateOfType<State<MainScreen>>();
                if (mainScreen != null) {
                  (mainScreen as dynamic).changeTab(1); // Index 1 = Riwayat tab
                }
              } else {
                AppHelpers.showSnackBar(context, 'Fitur ini akan segera hadir');
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return CustomButton(
      text: 'Keluar',
      onPressed: authProvider.isLoading
          ? null
          : () => _showLogoutDialog(authProvider),
      isOutlined: true,
      isFullWidth: true,
      backgroundColor: AppTheme.error,
      textColor: AppTheme.error,
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
