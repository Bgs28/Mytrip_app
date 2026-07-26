// lib/models/room_booking.dart
import 'room.dart';
import 'booking.dart';

class RoomBooking {
  final int id;
  final int roomId;
  final int bookingId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int totalPrice;
  final int guestsCount;
  final List<String>? guestNames;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Room? room;
  final Booking? booking;

  RoomBooking({
    required this.id,
    required this.roomId,
    required this.bookingId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalPrice,
    required this.guestsCount,
    this.guestNames,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.room,
    this.booking,
  });

  factory RoomBooking.fromJson(Map<String, dynamic> json) {
    return RoomBooking(
      id: json['id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      checkInDate: DateTime.parse(
        json['check_in_date'] ?? DateTime.now().toIso8601String(),
      ),
      checkOutDate: DateTime.parse(
        json['check_out_date'] ?? DateTime.now().toIso8601String(),
      ),
      totalPrice: json['total_price'] ?? 0,
      guestsCount: json['guests_count'] ?? 1,
      guestNames: json['guest_names'] != null
          ? List<String>.from(json['guest_names'])
          : null,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
      booking: json['booking'] != null
          ? Booking.fromJson(json['booking'])
          : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'checked_in':
        return 'Checked In';
      case 'checked_out':
        return 'Checked Out';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  int get nights {
    return checkOutDate.difference(checkInDate).inDays;
  }
}
