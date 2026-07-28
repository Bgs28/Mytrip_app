// lib/views/trips/bus_seat_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/bus_service.dart';
import '../../models/bus.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import '../payments/checkout_screen.dart';

class BusSeatSelectionScreen extends StatefulWidget {
  final int busId;
  final String busName;
  final int scheduleId;
  final String scheduleDate;
  final String departureTime;
  final int price;
  final String from;
  final String destination;

  const BusSeatSelectionScreen({
    super.key,
    required this.busId,
    required this.busName,
    required this.scheduleId,
    required this.scheduleDate,
    required this.departureTime,
    required this.price,
    required this.from,
    required this.destination,
  });

  @override
  State<BusSeatSelectionScreen> createState() => _BusSeatSelectionScreenState();
}

class _BusSeatSelectionScreenState extends State<BusSeatSelectionScreen> {
  final BusService _busService = BusService();
  List<Map<String, dynamic>> _seats = [];
  List<int> _selectedSeatIds = [];
  bool _isLoading = true;
  String? _error;
  int _availableSeats = 0;

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print(
        '📤 Loading bus seats for busId: ${widget.busId}, scheduleId: ${widget.scheduleId}',
      );

      final response = await _busService.getBusSeats(
        busId: widget.busId,
        scheduleId: widget.scheduleId,
      );

      print('📥 Response success: ${response.success}');
      print('📥 Response message: ${response.message}');
      print('📥 Response data: ${response.data}');

      if (!mounted) return;

      setState(() {
        if (response.success && response.data != null) {
          final data = response.data!;

          // Parse seats
          final seatsData = data['seats'];
          if (seatsData is List) {
            _seats = List<Map<String, dynamic>>.from(seatsData);
            print('✅ Seats loaded: ${_seats.length}');
          } else {
            _seats = [];
            print('⚠️ No seats data or invalid format');
          }

          // Parse schedule
          final scheduleData = data['schedule'];
          if (scheduleData is Map<String, dynamic>) {
            _availableSeats = (scheduleData['available_seats'] ?? 0) as int;
            print('✅ Available seats: $_availableSeats');
          } else {
            _availableSeats = 0;
            print('⚠️ No schedule data or invalid format');
          }
        } else {
          _error = response.message ?? 'Gagal memuat data kursi';
          print('❌ Error: $_error');
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
      print('❌ EXCEPTION: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Pilih Kursi'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          if (_selectedSeatIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  '${_selectedSeatIds.length} kursi',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
          ? ErrorWidgetCustom(message: _error!, onRetry: _loadSeats)
          : Column(
              children: [
                _buildTripInfo(),
                const SizedBox(height: 16),
                _buildSeatLegend(),
                const SizedBox(height: 8),
                _buildSeatLayout(),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildTripInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.busName,
                  style: AppTheme.heading3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${widget.from} → ${widget.destination}',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(widget.scheduleDate, style: AppTheme.bodySmall),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(widget.departureTime, style: AppTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppHelpers.formatCurrency(widget.price.toDouble()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const Text(
                '/ tiket',
                style: TextStyle(fontSize: 12, color: AppTheme.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            'Tersedia',
            AppTheme.primaryLightestBlue,
            AppTheme.primaryBlue,
          ),
          const SizedBox(width: 16),
          _buildLegendItem('Dipilih', AppTheme.primaryBlue, Colors.white),
          const SizedBox(width: 16),
          _buildLegendItem('Sudah Dipesan', AppTheme.lightGrey, AppTheme.grey),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color bgColor, Color textColor) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: textColor.withOpacity(0.3)),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: AppTheme.grey)),
      ],
    );
  }

