// lib/models/train.dart
class Train {
  final int id;
  final String trainName;
  final String from;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final int price;
  final int seat;
  final DateTime createdAt;
  final DateTime updatedAt;

  Train({
    required this.id,
    required this.trainName,
    required this.from,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.seat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Train.fromJson(Map<String, dynamic> json) {
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

    return Train(
      id: json['id'] ?? 0,
      trainName: json['train_name'] ?? '',
      from: json['from'] ?? '',
      destination: json['destination'] ?? '',
      departureTime: json['departure_time'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
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
      'train_name': trainName,
      'from': from,
      'destination': destination,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'price': price,
      'seat': seat,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
