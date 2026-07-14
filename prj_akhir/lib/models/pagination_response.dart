// lib/models/pagination_response.dart
class PaginationResponse<T> {
  final List<T> data;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  PaginationResponse({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final dataList = json['data'] as List? ?? [];
    return PaginationResponse<T>(
      data: dataList.map((item) => fromJsonT(item)).toList(),
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }
}
