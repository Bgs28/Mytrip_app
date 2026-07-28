// lib/providers/hotel_provider.dart
import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../models/api_response.dart';
import '../services/hotel_service.dart';

class HotelProvider extends ChangeNotifier {
  final HotelService _hotelService = HotelService();

  List<Hotel> _hotels = [];
  Hotel? _selectedHotel;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Hotel> get hotels => _hotels;
  Hotel? get selectedHotel => _selectedHotel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Load all hotels with search
  Future<void> loadHotels({String? search, bool refresh = false}) async {
    if (!refresh && _hotels.isNotEmpty && search == null) return;

    _setLoading(true);
    _error = null;

    // Reset search state saat refresh tanpa query
    if (refresh && search == null) {
      _searchQuery = '';
    }

    final effectiveSearch = (search ?? _searchQuery).isNotEmpty
        ? (search ?? _searchQuery)
        : null;

    try {
      final response = await _hotelService.getHotels(search: effectiveSearch);

      if (response.success && response.data != null) {
        _hotels = response.data!;
        if (search != null) _searchQuery = search;
      } else {
        _error = response.message;
        _hotels = [];
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _hotels = [];
    }

    _setLoading(false);
  }

  // Search hotels
  Future<void> searchHotels(String query) async {
    _setLoading(true);
    _error = null;
    _searchQuery = query;

    try {
      final response = await _hotelService.getHotels(
        search: query.isNotEmpty ? query : null,
      );

      if (response.success && response.data != null) {
        _hotels = response.data!;
      } else {
        _error = response.message;
        _hotels = [];
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _hotels = [];
    }

    _setLoading(false);
  }

  // Get hotel detail by ID
  Future<bool> loadHotelDetail(int id) async {
    _setLoading(true);
    _error = null;
    _selectedHotel = null;

    try {
      final response = await _hotelService.getHotelDetail(id);

      if (response.success && response.data != null) {
        _selectedHotel = response.data;
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

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Clear selected hotel
  void clearSelectedHotel() {
    _selectedHotel = null;
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
