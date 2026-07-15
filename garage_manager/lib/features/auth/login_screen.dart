import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String input = _identifierController.text.trim();
      final password = _passwordController.text;

      // Auto-complete email for demo ease
      if (!input.contains('@')) {
        if (input.toLowerCase() == 'admin' || input.toLowerCase() == 'manager') {
          input = '$input@garage.com';
        } else {
          input = '$input@gmail.com';
        }
      }

      try {
        final supabase = Supabase.instance.client;
        
        // 1. Authenticate user
        final AuthResponse res = await supabase.auth.signInWithPassword(
          email: input,
          password: password,
        );

        final user = res.user;
        if (user == null) {
          throw Exception('Không thể truy cập thông tin tài khoản.');
        }

        // 2. Fetch role from profile table
        final profile = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        final String role = profile?['role'] ?? 'customer';

        if (!mounted) return;

        // 3. Route according to role
        if (role == 'manager') {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.managerShell,
            (route) => false,
          );
        } else if (role == 'mechanic') {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.technicianShell,
            (route) => false,
          );
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.customerShell,
            (route) => false,
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        String errorMsg = e.toString();
        if (errorMsg.contains('Invalid login credentials')) {
          errorMsg = 'Sai tài khoản hoặc mật khẩu. Vui lòng kiểm tra lại!';
        } else {
          errorMsg = 'Đăng nhập thất bại: $errorMsg';
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

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      if (kIsWeb) {
        // For Web, use Supabase OAuth redirect flow directly
        await supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.origin,
        );
        return; // Browser will redirect, execution stops here.
      }

      // For Mobile, use native Google Sign-in to get idToken and accessToken
      final googleSignIn = GoogleSignIn(
        clientId: null,
        serverClientId: '35866768996-i7lscnq6vabem35b1m8gv3o6jltvvct2.apps.googleusercontent.com',
        scopes: ['email', 'openid', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Không nhận được mã xác thực Google (idToken).');
      }

      // 1. Authenticate with Supabase
      final res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = res.user;
      if (user == null) {
        throw Exception('Không lấy được thông tin tài khoản từ Supabase.');
      }

      // 2. Fetch or create profile
      var profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      String role = 'customer';

      if (profile == null) {
        // First login, register in database
        final fullName = user.userMetadata?['full_name'] ?? googleUser.displayName ?? 'Khách hàng Google';
        final email = user.email ?? googleUser.email;

        await supabase.from('profiles').insert({
          'id': user.id,
          'role': 'customer',
          'full_name': fullName,
          'phone': null,
          'email': email,
        });

        await supabase.from('customers').insert({
          'full_name': fullName,
          'phone': null,
          'email': email,
          'user_id': user.id,
        });
      } else {
        role = profile['role'] ?? 'customer';
      }

      if (!mounted) return;

      // 3. Route based on role
      if (role == 'manager') {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.managerShell,
          (route) => false,
        );
      } else if (role == 'mechanic') {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.technicianShell,
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.customerShell,
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      String errorMsg = e.toString();
      if (errorMsg.contains('sign_in_canceled') || errorMsg.contains('canceled')) {
        errorMsg = 'Đã hủy đăng nhập bằng Google.';
      } else {
        errorMsg = 'Lỗi đăng nhập Google: $errorMsg';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // App Logo/Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.two_wheeler_outlined,
                      size: 40,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Đăng nhập',
                    style: GoogleFonts.sora(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Đăng nhập tài khoản Garage của bạn',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                Text(
                  'Tài khoản (Số điện thoại / Email)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Nhập số điện thoại hoặc email...',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tài khoản đăng nhập';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

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
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
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
                const SizedBox(height: 12),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Quên mật khẩu?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                 // Submit Button
                PrimaryButton(
                  label: _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                  onPressed: _isLoading ? null : _handleLogin,
                ),
                const SizedBox(height: 20),

                // Or Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Hoặc đăng nhập bằng',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),
                const SizedBox(height: 20),

                // Google Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    label: Text(
                      'Đăng nhập bằng Google',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.borderSubtle),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.register);
                        },
                        child: Text(
                          'Đăng ký ngay',
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
