// lib/views/trips/hotel_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/trip_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_textfield.dart';
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

  Future<void> _loadData() async {
    final provider = Provider.of<HotelProvider>(context, listen: false);
    await provider.loadHotels(refresh: true);
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
          _buildSearchBar(),
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

                return ListView.builder(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.cardShadow,
      ),
      child: CustomTextField(
        label: 'Cari Hotel',
        hint: 'Cari berdasarkan nama atau lokasi',
        controller: _searchController,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  _applySearch();
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        onChanged: (value) => _applySearch(),
      ),
    );
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
}
