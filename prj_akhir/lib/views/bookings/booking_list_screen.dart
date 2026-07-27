// lib/views/bookings/booking_list_screen.dart - Update dengan payment status
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';
import '../../models/payment.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import 'booking_detail_screen.dart';
import '../payments/payment_upload_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Pending', 'Paid', 'Cancel'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    await provider.loadBookingHistory(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.grey,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pending'),
            Tab(text: 'Paid'),
            Tab(text: 'Cancel'),
          ],
          onTap: (index) {
            setState(() {
              _selectedFilter = _filters[index];
            });
          },
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            color: AppTheme.primaryBlue,
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.bookings.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.error != null && provider.bookings.isEmpty) {
            return ErrorWidgetCustom(
              message: provider.error!,
              onRetry: _loadData,
            );
          }

          final filteredBookings = _getFilteredBookings(provider.bookings);

          if (filteredBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmptyState(
                    title: 'Belum Ada Booking',
                    message: 'Mulai pesan tiket perjalanan Anda sekarang!',
                    icon: Icons.history,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Cari Tiket Sekarang',
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    isFullWidth: false,
                    width: 200,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                return BookingCard(
                  booking: booking,
                  onTap: () => _navigateToDetail(booking.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<Booking> _getFilteredBookings(List<Booking> bookings) {
    if (_selectedFilter == 'Semua') return bookings;

    return bookings.where((booking) {
      final status = booking.status ?? '';
      return status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  void _navigateToDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailScreen(bookingId: id),
      ),
    );
  }
}
