// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;

  const StatusBadge({super.key, required this.status, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(config.icon, color: config.color, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusConfig(
          label: 'Pending',
          color: AppTheme.warning,
          icon: Icons.hourglass_top,
        );
      case 'paid':
      case 'completed':
        return _StatusConfig(
          label: 'Paid',
          color: AppTheme.success,
          icon: Icons.check_circle,
        );
      case 'cancel':
      case 'cancelled':
        return _StatusConfig(
          label: 'Cancelled',
          color: AppTheme.error,
          icon: Icons.cancel,
        );
      default:
        return _StatusConfig(
          label: status,
          color: AppTheme.grey,
          icon: Icons.circle,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig({required this.label, required this.color, required this.icon});
}
