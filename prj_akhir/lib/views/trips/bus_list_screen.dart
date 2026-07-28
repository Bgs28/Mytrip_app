// lib/views/trips/bus_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/trip_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';

class BusListScreen extends StatefulWidget {
  const BusListScreen({super.key});

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _fromController.clear();
    _destinationController.clear();
    final provider = Provider.of<BusProvider>(context, listen: false);
    await provider.loadBuses(refresh: true);
  }

  void _applyFilters() {
    final provider = Provider.of<BusProvider>(context, listen: false);
    final from = _fromController.text.trim();
    final dest = _destinationController.text.trim();
    if (from.isEmpty && dest.isEmpty) {
      provider.loadBuses(refresh: true);
    } else {
      provider.searchBuses(
        from: from.isNotEmpty ? from : null,
        destination: dest.isNotEmpty ? dest : null,
      );
    }
  }

  void _navigateToDetail(int id) {
    Navigator.pushNamed(context, '/bus-detail', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Daftar Bus'),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppTheme.white,
            child: Column(
              children: [
                // Asal
                TextField(
                  controller: _fromController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Kota asal...',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.grey,
                    ),
                    suffixIcon: _fromController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.grey, size: 18),
                            onPressed: () {
                              _fromController.clear();
                              _applyFilters();
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
                const SizedBox(height: 8),
                // Tujuan
                TextField(
                  controller: _destinationController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Kota tujuan...',
                    prefixIcon: const Icon(
                      Icons.flag_outlined,
                      color: AppTheme.grey,
                    ),
                    suffixIcon: _destinationController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.grey, size: 18),
                            onPressed: () {
                              _destinationController.clear();
                              _applyFilters();
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
                const SizedBox(height: 4),
              ],
            ),
          ),
          // List bus
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

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
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
