// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _apiService.init();
    await checkAuthStatus();
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _error = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token != null && token.isNotEmpty) {
        // Token exists, try to get user data
        final response = await _authService.getCurrentUser();

        if (response.success && response.data != null) {
          _user = response.data;
          _isLoggedIn = true;
        } else {
          // Token invalid or expired
          await _authService.logout();
          _user = null;
          _isLoggedIn = false;
        }
      } else {
        _user = null;
        _isLoggedIn = false;
      }
    } catch (e) {
      _error = 'Gagal memeriksa status login: $e';
      _user = null;
      _isLoggedIn = false;
    }

    _setLoading(false);
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data.containsKey('token')) {
          await _apiService.setToken(data['token']);

          // Parse user from response
          if (data.containsKey('user')) {
            _user = User.fromJson(data['user']);
            _isLoggedIn = true;
          }
        }
        _setLoading(false);
        return true;
      } else {
        _error = response.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _setLoading(false);
      return false;
    }
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        // Parse user from response
        if (data.containsKey('user')) {
          _user = User.fromJson(data['user']);
          _isLoggedIn = true;
        }

        _setLoading(false);
        return true;
      } else {
        _error = response.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _user = null;
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      _error = 'Gagal logout: $e';
    }

    _setLoading(false);
  }

  // Update user data locally
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
