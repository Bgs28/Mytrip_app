// lib/views/trips/train_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/train_provider.dart';
import '../../widgets/trip_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/theme.dart';

class TrainListScreen extends StatefulWidget {
  const TrainListScreen({super.key});

  @override
  State<TrainListScreen> createState() => _TrainListScreenState();
}

class _TrainListScreenState extends State<TrainListScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<TrainProvider>(context, listen: false);
    await provider.loadTrains(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Daftar Kereta'),
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

                return ListView.builder(
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
            label: 'Stasiun Asal',
            hint: 'Cari berdasarkan stasiun asal',
            controller: _fromController,
            prefixIcon: const Icon(Icons.train_outlined),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Stasiun Tujuan',
            hint: 'Cari berdasarkan stasiun tujuan',
            controller: _destinationController,
            prefixIcon: const Icon(Icons.train_outlined),
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
    final provider = Provider.of<TrainProvider>(context, listen: false);
    provider.searchTrains(
      from: _fromController.text.trim().isNotEmpty
          ? _fromController.text.trim()
          : null,
      destination: _destinationController.text.trim().isNotEmpty
          ? _destinationController.text.trim()
          : null,
    );
  }

  void _navigateToDetail(int id) {
    Navigator.pushNamed(context, '/train-detail', arguments: id);
  }
}
