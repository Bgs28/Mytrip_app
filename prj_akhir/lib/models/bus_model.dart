class BusModel {
  final int id;
  final String name;
  final String fromLocation;
  final String toLocation;
  final int price;
  final String? description;

  BusModel({
    required this.id,
    required this.name,
    required this.fromLocation,
    required this.toLocation,
    required this.price,
    this.description,
  });

  // WAJIB ADA: Fungsi inilah yang dicari oleh api_service.dart
  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      // Menyesuaikan field dari database Laravel kamu ('from' atau 'from_location')
      fromLocation: json['from'] ?? json['from_location'] ?? '',
      toLocation: json['destination'] ?? json['to_location'] ?? '',
      price: json['price'] != null ? int.parse(json['price'].toString()) : 0,
      description: json['description'],
    );
  }
}
