import 'package:flutter/material.dart';

class BookingHotelPage extends StatefulWidget {
  const BookingHotelPage({super.key});

  @override
  State<BookingHotelPage> createState() => _BookingHotelPageState();
}

class _BookingHotelPageState extends State<BookingHotelPage> {
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController checkinController = TextEditingController();
  final TextEditingController checkoutController = TextEditingController();

  int tamu = 1;
  int kamar = 1;

  InputDecoration _buildDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildCounter(
    String label,
    int value,
    VoidCallback onRemove,
    VoidCallback onAdd,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline, color: Colors.blue),
            ),
            Text(
              '$value',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Booking Hotel'),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue.withOpacity(0.88)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.hotel,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Temukan hotel nyaman untuk liburanmu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Pilih lokasi, tanggal, dan jumlah kamar.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: lokasiController,
                      decoration: _buildDecoration(
                        'Lokasi / Kota',
                        Icons.location_on,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: checkinController,
                      readOnly: true,
                      decoration: _buildDecoration('Check-in', Icons.login),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            checkinController.text =
                                '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: checkoutController,
                      readOnly: true,
                      decoration: _buildDecoration('Check-out', Icons.logout),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            checkoutController.text =
                                '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCounter(
                      'Jumlah Tamu',
                      tamu,
                      () {
                        if (tamu > 1) {
                          setState(() => tamu--);
                        }
                      },
                      () {
                        setState(() => tamu++);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCounter(
                      'Jumlah Kamar',
                      kamar,
                      () {
                        if (kamar > 1) {
                          setState(() => kamar--);
                        }
                      },
                      () {
                        setState(() => kamar++);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          print('Cari hotel...');
                          print('Lokasi: ${lokasiController.text}');
                          print('Check-in: ${checkinController.text}');
                          print('Check-out: ${checkoutController.text}');
                          print('Tamu: $tamu');
                          print('Kamar: $kamar');
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cari Hotel'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
