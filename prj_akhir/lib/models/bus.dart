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
    return Bus(
      id: json['id'] ?? 0,
      busName: json['bus_name'] ?? '',
      from: json['from'] ?? '',
      destination: json['destination'] ?? '',
      departureTime: json['departure_time'] ?? '',
      price: json['price'] ?? 0,
      seat: json['seat'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
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
