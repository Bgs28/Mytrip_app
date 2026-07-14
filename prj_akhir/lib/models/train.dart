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
    return Train(
      id: json['id'] ?? 0,
      trainName: json['train_name'] ?? '',
      from: json['from'] ?? '',
      destination: json['destination'] ?? '',
      departureTime: json['departure_time'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
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
