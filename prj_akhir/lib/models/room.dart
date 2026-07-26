// lib/models/room.dart
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
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
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
}
