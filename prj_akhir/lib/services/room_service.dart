// lib/services/room_service.dart
import '../models/room.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class RoomService {
  final ApiService _apiService = ApiService();

  // Get rooms by hotel ID
  Future<ApiResponse<List<Room>>> getRoomsByHotel(int hotelId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}/hotels/$hotelId/rooms',
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final roomsData = data['rooms'] as List? ?? [];
        final rooms = roomsData.map((item) => Room.fromJson(item)).toList();
        return ApiResponse<List<Room>>(
          success: true,
          message: response.message,
          data: rooms,
        );
      }

      return ApiResponse<List<Room>>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<Room>>.error('Terjadi kesalahan: $e');
    }
  }

  // Check room availability
  Future<ApiResponse<Map<String, dynamic>>> checkAvailability({
    required int roomId,
    required String checkIn,
    required String checkOut,
  }) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}/rooms/$roomId/availability',
        queryParameters: {'check_in': checkIn, 'check_out': checkOut},
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

  // Book a room
  Future<ApiResponse<Map<String, dynamic>>> bookRoom({
    required int roomId,
    required String checkIn,
    required String checkOut,
    required int guestsCount,
    List<String>? guestNames,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.baseUrl}/rooms/book',
        data: {
          'room_id': roomId,
          'check_in': checkIn,
          'check_out': checkOut,
          'guests_count': guestsCount,
          'guest_names': guestNames,
          'notes': notes,
        },
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
