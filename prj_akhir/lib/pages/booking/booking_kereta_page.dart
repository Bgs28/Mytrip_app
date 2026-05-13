import 'package:flutter/material.dart';

class BookingKeretaPage extends StatefulWidget {
  const BookingKeretaPage({super.key});

  @override
  State<BookingKeretaPage> createState() => _BookingKeretaPageState();
}

class _BookingKeretaPageState extends State<BookingKeretaPage> {
  final TextEditingController asalController = TextEditingController();
  final TextEditingController tujuanController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  int penumpang = 1;

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
        title: const Text('Booking Kereta'),
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
                    colors: [Colors.blue, Colors.blue.withOpacity(0.86)],
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
                        Icons.train,
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
                            'Booking kereta lebih cepat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Isi stasiun, tanggal, dan penumpang.',
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
                      controller: asalController,
                      decoration: _buildDecoration('Stasiun Asal', Icons.train),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tujuanController,
                      decoration: _buildDecoration(
                        'Stasiun Tujuan',
                        Icons.location_on,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tanggalController,
                      readOnly: true,
                      decoration: _buildDecoration(
                        'Tanggal Berangkat',
                        Icons.date_range,
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            tanggalController.text =
                                '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCounter(
                      'Jumlah Penumpang',
                      penumpang,
                      () {
                        if (penumpang > 1) {
                          setState(() => penumpang--);
                        }
                      },
                      () {
                        setState(() => penumpang++);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          print('Cari tiket kereta...');
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cari Kereta'),
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
