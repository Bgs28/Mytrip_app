// lib/services/e_ticket_service.dart
import 'dart:convert';
import '../models/e_ticket.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class ETicketService {
  final ApiService _apiService = ApiService();

  // Get E-Ticket by booking ID
  Future<ApiResponse<Map<String, dynamic>>> getETicket(int bookingId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}/e-tickets/$bookingId',
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.message,
          data: data,
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

  // Check-in using check-in code
  Future<ApiResponse<ETicket>> checkIn(String checkInCode) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.baseUrl}/e-tickets/check-in',
        data: {'check_in_code': checkInCode},
      );

      if (response.success && response.data != null) {
        final eTicket = ETicket.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse<ETicket>(
          success: true,
          message: response.message,
          data: eTicket,
        );
      }

      return ApiResponse<ETicket>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<ETicket>.error('Terjadi kesalahan: $e');
    }
  }
}
