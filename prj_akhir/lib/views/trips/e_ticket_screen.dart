// lib/views/trips/e_ticket_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../services/e_ticket_service.dart';
import '../../models/e_ticket.dart';
import '../../models/booking.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';

class ETicketScreen extends StatefulWidget {
  final int bookingId;
  final Booking booking;

  const ETicketScreen({
    super.key,
    required this.bookingId,
    required this.booking,
  });

  @override
  State<ETicketScreen> createState() => _ETicketScreenState();
}

class _ETicketScreenState extends State<ETicketScreen> {
  final ETicketService _eTicketService = ETicketService();
  bool _isLoading = true;
  ETicket? _eTicket;
  String? _error;
  String? _qrCodeData;

  @override
  void initState() {
    super.initState();
    _loadETicket();
  }

  Future<void> _loadETicket() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _eTicketService.getETicket(widget.bookingId);

      if (response.success && response.data != null) {
        final data = response.data!;
        _eTicket = ETicket.fromJson(data['e_ticket'] ?? {});
        _qrCodeData = data['qr_code'];
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Gagal mengambil E-Ticket';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('E-Ticket'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadETicket,
            icon: const Icon(Icons.refresh),
            color: AppTheme.primaryBlue,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
          ? ErrorWidgetCustom(message: _error!, onRetry: _loadETicket)
          : _buildETicketContent(),
    );
  }

  Widget _buildETicketContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // E-Ticket Card
          _buildETicketCard(),
          const SizedBox(height: 16),

          // QR Code
          _buildQRCodeSection(),
          const SizedBox(height: 16),

          // Check-in Code
          _buildCheckInCodeSection(),
          const SizedBox(height: 16),

          // Booking Info
          _buildBookingInfo(),
          const SizedBox(height: 24),

          // Actions
          _buildActionButtons(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildETicketCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🎫 E-TICKET',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _eTicket!.isUsed
                        ? AppTheme.grey.withOpacity(0.3)
                        : AppTheme.success.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _eTicket!.statusLabel,
                    style: TextStyle(
                      color: _eTicket!.isUsed
                          ? AppTheme.grey
                          : AppTheme.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _eTicket!.ticketCode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.booking.typeLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Valid Until',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        AppHelpers.formatDate(_eTicket!.validUntil),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Check-in Code',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        _eTicket!.checkInCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    if (_qrCodeData == null || _qrCodeData!.isEmpty) {
      return Container();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '📱 Scan QR Code untuk Check-in',
              style: AppTheme.heading4,
            ),
            const SizedBox(height: 12),
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.lightGrey),
              ),
              child: _qrCodeData != null
                  ? Image.memory(
                      base64Decode(_qrCodeData!),
                      fit: BoxFit.contain,
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 8),
            Text(
              'Tunjukkan QR Code ini saat check-in',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInCodeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('🔑 Kode Check-in', style: AppTheme.heading4),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightestBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _eTicket!.checkInCode,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      // Copy to clipboard
                      // TODO: Implement copy
                      AppHelpers.showSnackBar(
                        context,
                        'Kode check-in disalin!',
                      );
                    },
                    icon: const Icon(Icons.copy, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Berikan kode ini kepada petugas untuk check-in',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Detail Booking', style: AppTheme.heading4),
            const SizedBox(height: 12),
            _buildInfoRow('Kode Booking', widget.booking.bookingCode),
            _buildInfoRow('Tipe', widget.booking.typeLabel),
            _buildInfoRow(
              'Total Harga',
              AppHelpers.formatCurrency(widget.booking.totalPrice.toDouble()),
            ),
            _buildInfoRow(
              'Tanggal Booking',
              AppHelpers.formatDate(widget.booking.createdAt),
            ),
            _buildInfoRow('Status', widget.booking.statusLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodySmall),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (!_eTicket!.isUsed) ...[
          CustomButton(
            text: 'Check-in',
            onPressed: _showCheckInDialog,
            isFullWidth: true,
          ),
          const SizedBox(height: 12),
        ],
        CustomButton(
          text: 'Kembali ke Riwayat',
          onPressed: () => Navigator.pop(context),
          isOutlined: true,
          isFullWidth: true,
        ),
      ],
    );
  }

  void _showCheckInDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Check-in'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin melakukan check-in?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightestBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Kode Check-in: ${_eTicket!.checkInCode}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processCheckIn();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.success),
            child: const Text('Ya, Check-in'),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckIn() async {
    AppHelpers.showLoadingDialog(context);

    try {
      final response = await _eTicketService.checkIn(_eTicket!.checkInCode);

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (response.success) {
        AppHelpers.showSnackBar(
          context,
          '✅ Check-in berhasil! Selamat menikmati perjalanan.',
        );
        await _loadETicket(); // Refresh data
      } else {
        AppHelpers.showSnackBar(
          context,
          response.message ?? 'Gagal check-in',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      AppHelpers.showSnackBar(context, 'Terjadi kesalahan: $e', isError: true);
    }
  }
}
