// lib/views/trips/bus_detail_screen.dart - Update dengan Schedules
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/bus_service.dart';
import '../../models/bus.dart';
import '../../models/bus_schedule.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';
import 'bus_seat_selection_screen.dart';

class BusDetailScreen extends StatefulWidget {
  final int busId;

  const BusDetailScreen({super.key, required this.busId});

  @override
  State<BusDetailScreen> createState() => _BusDetailScreenState();
}

class _BusDetailScreenState extends State<BusDetailScreen> {
  final BusService _busService = BusService();
  List<BusSchedule> _schedules = [];
  bool _isLoadingSchedules = false;
  BusSchedule? _selectedSchedule;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<BusProvider>(context, listen: false);
    await provider.loadBusDetail(widget.busId);
    await _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoadingSchedules = true;
    });

    try {
      final response = await _busService.getBusSchedules(widget.busId);

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _schedules = response.data!;
            print('✅ Bus Schedules loaded: ${_schedules.length}');

            if (_schedules.isNotEmpty) {
              _selectedSchedule = _schedules.firstWhere(
                (s) => s.status == 'active',
                orElse: () => _schedules.first,
              );
              print('✅ Selected schedule: ${_selectedSchedule?.id}');
            }
          } else {
            print('❌ Failed to load bus schedules: ${response.message}');
            _error = response.message ?? 'Gagal memuat jadwal';
          }
          _isLoadingSchedules = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Terjadi kesalahan: $e';
          _isLoadingSchedules = false;
        });
      }
      print('❌ Error loading bus schedules: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: Consumer<BusProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(isFullScreen: true);
          }

          if (provider.error != null || provider.selectedBus == null) {
            return ErrorWidgetCustom(
              message: provider.error ?? 'Data bus tidak ditemukan',
              onRetry: _loadData,
            );
          }

          final bus = provider.selectedBus!;
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
                            Icons.directions_bus,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bus.busName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${bus.from} → ${bus.destination}',
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
                    _buildBusInfo(bus),
                    const SizedBox(height: 16),
                    _buildRouteInfo(bus),
                    const SizedBox(height: 16),
                    _buildScheduleSection(bus),
                    const SizedBox(height: 16),
                    _buildPriceAndSeat(bus),
                    const SizedBox(height: 24),
                    _buildBookButton(bus),
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

  Widget _buildBusInfo(Bus bus) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightestBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_bus,
                color: AppTheme.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bus.busName, style: AppTheme.heading3),
                  const SizedBox(height: 4),
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
                      'BUS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(
              status: bus.status == 'active' ? 'Tersedia' : 'Tidak Tersedia',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo(Bus bus) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🚏 Rute Perjalanan', style: AppTheme.heading4),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryLightestBlue,
                        child: Icon(
                          Icons.location_on,
                          color: AppTheme.primaryBlue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Kota Asal', style: AppTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        bus.from,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_forward, color: AppTheme.grey),
                      const SizedBox(height: 8),
                      Text('Durasi', style: AppTheme.bodySmall),
                      const SizedBox(height: 4),
                      if (_selectedSchedule != null)
                        Text(
                          _selectedSchedule!.arrivalTime,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        )
                      else
                        const Text('-', style: AppTheme.bodyMedium),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryLightestBlue,
                        child: Icon(
                          Icons.location_on,
                          color: AppTheme.primaryBlue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Kota Tujuan', style: AppTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        bus.destination,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection(Bus bus) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📅 Jadwal Keberangkatan', style: AppTheme.heading4),
            const SizedBox(height: 12),
            if (_isLoadingSchedules)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_schedules.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: Text('Belum ada jadwal tersedia')),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _schedules[index];
                    final isSelected = _selectedSchedule?.id == schedule.id;
                    return _buildScheduleCard(schedule, isSelected);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BusSchedule schedule, bool isSelected) {
    final isAvailable =
        schedule.status == 'active' && schedule.availableSeats > 0;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                _selectedSchedule = schedule;
              });
            }
          : null,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLightestBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : (isAvailable
                      ? AppTheme.lightGrey
                      : AppTheme.grey.withOpacity(0.3)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              schedule.departureDateFormatted,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isAvailable ? AppTheme.black : AppTheme.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  schedule.departureTime,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isAvailable ? AppTheme.black : AppTheme.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${schedule.availableSeats} kursi',
              style: TextStyle(
                fontSize: 11,
                color: isAvailable ? AppTheme.success : AppTheme.grey,
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryBlue,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAndSeat(Bus bus) {
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
                  const Text('💰 Harga Tiket', style: AppTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    _selectedSchedule != null
                        ? AppHelpers.formatCurrency(
                            _selectedSchedule!.price.toDouble(),
                          )
                        : AppHelpers.formatCurrency(bus.price.toDouble()),
                    style: const TextStyle(
                      fontSize: 24,
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
                  const Text('💺 Kursi Tersedia', style: AppTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    _selectedSchedule != null
                        ? '${_selectedSchedule!.availableSeats} kursi'
                        : '${bus.seat} kursi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          _selectedSchedule != null &&
                              _selectedSchedule!.availableSeats > 0
                          ? AppTheme.success
                          : AppTheme.error,
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

  Widget _buildBookButton(Bus bus) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<BookingProvider>(
          builder: (context, bookingProvider, child) {
            final isAvailable =
                _selectedSchedule != null &&
                _selectedSchedule!.status == 'active' &&
                _selectedSchedule!.availableSeats > 0;

            return CustomButton(
              text: _selectedSchedule == null
                  ? 'Pilih Jadwal Terlebih Dahulu'
                  : (isAvailable
                        ? 'Pilih Kursi Sekarang'
                        : 'Jadwal Tidak Tersedia'),
              onPressed: isAvailable && !bookingProvider.isCreating
                  ? () {
                      if (!authProvider.isLoggedIn) {
                        _showLoginRequired();
                        return;
                      }
                      _navigateToSeatSelection(bus);
                    }
                  : null,
              isFullWidth: true,
              backgroundColor: isAvailable
                  ? AppTheme.primaryBlue
                  : AppTheme.grey,
            );
          },
        );
      },
    );
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Diperlukan'),
        content: const Text(
          'Anda harus login terlebih dahulu untuk memesan tiket.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Login',
              style: TextStyle(color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSeatSelection(Bus bus) {
    if (_selectedSchedule == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusSeatSelectionScreen(
          busId: bus.id,
          busName: bus.busName,
          scheduleId: _selectedSchedule!.id,
          scheduleDate: _selectedSchedule!.departureDateFormatted,
          departureTime: _selectedSchedule!.departureTime,
          price: _selectedSchedule!.price,
          from: bus.from,
          destination: bus.destination,
        ),
      ),
    );
  }
}
