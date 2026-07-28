// lib/models/bus.dart - Update parsing price
class Bus {
  final int id;
  final String busName;
  final String from;
  final String destination;
  final String departureTime;
  final int price;
  final int seat;
  final String? status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bus({
    required this.id,
    required this.busName,
    required this.from,
    required this.destination,
    required this.departureTime,
    required this.price,
    required this.seat,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
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

    return Bus(
      id: json['id'] ?? 0,
      busName: json['bus_name'] ?? '',
      from: json['from'] ?? '',
      destination: json['destination'] ?? '',
      departureTime: json['departure_time'] ?? '',
      price: parseToInt(json['price']),
      seat: parseToInt(json['seat']),
      status: json['status'] ?? 'active',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
