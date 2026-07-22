// lib/models/bus.dart
class Bus {
  final int id;
  final String busName;
  final String from;
  final String destination;
  final String departureTime;
  final int price;
  final int seat;
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    // Helper function untuk convert ke int dengan aman
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

    return Bus(
      id: json['id'] ?? 0,
      busName: json['bus_name'] ?? '',
      from: json['from'] ?? '',
      destination: json['destination'] ?? '',
      departureTime: json['departure_time'] ?? '',
      price: parseToInt(json['price']),
      seat: parseToInt(json['seat']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus_name': busName,
      'from': from,
      'destination': destination,
      'departure_time': departureTime,
      'price': price,
      'seat': seat,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
