import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import 'customers/customer_list_screen.dart';
import 'dashboard/manager_dashboard_screen.dart';
import 'invoices/manager_invoice_list_screen.dart';
import 'inventory/inventory_screen.dart';
import 'promotions/promo_compose_screen.dart';
import 'revenue/manager_revenue_stats_screen.dart';
import 'services/services_pricing_screen.dart';
import 'vouchers/voucher_management_screen.dart';

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
    ];

    final titles = ['Tổng quan', 'Quản lý Khách hàng', 'Kho Phụ Tùng'];

    return AppScaffold(
      title: titles[_currentIndex],
      currentIndex: _currentIndex,
      onNavChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      drawer: _ManagerDrawer(
        onOpenInvoices: () {
          setState(() {
            _showInvoiceList = true;
          });
        },
      ),
      navItems: const [
        AppNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
        AppNavItem(icon: Icons.people_outlined, label: 'Khách hàng'),
        AppNavItem(icon: Icons.inventory_2_outlined, label: 'Kho hàng'),
      ],
      body: pages[_currentIndex],
    );
  }
}

class _ManagerDrawer extends StatelessWidget {
  const _ManagerDrawer({required this.onOpenInvoices});

  final VoidCallback onOpenInvoices;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceCard,
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.bgApp,
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.accent,
                  radius: 28,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quản Trị Viên',
                        style: GoogleFonts.sora(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Supabase.instance.client.auth.currentUser?.email ??
                            'admin@garage.com',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    'Tất cả hóa đơn',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Xem danh sách hóa đơn',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    onOpenInvoices();
                  },
                ),
                const Divider(color: AppColors.divider, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.bar_chart_outlined,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    'Thống kê doanh thu (D10)',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Xem biểu đồ & cơ cấu thu',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManagerRevenueStatsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: AppColors.divider, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    'Quản lý Voucher (D7)',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Tạo & cấp phát voucher',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VoucherManagementScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: AppColors.divider, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.campaign_outlined,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    'Soạn thông báo KM (D8)',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Gửi tin khuyến mãi hàng loạt',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PromoComposeScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: AppColors.divider, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.build_circle_outlined,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    'Dịch vụ & Bảng giá (D6)',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Cấu hình giá dịch vụ',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ServicesPricingScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.assignment_ind_outlined,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    'Tiếp nhận & Giao việc',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Xem lịch khách đặt & phân công thợ',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.appointmentManagement,
                    );
                  },
                ),
                const Divider(color: AppColors.divider, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.logout_outlined,
                    color: AppColors.statusError,
                  ),
                  title: Text(
                    'Đăng xuất',
                    style: GoogleFonts.inter(
                      color: AppColors.statusError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Thoát tài khoản quản trị',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context); // close drawer
                    try {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      print('Error signing out: $e');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
