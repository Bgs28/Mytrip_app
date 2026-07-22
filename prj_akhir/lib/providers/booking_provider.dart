// lib/providers/booking_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../models/api_response.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final PaymentService _paymentService = PaymentService();

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
      print('📤 Creating booking with:');
      print('   type: $type');
      print('   itemId: $itemId');
      print('   totalPrice: $totalPrice');

      final response = await _bookingService.createBooking(
        type: type,
        itemId: itemId,
        totalPrice: totalPrice,
      );

      print('📥 Booking response success: ${response.success}');
      print('📥 Booking response data: ${response.data}');

      if (response.success && response.data != null) {
        final booking = response.data!;
        print('✅ Booking created: ${booking.id}');
        _bookings.insert(0, booking);
        _selectedBooking = booking;
        _isCreating = false;
        notifyListeners();
        return true;
      } else {
        print('❌ Booking failed: ${response.message}');
        _error = response.message;
        _isCreating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Booking error: $e');
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

  Future<Payment?> createBookingWithPayment({
    required String type,
    required int itemId,
    required int totalPrice,
    required String paymentMethod,
    String? promoCode,
    String? notes,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Create Booking
      final bookingResponse = await _bookingService.createBooking(
        type: type,
        itemId: itemId,
        totalPrice: totalPrice,
      );

      if (!bookingResponse.success || bookingResponse.data == null) {
        _error = bookingResponse.message;
        _isCreating = false;
        notifyListeners();
        return null;
      }

      final booking = bookingResponse.data!;

      // Step 2: Create Payment
      final paymentResponse = await _paymentService.createPayment(
        bookingId: booking.id,
        paymentMethod: paymentMethod,
        promoCode: promoCode,
        notes: notes,
      );

      if (!paymentResponse.success || paymentResponse.data == null) {
        _error = paymentResponse.message;
        _isCreating = false;
        notifyListeners();
        return null;
      }

      // Step 3: Add booking to list
      _bookings.insert(0, booking);
      _selectedBooking = booking;

      _isCreating = false;
      notifyListeners();

      return paymentResponse.data;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isCreating = false;
      notifyListeners();
      return null;
    }
  }

  // Upload proof for payment
  Future<bool> uploadPaymentProof({
    required int paymentId,
    required File proofFile,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _paymentService.uploadProof(
        paymentId: paymentId,
        proofFile: proofFile,
      );

      if (response.success) {
        // Refresh booking history to get updated status
        await loadBookingHistory(refresh: true);
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

  Future<bool> cancelBooking(int id) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _bookingService.cancelBooking(id);

      if (response.success && response.data != null) {
        // Update booking di list
        final index = _bookings.indexWhere((b) => b.id == id);
        if (index != -1) {
          _bookings[index] = response.data!;
        }

        // Update selected booking if it's the same
        if (_selectedBooking?.id == id) {
          _selectedBooking = response.data;
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
}
