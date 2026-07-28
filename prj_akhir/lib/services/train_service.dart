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

  // Get train schedules
  Future<ApiResponse<List<TrainSchedule>>> getTrainSchedules(
    int trainId,
  ) async {
    try {
      print('📤 Fetching train schedules for trainId: $trainId');

      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.trainsEndpoint}/$trainId/schedules',
      );

      print('📥 Response success: ${response.success}');
      print('📥 Response data type: ${response.data.runtimeType}');
      print('📥 Response data: ${response.data}');

      if (response.success && response.data != null) {
        List<TrainSchedule> schedules = [];

        // Jika response.data adalah List langsung
        if (response.data is List) {
          final listData = response.data as List;
          print('📦 List data length: ${listData.length}');

          // Cek tipe data di dalam list
          if (listData.isNotEmpty) {
            final firstItem = listData.first;
            print('📦 First item type: ${firstItem.runtimeType}');

            // Jika sudah berupa TrainSchedule
            if (firstItem is TrainSchedule) {
              schedules = listData.cast<TrainSchedule>();
              print('✅ Already TrainSchedule objects');
            }
            // Jika berupa Map
            else if (firstItem is Map<String, dynamic>) {
              schedules = listData
                  .map(
                    (item) =>
                        TrainSchedule.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
              print('✅ Parsed from Map');
            }
            // Unknown type
            else {
              print('⚠️ Unknown item type: ${firstItem.runtimeType}');
            }
          }
        }
        // Jika response.data adalah Map dengan key 'data'
        else if (response.data is Map) {
          final dataMap = response.data as Map;
          if (dataMap.containsKey('data')) {
            final listData = dataMap['data'];
            if (listData is List) {
              if (listData.isNotEmpty && listData.first is Map) {
                schedules = listData
                    .map(
                      (item) =>
                          TrainSchedule.fromJson(item as Map<String, dynamic>),
                    )
                    .toList();
              } else if (listData.isNotEmpty &&
                  listData.first is TrainSchedule) {
                schedules = listData.cast<TrainSchedule>();
              }
            }
          }
        }

        print('✅ Schedules parsed: ${schedules.length}');

        return ApiResponse<List<TrainSchedule>>(
          success: true,
          message: response.message,
          data: schedules,
        );
      }

      return ApiResponse<List<TrainSchedule>>.error(
        response.message ?? 'Gagal mengambil jadwal',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Error fetching train schedules: $e');
      return ApiResponse<List<TrainSchedule>>.error('Terjadi kesalahan: $e');
    }
  }

  // Get train seats with availability for a schedule
  Future<ApiResponse<Map<String, dynamic>>> getTrainSeats({
    required int trainId,
    required int scheduleId,
  }) async {
    try {
      print(
        '📤 Fetching train seats for trainId: $trainId, scheduleId: $scheduleId',
      );

      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.trainsEndpoint}/$trainId/seats',
        queryParameters: {'schedule_id': scheduleId},
      );

      print('📥 Response success: ${response.success}');
      print('📥 Response data type: ${response.data.runtimeType}');
      print('📥 Response data: ${response.data}');

      if (response.success && response.data != null) {
        // Response data harus berupa Map<String, dynamic>
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;

          // Validasi struktur data
          if (!data.containsKey('seats')) {
            print('⚠️ Response missing "seats" key');
            return ApiResponse<Map<String, dynamic>>.error(
              'Data kursi tidak valid',
              statusCode: response.statusCode,
            );
          }

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: response.message,
            data: data,
          );
        } else {
          print('⚠️ Response data is not a Map');
          return ApiResponse<Map<String, dynamic>>.error(
            'Format data tidak valid',
            statusCode: response.statusCode,
          );
        }
      }

      return ApiResponse<Map<String, dynamic>>.error(
        response.message ?? 'Gagal mengambil kursi',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Error fetching train seats: $e');
      return ApiResponse<Map<String, dynamic>>.error('Terjadi kesalahan: $e');
    }
  }

  // Book train seats
  Future<ApiResponse<Map<String, dynamic>>> bookTrainSeats({
    required int trainId,
    required int scheduleId,
    required List<int> seatIds,
    required String? notes,
    int? bookingId,
  }) async {
    try {
      print('📤 Booking train seats:');
      print('   trainId: $trainId');
      print('   scheduleId: $scheduleId');
      print('   seatIds: $seatIds');
      print('   bookingId: $bookingId');
      print('   notes: $notes');

      final data = <String, dynamic>{
        'schedule_id': scheduleId,
        'seat_ids': seatIds,
        'notes': notes,
      };
      if (bookingId != null) data['booking_id'] = bookingId;

      final response = await _apiService.post(
        '${AppConstants.baseUrl}${AppConstants.trainsEndpoint}/$trainId/book',
        data: data,
      );

      print('📥 Response: ${response.success}');
      print('📥 Message: ${response.message}');
      print('📥 Data: ${response.data}');

      if (response.success && response.data != null) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.message,
          data: response.data as Map<String, dynamic>?,
        );
      }

      return ApiResponse<Map<String, dynamic>>.error(
        response.message ?? 'Gagal booking kereta',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Error booking train: $e');
      return ApiResponse<Map<String, dynamic>>.error('Terjadi kesalahan: $e');
    }
  }
}
