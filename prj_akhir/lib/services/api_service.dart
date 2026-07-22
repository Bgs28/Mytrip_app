// lib/services/api_service.dart - Tambahkan method patch

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/api_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  Dio get dio => _dio;

  Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    await _loadToken();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          debugPrint('🚀 Request: ${options.method} ${options.path}');
          debugPrint('📦 Headers: ${options.headers}');
          debugPrint('📦 Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ Response: ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('❌ Error: ${error.message}');
          debugPrint('❌ Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(AppConstants.tokenKey);
    } catch (e) {
      debugPrint('Error loading token: $e');
    }
  }

  Future<void> setToken(String token) async {
    _token = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  Future<void> clearToken() async {
    _token = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
    } catch (e) {
      debugPrint('Error clearing token: $e');
    }
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (fromJsonT != null) {
          return ApiResponse<T>(
            success: data['success'] ?? true,
            message: data['message'] ?? 'Success',
            data: fromJsonT(data),
          );
        }
        return ApiResponse<T>(
          success: data['success'] ?? true,
          message: data['message'] ?? 'Success',
          data: data['data'] as T?,
        );
      }

      return ApiResponse<T>.error(
        'Failed to fetch data',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error('Unexpected error: $e');
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      debugPrint('📤 POST Request: $endpoint');
      debugPrint('📤 Data: $data');

      final response = await _dio.post(endpoint, data: data);

      debugPrint('📥 Response: ${response.statusCode}');
      debugPrint('📥 Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (fromJsonT != null) {
          return ApiResponse<T>(
            success: responseData['success'] ?? true,
            message: responseData['message'] ?? 'Success',
            data: fromJsonT(responseData),
          );
        }
        return ApiResponse<T>(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Success',
          data: responseData['data'] as T?,
        );
      }

      return ApiResponse<T>.error(
        'Failed to post data',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      return _handleError<T>(e);
    } catch (e) {
      debugPrint('❌ Error: $e');
      return ApiResponse<T>.error('Unexpected error: $e');
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (fromJsonT != null) {
          return ApiResponse<T>(
            success: responseData['success'] ?? true,
            message: responseData['message'] ?? 'Success',
            data: fromJsonT(responseData),
          );
        }
        return ApiResponse<T>(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Success',
          data: responseData['data'] as T?,
        );
      }

      return ApiResponse<T>.error(
        'Failed to update data',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error('Unexpected error: $e');
    }
  }

  // Generic PATCH request - TAMBAHKAN METHOD INI
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      debugPrint('📤 PATCH Request: $endpoint');
      debugPrint('📤 Data: $data');

      final response = await _dio.patch(endpoint, data: data);

      debugPrint('📥 Response: ${response.statusCode}');
      debugPrint('📥 Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (fromJsonT != null) {
          return ApiResponse<T>(
            success: responseData['success'] ?? true,
            message: responseData['message'] ?? 'Success',
            data: fromJsonT(responseData),
          );
        }
        return ApiResponse<T>(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Success',
          data: responseData['data'] as T?,
        );
      }

      return ApiResponse<T>.error(
        'Failed to patch data',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      return _handleError<T>(e);
    } catch (e) {
      debugPrint('❌ Error: $e');
      return ApiResponse<T>.error('Unexpected error: $e');
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final response = await _dio.delete(endpoint);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.data;
        if (fromJsonT != null && responseData != null) {
          return ApiResponse<T>(
            success: responseData['success'] ?? true,
            message: responseData['message'] ?? 'Success',
            data: fromJsonT(responseData),
          );
        }
        return ApiResponse<T>(
          success: true,
          message: 'Data deleted successfully',
        );
      }

      return ApiResponse<T>.error(
        'Failed to delete data',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error('Unexpected error: $e');
    }
  }

  // Error handler
  ApiResponse<T> _handleError<T>(DioException e) {
    String message = 'Terjadi kesalahan pada server';

    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        message = data['message'];
      } else if (data is Map && data.containsKey('error')) {
        message = data['error'];
      } else {
        message = 'Server error: ${e.response?.statusCode}';
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Koneksi timeout. Periksa koneksi internet Anda';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Tidak dapat terhubung ke server';
    } else if (e.type == DioExceptionType.unknown) {
      message = 'Terjadi kesalahan jaringan';
    }

    return ApiResponse<T>.error(message, statusCode: e.response?.statusCode);
  }
}
