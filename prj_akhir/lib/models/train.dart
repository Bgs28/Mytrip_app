// lib/models/train.dart - Update parsing price
class Train {
  final int id;
  final String trainName;
  final String from;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final int price;
  final int seat;
  final String? status;
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
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Train.fromJson(Map<String, dynamic> json) {
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

    return Train(
      id: json['id'] ?? 0,
      trainName: json['train_name'] ?? '',
      from: json['from'] ?? '',
      destination: json['destination'] ?? '',
      departureTime: json['departure_time'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
      price: parseToInt(json['price']),
      seat: parseToInt(json['seat']),
      status: json['status'] ?? 'active',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
