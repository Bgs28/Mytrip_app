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
  final String status;
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
    double parseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
        if (cleaned.isEmpty) return 0.0;
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    return Payment(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      promoId: json['promo_id'],
      invoiceNumber: json['invoice_number'] ?? '',
      baseAmount: parseToDouble(json['base_amount']),
      discountAmount: parseToDouble(json['discount_amount']),
      totalAmount: parseToDouble(json['total_amount']),
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? 'pending',
      proofOfPayment: json['proof_of_payment'],
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'])
          : null,
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
      booking: json['booking'] != null
          ? Booking.fromJson(json['booking'])
          : null,
      promo: json['promo'] != null ? Promo.fromJson(json['promo']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'paid':
        return 'Lunas';
      case 'failed':
        return 'Gagal';
      case 'refunded':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FF9800';
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

  bool get hasProof => proofOfPayment != null && proofOfPayment!.isNotEmpty;
  String get proofUrl => proofOfPayment != null
      // ? 'http://192.168.126.112:8000/storage/payments/$proofOfPayment'
      ? 'http://127.0.0.1:8000/storage/payments/$proofOfPayment'
      : '';
}
