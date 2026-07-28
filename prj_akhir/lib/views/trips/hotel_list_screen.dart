// lib/views/trips/hotel_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/trip_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  final TextEditingController _searchController = TextEditingController();

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
    final provider = Provider.of<HotelProvider>(context, listen: false);
    await provider.loadHotels(refresh: true);
  }

  void _applySearch() {
    final provider = Provider.of<HotelProvider>(context, listen: false);
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      provider.loadHotels(refresh: true);
    } else {
      provider.searchHotels(query);
    }
  }

  void _navigateToDetail(int id) {
    Navigator.pushNamed(context, '/hotel-detail', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Daftar Hotel'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            color: AppTheme.primaryBlue,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar selalu tampil
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: AppTheme.white,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applySearch(),
              decoration: InputDecoration(
                hintText: 'Cari nama hotel atau lokasi...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.grey),
                        onPressed: () {
                          _searchController.clear();
                          _applySearch();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.lightGrey,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // List hotel
          Expanded(
            child: Consumer<HotelProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.hotels.isEmpty) {
                  return const LoadingWidget();
                }

                if (provider.error != null && provider.hotels.isEmpty) {
                  return ErrorWidgetCustom(
                    message: provider.error!,
                    onRetry: _loadData,
                  );
                }

                if (provider.hotels.isEmpty) {
                  return const EmptyState(
                    title: 'Tidak Ada Hotel',
                    message: 'Belum ada hotel yang tersedia saat ini',
                    icon: Icons.hotel,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.hotels.length,
                    itemBuilder: (context, index) {
                      final hotel = provider.hotels[index];
                      return TripCard(
                        trip: hotel,
                        type: TripType.hotel,
                        onTap: () => _navigateToDetail(hotel.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
