// lib/widgets/trip_card.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../models/bus.dart';
import '../models/train.dart';
import '../models/hotel.dart';

enum TripType { bus, train, hotel }

class TripCard extends StatelessWidget {
  final dynamic trip;
  final TripType type;
  final VoidCallback? onTap;
  final bool isFavorite;

  const TripCard({
    super.key,
    required this.trip,
    required this.type,
    this.onTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    if (type == TripType.hotel) {
      return _buildHotelCard(context);
    }
    return _buildTripCard(context);
  }

  // ─── Hotel card: foto besar + nama + lokasi + rating + tombol ───────────────
  Widget _buildHotelCard(BuildContext context) {
    final hotel = trip as Hotel;
    final imageUrl = hotel.imageUrl;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto hotel
            Container(
              height: 160,
              width: double.infinity,
              color: AppTheme.primaryLightestBlue,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.hotel,
                          size: 48,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.hotel,
                        size: 48,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
            ),
            // Info hotel
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.name,
                          style: AppTheme.heading4,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppTheme.grey,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                hotel.location,
                                style: AppTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (hotel.rating != null)
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppTheme.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hotel.rating!.toStringAsFixed(1),
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Lihat Detail',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  // ─── Bus / Train card: icon + nama + asal→tujuan + harga + tombol ───────────
  Widget _buildTripCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildBusTrain(),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryLightestBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIcon(), color: AppTheme.primaryBlue, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getName(),
                style: AppTheme.heading4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                type == TripType.bus ? 'Bus' : 'Kereta Api',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (isFavorite)
          const Icon(Icons.favorite, color: AppTheme.error, size: 20),
      ],
    );
  }

  Widget _buildBusTrain() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFrom(),
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Berangkat: ${_getDepartureTime()}',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward, color: AppTheme.grey, size: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getDestination(),
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kursi: ${_getSeat()} tersisa',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppHelpers.formatCurrency(_getPrice().toDouble()),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Lihat Detail',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIcon() {
    switch (type) {
      case TripType.bus:
        return Icons.directions_bus;
      case TripType.train:
        return Icons.train;
      case TripType.hotel:
        return Icons.hotel;
    }
  }

  String _getName() {
    switch (type) {
      case TripType.bus:
        return (trip as Bus).busName;
      case TripType.train:
        return (trip as Train).trainName;
      case TripType.hotel:
        return (trip as Hotel).name;
    }
  }

  String _getFrom() {
    switch (type) {
      case TripType.bus:
        return (trip as Bus).from;
      case TripType.train:
        return (trip as Train).from;
      case TripType.hotel:
        return '';
    }
  }

  String _getDestination() {
    switch (type) {
      case TripType.bus:
        return (trip as Bus).destination;
      case TripType.train:
        return (trip as Train).destination;
      case TripType.hotel:
        return '';
    }
  }

  String _getDepartureTime() {
    switch (type) {
      case TripType.bus:
        return (trip as Bus).departureTime;
      case TripType.train:
        return (trip as Train).departureTime;
      case TripType.hotel:
        return '';
    }
  }

  int _getPrice() {
    switch (type) {
      case TripType.bus:
        return (trip as Bus).price;
      case TripType.train:
        return (trip as Train).price;
      case TripType.hotel:
        return (trip as Hotel).price;
    }
  }

  int _getSeat() {
    switch (type) {
      case TripType.bus:
        return (trip as Bus).seat;
      case TripType.train:
        return (trip as Train).seat;
      case TripType.hotel:
        return 0;
    }
  }
}
