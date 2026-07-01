import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/fake_data.dart';
import '../../core/models.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import 'voucher_management_screen.dart';
import 'promo_compose_screen.dart';
import 'services_pricing_screen.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key, required this.onOpenInvoices});

  final VoidCallback onOpenInvoices;

  @override
  Widget build(BuildContext context) {
    final paidCount = demoInvoices
        .where((invoice) => invoice.status == InvoicePaymentStatus.paid)
        .length;
    final waitingCount = demoInvoices.length - paidCount;
    final revenueText = _formatMoney(
      demoInvoices.fold<int>(
        0,
        (total, invoice) => total + _parseMoney(invoice.totalText),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tổng quan hôm nay',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _KpiCard(
              icon: Icons.payments_outlined,
              label: 'Doanh thu',
              value: revenueText,
              color: AppColors.accent,
            ),
            _KpiCard(
              icon: Icons.receipt_long_outlined,
              label: 'Hóa đơn',
              value: demoInvoices.length.toString(),
              color: AppColors.textPrimary,
            ),
            _KpiCard(
              icon: Icons.check_circle_outline,
              label: 'Đã thanh toán',
              value: paidCount.toString(),
              color: AppColors.statusDone,
            ),
            _KpiCard(
              icon: Icons.hourglass_empty_outlined,
              label: 'Chờ xử lý',
              value: waitingCount.toString(),
              color: AppColors.statusWait,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Lối tắt quản lý',
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _ShortcutCard(
          icon: Icons.receipt_long_outlined,
          title: 'Tất cả hóa đơn',
          subtitle: 'Xem danh sách và mở chi tiết hóa đơn',
          onTap: onOpenInvoices,
        ),
        const SizedBox(height: 12),
        _ShortcutCard(
          icon: Icons.confirmation_number_outlined,
          title: 'Quản lý Voucher (D7)',
          subtitle: 'Tạo và cấp phát voucher cho khách hàng',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VoucherManagementScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _ShortcutCard(
          icon: Icons.campaign_outlined,
          title: 'Soạn thông báo KM (D8)',
          subtitle: 'Gửi tin khuyến mãi hàng loạt',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PromoComposeScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _ShortcutCard(
          icon: Icons.build_circle_outlined,
          title: 'Dịch vụ & Bảng giá (D6)',
          subtitle: 'Cấu hình giá dịch vụ và thêm dịch vụ mới',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServicesPricingScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.robotoMono(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

int _parseMoney(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(digits) ?? 0;
}

String _formatMoney(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }
  return '$bufferđ';
}
