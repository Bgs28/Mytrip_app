// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor ?? AppTheme.primaryBlue,
              side: BorderSide(
                color: backgroundColor ?? AppTheme.primaryBlue,
                width: 2,
              ),
              minimumSize: Size(
                isFullWidth ? double.infinity : (width ?? 200),
                height ?? 50,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 12),
              ),
            ),
            child: _buildChild(),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppTheme.primaryBlue,
              foregroundColor: textColor ?? AppTheme.white,
              minimumSize: Size(
                isFullWidth ? double.infinity : (width ?? 200),
                height ?? 50,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 12),
              ),
              elevation: 4,
              shadowColor: (backgroundColor ?? AppTheme.primaryBlue)
                  .withOpacity(0.3),
            ),
            child: _buildChild(),
          );

    return button;
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text, style: AppTheme.buttonText),
        ],
      );
    }

    return Text(text, style: AppTheme.buttonText);
  }
}
