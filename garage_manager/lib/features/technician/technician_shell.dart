import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import 'job_list_screen.dart';
import 'technician_profile_screen.dart';

class TechnicianShell extends StatefulWidget {
  const TechnicianShell({super.key});

  @override
  State<TechnicianShell> createState() => _TechnicianShellState();
}

class _TechnicianShellState extends State<TechnicianShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const JobListScreen(),
      const _TechnicianPlaceholderPage(
        title: 'Thông báo',
        icon: Icons.notifications_outlined,
      ),
      const TechnicianProfileScreen(),
    ];

    final titles = ['Công việc của tôi', 'Thông báo', 'Tài khoản'];

    return AppScaffold(
      title: titles[_currentIndex],
      currentIndex: _currentIndex,
      onNavChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      navItems: const [
        AppNavItem(icon: Icons.assignment_outlined, label: 'Công việc'),
        AppNavItem(icon: Icons.notifications_outlined, label: 'Thông báo'),
        AppNavItem(icon: Icons.person_outline, label: 'Tài khoản'),
      ],
      body: pages[_currentIndex],
    );
  }
}

class _TechnicianPlaceholderPage extends StatelessWidget {
  const _TechnicianPlaceholderPage({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.sora(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tính năng đang được phát triển.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
