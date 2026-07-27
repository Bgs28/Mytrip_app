// lib/services/train_service.dart
import '../models/train.dart';
import '../models/train_schedule.dart';
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

  Future<ApiResponse<List<TrainSchedule>>> getTrainSchedules(
    int trainId,
  ) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.trainsEndpoint}/$trainId/schedules',
      );

      if (response.success && response.data != null) {
        final data = response.data as List;
        final schedules = data
            .map((item) => TrainSchedule.fromJson(item))
            .toList();
        return ApiResponse<List<TrainSchedule>>(
          success: true,
          message: response.message,
          data: schedules,
        );
      }

      return ApiResponse<List<TrainSchedule>>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<TrainSchedule>>.error('Terjadi kesalahan: $e');
    }
  }

  // Get train seats with availability for a schedule
  Future<ApiResponse<List<Map<String, dynamic>>>> getTrainSeats({
    required int trainId,
    required int scheduleId,
  }) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.trainsEndpoint}/$trainId/seats',
        queryParameters: {'schedule_id': scheduleId},
      );

      if (response.success && response.data != null) {
        final data = response.data as List;
        return ApiResponse<List<Map<String, dynamic>>>(
          success: true,
          message: response.message,
          data: data.map((item) => item as Map<String, dynamic>).toList(),
        );
      }

      return ApiResponse<List<Map<String, dynamic>>>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>.error(
        'Terjadi kesalahan: $e',
      );
    }
  }

  // Book train seats
  Future<ApiResponse<Map<String, dynamic>>> bookTrainSeats({
    required int trainId,
    required int scheduleId,
    required List<int> seatIds,
    required String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.baseUrl}${AppConstants.trainsEndpoint}/$trainId/book',
        data: {'schedule_id': scheduleId, 'seat_ids': seatIds, 'notes': notes},
      );

      if (response.success && response.data != null) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.message,
          data: response.data as Map<String, dynamic>?,
        );
      }

      return ApiResponse<Map<String, dynamic>>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error('Terjadi kesalahan: $e');
    }
  }
}
