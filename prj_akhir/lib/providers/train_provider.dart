// lib/providers/train_provider.dart
import 'package:flutter/material.dart';
import '../models/train.dart';
import '../models/api_response.dart';
import '../services/train_service.dart';

class TrainProvider extends ChangeNotifier {
  final TrainService _trainService = TrainService();

  List<Train> _trains = [];
  Train? _selectedTrain;
  bool _isLoading = false;
  String? _error;
  String _searchFrom = '';
  String _searchDestination = '';

  List<Train> get trains => _trains;
  Train? get selectedTrain => _selectedTrain;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchFrom => _searchFrom;
  String get searchDestination => _searchDestination;

  // Load all trains with filters
  Future<void> loadTrains({
    String? from,
    String? destination,
    bool refresh = false,
  }) async {
    if (!refresh && _trains.isNotEmpty) return;

    _setLoading(true);
    _error = null;

    // Reset search state saat refresh tanpa filter
    if (refresh && from == null && destination == null) {
      _searchFrom = '';
      _searchDestination = '';
    }

    try {
      final response = await _trainService.getTrains(
        from: (from ?? _searchFrom).isNotEmpty ? (from ?? _searchFrom) : null,
        destination: (destination ?? _searchDestination).isNotEmpty
            ? (destination ?? _searchDestination)
            : null,
      );

      if (response.success && response.data != null) {
        _trains = response.data!;
        if (from != null) _searchFrom = from;
        if (destination != null) _searchDestination = destination;
      } else {
        _error = response.message;
        _trains = [];
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _trains = [];
    }

    _setLoading(false);
  }

  // Search trains
  Future<void> searchTrains({String? from, String? destination}) async {
    _setLoading(true);
    _error = null;
    _searchFrom = from ?? '';
    _searchDestination = destination ?? '';

    try {
      final response = await _trainService.getTrains(
        from: (from ?? '').isNotEmpty ? from : null,
        destination: (destination ?? '').isNotEmpty ? destination : null,
      );

      if (response.success && response.data != null) {
        _trains = response.data!;
      } else {
        _error = response.message;
        _trains = [];
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _trains = [];
    }

    _setLoading(false);
  }

  // Get train detail by ID
  Future<bool> loadTrainDetail(int id) async {
    _setLoading(true);
    _error = null;
    _selectedTrain = null;

    try {
      final response = await _trainService.getTrainDetail(id);

      if (response.success && response.data != null) {
        _selectedTrain = response.data;
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

  // Clear selected train
  void clearSelectedTrain() {
    _selectedTrain = null;
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
