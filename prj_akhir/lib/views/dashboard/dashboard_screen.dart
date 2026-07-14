// lib/views/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/train_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/trip_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart'; // Tambahkan import status_badge

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Bus', 'Kereta', 'Hotel'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final trainProvider = Provider.of<TrainProvider>(context, listen: false);
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      busProvider.loadBuses(),
      trainProvider.loadTrains(),
      hotelProvider.loadHotels(),
      bookingProvider.loadBookingHistory(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildCategoryFilter(),
                const SizedBox(height: 20),
                _buildQuickStats(),
                const SizedBox(height: 20),
                _buildPopularTrips(),
                const SizedBox(height: 20),
                _buildRecentBookings(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        return Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user?.name ?? 'Pengguna'}!',
                    style: AppTheme.heading3,
                  ),
                  Text('Ayo mulai perjalanan Anda', style: AppTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                AppHelpers.showSnackBar(
                  context,
                  'Fitur notifikasi akan segera hadir',
                );
              },
              icon: const Icon(Icons.notifications_outlined),
              color: AppTheme.primaryBlue,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari destinasi, hotel, atau tiket...',
          hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.grey),
          prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear, color: AppTheme.grey),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (value) {
          setState(() {});
        },
        onSubmitted: (value) {
          _performSearch(value);
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              _filterByCategory(category);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.lightGrey,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer3<BusProvider, TrainProvider, HotelProvider>(
      builder: (context, busProvider, trainProvider, hotelProvider, child) {
        final totalItems =
            busProvider.buses.length +
            trainProvider.trains.length +
            hotelProvider.hotels.length;

        return Row(
          children: [
            _buildStatCard(
              '🚌',
              busProvider.buses.length.toString(),
              'Bus Tersedia',
              Colors.blue,
            ),
            _buildStatCard(
              '🚆',
              trainProvider.trains.length.toString(),
              'Kereta Tersedia',
              Colors.purple,
            ),
            _buildStatCard(
              '🏨',
              hotelProvider.hotels.length.toString(),
              'Hotel Tersedia',
              Colors.orange,
            ),
            _buildStatCard(
              '📋',
              totalItems.toString(),
              'Total Item',
              Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String emoji, String count, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(count, style: AppTheme.heading4.copyWith(fontSize: 16)),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularTrips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('✨ Populer', style: AppTheme.heading3),
            TextButton(
              onPressed: () {
                // Navigasi ke tab Bus menggunakan Navigator
                // Karena kita tidak bisa akses _MainScreenState dari sini
                Navigator.pushNamed(context, '/main');
                // Setelah navigasi, kita bisa menggunakan arguments
              },
              child: Text('Lihat Semua', style: AppTheme.linkText),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer3<BusProvider, TrainProvider, HotelProvider>(
          builder: (context, busProvider, trainProvider, hotelProvider, child) {
            final allTrips = <Map<String, dynamic>>[];

            // Add buses
            for (var bus in busProvider.buses.take(2)) {
              allTrips.add({'data': bus, 'type': TripType.bus});
            }

            // Add trains
            for (var train in trainProvider.trains.take(2)) {
              allTrips.add({'data': train, 'type': TripType.train});
            }

            // Add hotels
            for (var hotel in hotelProvider.hotels.take(2)) {
              allTrips.add({'data': hotel, 'type': TripType.hotel});
            }

            // Shuffle and take 3
            allTrips.shuffle();
            final displayedTrips = allTrips.take(3).toList();

            if (displayedTrips.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('Belum ada data tersedia')),
              );
            }

            return SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayedTrips.length,
                itemBuilder: (context, index) {
                  final trip = displayedTrips[index];
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TripCard(
                      trip: trip['data'],
                      type: trip['type'],
                      onTap: () {
                        _navigateToDetail(trip['data'], trip['type']);
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentBookings() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final bookings = bookingProvider.bookings;
        final recentBookings = bookings.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📋 Booking Terbaru', style: AppTheme.heading3),
            const SizedBox(height: 12),
            if (bookingProvider.isLoading)
              const LoadingWidget()
            else if (recentBookings.isEmpty)
              const EmptyState(
                title: 'Belum Ada Booking',
                message: 'Mulai pesan tiket perjalanan Anda sekarang!',
                icon: Icons.history,
              )
            else
              Column(
                children: recentBookings.map((booking) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLightestBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            booking.typeIcon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.bookingCode,
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${booking.typeLabel} • ${AppHelpers.formatCurrency(booking.totalPrice.toDouble())}',
                                style: AppTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        // FIX: Gunakan StatusBadge widget atau AppHelpers.getStatusLabel
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppHelpers.getStatusColor(
                              booking.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppHelpers.getStatusLabel(
                              booking.status,
                            ), // FIX: Method sudah ada
                            style: TextStyle(
                              color: AppHelpers.getStatusColor(booking.status),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Future<void> _refreshData() async {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final trainProvider = Provider.of<TrainProvider>(context, listen: false);
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      busProvider.loadBuses(refresh: true),
      trainProvider.loadTrains(refresh: true),
      hotelProvider.loadHotels(refresh: true),
      bookingProvider.loadBookingHistory(refresh: true),
    ]);
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final trainProvider = Provider.of<TrainProvider>(context, listen: false);
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);

    busProvider.searchBuses(from: query, destination: query);

    trainProvider.searchTrains(from: query, destination: query);

    hotelProvider.searchHotels(query);

    AppHelpers.showSnackBar(
      context,
      'Menampilkan hasil pencarian untuk: $query',
    );
  }

  void _filterByCategory(String category) {
    if (category == 'Semua') {
      _loadData();
    } else {
      AppHelpers.showSnackBar(context, 'Menampilkan kategori: $category');
    }
  }

  void _navigateToDetail(dynamic trip, TripType type) {
    switch (type) {
      case TripType.bus:
        Navigator.pushNamed(context, '/bus-detail', arguments: trip.id);
        break;
      case TripType.train:
        Navigator.pushNamed(context, '/train-detail', arguments: trip.id);
        break;
      case TripType.hotel:
        Navigator.pushNamed(context, '/hotel-detail', arguments: trip.id);
        break;
    }
  }
}
