// lib/widgets/booking_card.dart
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  const BookingCard({super.key, required this.booking, this.onTap});

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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLightestBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.typeIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.bookingCode,
                          style: AppTheme.heading4.copyWith(fontSize: 16),
                        ),
                        Text(
                          '${booking.typeLabel} • Item #${booking.itemId}',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Harga', style: AppTheme.bodySmall),
                      Text(
                        AppHelpers.formatCurrency(
                          booking.totalPrice.toDouble(),
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Tanggal Booking', style: AppTheme.bodySmall),
                      Text(
                        AppHelpers.formatDate(booking.createdAt),
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;

    switch (booking.status.toLowerCase()) {
      case 'pending':
        color = AppTheme.warning;
        label = 'Pending';
        break;
      case 'paid':
        color = AppTheme.success;
        label = 'Paid';
        break;
      case 'cancel':
        color = AppTheme.error;
        label = 'Cancel';
        break;
      default:
        color = AppTheme.grey;
        label = booking.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
