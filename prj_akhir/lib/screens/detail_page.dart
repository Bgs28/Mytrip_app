import 'package:flutter/material.dart';

class DetailTicketPage extends StatelessWidget {
  final String category;
  final int itemId;
  final String name;
  final String routeInfo;
  final int price;

  const DetailTicketPage({
    Key? key,
    required this.category,
    required this.itemId,
    required this.name,
    required this.routeInfo,
    required this.price,
  }) : super(key: key);

  void _handleBooking(BuildContext context) {
    // Di sinilah logika menembak API Booking Laravel dilakukan di langkah berikutnya
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Memproses booking $name...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail $category'),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Gambar Banner Ilustrasi
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category == 'Hotel'
                          ? Icons.hotel
                          : (category == 'Kereta'
                                ? Icons.train
                                : Icons.directions_bus),
                      size: 80,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama & Rute
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    routeInfo,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const Divider(height: 32),

                  // Detail Fasilitas Tambahan (Dummy Layout)
                  const Text(
                    'Fasilitas & Informasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const ListTile(
                    leading: Icon(Icons.airline_seat_recline_normal),
                    title: Text('Kursi Nyaman & AC Dingin'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.confirmation_number_outlined),
                    title: Text('Tiket Elektronik Langsung Aktif'),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM ACTION BAR: Harga dan Tombol Beli
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Rp $price',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _handleBooking(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Pesan Sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
