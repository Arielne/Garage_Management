import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import 'customers/customer_list_screen.dart';
import 'dashboard/manager_dashboard_screen.dart';
import 'invoices/manager_invoice_list_screen.dart';
import 'inventory/inventory_screen.dart';

class ManagerShell extends StatefulWidget {
  const ManagerShell({super.key});

  @override
  State<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends State<ManagerShell> {
  int _currentIndex = 0;
  bool _showInvoiceList = false;

  @override
  Widget build(BuildContext context) {
    if (_showInvoiceList) {
      return AppScaffold(
        title: 'Tất cả hóa đơn',
        leading: IconButton(
          tooltip: 'Quay lại',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showInvoiceList = false;
            });
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Tải xuống',
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
          ),
        ],
        body: const ManagerInvoiceListScreen(),
      );
    }

    final List<Widget> pages = [
      ManagerDashboardScreen(
        onOpenInvoices: () {
          setState(() {
            _showInvoiceList = true;
          });
        },
      ),
      const CustomerListScreen(),
      const InventoryScreen(),
      const _ManagerPlaceholderPage(
        title: 'Tài Khoản Quản Lý',
        icon: Icons.person_outline,
      ),
    ];

    final titles = [
      'Tổng quan',
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
