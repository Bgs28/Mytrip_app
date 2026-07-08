class TrainModel {
  final int id;
  final String name;
  final String fromLocation;
  final String toLocation;
  final int price;
  final String? description;

  TrainModel({
    required this.id,
    required this.name,
    required this.fromLocation,
    required this.toLocation,
    required this.price,
    this.description,
  });

  factory TrainModel.fromJson(Map<String, dynamic> json) {
    return TrainModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      fromLocation: json['from'] ?? json['from_location'] ?? '',
      toLocation: json['destination'] ?? json['to_location'] ?? '',
      price: json['price'] != null ? int.parse(json['price'].toString()) : 0,
      description: json['description'],
    );
  }
}
