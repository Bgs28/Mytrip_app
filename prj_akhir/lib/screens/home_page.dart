import './detail_page.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_guard.dart';
import '../../models/bus_model.dart';
import '../../models/train_model.dart';
import '../../models/hotel_model.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  // State untuk melacak kategori mana yang sedang dipilih user ('Bus', 'Kereta', atau 'Hotel')
  String _selectedCategory = 'Bus';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER & SEARCH BOX
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mau ke mana hari ini?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari kota asal atau tujuan...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. KATEGORI MENU (Bisa diklik untuk mengubah state)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryMenu(
                      Icons.directions_bus,
                      'Bus',
                      Colors.orange,
                    ),
                    _buildCategoryMenu(Icons.train, 'Kereta', Colors.green),
                    _buildCategoryMenu(Icons.hotel, 'Hotel', Colors.blue),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. DAFTAR REKOMENDASI DINAMIS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Rekomendasi $_selectedCategory',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Memanggil builder list dinamis sesuai kategori yang dipilih
              _buildDynamicList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper: Tombol Kategori yang Responsif terhadap Klik
  Widget _buildCategoryMenu(IconData icon, String label, Color color) {
    final bool isSelected = _selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label; // Mengubah data list rekomendasi di bawah
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
              color: isSelected ? color : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper: Memilih FutureBuilder yang Sesuai dengan State Kategori
  Widget _buildDynamicList() {
    if (_selectedCategory == 'Bus') {
      return FutureBuilder<List<BusModel>>(
        future: _apiService.getBuses(),
        builder: (context, snapshot) => _handleSnapshot<BusModel>(
          snapshot,
          Icons.directions_bus,
          Colors.orange,
        ),
      );
    } else if (_selectedCategory == 'Kereta') {
      return FutureBuilder<List<TrainModel>>(
        future: _apiService.getTrains(),
        builder: (context, snapshot) =>
            _handleSnapshot<TrainModel>(snapshot, Icons.train, Colors.green),
      );
    } else {
      return FutureBuilder<List<HotelModel>>(
        future: _apiService.getHotels(),
        builder: (context, snapshot) =>
            _handleSnapshot<HotelModel>(snapshot, Icons.hotel, Colors.blue),
      );
    }
  }

  // Handler Snapshot Generic agar hemat kode dan rapi
  Widget _handleSnapshot<T>(
    AsyncSnapshot<List<T>> snapshot,
    IconData icon,
    Color color,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Gagal memuat data dari Laravel.\nPastikan Endpoint /${_selectedCategory.toLowerCase()}s aktif.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Tidak ada $_selectedCategory tersedia.'),
        ),
      );
    }

    final listData = snapshot.data!;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listData.length,
      itemBuilder: (context, index) {
        final item = listData[index];

        // Ekstraksi data dinamis karena nama properti model bisa sedikit berbeda (misal: hotel pakai location, bus pakai fromLocation)
        String name = '';
        String routeInfo = '';
        int price = 0;
        int itemId = 0;

        if (item is BusModel) {
          name = item.name;
          routeInfo = '${item.fromLocation} ➔ ${item.toLocation}';
          price = item.price;
          itemId = item.id;
        } else if (item is TrainModel) {
          name = item.name;
          routeInfo = '${item.fromLocation} ➔ ${item.toLocation}';
          price = item.price;
          itemId = item.id;
        } else if (item is HotelModel) {
          name = item.name;
          routeInfo = 'Lokasi: ${item.location}';
          price = item.price;
          itemId = item.id;
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(routeInfo),
                const SizedBox(height: 8),
                Text(
                  'Rp $price',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              // Proteksi AuthGuard untuk semua jenis item tiket
              AuthGuard.checkAndNavigate(
                context: context,
                targetPage: DetailTicketPage(
                  // <- SEKARANG MENGARAH KE DETAIL ASLI
                  category: _selectedCategory,
                  itemId: itemId,
                  name: name,
                  routeInfo: routeInfo,
                  price: price,
                ),
                loginPage: const LoginPage(),
              );
            },
          ),
        );
      },
    );
  }
}
