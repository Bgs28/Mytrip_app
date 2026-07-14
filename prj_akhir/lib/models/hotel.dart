// lib/models/hotel.dart
class Hotel {
  final int id;
  final String name;
  final String location;
  final String? description;
  final int price;
  final double? rating;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    required this.price,
    this.rating,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'],
      price: json['price'] ?? 0,
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : null,
      image: json['image'],
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
      'name': name,
      'location': location,
      'description': description,
      'price': price,
      'rating': rating,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
