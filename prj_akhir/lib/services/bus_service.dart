// lib/services/bus_service.dart
import '../models/bus.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class BusService {
  final ApiService _apiService = ApiService();

  // Get all buses with optional filters
  Future<ApiResponse<List<Bus>>> getBuses({
    String? from,
    String? destination,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (from != null && from.isNotEmpty) queryParams['from'] = from;
      if (destination != null && destination.isNotEmpty) {
        queryParams['destination'] = destination;
      }

      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.busesEndpoint}',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data as List;
        final buses = data.map((item) => Bus.fromJson(item)).toList();
        return ApiResponse<List<Bus>>(
          success: true,
          message: response.message,
          data: buses,
        );
      }

      return ApiResponse<List<Bus>>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<Bus>>.error('Terjadi kesalahan: $e');
    }
  }

  // Get bus detail by ID
  Future<ApiResponse<Bus>> getBusDetail(int id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.busesEndpoint}/$id',
      );

      if (response.success && response.data != null) {
        final bus = Bus.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse<Bus>(
          success: true,
          message: response.message,
          data: bus,
        );
      }

      return ApiResponse<Bus>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<Bus>.error('Terjadi kesalahan: $e');
    }
  }
}
