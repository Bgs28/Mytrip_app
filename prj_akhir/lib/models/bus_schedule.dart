// lib/models/bus_schedule.dart
class BusSchedule {
  final int id;
  final int busId;
  final DateTime departureDate;
  final String departureTime;
  final String arrivalTime;
  final int availableSeats;
  final int price;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusSchedule({
    required this.id,
    required this.busId,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.availableSeats,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    // Helper function untuk parse price dengan aman
    // Menangani format int (5000), double (5000.0), dan string ("5000", "5000.00", "5.000")
    int parsePrice(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        // Coba parse langsung dulu (untuk "5000" atau "5000.00")
        final directDouble = double.tryParse(value);
        if (directDouble != null) return directDouble.round();
        // Fallback: hapus karakter non-digit dan non-titik, lalu parse
        final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
        if (cleaned.isEmpty) return 0;
        return double.tryParse(cleaned)?.round() ?? 0;
      }
      return 0;
    }

    int parseToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleaned.isEmpty) return 0;
        return int.tryParse(cleaned) ?? 0;
      }
      return 0;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return BusSchedule(
      id: json['id'] ?? 0,
      busId: json['bus_id'] ?? 0,
      departureDate: parseDate(json['departure_date']),
      departureTime: json['departure_time'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
      availableSeats: parseToInt(json['available_seats']),
      price: parsePrice(json['price']),
      status: json['status'] ?? 'active',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Tersedia';
      case 'full':
        return 'Penuh';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status) {
      case 'active':
        return '#34A853';
      case 'full':
        return '#EA4335';
      case 'cancelled':
        return '#80868B';
      default:
        return '#80868B';
    }
  }

  String get departureDateFormatted {
    return '${departureDate.day}/${departureDate.month}/${departureDate.year}';
  }
}
