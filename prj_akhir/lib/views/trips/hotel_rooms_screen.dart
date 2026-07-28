// lib/views/trips/hotel_rooms_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/room_service.dart';
import '../../models/room.dart';
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
  final TextEditingController _guestController = TextEditingController();
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
    _guestController.text = _guestsCount.toString();
    _loadRooms();
  }

  @override
  void dispose() {
    _guestController.dispose();
    super.dispose();
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
          ? ErrorWidgetCustom(message: _error!, onRetry: _loadRooms)
          : Column(
              children: [
                _buildDateSelection(),
                Expanded(child: _buildRoomList()),
                if (_selectedRoom != null &&
                    _checkInDate != null &&
                    _checkOutDate != null)
                  _buildBottomBar(),
              ],
            ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jumlah Tamu', style: AppTheme.bodySmall),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.lightGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_guestsCount > 1) {
                                setState(() {
                                  _guestsCount--;
                                  _guestController.text = _guestsCount
                                      .toString();
                                });
                              }
                            },
                            icon: const Icon(Icons.remove, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _guestController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
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
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _guestsCount++;
                                _guestController.text = _guestsCount.toString();
                              });
                            },
                            icon: const Icon(Icons.add, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Malam', style: AppTheme.bodySmall),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLightestBlue,
                        borderRadius: BorderRadius.circular(8),
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
          border: Border.all(
            color: date != null ? AppTheme.primaryBlue : AppTheme.lightGrey,
            width: date != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: date != null ? AppTheme.primaryLightestBlue : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: date != null ? AppTheme.primaryBlue : AppTheme.grey,
                fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: date != null ? AppTheme.primaryBlue : AppTheme.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Pilih tanggal',
                  style: TextStyle(
                    fontSize: 13,
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
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
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

    if (availableRooms.isEmpty) {
      return const Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableRooms.length,
      itemBuilder: (context, index) {
        final room = availableRooms[index];
        final isSelected = _selectedRoom?.id == room.id;
        return _buildRoomItem(room, isSelected);
      },
    );
  }

  Widget _buildRoomItem(Room room, bool isSelected) {
    final isAvailable = _checkInDate != null && _checkOutDate != null;
    final nights = isAvailable
        ? _checkOutDate!.difference(_checkInDate!).inDays
        : 0;
    final totalPrice = isAvailable
        ? room.pricePerNight * nights
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
                      const Text(
                        ' / malam',
                        style: TextStyle(fontSize: 12, color: AppTheme.grey),
                      ),
                      if (isAvailable && nights > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• $nights malam',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isAvailable && nights > 0) ...[
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

  Widget _buildBottomBar() {
    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    final totalPrice = _selectedRoom!.pricePerNight * nights;

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total Harga', style: AppTheme.bodySmall),
                Text(
                  AppHelpers.formatCurrency(totalPrice.toDouble()),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Text(
                  '${_selectedRoom!.roomName} • $nights malam',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          CustomButton(
            text: 'Lanjut ke Pembayaran',
            onPressed: () => _navigateToCheckout(totalPrice),
            isFullWidth: false,
            width: 160,
            height: 45,
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
            'type': 'hotel',
            'itemId': _selectedRoom!.id,
            'name': _selectedRoom!.roomName,
            'price': totalPrice,
            'hotelName': widget.hotelName,
            'roomNumber': _selectedRoom!.roomNumber,
            'checkIn': _checkInDate!.toIso8601String(),
            'checkOut': _checkOutDate!.toIso8601String(),
            'guestsCount': _guestsCount,
            'roomType': _selectedRoom!.roomTypeLabel,
            'capacity': _selectedRoom!.capacity,
          },
        ),
      ),
    );
  }
}
