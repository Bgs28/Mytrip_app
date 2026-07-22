// lib/views/payments/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../services/promo_service.dart'; // Tambahkan import PromoService
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';
import 'payment_upload_screen.dart';

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
  final _promoCodeController = TextEditingController();

  String? _selectedPaymentMethod;
  final List<Map<String, String>> _paymentMethods = [
    {'label': 'Bank Transfer (BCA)', 'value': 'bank_transfer_bca'},
    {'label': 'Bank Transfer (Mandiri)', 'value': 'bank_transfer_mandiri'},
    {'label': 'Bank Transfer (BNI)', 'value': 'bank_transfer_bni'},
    {'label': 'E-Wallet (OVO)', 'value': 'ovo'},
    {'label': 'E-Wallet (GoPay)', 'value': 'gopay'},
  ];

  bool _isLoading = false;
  bool _isPromoValid = false;
  double _discountAmount = 0;
  double _finalPrice = 0;

  // Inisialisasi PromoService
  final PromoService _promoService = PromoService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _finalPrice = widget.args['price'].toDouble();

    // Set default value setelah widget siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedPaymentMethod = 'bank_transfer_bca';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _nameController.text = authProvider.user!.name;
    }
  }

  // ==================== BUILD METHOD ====================
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
      body: _isLoading
          ? const LoadingWidget(
              message: 'Memproses pesanan...',
              isFullScreen: true,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildItemSummary(
                      type,
                      name,
                      price,
                      from,
                      destination,
                      departureTime,
                    ),
                    const SizedBox(height: 16),
                    _buildCustomerInfo(),
                    const SizedBox(height: 16),
                    _buildPromoCodeSection(price),
                    const SizedBox(height: 16),
                    _buildPaymentMethod(),
                    const SizedBox(height: 16),
                    _buildPaymentInstructions(price),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ==================== WIDGET BUILDERS ====================

  Widget _buildItemSummary(
    String type,
    String name,
    int price,
    dynamic from,
    dynamic destination,
    dynamic departureTime,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Ringkasan Pesanan', style: AppTheme.heading4),
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
                      Text(_getTypeLabel(type), style: AppTheme.bodySmall),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dari', style: AppTheme.bodySmall),
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
                        const Text('Tujuan', style: AppTheme.bodySmall),
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
              _buildInfoRow('Lokasi', widget.args['location'] ?? ''),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Harga', style: AppTheme.heading4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_isPromoValid && _discountAmount > 0) ...[
                      Text(
                        AppHelpers.formatCurrency(price.toDouble()),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        AppHelpers.formatCurrency(_finalPrice),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ] else ...[
                      Text(
                        AppHelpers.formatCurrency(price.toDouble()),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('👤 Informasi Pemesan', style: AppTheme.heading4),
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
    );
  }

  Widget _buildPromoCodeSection(int price) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎫 Kode Promo', style: AppTheme.heading4),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: '',
                    hint: 'Masukkan kode promo',
                    controller: _promoCodeController,
                    prefixIcon: const Icon(
                      Icons.local_offer_outlined,
                      color: AppTheme.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _validatePromo(price),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    minimumSize: const Size(80, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Pakai'),
                ),
              ],
            ),
            if (_isPromoValid && _discountAmount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Diskon ${AppHelpers.formatCurrency(_discountAmount)} berhasil diterapkan!',
                      style: TextStyle(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💳 Metode Pembayaran', style: AppTheme.heading4),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              hint: const Text('Pilih metode pembayaran'),
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lightGrey),
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
                  value: method['value'],
                  child: Row(
                    children: [
                      _getPaymentIcon(method['value']!),
                      const SizedBox(width: 8),
                      Text(method['label']!),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Silahkan pilih metode pembayaran';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInstructions(int price) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📝 Instruksi Pembayaran', style: AppTheme.heading4),
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
                    _isPromoValid && _discountAmount > 0
                        ? AppHelpers.formatCurrency(_finalPrice)
                        : AppHelpers.formatCurrency(price.toDouble()),
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
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Konfirmasi Pesanan',
          onPressed: _isLoading ? null : _processCheckout,
          isFullWidth: true,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Batal',
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          isOutlined: true,
          isFullWidth: true,
        ),
      ],
    );
  }

  // ==================== HELPER METHODS ====================

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
    if (method.contains('bca')) {
      return const Icon(Icons.account_balance, color: Colors.blue, size: 20);
    } else if (method.contains('mandiri')) {
      return const Icon(Icons.account_balance, color: Colors.orange, size: 20);
    } else if (method.contains('bni')) {
      return const Icon(Icons.account_balance, color: Colors.green, size: 20);
    } else if (method.contains('ovo')) {
      return const Icon(Icons.wallet, color: Colors.purple, size: 20);
    } else if (method.contains('gopay')) {
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

  // ==================== VALIDASI PROMO (PERBAIKAN) ====================

  Future<void> _validatePromo(int price) async {
    final code = _promoCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      AppHelpers.showSnackBar(
        context,
        'Masukkan kode promo terlebih dahulu',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Gunakan PromoService, BUKAN PaymentService
      final response = await _promoService.validatePromo(
        code: code,
        totalPrice: price.toDouble(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.success && response.data != null) {
        final data = response.data!;
        final discount = data['discount_amount'] ?? 0;
        final finalPrice = data['final_price'] ?? price;

        setState(() {
          _isPromoValid = true;
          _discountAmount = discount.toDouble();
          _finalPrice = finalPrice.toDouble();
        });

        AppHelpers.showSnackBar(
          context,
          '✅ Kode promo valid! Diskon ${AppHelpers.formatCurrency(discount.toDouble())}',
        );
      } else {
        setState(() {
          _isPromoValid = false;
          _discountAmount = 0;
          _finalPrice = price.toDouble();
        });

        AppHelpers.showSnackBar(
          context,
          response.message ?? 'Kode promo tidak valid',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      AppHelpers.showSnackBar(context, 'Terjadi kesalahan: $e', isError: true);
    }
  }

  // ==================== PROCESS CHECKOUT ====================

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPaymentMethod == null || _selectedPaymentMethod!.isEmpty) {
      AppHelpers.showSnackBar(
        context,
        'Silahkan pilih metode pembayaran terlebih dahulu',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    try {
      // STEP 1: Create Booking
      print('📤 Creating booking...');
      final bookingSuccess = await bookingProvider.createBooking(
        type: widget.args['type'],
        itemId: widget.args['itemId'],
        totalPrice: widget.args['price'],
      );

      if (!bookingSuccess || bookingProvider.selectedBooking == null) {
        setState(() {
          _isLoading = false;
        });
        AppHelpers.showSnackBar(
          context,
          bookingProvider.error ?? 'Gagal membuat booking',
          isError: true,
        );
        return;
      }

      final booking = bookingProvider.selectedBooking!;
      print('✅ Booking created with ID: ${booking.id}');

      // STEP 2: Create Payment
      print('📤 Creating payment for booking ID: ${booking.id}');
      print('📤 Payment method: $_selectedPaymentMethod');

      final paymentService = PaymentService();
      final paymentResponse = await paymentService.createPayment(
        bookingId: booking.id,
        paymentMethod: _selectedPaymentMethod!,
        promoCode: _isPromoValid ? _promoCodeController.text.trim() : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (paymentResponse.success && paymentResponse.data != null) {
        final payment = paymentResponse.data!;
        print('✅ Payment created with ID: ${payment.id}');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentUploadScreen(
                paymentId: payment.id,
                bookingCode: booking.bookingCode,
                totalAmount: payment.totalAmount,
                paymentMethod: _selectedPaymentMethod!,
              ),
            ),
          );
        }
      } else {
        print('❌ Payment creation failed: ${paymentResponse.message}');
        AppHelpers.showSnackBar(
          context,
          paymentResponse.message ?? 'Gagal membuat pembayaran',
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Error in checkout: $e');
      AppHelpers.showSnackBar(context, 'Terjadi kesalahan: $e', isError: true);
    }
  }
}
