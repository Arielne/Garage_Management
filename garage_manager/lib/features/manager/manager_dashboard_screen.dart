import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/fake_data.dart';
import '../../core/models.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import 'customer_provider.dart';
import 'manager_revenue_stats_screen.dart';
import 'promo_compose_screen.dart';
import 'services_pricing_screen.dart';
import 'voucher_management_screen.dart';

const _monthlyRevenue = [
  _RevenuePoint(label: 'T1', value: 18500000),
  _RevenuePoint(label: 'T2', value: 22600000),
  _RevenuePoint(label: 'T3', value: 19800000),
  _RevenuePoint(label: 'T4', value: 28400000),
  _RevenuePoint(label: 'T5', value: 31200000),
  _RevenuePoint(label: 'T6', value: 35400000),
];

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key, required this.onOpenInvoices});

  final VoidCallback onOpenInvoices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerProvider);
    final paidCount = demoInvoices
        .where((invoice) => invoice.status == InvoicePaymentStatus.paid)
        .length;
    final waitingCount = demoInvoices.length - paidCount;
    final vehicleCount = customers.fold<int>(
      0,
      (total, customer) => total + customer.vehicles.length,
    );
    final activeVehicleCount = customers.fold<int>(
      0,
      (total, customer) {
        final activeVehicles = customer.vehicles.where(
          (vehicle) => vehicle.status == 'active',
        );
        return total + activeVehicles.length;
      },
    );
    final lowStockCount = demoInventoryItems
        .where((inventoryItem) => inventoryItem.isLowStock)
        .length;
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
            _KpiCard(
              icon: Icons.groups_outlined,
              label: 'Khách hàng',
              value: customers.length.toString(),
              color: AppColors.accent,
            ),
            _KpiCard(
              icon: Icons.two_wheeler_outlined,
              label: 'Xe đang sửa',
              value: '$activeVehicleCount/$vehicleCount',
              color: AppColors.statusDone,
            ),
            _KpiCard(
              icon: Icons.inventory_2_outlined,
              label: 'Phụ tùng',
              value: demoInventoryItems.length.toString(),
              color: AppColors.textPrimary,
            ),
            _KpiCard(
              icon: Icons.warning_amber_outlined,
              label: 'Sắp hết hàng',
              value: lowStockCount.toString(),
              color: AppColors.statusWait,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _RevenueChartCard(
          revenuePoints: _monthlyRevenue,
          totalText: _formatCompactMoney(
            _monthlyRevenue.fold<int>(
              0,
              (total, point) => total + point.value,
            ),
          ),
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
          icon: Icons.bar_chart_outlined,
          title: 'Thống kê doanh thu (D10)',
          subtitle: 'Xem biểu đồ doanh thu và cơ cấu nguồn thu',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ManagerRevenueStatsScreen(),
              ),
            );
          },
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

class _RevenueChartCard extends StatelessWidget {
  const _RevenueChartCard({
    required this.revenuePoints,
    required this.totalText,
  });

  final List<_RevenuePoint> revenuePoints;
  final String totalText;

  @override
  Widget build(BuildContext context) {
    final maxValue = revenuePoints.fold<int>(
      0,
      (max, point) => point.value > max ? point.value : max,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biểu đồ doanh thu',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '6 tháng gần nhất',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalText,
                    style: GoogleFonts.robotoMono(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const _LegendDot(label: 'Doanh thu'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 132,
            width: double.infinity,
            child: CustomPaint(
              painter: _RevenueBarChartPainter(
                revenuePoints: revenuePoints,
                maxValue: maxValue == 0 ? 1 : maxValue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final point in revenuePoints)
                Text(
                  point.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RevenueBarChartPainter extends CustomPainter {
  const _RevenueBarChartPainter({
    required this.revenuePoints,
    required this.maxValue,
  });

  final List<_RevenuePoint> revenuePoints;
  final int maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    final barPaint = Paint()..color = AppColors.accent;
    final mutedBarPaint = Paint()..color = AppColors.accentSoft;

    const gridCount = 4;
    for (var index = 0; index <= gridCount; index++) {
      final y = size.height * index / gridCount;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (revenuePoints.isEmpty) {
      return;
    }

    final slotWidth = size.width / revenuePoints.length;
    final barWidth = slotWidth * 0.46;
    for (var index = 0; index < revenuePoints.length; index++) {
      final point = revenuePoints[index];
      final normalizedValue = point.value / maxValue;
      final barHeight = size.height * normalizedValue.clamp(0.0, 1.0);
      final left = index * slotWidth + (slotWidth - barWidth) / 2;
      final top = size.height - barHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        const Radius.circular(8),
      );
      final paint = index == revenuePoints.length - 1 ? barPaint : mutedBarPaint;
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueBarChartPainter oldDelegate) {
    return oldDelegate.revenuePoints != revenuePoints ||
        oldDelegate.maxValue != maxValue;
  }
}

class _RevenuePoint {
  const _RevenuePoint({required this.label, required this.value});

  final String label;
  final int value;
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

String _formatCompactMoney(int value) {
  final millionValue = value / 1000000;
  final text = millionValue.toStringAsFixed(millionValue % 1 == 0 ? 0 : 1);
  return '${text.replaceAll('.', ',')}trđ';
}
