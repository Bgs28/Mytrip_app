// lib/services/booking_service.dart
import '../models/booking.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class BookingService {
  final ApiService _apiService = ApiService();

  // Create new booking
  Future<ApiResponse<Booking>> createBooking({
    required String type, // 'bus', 'train', 'hotel'
    required int itemId,
    required int totalPrice,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.baseUrl}${AppConstants.bookingsEndpoint}',
        data: {'type': type, 'item_id': itemId, 'total_price': totalPrice},
      );

      if (response.success && response.data != null) {
        final booking = Booking.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse<Booking>(
          success: true,
          message: response.message,
          data: booking,
        );
      }

      return ApiResponse<Booking>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<Booking>.error('Terjadi kesalahan: $e');
    }
  }

  // Get booking history
  Future<ApiResponse<List<Booking>>> getBookingHistory() async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.bookingsEndpoint}/history',
      );

      if (response.success && response.data != null) {
        final data = response.data as List;
        final bookings = data.map((item) => Booking.fromJson(item)).toList();
        return ApiResponse<List<Booking>>(
          success: true,
          message: response.message,
          data: bookings,
        );
      }

      return ApiResponse<List<Booking>>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<Booking>>.error('Terjadi kesalahan: $e');
    }
  }

  // Get booking detail by ID
  Future<ApiResponse<Booking>> getBookingDetail(int id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}${AppConstants.bookingsEndpoint}/$id',
      );

      if (response.success && response.data != null) {
        final booking = Booking.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse<Booking>(
          success: true,
          message: response.message,
          data: booking,
        );
      }

      return ApiResponse<Booking>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<Booking>.error('Terjadi kesalahan: $e');
    }
  }
}
