// lib/views/bookings/booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/train_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/booking.dart';
import '../../models/bus.dart';
import '../../models/train.dart';
import '../../models/hotel.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_button.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    await provider.loadBookingDetail(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Detail Booking'),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.error != null || provider.selectedBooking == null) {
            return ErrorWidgetCustom(
              message: provider.error ?? 'Data booking tidak ditemukan',
              onRetry: _loadData,
            );
          }

          final booking = provider.selectedBooking!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(booking),
                const SizedBox(height: 16),
                _buildBookingInfo(booking),
                const SizedBox(height: 16),
                _buildItemDetail(booking),
                const SizedBox(height: 16),
                _buildPaymentInfo(booking),
                const SizedBox(height: 24),
                _buildActionButtons(booking),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Booking booking) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.bookingCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.typeLabel} • ${AppHelpers.formatDate(booking.createdAt)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: booking.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfo(Booking booking) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Informasi Booking', style: AppTheme.heading4),
            const SizedBox(height: 12),
            _buildInfoRow('Kode Booking', booking.bookingCode),
            _buildInfoRow('Tipe', booking.typeLabel),
            _buildInfoRow('ID Item', '#${booking.itemId}'),
            _buildInfoRow('Status', booking.statusLabel),
            _buildInfoRow(
              'Tanggal Booking',
              AppHelpers.formatDate(booking.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodySmall),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(Booking booking) {
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
                Text(booking.typeIcon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text('Detail ${booking.typeLabel}', style: AppTheme.heading4),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder(
              future: _getItemDetail(booking),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Text(
                    'Data tidak tersedia',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.grey),
                  );
                }

                final item = snapshot.data!;
                return _buildItemDetailContent(item, booking.type);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _getItemDetail(Booking booking) async {
    switch (booking.type.toLowerCase()) {
      case 'bus':
        final provider = Provider.of<BusProvider>(context, listen: false);
        await provider.loadBusDetail(booking.itemId);
        return provider.selectedBus;
      case 'train':
        final provider = Provider.of<TrainProvider>(context, listen: false);
        await provider.loadTrainDetail(booking.itemId);
        return provider.selectedTrain;
      case 'hotel':
        final provider = Provider.of<HotelProvider>(context, listen: false);
        await provider.loadHotelDetail(booking.itemId);
        return provider.selectedHotel;
      default:
        return null;
    }
  }

  Widget _buildItemDetailContent(dynamic item, String type) {
    switch (type.toLowerCase()) {
      case 'bus':
        final bus = item as Bus;
        return Column(
          children: [
            _buildDetailRow('Nama Bus', bus.busName),
            _buildDetailRow('Kota Asal', bus.from),
            _buildDetailRow('Kota Tujuan', bus.destination),
            _buildDetailRow('Waktu Berangkat', bus.departureTime),
            _buildDetailRow('Kursi Tersedia', '${bus.seat} kursi'),
          ],
        );
      case 'train':
        final train = item as Train;
        return Column(
          children: [
            _buildDetailRow('Nama Kereta', train.trainName),
            _buildDetailRow('Stasiun Asal', train.from),
            _buildDetailRow('Stasiun Tujuan', train.destination),
            _buildDetailRow('Waktu Berangkat', train.departureTime),
            _buildDetailRow('Waktu Tiba', train.arrivalTime),
            _buildDetailRow('Kursi Tersedia', '${train.seat} kursi'),
          ],
        );
      case 'hotel':
        final hotel = item as Hotel;
        return Column(
          children: [
            _buildDetailRow('Nama Hotel', hotel.name),
            _buildDetailRow('Lokasi', hotel.location),
            if (hotel.rating != null)
              _buildDetailRow('Rating', '⭐ ${hotel.rating}'),
            if (hotel.description != null)
              _buildDetailRow('Deskripsi', hotel.description!, isLong: true),
          ],
        );
      default:
        return const Text('Tipe item tidak dikenal');
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: AppTheme.bodySmall)),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              maxLines: isLong ? 3 : 1,
              overflow: isLong ? TextOverflow.ellipsis : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(Booking booking) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💳 Informasi Pembayaran', style: AppTheme.heading4),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Total Harga',
              AppHelpers.formatCurrency(booking.totalPrice.toDouble()),
            ),
            _buildInfoRow('Metode Pembayaran', 'Transfer Bank'),
            _buildInfoRow('Status Pembayaran', booking.statusLabel),
            if (booking.status.toLowerCase() == 'paid') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.success),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Pembayaran telah dikonfirmasi',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (booking.status.toLowerCase() == 'pending') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top, color: AppTheme.warning),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Menunggu pembayaran. Silahkan transfer sesuai instruksi.',
                        style: TextStyle(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Booking booking) {
    if (booking.status.toLowerCase() == 'pending') {
      return Column(
        children: [
          CustomButton(
            text: 'Lakukan Pembayaran',
            onPressed: () {
              AppHelpers.showSnackBar(
                context,
                'Fitur pembayaran akan segera hadir',
              );
            },
            isFullWidth: true,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Batalkan Booking',
            onPressed: () {
              _showCancelDialog(booking);
            },
            isOutlined: true,
            isFullWidth: true,
            backgroundColor: AppTheme.error,
            textColor: AppTheme.error,
          ),
        ],
      );
    }

    return CustomButton(
      text: 'Kembali ke Riwayat',
      onPressed: () => Navigator.pop(context),
      isFullWidth: true,
    );
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Booking'),
        content: Text(
          'Apakah Anda yakin ingin membatalkan booking dengan kode ${booking.bookingCode}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppHelpers.showSnackBar(context, 'Booking berhasil dibatalkan');
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}
