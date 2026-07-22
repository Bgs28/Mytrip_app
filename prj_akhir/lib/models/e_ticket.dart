// lib/models/e_ticket.dart
class ETicket {
  final int id;
  final int bookingId;
  final int userId;
  final String ticketCode;
  final String? qrCode;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isUsed;
  final DateTime? usedAt;
  final String checkInCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  ETicket({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.ticketCode,
    this.qrCode,
    required this.validFrom,
    required this.validUntil,
    required this.isUsed,
    this.usedAt,
    required this.checkInCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ETicket.fromJson(Map<String, dynamic> json) {
    return ETicket(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      ticketCode: json['ticket_code'] ?? '',
      qrCode: json['qr_code'],
      validFrom: DateTime.parse(
        json['valid_from'] ?? DateTime.now().toIso8601String(),
      ),
      validUntil: DateTime.parse(
        json['valid_until'] ?? DateTime.now().toIso8601String(),
      ),
      isUsed: json['is_used'] ?? false,
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
      checkInCode: json['check_in_code'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  String get statusLabel {
    if (isUsed) return 'Sudah Digunakan';
    if (DateTime.now().isAfter(validUntil)) return 'Kadaluarsa';
    return 'Aktif';
  }

  String get statusColor {
    if (isUsed) return '#80868B';
    if (DateTime.now().isAfter(validUntil)) return '#EA4335';
    return '#34A853';
  }
}
