// lib/models/room.dart
import '../utils/constants.dart';
class Room {
  final int id;
  final int hotelId;
  final String roomNumber;
  final String roomType;
  final String roomName;
  final String? description;
  final int pricePerNight;
  final int capacity;
  final String bedType;
  final int? size;
  final List<String>? facilities;
  final List<String>? images;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Room({
    required this.id,
    required this.hotelId,
    required this.roomNumber,
    required this.roomType,
    required this.roomName,
    this.description,
    required this.pricePerNight,
    required this.capacity,
    required this.bedType,
    this.size,
    this.facilities,
    this.images,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      roomNumber: json['room_number'] ?? '',
      roomType: json['room_type'] ?? '',
      roomName: json['room_name'] ?? '',
      description: json['description'],
      pricePerNight: json['price_per_night'] ?? 0,
      capacity: json['capacity'] ?? 2,
      bedType: json['bed_type'] ?? '',
      size: json['size'],
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : null,
      // Gunakan images_url (URL lengkap dari backend) jika ada,
      // fallback ke images (nama file) yang akan diproses buildStorageUrl
      images: _parseImages(json),
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Ambil list URL gambar dari response API.
  /// Prioritas: images_url (URL lengkap dari backend accessor) → images (nama file)
  static List<String>? _parseImages(Map<String, dynamic> json) {
    // Coba pakai images_url yang dikirim backend (sudah URL lengkap)
    if (json['images_url'] != null) {
      final list = json['images_url'];
      if (list is List && list.isNotEmpty) {
        return List<String>.from(list.where((e) => e != null && e.toString().isNotEmpty));
      }
    }
    // Fallback ke images (nama file)
    if (json['images'] != null) {
      final list = json['images'];
      if (list is List && list.isNotEmpty) {
        return List<String>.from(list.where((e) => e != null && e.toString().isNotEmpty));
      }
    }
    return null;
  }

  String get roomTypeLabel {
    switch (roomType) {
      case 'standard':
        return 'Standard';
      case 'deluxe':
        return 'Deluxe';
      case 'suite':
        return 'Suite';
      case 'family':
        return 'Family';
      case 'presidential':
        return 'Presidential';
      default:
        return roomType;
    }
  }

  String get bedTypeLabel {
    switch (bedType) {
      case 'single':
        return 'Single Bed';
      case 'double':
        return 'Double Bed';
      case 'twin':
        return 'Twin Beds';
      case 'queen':
        return 'Queen Bed';
      case 'king':
        return 'King Bed';
      default:
        return bedType;
    }
  }

  /// URL lengkap gambar kamar dari Laravel storage.
  /// Jika images sudah berisi URL lengkap (dari backend accessor images_url),
  /// pakai langsung. Jika masih nama file, bangun URL via AppConstants.
  List<String> get imageUrls {
    if (images == null || images!.isEmpty) return [];
    return images!.map((img) {
      if (img.startsWith('http')) return img;
      return AppConstants.buildStorageUrl(img, folder: 'rooms');
    }).where((url) => url.isNotEmpty).toList();
  }
}
