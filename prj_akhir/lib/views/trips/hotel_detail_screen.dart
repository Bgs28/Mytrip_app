// lib/views/trips/hotel_detail_screen.dart - Update dengan Rooms
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/room_service.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';
import 'hotel_rooms_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  final int hotelId;

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final RoomService _roomService = RoomService();
  List<Room> _rooms = [];
  bool _isLoadingRooms = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<HotelProvider>(context, listen: false);
    await provider.loadHotelDetail(widget.hotelId);
    await _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoadingRooms = true;
    });

    final response = await _roomService.getRoomsByHotel(widget.hotelId);

    if (mounted) {
      setState(() {
        if (response.success && response.data != null) {
          _rooms = response.data!;
        }
        _isLoadingRooms = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: Consumer<HotelProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(isFullScreen: true);
          }

          if (provider.error != null || provider.selectedHotel == null) {
            return ErrorWidgetCustom(
              message: provider.error ?? 'Data hotel tidak ditemukan',
              onRetry: _loadData,
            );
          }

          final hotel = provider.selectedHotel!;
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppTheme.white,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios),
                  color: AppTheme.black,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.hotel,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hotel.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hotel.location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHotelInfo(hotel),
                    const SizedBox(height: 16),
                    _buildDescription(hotel),
                    const SizedBox(height: 16),
                    _buildRoomsSection(hotel),
                    const SizedBox(height: 16),
                    _buildPriceAndRating(hotel),
                    const SizedBox(height: 24),
                    _buildBookButton(hotel),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHotelInfo(Hotel hotel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightestBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.hotel,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hotel.name, style: AppTheme.heading3),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hotel.location,
                              style: AppTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: 'Tersedia'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (hotel.rating != null) ...[
                  const Icon(Icons.star, color: AppTheme.warning, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    hotel.rating!.toString(),
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('/ 5', style: AppTheme.bodySmall),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 20, color: AppTheme.lightGrey),
                  const SizedBox(width: 12),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightestBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'HOTEL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
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

  Widget _buildDescription(Hotel hotel) {
    if (hotel.description == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📝 Deskripsi', style: AppTheme.heading4),
            const SizedBox(height: 8),
            Text(
              hotel.description!,
              style: AppTheme.bodyMedium.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsSection(Hotel hotel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🛏️ Kamar Tersedia', style: AppTheme.heading4),
                if (_rooms.isNotEmpty)
                  Text('${_rooms.length} kamar', style: AppTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingRooms)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_rooms.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: Text('Belum ada kamar tersedia')),
              )
            else
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _rooms.length > 5 ? 5 : _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    return _buildRoomCard(room, hotel);
                  },
                ),
              ),
            if (_rooms.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelRoomsScreen(
                          hotelId: hotel.id,
                          hotelName: hotel.name,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Lihat Semua Kamar (${_rooms.length})',
                    style: AppTheme.linkText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room, Hotel hotel) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: room.isAvailable ? Colors.white : AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: room.isAvailable ? AppTheme.primaryBlue : AppTheme.grey,
          width: 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLightestBlue,
                borderRadius: BorderRadius.circular(8),
                image: room.images != null && room.images!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(room.imageUrls.first),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              child: room.imageUrls.isEmpty
                  ? const Icon(
                      Icons.hotel,
                      color: AppTheme.primaryBlue,
                      size: 40,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              room.roomName,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            Text(
              AppHelpers.formatCurrency(room.pricePerNight.toDouble()),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            if (room.isAvailable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToRoomBooking(room, hotel);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Pilih', style: TextStyle(fontSize: 12)),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    'Tidak Tersedia',
                    style: TextStyle(fontSize: 12, color: AppTheme.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAndRating(Hotel hotel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💰 Harga per Malam', style: AppTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    _rooms.isNotEmpty
                        ? 'Mulai ${AppHelpers.formatCurrency(_rooms.map((r) => r.pricePerNight).reduce((a, b) => a < b ? a : b).toDouble())}'
                        : 'Harga belum tersedia',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 50, color: AppTheme.lightGrey),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('⭐ Rating', style: AppTheme.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: AppTheme.warning, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        hotel.rating?.toString() ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton(Hotel hotel) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<BookingProvider>(
          builder: (context, bookingProvider, child) {
            return CustomButton(
              text: 'Lihat Semua Kamar',
              onPressed: bookingProvider.isCreating
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelRoomsScreen(
                            hotelId: hotel.id,
                            hotelName: hotel.name,
                          ),
                        ),
                      );
                    },
              isFullWidth: true,
            );
          },
        );
      },
    );
  }

  void _navigateToRoomBooking(Room room, Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelRoomsScreen(
          hotelId: hotel.id,
          hotelName: hotel.name,
          selectedRoom: room,
        ),
      ),
    );
  }
}
