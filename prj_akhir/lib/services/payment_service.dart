// lib/services/payment_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  // Upload proof of payment - FIX URL
  Future<ApiResponse<Payment>> uploadProof({
    required int paymentId,
    required File proofFile,
  }) async {
    try {
      // URL yang benar
      final url =
          '${AppConstants.baseUrl}${AppConstants.paymentsEndpoint}/$paymentId/upload-proof';
      // debugPrint('📤 Uploading to: $url');

      // Cek apakah file ada
      if (!await proofFile.exists()) {
        return ApiResponse<Payment>.error('File tidak ditemukan');
      }

      // Cek ukuran file
      final size = await proofFile.length();
      debugPrint('📦 File size: $size bytes');
      if (size > 2 * 1024 * 1024) {
        return ApiResponse<Payment>.error(
          'Ukuran file terlalu besar (maksimal 2MB)',
        );
      }

      // Deteksi ekstensi dan content-type dari nama file asli
      final originalPath = proofFile.path.toLowerCase();
      String ext;
      String mimeType;
      if (originalPath.endsWith('.png')) {
        ext = 'png';
        mimeType = 'image/png';
      } else if (originalPath.endsWith('.gif')) {
        ext = 'gif';
        mimeType = 'image/gif';
      } else {
        ext = 'jpg';
        mimeType = 'image/jpeg';
      }

      // Untuk semua platform, kita gunakan MultipartFile
      final bytes = await proofFile.readAsBytes();
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: 'proof_${DateTime.now().millisecondsSinceEpoch}.$ext',
        contentType: DioMediaType.parse(mimeType),
      );

      final formData = FormData.fromMap({'proof_of_payment': multipartFile});

      final response = await _apiService.dio.post(
        url,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
        'Upload gagal: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      debugPrint('❌ Status Code: ${e.response?.statusCode}');

      String message = 'Gagal upload bukti pembayaran';
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        }
      }
      return ApiResponse<Payment>.error(
        message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
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
