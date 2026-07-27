// lib/views/trips/train_detail_screen.dart - Update dengan Schedules
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/train_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/train_service.dart';
import '../../models/train.dart';
import '../../models/train_schedule.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';
import 'train_seat_selection_screen.dart';

class TrainDetailScreen extends StatefulWidget {
  final int trainId;

  const TrainDetailScreen({super.key, required this.trainId});

  @override
  State<TrainDetailScreen> createState() => _TrainDetailScreenState();
}

class _TrainDetailScreenState extends State<TrainDetailScreen> {
  final TrainService _trainService = TrainService();
  List<TrainSchedule> _schedules = [];
  bool _isLoadingSchedules = false;
  TrainSchedule? _selectedSchedule;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<TrainProvider>(context, listen: false);
    await provider.loadTrainDetail(widget.trainId);
    await _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoadingSchedules = true;
    });

    final response = await _trainService.getTrainSchedules(widget.trainId);

    if (mounted) {
      setState(() {
        if (response.success && response.data != null) {
          _schedules = response.data!;
          // Pilih schedule aktif pertama
          if (_schedules.isNotEmpty) {
            _selectedSchedule = _schedules.firstWhere(
              (s) => s.status == 'active',
              orElse: () => _schedules.first,
            );
          }
        }
        _isLoadingSchedules = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: Consumer<TrainProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(isFullScreen: true);
          }

          if (provider.error != null || provider.selectedTrain == null) {
            return ErrorWidgetCustom(
              message: provider.error ?? 'Data kereta tidak ditemukan',
              onRetry: _loadData,
            );
          }

          final train = provider.selectedTrain!;
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
                            Icons.train,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            train.trainName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${train.from} → ${train.destination}',
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
                    _buildTrainInfo(train),
                    const SizedBox(height: 16),
                    _buildRouteInfo(train),
                    const SizedBox(height: 16),
                    _buildScheduleSection(train),
                    const SizedBox(height: 16),
                    _buildPriceAndSeat(train),
                    const SizedBox(height: 24),
                    _buildBookButton(train),
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

  Widget _buildTrainInfo(Train train) {
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
                Icons.train,
                color: AppTheme.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(train.trainName, style: AppTheme.heading3),
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
                      'KERETA API',
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
              status: train.status == 'active' ? 'Tersedia' : 'Tidak Tersedia',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo(Train train) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🚉 Rute Perjalanan', style: AppTheme.heading4),
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
                      Text('Stasiun Asal', style: AppTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        train.from,
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
                      Text('Stasiun Tujuan', style: AppTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        train.destination,
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

  Widget _buildScheduleSection(Train train) {
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

  Widget _buildScheduleCard(TrainSchedule schedule, bool isSelected) {
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

  Widget _buildPriceAndSeat(Train train) {
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
                        : AppHelpers.formatCurrency(train.price.toDouble()),
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
                        : '${train.seat} kursi',
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

  Widget _buildBookButton(Train train) {
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
                      _navigateToSeatSelection(train);
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

  void _navigateToSeatSelection(Train train) {
    if (_selectedSchedule == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainSeatSelectionScreen(
          trainId: train.id,
          trainName: train.trainName,
          scheduleId: _selectedSchedule!.id,
          scheduleDate: _selectedSchedule!.departureDateFormatted,
          departureTime: _selectedSchedule!.departureTime,
          arrivalTime: _selectedSchedule!.arrivalTime,
          price: _selectedSchedule!.price,
          from: train.from,
          destination: train.destination,
        ),
      ),
    );
  }
}
