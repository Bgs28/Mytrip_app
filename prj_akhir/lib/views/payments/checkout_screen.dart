// lib/views/payments/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> args;

  const CheckoutScreen({super.key, required this.args});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'Bank Transfer (BCA)';
  final List<String> _paymentMethods = [
    'Bank Transfer (BCA)',
    'Bank Transfer (Mandiri)',
    'Bank Transfer (BNI)',
    'E-Wallet (OVO)',
    'E-Wallet (GoPay)',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _nameController.text = authProvider.user!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.args['type'] ?? '';
    final name = widget.args['name'] ?? '';
    final price = widget.args['price'] ?? 0;
    final from = widget.args['from'];
    final destination = widget.args['destination'];
    final departureTime = widget.args['departureTime'];

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isCreating) {
            return const LoadingWidget(
              message: 'Memproses pesanan...',
              isFullScreen: true,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Summary
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📋 Ringkasan Pesanan',
                            style: AppTheme.heading4,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLightestBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _getTypeIcon(type),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _getTypeLabel(type),
                                      style: AppTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          if (from != null && destination != null) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dari',
                                        style: AppTheme.bodySmall,
                                      ),
                                      Text(
                                        from,
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: AppTheme.grey,
                                  size: 16,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Tujuan',
                                        style: AppTheme.bodySmall,
                                      ),
                                      Text(
                                        destination,
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (departureTime != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppTheme.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Berangkat: $departureTime',
                                    style: AppTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ] else ...[
                            _buildInfoRow(
                              'Lokasi',
                              widget.args['location'] ?? '',
                            ),
                          ],
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Harga',
                                style: AppTheme.heading4,
                              ),
                              Text(
                                AppHelpers.formatCurrency(price.toDouble()),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Customer Info
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '👤 Informasi Pemesan',
                            style: AppTheme.heading4,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Nama Lengkap',
                            controller: _nameController,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama harus diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Nomor Telepon',
                            hint: 'Contoh: 081234567890',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor telepon harus diisi';
                              }
                              if (value.length < 10) {
                                return 'Nomor telepon minimal 10 digit';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Catatan (Opsional)',
                            hint: 'Tambahkan catatan untuk pemesanan',
                            controller: _notesController,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💳 Metode Pembayaran',
                            style: AppTheme.heading4,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedPaymentMethod,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.lightGrey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.lightGrey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryBlue,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: _paymentMethods.map((method) {
                              return DropdownMenuItem<String>(
                                value: method,
                                child: Row(
                                  children: [
                                    _getPaymentIcon(method),
                                    const SizedBox(width: 8),
                                    Text(method),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Instructions
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📝 Instruksi Pembayaran',
                            style: AppTheme.heading4,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLightestBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Transfer ke rekening berikut:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Bank: BCA',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'Nomor Rekening: 1234567890',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'Atas Nama: MyTrip Official',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Total yang harus ditransfer:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  AppHelpers.formatCurrency(price.toDouble()),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Checkout Button
                  CustomButton(
                    text: 'Konfirmasi Pesanan',
                    onPressed: () => _processCheckout(),
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Batal',
                    onPressed: () => Navigator.pop(context),
                    isOutlined: true,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bus':
        return const Icon(Icons.directions_bus, color: AppTheme.primaryBlue);
      case 'train':
        return const Icon(Icons.train, color: AppTheme.primaryBlue);
      case 'hotel':
        return const Icon(Icons.hotel, color: AppTheme.primaryBlue);
      default:
        return const Icon(Icons.receipt, color: AppTheme.primaryBlue);
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'bus':
        return 'Bus';
      case 'train':
        return 'Kereta Api';
      case 'hotel':
        return 'Hotel';
      default:
        return type;
    }
  }

  Widget _getPaymentIcon(String method) {
    if (method.contains('BCA')) {
      return const Icon(Icons.account_balance, color: Colors.blue, size: 20);
    } else if (method.contains('Mandiri')) {
      return const Icon(Icons.account_balance, color: Colors.orange, size: 20);
    } else if (method.contains('BNI')) {
      return const Icon(Icons.account_balance, color: Colors.green, size: 20);
    } else if (method.contains('OVO')) {
      return const Icon(Icons.wallet, color: Colors.purple, size: 20);
    } else if (method.contains('GoPay')) {
      return const Icon(Icons.wallet, color: Colors.red, size: 20);
    }
    return const Icon(Icons.payment, color: AppTheme.grey, size: 20);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: AppTheme.bodySmall)),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.trim().isEmpty) {
      AppHelpers.showSnackBar(context, 'Nama harus diisi', isError: true);
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      AppHelpers.showSnackBar(
        context,
        'Nomor telepon harus diisi',
        isError: true,
      );
      return;
    }

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    final success = await bookingProvider.createBooking(
      type: widget.args['type'],
      itemId: widget.args['itemId'],
      totalPrice: widget.args['price'],
    );

    if (success && mounted) {
      // Show success dialog
      _showSuccessDialog();
    } else if (mounted && bookingProvider.error != null) {
      AppHelpers.showSnackBar(context, bookingProvider.error!, isError: true);
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
            Text('Pesanan Berhasil!', style: AppTheme.heading3),
            SizedBox(height: 8),
            Text(
              'Silahkan lakukan pembayaran sesuai instruksi yang telah diberikan.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Lihat Riwayat',
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
}
