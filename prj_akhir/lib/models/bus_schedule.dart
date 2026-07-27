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
    return BusSchedule(
      id: json['id'] ?? 0,
      busId: json['bus_id'] ?? 0,
      departureDate: DateTime.parse(
        json['departure_date'] ?? DateTime.now().toIso8601String(),
      ),
      departureTime: json['departure_time'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
      availableSeats: json['available_seats'] ?? 0,
      price: json['price'] ?? 0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
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
