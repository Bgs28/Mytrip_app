// lib/services/hotel_service.dart
import '../models/hotel.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class HotelService {
  final ApiService _apiService = ApiService();

  // Get all hotels with optional search
  Future<ApiResponse<List<Hotel>>> getHotels({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.hotelsEndpoint}',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data as List;
        final hotels = data.map((item) => Hotel.fromJson(item)).toList();
        return ApiResponse<List<Hotel>>(
          success: true,
          message: response.message,
          data: hotels,
        );
      }

      return ApiResponse<List<Hotel>>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<Hotel>>.error('Terjadi kesalahan: $e');
    }
  }

  // Get hotel detail by ID
  Future<ApiResponse<Hotel>> getHotelDetail(int id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.hotelsEndpoint}/$id',
      );

      if (response.success && response.data != null) {
        final hotel = Hotel.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse<Hotel>(
          success: true,
          message: response.message,
          data: hotel,
        );
      }

      return ApiResponse<Hotel>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<Hotel>.error('Terjadi kesalahan: $e');
    }
  }
}
