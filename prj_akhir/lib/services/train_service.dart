// lib/services/train_service.dart
import '../models/train.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class TrainService {
  final ApiService _apiService = ApiService();

  // Get all trains with optional filters
  Future<ApiResponse<List<Train>>> getTrains({
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
        '${AppConstants.baseUrl}${AppConstants.trainsEndpoint}',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data as List;
        final trains = data.map((item) => Train.fromJson(item)).toList();
        return ApiResponse<List<Train>>(
          success: true,
          message: response.message,
          data: trains,
        );
      }

      return ApiResponse<List<Train>>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<Train>>.error('Terjadi kesalahan: $e');
    }
  }

  // Get train detail by ID
  Future<ApiResponse<Train>> getTrainDetail(int id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.trainsEndpoint}/$id',
      );

      if (response.success && response.data != null) {
        final train = Train.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse<Train>(
          success: true,
          message: response.message,
          data: train,
        );
      }

      return ApiResponse<Train>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<Train>.error('Terjadi kesalahan: $e');
    }
  }
}
