import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;

      try {
        final supabase = Supabase.instance.client;

        // 1. Sign up user in Supabase Auth
        final AuthResponse res = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final user = res.user;
        if (user == null) {
          throw Exception('Không nhận được thông tin tài khoản từ hệ thống.');
        }

        // 2. Insert into profiles table
        await supabase.from('profiles').insert({
          'id': user.id,
          'role': 'customer',
          'full_name': name,
          'phone': phone,
          'email': email,
        });

        // 3. Insert into customers table
        await supabase.from('customers').insert({
          'full_name': name,
          'phone': phone,
          'email': email,
          'user_id': user.id,
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký tài khoản thành công!'),
            backgroundColor: AppColors.statusDone,
          ),
        );

        // Auto-navigate to Customer Shell
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.customerShell,
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;

        String errorMsg = e.toString();
        if (errorMsg.contains('User already registered') || errorMsg.contains('already exists')) {
          errorMsg = 'Email hoặc Số điện thoại này đã được đăng ký tài khoản trước đó!';
        } else {
          errorMsg = 'Đăng ký thất bại: $errorMsg';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.statusError,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: const Text('Đăng ký'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo tài khoản khách hàng',
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Điền các thông tin bên dưới để bắt đầu quản lý và theo dõi tiến trình làm xe.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Full Name
                Text(
                  'Họ và tên',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    hintText: 'Nhập họ và tên...',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number
                Text(
                  'Số điện thoại',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Nhập số điện thoại...',
                    prefixIcon: Icon(Icons.phone_android_outlined, color: AppColors.textSecondary, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    final phoneRegex = RegExp(r'^(0[35789])+([0-9]{8})$');
                    if (!phoneRegex.hasMatch(value.trim())) {
                      return 'Số điện thoại không hợp lệ (ví dụ: 0987654321)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email
                Text(
                  'Email',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Nhập email...',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Email không hợp lệ (ví dụ: name@example.com)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                Text(
                  'Mật khẩu',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Nhập mật khẩu...',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải dài ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password
                Text(
                  'Xác nhận mật khẩu',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Nhập lại mật khẩu...',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập lại mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                PrimaryButton(
                  label: _isLoading ? 'Đang đăng ký...' : 'Đăng ký tài khoản',
                  onPressed: _isLoading ? null : _handleRegister,
                ),
                const SizedBox(height: 24),

                // Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Đăng nhập ngay',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
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
