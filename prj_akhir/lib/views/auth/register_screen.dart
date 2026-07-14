// lib/views/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 24),

                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.buttonShadow,
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: AppTheme.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Daftar Akun', style: AppTheme.heading1),
                      const SizedBox(height: 8),
                      Text(
                        'Buat akun MyTrip untuk mulai booking',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Name Field
                CustomTextField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppTheme.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama harus diisi';
                    }
                    if (value.length < 3) {
                      return 'Nama minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'Masukkan email Anda',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppTheme.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
                    }
                    if (!AppHelpers.isValidEmail(value)) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Minimal 8 karakter',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppTheme.grey,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.grey,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password harus diisi';
                    }
                    if (value.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                CustomTextField(
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password Anda',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  isRequired: true,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppTheme.grey,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.grey,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password harus diisi';
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Terms & Conditions
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeTerms = value ?? false;
                          });
                        },
                        activeColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi',
                        style: AppTheme.bodyMedium.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Daftar',
                      onPressed: authProvider.isLoading || !_agreeTerms
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final success = await authProvider.register(
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                );

                                if (success && mounted) {
                                  AppHelpers.showSnackBar(
                                    context,
                                    'Registrasi berhasil! Selamat datang di MyTrip',
                                  );
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/main',
                                  );
                                } else if (mounted &&
                                    authProvider.error != null) {
                                  AppHelpers.showSnackBar(
                                    context,
                                    authProvider.error!,
                                    isError: true,
                                  );
                                }
                              }
                            },
                      isLoading: authProvider.isLoading,
                      isFullWidth: true,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ', style: AppTheme.bodyMedium),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Masuk Sekarang', style: AppTheme.linkText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
