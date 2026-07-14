// lib/views/trips/hotel_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/hotel.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';

class HotelDetailScreen extends StatefulWidget {
  final int hotelId;

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<HotelProvider>(context, listen: false);
    await provider.loadHotelDetail(widget.hotelId);
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
                expandedHeight: 250,
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
              hotel.description ?? 'Tidak ada deskripsi untuk hotel ini.',
              style: AppTheme.bodyMedium.copyWith(height: 1.6),
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
                    AppHelpers.formatCurrency(hotel.price.toDouble()),
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
              text: 'Pesan Hotel Sekarang',
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
                              'Anda harus login terlebih dahulu untuk memesan hotel.',
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
                          'type': 'hotel',
                          'itemId': hotel.id,
                          'name': hotel.name,
                          'price': hotel.price,
                          'location': hotel.location,
                          'rating': hotel.rating,
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
