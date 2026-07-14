// lib/providers/bus_provider.dart
import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../models/api_response.dart';
import '../services/bus_service.dart';

class BusProvider extends ChangeNotifier {
  final BusService _busService = BusService();

  List<Bus> _buses = [];
  Bus? _selectedBus;
  bool _isLoading = false;
  String? _error;
  String _searchFrom = '';
  String _searchDestination = '';

  List<Bus> get buses => _buses;
  Bus? get selectedBus => _selectedBus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchFrom => _searchFrom;
  String get searchDestination => _searchDestination;

  // Load all buses with filters
  Future<void> loadBuses({
    String? from,
    String? destination,
    bool refresh = false,
  }) async {
    if (!refresh && _buses.isNotEmpty) return;

    _setLoading(true);
    _error = null;

    try {
      final response = await _busService.getBuses(
        from: from ?? _searchFrom,
        destination: destination ?? _searchDestination,
      );

      if (response.success && response.data != null) {
        _buses = response.data!;
        if (from != null) _searchFrom = from;
        if (destination != null) _searchDestination = destination;
      } else {
        _error = response.message;
        _buses = [];
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _buses = [];
    }

    _setLoading(false);
  }

  // Search buses
  Future<void> searchBuses({String? from, String? destination}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _busService.getBuses(
        from: from,
        destination: destination,
      );

      if (response.success && response.data != null) {
        _buses = response.data!;
        if (from != null) _searchFrom = from;
        if (destination != null) _searchDestination = destination;
      } else {
        _error = response.message;
        _buses = [];
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _buses = [];
    }

    _setLoading(false);
  }

  // Get bus detail by ID
  Future<bool> loadBusDetail(int id) async {
    _setLoading(true);
    _error = null;
    _selectedBus = null;

    try {
      final response = await _busService.getBusDetail(id);

      if (response.success && response.data != null) {
        _selectedBus = response.data;
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

  // Clear search filters
  void clearSearch() {
    _searchFrom = '';
    _searchDestination = '';
    notifyListeners();
  }

  // Clear selected bus
  void clearSelectedBus() {
    _selectedBus = null;
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
