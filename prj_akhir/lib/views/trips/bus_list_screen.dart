// lib/views/trips/bus_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bus_provider.dart';
import '../../models/bus.dart';
import '../../widgets/trip_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';

class BusListScreen extends StatefulWidget {
  const BusListScreen({super.key});

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<BusProvider>(context, listen: false);
    await provider.loadBuses(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Daftar Bus'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Icon(
              _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
              color: AppTheme.primaryBlue,
            ),
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            color: AppTheme.primaryBlue,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilters(),
          Expanded(
            child: Consumer<BusProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.buses.isEmpty) {
                  return const LoadingWidget();
                }

                if (provider.error != null && provider.buses.isEmpty) {
                  return ErrorWidgetCustom(
                    message: provider.error!,
                    onRetry: _loadData,
                  );
                }

                if (provider.buses.isEmpty) {
                  return const EmptyState(
                    title: 'Tidak Ada Bus',
                    message: 'Belum ada bus yang tersedia saat ini',
                    icon: Icons.directions_bus,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: provider.buses.length,
                  itemBuilder: (context, index) {
                    final bus = provider.buses[index];
                    return TripCard(
                      trip: bus,
                      type: TripType.bus,
                      onTap: () => _navigateToDetail(bus.id),
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          CustomTextField(
            label: 'Kota Asal',
            hint: 'Cari berdasarkan kota asal',
            controller: _fromController,
            prefixIcon: const Icon(Icons.location_on_outlined),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Kota Tujuan',
            hint: 'Cari berdasarkan kota tujuan',
            controller: _destinationController,
            prefixIcon: const Icon(Icons.location_on_outlined),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _fromController.clear();
                    _destinationController.clear();
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightGrey,
                    foregroundColor: AppTheme.grey,
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Cari'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    final provider = Provider.of<BusProvider>(context, listen: false);
    provider.searchBuses(
      from: _fromController.text.trim().isNotEmpty
          ? _fromController.text.trim()
          : null,
      destination: _destinationController.text.trim().isNotEmpty
          ? _destinationController.text.trim()
          : null,
    );
  }

  void _navigateToDetail(int id) {
    Navigator.pushNamed(context, '/bus-detail', arguments: id);
  }
}
