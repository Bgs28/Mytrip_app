// lib/models/hotel.dart - Tambahkan status jika perlu
import '../utils/constants.dart';
class Hotel {
  final int id;
  final String name;
  final String location;
  final String? description;
  final int price;
  final double? rating;
  final String? image;
  final String? status; // Tambahkan field status (optional)
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
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
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

    // Helper function untuk convert ke double dengan aman
    double? parseToDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    return Hotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'],
      price: parseToInt(json['price']),
      rating: parseToDouble(json['rating']),
      // Gunakan image_url (URL lengkap dari backend accessor) jika ada,
      // fallback ke image (nama file) yang akan diproses buildStorageUrl
      image: json['image_url']?.toString().isNotEmpty == true
          ? json['image_url']
          : json['image'],
      status: json['status'] ?? 'active',
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
      'name': name,
      'location': location,
      'description': description,
      'price': price,
      'rating': rating,
      'image': image,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// URL lengkap gambar hotel.
  /// Jika image sudah URL lengkap (dari backend accessor), pakai langsung.
  /// Jika masih nama file, bangun URL via AppConstants.
  String get imageUrl {
    if (image == null || image!.isEmpty) return '';
    if (image!.startsWith('http')) return image!;
    return AppConstants.buildStorageUrl(image, folder: 'hotels');
  }
}
