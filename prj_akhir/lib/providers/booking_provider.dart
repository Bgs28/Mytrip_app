// lib/providers/booking_provider.dart
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/api_response.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<Booking> _bookings = [];
  Booking? _selectedBooking;
  bool _isLoading = false;
  bool _isCreating = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get error => _error;

  // Load booking history
  Future<void> loadBookingHistory({bool refresh = false}) async {
    if (!refresh && _bookings.isNotEmpty) return;

    _setLoading(true);
    _error = null;

    try {
      final response = await _bookingService.getBookingHistory();

      if (response.success && response.data != null) {
        _bookings = response.data!;
      } else {
        _error = response.message;
        _bookings = [];
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _bookings = [];
    }

    _setLoading(false);
  }

  // Create new booking
  Future<bool> createBooking({
    required String type,
    required int itemId,
    required int totalPrice,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _bookingService.createBooking(
        type: type,
        itemId: itemId,
        totalPrice: totalPrice,
      );

      if (response.success && response.data != null) {
        // Add new booking to list
        _bookings.insert(0, response.data!);
        _selectedBooking = response.data;
        _isCreating = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isCreating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  // Get booking detail by ID
  Future<bool> loadBookingDetail(int id) async {
    _setLoading(true);
    _error = null;
    _selectedBooking = null;

    try {
      final response = await _bookingService.getBookingDetail(id);

      if (response.success && response.data != null) {
        _selectedBooking = response.data;
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

  // Clear selected booking
  void clearSelectedBooking() {
    _selectedBooking = null;
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
