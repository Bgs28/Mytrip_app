// lib/views/trips/train_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/train_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/train.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';

class TrainDetailScreen extends StatefulWidget {
  final int trainId;

  const TrainDetailScreen({super.key, required this.trainId});

  @override
  State<TrainDetailScreen> createState() => _TrainDetailScreenState();
}

class _TrainDetailScreenState extends State<TrainDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<TrainProvider>(context, listen: false);
    await provider.loadTrainDetail(widget.trainId);
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
                StatusBadge(status: 'Tersedia'),
              ],
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
                      const SizedBox(height: 4),
                      Text(
                        'Berangkat: ${train.departureTime}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: AppTheme.grey),
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
                      const SizedBox(height: 4),
                      Text(
                        'Tiba: ${train.arrivalTime}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightestBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimasi Perjalanan: ${_calculateDuration(train.departureTime, train.arrivalTime)}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
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

  String _calculateDuration(String departure, String arrival) {
    // Simple calculation - just return formatted string
    return '${departure} - ${arrival}';
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
                    AppHelpers.formatCurrency(train.price.toDouble()),
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
                    '${train.seat} kursi',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.success,
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
            return CustomButton(
              text: 'Pesan Tiket Sekarang',
              onPressed: bookingProvider.isCreating
                  ? null
                  : () async {
                      if (!authProvider.isLoggedIn) {
                        final shouldLogin = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            title: const Text('Login Diperlukan'),
                            content: const Text(
                              'Anda harus login terlebih dahulu untuk memesan tiket.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: AppTheme.primaryBlue),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogin == true && mounted) {
                          Navigator.pushNamed(context, '/login');
                        }
                        return;
                      }

                      final result = await Navigator.pushNamed(
                        context,
                        '/checkout',
                        arguments: {
                          'type': 'train',
                          'itemId': train.id,
                          'name': train.trainName,
                          'price': train.price,
                          'from': train.from,
                          'destination': train.destination,
                          'departureTime': train.departureTime,
                          'arrivalTime': train.arrivalTime,
                        },
                      );

                      if (result == true && mounted) {
                        AppHelpers.showSnackBar(
                          context,
                          'Pemesanan berhasil! Silahkan cek riwayat booking.',
                        );
                      }
                    },
              isLoading: bookingProvider.isCreating,
              isFullWidth: true,
            );
          },
        );
      },
    );
  }
}
