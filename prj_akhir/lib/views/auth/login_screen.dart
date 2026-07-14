// lib/views/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                          Icons.flight_takeoff,
                          color: AppTheme.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Welcome Back!', style: AppTheme.heading1),
                      const SizedBox(height: 8),
                      Text(
                        'Masuk ke akun MyTrip Anda',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

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
                  hint: 'Masukkan password Anda',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
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
                const SizedBox(height: 12),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Ingat Saya', style: AppTheme.bodyMedium),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        AppHelpers.showSnackBar(
                          context,
                          'Fitur lupa password akan segera hadir',
                        );
                      },
                      child: Text('Lupa Password?', style: AppTheme.linkText),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Masuk',
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final success = await authProvider.login(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                );

                                if (success && mounted) {
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

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun? ', style: AppTheme.bodyMedium),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Daftar Sekarang', style: AppTheme.linkText),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('atau', style: AppTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Guest Mode
                Center(
                  child: TextButton(
                    onPressed: () {
                      AppHelpers.showSnackBar(
                        context,
                        'Mode tamu akan segera hadir',
                      );
                    },
                    child: Text(
                      'Lanjutkan sebagai Tamu',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
