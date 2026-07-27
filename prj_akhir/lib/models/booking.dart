// lib/models/booking.dart - Perbaiki parsing totalPrice dan discountAmount

import 'user.dart';
import 'payment.dart';

class Booking {
  final int id;
  final int userId;
  final String type;
  final int itemId;
  final String bookingCode;
  final int totalPrice;
  final int discountAmount;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final Payment? payment; // Tambahkan relasi payment

  Booking({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemId,
    required this.bookingCode,
    required this.totalPrice,
    this.discountAmount = 0,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.payment,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
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
    double parseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Hapus titik dan koma, lalu parse
        final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
        if (cleaned.isEmpty) return 0.0;
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? '',
      itemId: json['item_id'] ?? 0,
      bookingCode: json['booking_code'] ?? '',
      totalPrice: parseToInt(json['total_price']),
      discountAmount: parseToInt(json['discount_amount'] ?? 0),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,
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
      'discount_amount': discountAmount,
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
      case 'awaiting_verification':
        return 'Menunggu Verifikasi';
      default:
        return status;
    }
  }

  // Helper untuk status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FBBC04';
      case 'awaiting_verification':
        return '#FF9800'; // Orange
      case 'paid':
        return '#34A853';
      case 'cancel':
        return '#EA4335';
      default:
        return '#80868B';
    }
  }

  // Status badge icon
  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'pending':
        return '⏳';
      case 'awaiting_verification':
        return '🔄';
      case 'paid':
        return '✅';
      case 'cancel':
        return '❌';
      default:
        return '📋';
    }
  }
}
