import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggedIn = false;
  String _userName = 'Pengguna MyTrip';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Fungsi pengecekan token lokal agar tidak meminta login terus-menerus
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      // Kamu juga bisa mengambil nama user jika disimpan saat login
      _userName = prefs.getString('user_name') ?? 'Pelanggan Setia';
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus token dan status login

    // Kembalikan ke halaman utama dan reset navigasi
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.mainNavigator,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Jika ternyata belum login di shared preferences, beri tombol untuk ke halaman login
    if (!_isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Yuk, masuk ke akun MyTrip milikmu!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Berpindah ke login, jika sukses (return true), segarkan status profil
                  final success = await Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                  );
                  if (success == true) {
                    _checkLoginStatus();
                  }
                },
                child: const Text('Masuk Akun'),
              ),
            ],
          ),
        ),
      );
    }

    // Jika sudah login, tampilkan menu profil asli
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              _userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: const Text('Member Premium MyTrip'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Pemesanan Tiket'),
            onTap: () {
              // Nanti diarahkan ke HistoryPage
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Keluar dari Akun',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }
}
