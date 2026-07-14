// lib/models/booking.dart
import 'user.dart';

class Booking {
  final int id;
  final int userId;
  final String type; // 'bus', 'train', 'hotel'
  final int itemId;
  final String bookingCode;
  final int totalPrice;
  final String
  status; // 'pending', 'paid', 'cancel' - Pastikan ini tidak nullable
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user; // Relasi user (optional)

  Booking({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemId,
    required this.bookingCode,
    required this.totalPrice,
    required this.status, // Required, tidak nullable
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? '',
      itemId: json['item_id'] ?? 0,
      bookingCode: json['booking_code'] ?? '',
      totalPrice: json['total_price'] ?? 0,
      status: json['status'] ?? 'pending', // Default value jika null
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'item_id': itemId,
      'booking_code': bookingCode,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  // Helper untuk mendapatkan tipe item
  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'bus':
        return 'Bus';
      case 'train':
        return 'Kereta Api';
      case 'hotel':
        return 'Hotel';
      default:
        return type;
    }
  }

  // Helper untuk mendapatkan icon berdasarkan tipe
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'bus':
        return '🚌';
      case 'train':
        return '🚆';
      case 'hotel':
        return '🏨';
      default:
        return '📋';
    }
  }

  // Helper untuk status label
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'cancel':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Helper untuk status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FBBC04'; // Yellow
      case 'paid':
        return '#34A853'; // Green
      case 'cancel':
        return '#EA4335'; // Red
      default:
        return '#80868B'; // Grey
    }
  }
}
