// lib/views/trips/hotel_rooms_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/room_service.dart';
import '../../models/room.dart';
import '../../models/hotel.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../payments/checkout_screen.dart';

class HotelRoomsScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;
  final Room? selectedRoom;

  const HotelRoomsScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
    this.selectedRoom,
  });

  @override
  State<HotelRoomsScreen> createState() => _HotelRoomsScreenState();
}

class _HotelRoomsScreenState extends State<HotelRoomsScreen> {
  final RoomService _roomService = RoomService();
  List<Room> _rooms = [];
  bool _isLoading = true;
  String? _error;

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestsCount = 2;
  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.selectedRoom;
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _roomService.getRoomsByHotel(widget.hotelId);

    if (mounted) {
      setState(() {
        if (response.success && response.data != null) {
          _rooms = response.data!;
        } else {
          _error = response.message;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text('Pilih Kamar - ${widget.hotelName}'),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
          ? ErrorWidgetCustom(message: _error!, onRetry: _loadRooms)
          : Column(children: [_buildDateSelection(), _buildRoomList()]),
    );
  }

  Widget _buildDateSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📅 Pilih Tanggal', style: AppTheme.heading4),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: 'Check-in',
                  date: _checkInDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePicker(
                  label: 'Check-out',
                  date: _checkOutDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Jumlah Tamu',
                  hint: 'Jumlah tamu',
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: _guestsCount.toString(),
                  ),
                  onChanged: (value) {
                    final intVal = int.tryParse(value);
                    if (intVal != null && intVal > 0) {
                      setState(() {
                        _guestsCount = intVal;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Malam', style: AppTheme.bodySmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLightestBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _checkInDate != null && _checkOutDate != null
                            ? '${_checkOutDate!.difference(_checkInDate!).inDays} malam'
                            : '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightGrey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null ? AppHelpers.formatDate(date) : 'Pilih tanggal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: date != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: date != null ? AppTheme.black : AppTheme.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final now = DateTime.now();
    final initialDate = isCheckIn
        ? (_checkInDate ?? now)
        : (_checkOutDate ?? now.add(const Duration(days: 1)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppTheme.primaryBlue,
            colorScheme: ColorScheme.light(primary: AppTheme.primaryBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
            _checkOutDate = picked.add(const Duration(days: 1));
          }
        } else {
          if (_checkInDate != null && picked.isBefore(_checkInDate!)) {
            AppHelpers.showSnackBar(
              context,
              'Check-out harus setelah check-in',
              isError: true,
            );
            return;
          }
          _checkOutDate = picked;
        }
      });
    }
  }

  Widget _buildRoomList() {
    final availableRooms = _rooms.where((room) => room.isAvailable).toList();

    return Expanded(
      child: availableRooms.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel, size: 64, color: AppTheme.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada kamar tersedia', style: AppTheme.heading3),
                  SizedBox(height: 8),
                  Text('Silahkan cek hotel lain', style: AppTheme.bodyMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableRooms.length,
              itemBuilder: (context, index) {
                final room = availableRooms[index];
                final isSelected = _selectedRoom?.id == room.id;
                return _buildRoomItem(room, isSelected);
              },
            ),
    );
  }

  Widget _buildRoomItem(Room room, bool isSelected) {
    final isAvailable = _checkInDate != null && _checkOutDate != null;
    final totalPrice = isAvailable
        ? room.pricePerNight * _checkOutDate!.difference(_checkInDate!).inDays
        : room.pricePerNight;

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          width: 2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryLightestBlue,
                borderRadius: BorderRadius.circular(12),
                image: room.images != null && room.images!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(room.images![0]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: room.images == null || room.images!.isEmpty
                  ? const Icon(
                      Icons.hotel,
                      color: AppTheme.primaryBlue,
                      size: 40,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.roomName,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLightestBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          room.roomTypeLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${room.capacity} org',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        AppHelpers.formatCurrency(
                          room.pricePerNight.toDouble(),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      if (isAvailable) ...[
                        const Text(
                          ' / malam',
                          style: TextStyle(fontSize: 12, color: AppTheme.grey),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${_checkOutDate!.difference(_checkInDate!).inDays} malam',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isAvailable) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${AppHelpers.formatCurrency(totalPrice.toDouble())}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                const SizedBox(height: 8),
                if (isAvailable)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRoom = room;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.white,
                      foregroundColor: isSelected
                          ? AppTheme.white
                          : AppTheme.primaryBlue,
                      side: BorderSide(color: AppTheme.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      isSelected ? 'Dipilih' : 'Pilih',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to Checkout
  void _navigateToCheckout() {
    if (_selectedRoom == null) {
      AppHelpers.showSnackBar(
        context,
        'Silahkan pilih kamar terlebih dahulu',
        isError: true,
      );
      return;
    }

    if (_checkInDate == null || _checkOutDate == null) {
      AppHelpers.showSnackBar(
        context,
        'Silahkan pilih tanggal check-in dan check-out',
        isError: true,
      );
      return;
    }

    final totalPrice =
        _selectedRoom!.pricePerNight *
        _checkOutDate!.difference(_checkInDate!).inDays;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          args: {
            'type': 'hotel',
            'itemId': _selectedRoom!.id,
            'name': _selectedRoom!.roomName,
            'price': totalPrice,
            'hotelName': widget.hotelName,
            'roomNumber': _selectedRoom!.roomNumber,
            'checkIn': _checkInDate!.toIso8601String(),
            'checkOut': _checkOutDate!.toIso8601String(),
            'guestsCount': _guestsCount,
          },
        ),
      ),
    );
  }
}
