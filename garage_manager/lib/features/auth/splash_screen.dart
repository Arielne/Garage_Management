import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_colors.dart';
import '../../core/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;

      bool isInitialized = false;
      try {
        Supabase.instance;
        isInitialized = true;
      } catch (_) {}

      if (isInitialized) {
        final supabase = Supabase.instance.client;
        final session = supabase.auth.currentSession;

        if (session != null) {
          final user = session.user;
          try {
            var profile = await supabase
                .from('profiles')
                .select('role')
                .eq('id', user.id)
                .maybeSingle();

            String role = 'customer';

            if (profile == null) {
              final fullName = user.userMetadata?['full_name'] ?? 'Khách hàng Google';
              final email = user.email ?? '';

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

            if (role == 'manager') {
              Navigator.of(context).pushReplacementNamed(AppRoutes.managerShell);
            } else if (role == 'mechanic') {
              Navigator.of(context).pushReplacementNamed(AppRoutes.technicianShell);
            } else {
              Navigator.of(context).pushReplacementNamed(AppRoutes.customerShell);
            }
          } catch (e) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            }
          }
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.two_wheeler_outlined,
                  size: 72,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'GARAGE MANAGER',
                style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hệ Thống Quản Lý Độ & Nâng Cấp Xe',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
