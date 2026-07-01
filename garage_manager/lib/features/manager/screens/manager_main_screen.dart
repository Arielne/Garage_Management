import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/list_scaffold.dart';
import 'voucher_management_screen.dart';
import 'services_pricing_screen.dart';
import 'promo_compose_screen.dart';

class ManagerMainScreen extends StatefulWidget {
  const ManagerMainScreen({super.key});

  @override
  State<ManagerMainScreen> createState() => _ManagerMainScreenState();
}

class _ManagerMainScreenState extends State<ManagerMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;
    String title;

    switch (_currentIndex) {
      case 0:
        title = 'Tổng quan';
        body = const _ManagerDashboardBody();
        break;
      case 1:
        title = 'Khách hàng';
        body = const Center(child: Text('Màn hình Khách hàng (Chưa làm)'));
        break;
      case 2:
        title = 'Kho phụ tùng';
        body = const Center(child: Text('Màn hình Kho (Chưa làm)'));
        break;
      case 3:
        title = 'Tài khoản';
        body = const Center(child: Text('Màn hình Tài khoản (Chưa làm)'));
        break;
      default:
        title = '';
        body = const SizedBox();
    }

    return AppScaffold(
      title: title,
      currentIndex: _currentIndex,
      onNavChanged: (index) => setState(() => _currentIndex = index),
      navItems: const [
        AppNavItem(icon: Icons.dashboard_outlined, label: 'Tổng quan'),
        AppNavItem(icon: Icons.people_outline, label: 'Khách hàng'),
        AppNavItem(icon: Icons.inventory_2_outlined, label: 'Kho'),
        AppNavItem(icon: Icons.person_outline, label: 'Tài khoản'),
      ],
      body: body,
    );
  }
}

class _ManagerDashboardBody extends StatelessWidget {
  const _ManagerDashboardBody();

  @override
  Widget build(BuildContext context) {
    return ListScaffold(
      children: [
        const Text(
          'Tính năng (Quang Huy)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        _buildShortcutCard(
          context,
          icon: Icons.local_offer_outlined,
          title: 'Quản lý Voucher (D7)',
          color: AppColors.accent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VoucherManagementScreen()),
          ),
        ),
        const SizedBox(height: 8),
        _buildShortcutCard(
          context,
          icon: Icons.campaign_outlined,
          title: 'Soạn thông báo KM (D8)',
          color: AppColors.statusDone,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PromoComposeScreen()),
          ),
        ),
        const SizedBox(height: 8),
        _buildShortcutCard(
          context,
          icon: Icons.build_circle_outlined,
          title: 'Dịch vụ & Bảng giá (D6)',
          color: AppColors.statusWait,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServicesPricingScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutCard(BuildContext context, {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
