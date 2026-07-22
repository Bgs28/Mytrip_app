// lib/services/payment_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/payment.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  // Create payment
  Future<ApiResponse<Payment>> createPayment({
    required int bookingId,
    required String paymentMethod,
    String? promoCode,
    String? notes,
  }) async {
    try {
      final data = {'booking_id': bookingId, 'payment_method': paymentMethod};

      if (promoCode != null && promoCode.isNotEmpty) {
        data['promo_code'] = promoCode;
      }

      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }

      final response = await _apiService.post(
        '${AppConstants.baseUrl}/payments',
        data: data,
      );

      if (response.success && response.data != null) {
        final payment = Payment.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse<Payment>(
          success: true,
          message: response.message,
          data: payment,
        );
      }

      return ApiResponse<Payment>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<Payment>.error('Terjadi kesalahan: $e');
    }
  }

  // Upload proof of payment
  Future<ApiResponse<Payment>> uploadProof({
    required int paymentId,
    required File proofFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'proof_of_payment': await MultipartFile.fromFile(
          proofFile.path,
          filename: proofFile.path.split('/').last,
        ),
      });

      final response = await _apiService.dio.post(
        '${AppConstants.baseUrl}/payments/$paymentId/upload-proof',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          return ApiResponse<Payment>(
            success: true,
            message: data['message'] ?? 'Upload berhasil',
            data: payment,
          );
        }
        return ApiResponse<Payment>.error(
          data['message'] ?? 'Upload gagal',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<Payment>.error(
        'Upload gagal',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<Payment>.error('Terjadi kesalahan: $e');
    }
  }

  // Get payment detail
  Future<ApiResponse<Payment>> getPaymentDetail(int id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}/payments/$id',
      );

      if (response.success && response.data != null) {
        final payment = Payment.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse<Payment>(
          success: true,
          message: response.message,
          data: payment,
        );
      }

      return ApiResponse<Payment>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<Payment>.error('Terjadi kesalahan: $e');
    }
  }

  // Get payment history
  Future<ApiResponse<List<Payment>>> getPaymentHistory() async {
    try {
      final response = await _apiService.get(
        '${AppConstants.baseUrl}/payments/history',
      );

      if (response.success && response.data != null) {
        final data = response.data as List;
        final payments = data.map((item) => Payment.fromJson(item)).toList();
        return ApiResponse<List<Payment>>(
          success: true,
          message: response.message,
          data: payments,
        );
      }

      return ApiResponse<List<Payment>>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<Payment>>.error('Terjadi kesalahan: $e');
    }
  }
}
