// lib/services/bus_service.dart
import '../models/bus.dart';
import '../models/bus_schedule.dart';
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

  // Get bus schedules
  Future<ApiResponse<List<BusSchedule>>> getBusSchedules(int busId) async {
    try {
      print('📤 Fetching bus schedules for busId: $busId');

      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.busesEndpoint}/$busId/schedules',
      );

      print('📥 Response success: ${response.success}');
      print('📥 Response data type: ${response.data.runtimeType}');
      print('📥 Response data: ${response.data}');

      if (response.success && response.data != null) {
        List<BusSchedule> schedules = [];

        if (response.data is List) {
          final listData = response.data as List;
          print('📦 List data length: ${listData.length}');

          if (listData.isNotEmpty) {
            final firstItem = listData.first;
            print('📦 First item type: ${firstItem.runtimeType}');

            if (firstItem is BusSchedule) {
              schedules = listData.cast<BusSchedule>();
              print('✅ Already BusSchedule objects');
            } else if (firstItem is Map<String, dynamic>) {
              schedules = listData
                  .map(
                    (item) =>
                        BusSchedule.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
              print('✅ Parsed from Map');
            } else {
              print('⚠️ Unknown item type: ${firstItem.runtimeType}');
            }
          }
        } else if (response.data is Map) {
          final dataMap = response.data as Map;
          if (dataMap.containsKey('data')) {
            final listData = dataMap['data'];
            if (listData is List) {
              if (listData.isNotEmpty && listData.first is Map) {
                schedules = listData
                    .map(
                      (item) =>
                          BusSchedule.fromJson(item as Map<String, dynamic>),
                    )
                    .toList();
              } else if (listData.isNotEmpty && listData.first is BusSchedule) {
                schedules = listData.cast<BusSchedule>();
              }
            }
          }
        }

        print('✅ Bus Schedules parsed: ${schedules.length}');

        return ApiResponse<List<BusSchedule>>(
          success: true,
          message: response.message,
          data: schedules,
        );
      }

      return ApiResponse<List<BusSchedule>>.error(
        response.message ?? 'Gagal mengambil jadwal',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Error fetching bus schedules: $e');
      return ApiResponse<List<BusSchedule>>.error('Terjadi kesalahan: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getBusSeats({
    required int busId,
    required int scheduleId,
  }) async {
    try {
      print('========================================');
      print('📤 BUS SERVICE: getBusSeats');
      print('   busId: $busId');
      print('   scheduleId: $scheduleId');
      print('========================================');

      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.busesEndpoint}/$busId/seats',
        queryParameters: {'schedule_id': scheduleId},
      );

      print('📥 BUS SERVICE RESPONSE:');
      print('   success: ${response.success}');
      print('   message: ${response.message}');
      print('   statusCode: ${response.statusCode}');
      print('   data type: ${response.data.runtimeType}');
      print('   data: ${response.data}');

      if (response.success && response.data != null) {
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          print('✅ Data is Map with keys: ${data.keys}');

          if (!data.containsKey('seats')) {
            print('❌ Response missing "seats" key');
            return ApiResponse<Map<String, dynamic>>.error(
              'Data kursi tidak valid: missing "seats"',
              statusCode: response.statusCode,
            );
          }

          final seatsData = data['seats'];
          print('📦 seatsData type: ${seatsData.runtimeType}');
          if (seatsData is List) {
            print('✅ seatsData is List with length: ${seatsData.length}');
          } else {
            print('❌ seatsData is NOT a List!');
          }

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: response.message,
            data: data,
          );
        } else {
          print('❌ Response data is not a Map');
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
      print('❌ EXCEPTION in getBusSeats: $e');
      return ApiResponse<Map<String, dynamic>>.error('Terjadi kesalahan: $e');
    }
  }

  // Book bus seats
  Future<ApiResponse<Map<String, dynamic>>> bookBusSeats({
    required int busId,
    required int scheduleId,
    required List<int> seatIds,
    required String? notes,
    int? bookingId,
  }) async {
    try {
      print('📤 Booking bus seats:');
      print('   busId: $busId');
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
        '${AppConstants.baseUrl}${AppConstants.busesEndpoint}/$busId/book',
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
        response.message ?? 'Gagal booking bus',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Error booking bus: $e');
      return ApiResponse<Map<String, dynamic>>.error('Terjadi kesalahan: $e');
    }
  }
}
