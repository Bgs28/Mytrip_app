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
              _buildContent(),
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
              if (_getSubtitle() != null) ...[
                const SizedBox(height: 4),
                Text(_getSubtitle()!, style: AppTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (isFavorite) Icon(Icons.favorite, color: AppTheme.error, size: 20),
      ],
    );
  }

  Widget _buildContent() {
    switch (type) {
      case TripType.bus:
      case TripType.train:
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
      case TripType.hotel:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getLocation(), style: AppTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_getRating() != null) ...[
                  Icon(Icons.star, color: AppTheme.warning, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _getRating()!.toString(),
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  child: Text(
                    _getTypeLabel(),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
    }
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

  String? _getSubtitle() {
    switch (type) {
      case TripType.bus:
        return 'Bus';
      case TripType.train:
        return 'Kereta Api';
      case TripType.hotel:
        return null;
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

  String _getLocation() {
    if (type == TripType.hotel) {
      return (trip as Hotel).location;
    }
    return '';
  }

  double? _getRating() {
    if (type == TripType.hotel) {
      return (trip as Hotel).rating;
    }
    return null;
  }

  String _getTypeLabel() {
    switch (type) {
      case TripType.bus:
        return 'BUS';
      case TripType.train:
        return 'TRAIN';
      case TripType.hotel:
        return 'HOTEL';
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
