// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Register
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '${AppConstants.baseUrl}${AppConstants.registerEndpoint}',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Registrasi berhasil',
          data: data,
        );
      }

      return ApiResponse<Map<String, dynamic>>.error(
        'Registrasi gagal',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String message = 'Registrasi gagal';
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          message = errors.values.first.first;
        }
      }
      return ApiResponse<Map<String, dynamic>>.error(
        message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error('Terjadi kesalahan: $e');
    }
  }

  // Login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '${AppConstants.baseUrl}${AppConstants.loginEndpoint}',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Save token
        if (data.containsKey('token')) {
          await _apiService.setToken(data['token']);
        }

        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Login berhasil',
          data: data,
        );
      }

      return ApiResponse<Map<String, dynamic>>.error(
        'Login gagal',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String message = 'Email atau password salah';
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        }
      }
      return ApiResponse<Map<String, dynamic>>.error(
        message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error('Terjadi kesalahan: $e');
    }
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    try {
      await _apiService.dio.post(
        '${AppConstants.baseUrl}${AppConstants.logoutEndpoint}',
      );
      await _apiService.clearToken();
      return ApiResponse<void>(success: true, message: 'Logout berhasil');
    } on DioException catch (e) {
      // Even if logout fails, clear token locally
      await _apiService.clearToken();
      return ApiResponse<void>.error(
        'Gagal logout: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      await _apiService.clearToken();
      return ApiResponse<void>.error('Terjadi kesalahan: $e');
    }
  }

  // Get Current User
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _apiService.dio.get(
        '${AppConstants.baseUrl}${AppConstants.userEndpoint}',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data.containsKey('data')) {
          final user = User.fromJson(data['data']);
          return ApiResponse<User>(
            success: true,
            message: 'Data user berhasil diambil',
            data: user,
          );
        }
        return ApiResponse<User>.error('Data user tidak valid');
      }

      return ApiResponse<User>.error(
        'Gagal mengambil data user',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse<User>.error(
        'Gagal mengambil data user: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<User>.error('Terjadi kesalahan: $e');
    }
  }
}
