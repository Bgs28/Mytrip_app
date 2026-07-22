// lib/services/promo_service.dart
import '../models/promo.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class PromoService {
  final ApiService _apiService = ApiService();

  // Get all active promos
  Future<ApiResponse<List<Promo>>> getPromos({String? targetType}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (targetType != null && targetType != 'all') {
        queryParams['target_type'] = targetType;
      }

      final response = await _apiService.get(
        '${AppConstants.baseUrl}/promos',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data as List;
        final promos = data.map((item) => Promo.fromJson(item)).toList();
        return ApiResponse<List<Promo>>(
          success: true,
          message: response.message,
          data: promos,
        );
      }

      return ApiResponse<List<Promo>>.error(
        response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<Promo>>.error('Terjadi kesalahan: $e');
    }
  }

  // Validate promo code
  Future<ApiResponse<Map<String, dynamic>>> validatePromo({
    required String code,
    required double totalPrice,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.baseUrl}/promos/validate',
        data: {'code': code, 'total_price': totalPrice},
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
