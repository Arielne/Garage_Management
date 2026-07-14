import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
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
      backgroundColor: const Color(0xFF2C2C2C),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.build, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'GARAGE',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'MANAGER',
                      style: TextStyle(color: Color(0xFFFF7A00)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quản lý độ & nâng cấp xe máy',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7A00)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Phiên bản 1.0.0',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