  Widget _buildSeatLayout() {
    // Layout 2-2
    final columns = 4;
    final rows = (_seats.length / columns).ceil();

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Bus icon
            Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.directions_bus,
                size: 32,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Seat grid
            ...List.generate(rows, (rowIndex) {
              final startIndex = rowIndex * columns;
              final endIndex = (startIndex + columns) > _seats.length
                  ? _seats.length
                  : startIndex + columns;
              final rowSeats = _seats.sublist(startIndex, endIndex);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left side (2 seats)
                    ...rowSeats
                        .sublist(0, rowSeats.length > 2 ? 2 : rowSeats.length)
                        .map((seat) {
                          return _buildSeatWidget(seat);
                        }),
                    // Aisle
                    if (rowSeats.length > 2)
                      Container(
                        width: 20,
                        alignment: Alignment.center,
                        child: Text(
                          '|',
                          style: TextStyle(
                            color: AppTheme.lightGrey,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    // Right side (2 seats)
                    if (rowSeats.length > 2)
                      ...rowSeats.sublist(2).map((seat) {
                        return _buildSeatWidget(seat);
                      }),
                    // Empty placeholders
                    if (rowSeats.length < 2)
                      ...List.generate(
                        2 - rowSeats.length,
                        (_) => Container(width: 40),
                      ),
                    if (rowSeats.length < 4)
                      ...List.generate(
                        4 - rowSeats.length,
                        (_) => Container(width: 40),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            // Info kursi yang dipilih
            if (_selectedSeatIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightestBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kursi terpilih: ${_selectedSeatIds.length} kursi',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatWidget(Map<String, dynamic> seat) {
    final seatId = seat['id'] ?? 0;
    final seatCode = seat['seat_code'] ?? '?';
    final isAvailable = seat['is_available'] ?? false;
    final isBooked = seat['is_booked'] ?? false;
    final isSelected = _selectedSeatIds.contains(seatId);

    Color bgColor;
    Color textColor;
    bool isClickable;

    if (isBooked) {
      bgColor = AppTheme.lightGrey;
      textColor = AppTheme.grey;
      isClickable = false;
    } else if (isSelected) {
      bgColor = AppTheme.primaryBlue;
      textColor = Colors.white;
      isClickable = true;
    } else if (isAvailable) {
      bgColor = AppTheme.primaryLightestBlue;
      textColor = AppTheme.primaryBlue;
      isClickable = true;
    } else {
      bgColor = AppTheme.lightGrey;
      textColor = AppTheme.grey;
      isClickable = false;
    }

    return GestureDetector(
      onTap: isClickable
          ? () {
              setState(() {
                if (isSelected) {
                  _selectedSeatIds.remove(seatId);
                } else {
                  _selectedSeatIds.add(seatId);
                }
              });
            }
          : null,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isBooked
                ? AppTheme.grey.withOpacity(0.3)
                : (isSelected
                      ? AppTheme.primaryBlue
                      : (isAvailable
                            ? AppTheme.primaryBlue.withOpacity(0.3)
                            : AppTheme.grey.withOpacity(0.3))),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: Center(
          child: Text(
            seatCode,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final totalPrice = widget.price * _selectedSeatIds.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kursi Tersisa', style: AppTheme.bodySmall),
                  Text(
                    '$_availableSeats kursi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _availableSeats > 0
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total', style: AppTheme.bodySmall),
                  Text(
                    AppHelpers.formatCurrency(totalPrice.toDouble()),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  if (_selectedSeatIds.isNotEmpty)
                    Text(
                      '${_selectedSeatIds.length} kursi × ${AppHelpers.formatCurrency(widget.price.toDouble())}',
                      style: AppTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_availableSeats == 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.error),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: AppTheme.error),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Maaf, kursi sudah habis. Silahkan pilih jadwal lain.',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          CustomButton(
            text: _selectedSeatIds.isEmpty
                ? 'Pilih Kursi Terlebih Dahulu'
                : 'Lanjutkan ke Pembayaran',
            onPressed: _selectedSeatIds.isEmpty || _availableSeats == 0
                ? null
                : () => _navigateToCheckout(totalPrice),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(int totalPrice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          args: {
            'type': 'bus',
            'itemId': widget.busId,
            'name': widget.busName,
            'price': totalPrice,
            'from': widget.from,
            'destination': widget.destination,
            'departureTime': widget.departureTime,
            'scheduleId': widget.scheduleId,
            'seatIds': _selectedSeatIds,
            'seatCount': _selectedSeatIds.length,
          },
        ),
      ),
    );
  }
}
