// lib/views/trips/train_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/train_provider.dart';
import '../../widgets/trip_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';

class TrainListScreen extends StatefulWidget {
  const TrainListScreen({super.key});

  @override
  State<TrainListScreen> createState() => _TrainListScreenState();
}

class _TrainListScreenState extends State<TrainListScreen> {
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
    final provider = Provider.of<TrainProvider>(context, listen: false);
    await provider.loadTrains(refresh: true);
  }

  void _applyFilters() {
    final provider = Provider.of<TrainProvider>(context, listen: false);
    final from = _fromController.text.trim();
    final dest = _destinationController.text.trim();
    if (from.isEmpty && dest.isEmpty) {
      provider.loadTrains(refresh: true);
    } else {
      provider.searchTrains(
        from: from.isNotEmpty ? from : null,
        destination: dest.isNotEmpty ? dest : null,
      );
    }
  }

  void _navigateToDetail(int id) {
    Navigator.pushNamed(context, '/train-detail', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Daftar Kereta'),
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
                // Stasiun asal
                TextField(
                  controller: _fromController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Stasiun asal...',
                    prefixIcon: const Icon(
                      Icons.train_outlined,
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
                // Stasiun tujuan
                TextField(
                  controller: _destinationController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Stasiun tujuan...',
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
          // List kereta
          Expanded(
            child: Consumer<TrainProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.trains.isEmpty) {
                  return const LoadingWidget();
                }

                if (provider.error != null && provider.trains.isEmpty) {
                  return ErrorWidgetCustom(
                    message: provider.error!,
                    onRetry: _loadData,
                  );
                }

                if (provider.trains.isEmpty) {
                  return const EmptyState(
                    title: 'Tidak Ada Kereta',
                    message: 'Belum ada kereta yang tersedia saat ini',
                    icon: Icons.train,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.trains.length,
                    itemBuilder: (context, index) {
                      final train = provider.trains[index];
                      return TripCard(
                        trip: train,
                        type: TripType.train,
                        onTap: () => _navigateToDetail(train.id),
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
