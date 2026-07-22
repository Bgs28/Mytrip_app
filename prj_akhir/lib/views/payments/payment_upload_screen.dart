// lib/views/payments/payment_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/booking_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';

class PaymentUploadScreen extends StatefulWidget {
  final int paymentId;
  final String bookingCode;
  final double totalAmount;
  final String paymentMethod;

  const PaymentUploadScreen({
    super.key,
    required this.paymentId,
    required this.bookingCode,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  State<PaymentUploadScreen> createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen> {
  File? _proofImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Upload Bukti Pembayaran'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: _isUploading
          ? const LoadingWidget(
              message: 'Mengupload bukti pembayaran...',
              isFullScreen: true,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Info Card
                  _buildPaymentInfoCard(),
                  const SizedBox(height: 16),

                  // Bank Account Info
                  _buildBankAccountInfo(),
                  const SizedBox(height: 16),

                  // Upload Photo Section
                  _buildUploadSection(),
                  const SizedBox(height: 16),

                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💳 Informasi Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Kode Booking', widget.bookingCode, Colors.white70),
            _buildInfoRow(
              'Total Pembayaran',
              AppHelpers.formatCurrency(widget.totalAmount),
              Colors.white,
              isBold: true,
            ),
            _buildInfoRow(
              'Metode Pembayaran',
              _getPaymentMethodLabel(widget.paymentMethod),
              Colors.white70,
            ),
            _buildInfoRow(
              'Status',
              'Menunggu Upload Bukti',
              Colors.yellow,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏦 Instruksi Transfer', style: AppTheme.heading4),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightestBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBankDetailRow('Bank', 'BCA'),
                  _buildBankDetailRow('Nomor Rekening', '1234567890'),
                  _buildBankDetailRow('Atas Nama', 'MyTrip Official'),
                  const Divider(),
                  _buildBankDetailRow(
                    'Total Transfer',
                    AppHelpers.formatCurrency(widget.totalAmount),
                    isBold: true,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppTheme.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Transfer sesuai dengan total yang tertera. Upload bukti transfer setelah melakukan pembayaran.',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailRow(
    String label,
    String value, {
    bool isBold = false,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isHighlight ? AppTheme.primaryBlue : AppTheme.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? AppTheme.primaryBlue : AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📷 Upload Bukti Transfer', style: AppTheme.heading4),
            const SizedBox(height: 8),
            Text(
              'Upload screenshot atau foto bukti transfer Anda',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.grey),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _proofImage != null
                        ? AppTheme.success
                        : AppTheme.grey.withOpacity(0.3),
                    width: _proofImage != null ? 2 : 1,
                  ),
                  image: _proofImage != null
                      ? DecorationImage(
                          image: FileImage(_proofImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _proofImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 48,
                            color: AppTheme.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap untuk upload bukti transfer',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.grey,
                            ),
                          ),
                          Text(
                            'Format: JPG, PNG (Max 2MB)',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.grey,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _proofImage = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.success,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '✓ Terpilih',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Kirim Bukti Pembayaran',
          onPressed: (_proofImage != null && !_isUploading)
              ? _uploadProof
              : null,
          isFullWidth: true,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Kembali ke Detail Booking',
          onPressed: () => Navigator.pop(context),
          isOutlined: true,
          isFullWidth: true,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // Navigate to booking list
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: Text('Lihat Riwayat Booking', style: AppTheme.linkText),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _proofImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memilih gambar: $e';
      });
    }
  }

  Future<void> _uploadProof() async {
    if (_proofImage == null) {
      setState(() {
        _errorMessage = 'Silahkan pilih bukti pembayaran terlebih dahulu';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    final success = await bookingProvider.uploadPaymentProof(
      paymentId: widget.paymentId,
      proofFile: _proofImage!,
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (success) {
      _showSuccessDialog();
    } else {
      setState(() {
        _errorMessage =
            bookingProvider.error ?? 'Gagal upload bukti pembayaran';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(
          Icons.check_circle,
          color: AppTheme.success,
          size: 64,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bukti Pembayaran Terkirim!', style: AppTheme.heading3),
            SizedBox(height: 8),
            Text(
              'Terima kasih, pembayaran Anda akan diverifikasi oleh admin.\n\n'
              'Status pembayaran akan berubah menjadi "Paid" setelah diverifikasi.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Lihat Riwayat Booking',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'bank_transfer_bca':
        return 'Bank Transfer BCA';
      case 'bank_transfer_mandiri':
        return 'Bank Transfer Mandiri';
      case 'bank_transfer_bni':
        return 'Bank Transfer BNI';
      case 'ovo':
        return 'OVO';
      case 'gopay':
        return 'GoPay';
      default:
        return method;
    }
  }
}
