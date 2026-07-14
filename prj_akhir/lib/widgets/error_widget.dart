// lib/widgets/error_widget.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ErrorWidgetCustom extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? buttonText;

  const ErrorWidgetCustom({
    super.key,
    required this.message,
    this.onRetry,
    this.buttonText = 'Coba Lagi',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppTheme.error, size: 64),
            const SizedBox(height: 16),
            Text('Oops! Terjadi Kesalahan', style: AppTheme.heading3),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.grey),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
