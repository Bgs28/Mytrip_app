class HotelModel {
  final int id;
  final String name;
  final String location;
  final int price;
  final String? description;

  HotelModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    this.description,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      price: json['price'] != null ? int.parse(json['price'].toString()) : 0,
      description: json['description'],
    );
  }
}
