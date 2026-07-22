// lib/models/payment.dart
import 'booking.dart';
import 'promo.dart';
import 'user.dart';

class Payment {
  final int id;
  final int bookingId;
  final int userId;
  final int? promoId;
  final String invoiceNumber;
  final double baseAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String status; // 'pending', 'paid', 'failed', 'refunded'
  final String? proofOfPayment;
  final DateTime? paidAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Booking? booking;
  final Promo? promo;
  final User? user;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    this.promoId,
    required this.invoiceNumber,
    required this.baseAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    this.proofOfPayment,
    this.paidAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.booking,
    this.promo,
    this.user,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      promoId: json['promo_id'],
      invoiceNumber: json['invoice_number'] ?? '',
      baseAmount: (json['base_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? 'pending',
      proofOfPayment: json['proof_of_payment'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      notes: json['notes'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      booking: json['booking'] != null
          ? Booking.fromJson(json['booking'])
          : null,
      promo: json['promo'] != null ? Promo.fromJson(json['promo']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FBBC04';
      case 'paid':
        return '#34A853';
      case 'failed':
        return '#EA4335';
      case 'refunded':
        return '#80868B';
      default:
        return '#80868B';
    }
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'bank_transfer_bca':
        return 'Bank Transfer BCA';
      case 'bank_transfer_mandiri':
        return 'Bank Transfer Mandiri';
      case 'bank_transfer_bni':
        return 'Bank Transfer BNI';
      case 'ovo':
        return 'OVO';
      case 'gopay':
        return 'GoPay';
      default:
        return paymentMethod;
    }
  }
}
