import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../core/app_routes.dart';
import 'customer_list_screen.dart';

class ManagerShell extends StatefulWidget {
  const ManagerShell({super.key});

  @override
  State<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends State<ManagerShell> {
  int _currentIndex = 1; // Default to Customer tab as requested

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _ManagerPlaceholderPage(title: 'Dashboard Thống Kê', icon: Icons.dashboard_outlined),
      const CustomerListScreen(),
      const _ManagerPlaceholderPage(title: 'Kho Phụ Tùng & Bộ Kit', icon: Icons.inventory_2_outlined),
      const _ManagerPlaceholderPage(title: 'Tài Khoản Quản Lý', icon: Icons.person_outline),
    ];

    final titles = [
      'Dashboard',
      'Quản lý Khách hàng',
      'Kho Phụ Tùng',
      'Tài khoản',
    ];

    return AppScaffold(
      title: titles[_currentIndex],
      currentIndex: _currentIndex,
      onNavChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      navItems: const [
        AppNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
        AppNavItem(icon: Icons.people_outlined, label: 'Khách hàng'),
        AppNavItem(icon: Icons.inventory_2_outlined, label: 'Kho hàng'),
        AppNavItem(icon: Icons.person_outline, label: 'Tài khoản'),
      ],
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.person_add_alt_1_outlined),
              onPressed: () {
                // Navigate to F2 Form (Thêm khách hàng)
                Navigator.of(context).pushNamed(AppRoutes.addCustomer);
              },
            )
          : null,
      body: pages[_currentIndex],
    );
  }
}

class _ManagerPlaceholderPage extends StatelessWidget {
  const _ManagerPlaceholderPage({required this.title, required this.icon});

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
            'Tính năng đang được phát triển bởi các thành viên khác.',
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
