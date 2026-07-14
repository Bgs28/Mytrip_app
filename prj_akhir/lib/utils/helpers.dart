// lib/utils/helpers.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

class AppHelpers {
  // Format Currency (Rupiah)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format Date
  static String formatDate(DateTime date, {String pattern = 'dd MMM yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  // Format Date Time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy HH:mm').format(dateTime);
  }

  // Format Time
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // Parse Date from String
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get Status Color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warning;
      case 'paid':
      case 'completed':
        return AppTheme.success;
      case 'cancel':
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.grey;
    }
  }

  // Get Status Text - FIX: Tambahkan method ini
  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'paid':
      case 'completed':
        return 'Paid';
      case 'cancel':
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Show Snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show Loading Dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
      ),
    );
  }

  // Validate Email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate Phone Number (Indonesia)
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?62[0-9]{9,13}$').hasMatch(phone);
  }

  // Truncate Text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
