// lib/models/promo.dart
class Promo {
  final int id;
  final String code;
  final String name;
  final String? description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double minPurchase;
  final double? maxDiscount;
  final String targetType; // 'all', 'bus', 'train', 'hotel'
  final DateTime startDate;
  final DateTime endDate;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Promo({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.minPurchase,
    this.maxDiscount,
    required this.targetType,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    required this.usageCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      discountType: json['discount_type'] ?? 'percentage',
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      minPurchase: (json['min_purchase'] ?? 0).toDouble(),
      maxDiscount: json['max_discount'] != null
          ? (json['max_discount'] as num).toDouble()
          : null,
      targetType: json['target_type'] ?? 'all',
      startDate: DateTime.parse(
        json['start_date'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['end_date'] ?? DateTime.now().toIso8601String(),
      ),
      usageLimit: json['usage_limit'],
      usageCount: json['usage_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  String get discountLabel {
    if (discountType == 'percentage') {
      return '${discountValue.toInt()}%';
    }
    return 'Rp ${discountValue.toInt()}';
  }

  String get targetLabel {
    switch (targetType) {
      case 'bus':
        return 'Bus';
      case 'train':
        return 'Kereta Api';
      case 'hotel':
        return 'Hotel';
      default:
        return 'Semua';
    }
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  bool get isAvailable {
    if (!isActive) return false;
    if (isExpired) return false;
    if (usageLimit != null && usageCount >= usageLimit!) return false;
    return true;
  }
}
