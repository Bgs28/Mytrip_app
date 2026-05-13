import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          historyCard(
            "Padang → Jakarta",
            "12 April 2026",
            "Rp 850.000",
            "Sukses",
          ),
          historyCard(
            "Jakarta → Bali",
            "20 April 2026",
            "Rp 1.200.000",
            "Pending",
          ),
          historyCard("Bali → Lombok", "25 April 2026", "Rp 600.000", "Sukses"),
        ],
      ),
    );
  }

  Widget historyCard(String route, String date, String price, String status) {
    Color statusColor = status == "Sukses" ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(date, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status, style: TextStyle(color: statusColor)),
          ),
        ],
      ),
    );
  }
}
