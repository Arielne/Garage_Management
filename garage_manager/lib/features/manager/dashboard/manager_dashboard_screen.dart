import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_card.dart';
import '../../customer/invoices/invoice_repository.dart';
import '../customers/customer_provider.dart';
import '../inventory/inventory_screen.dart';
import '../revenue/revenue_repository.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key, required this.onOpenInvoices});

  final VoidCallback onOpenInvoices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerProvider);
    final invoicesAsync = ref.watch(invoiceListProvider);
    final inventoryAsync = ref.watch(inventoryItemsProvider);
    final revenueAsync = ref.watch(
      revenueReportProvider((range: RevenueRange.month, weekStart: null, day: null)),
    );

    // Loading/lỗi gộp cho 3 nguồn Supabase: hóa đơn, kho phụ tùng, doanh thu.
    if (invoicesAsync.isLoading ||
        inventoryAsync.isLoading ||
        revenueAsync.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (invoicesAsync.hasError ||
        inventoryAsync.hasError ||
        revenueAsync.hasError) {
      return _DashboardError(
        onRetry: () {
          ref.invalidate(invoiceListProvider);
          ref.invalidate(inventoryItemsProvider);
          ref.invalidate(
            revenueReportProvider((range: RevenueRange.month, weekStart: null, day: null)),
          );
        },
      );
    }

    final invoices = invoicesAsync.value!;
    final inventory = inventoryAsync.value!;
    final revenue = revenueAsync.value!;

    // 4 thẻ tiền/hóa đơn tính theo THÁNG HIỆN TẠI (giờ VN của máy) cho cùng
    // một mốc; biểu đồ bên dưới vẫn giữ 6 tháng để xem xu hướng.
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    final monthInvoices = invoices.where((invoice) {
      final createdAt = invoice.createdAt;
      return !createdAt.isBefore(monthStart) && createdAt.isBefore(nextMonth);
    }).toList();
    final invoiceCount = monthInvoices.length;
    final paidCount = monthInvoices
        .where((invoice) => invoice.status == InvoicePaymentStatus.paid)
        .length;
    final waitingCount = invoiceCount - paidCount;
    final monthRevenue = monthInvoices
        .where((invoice) => invoice.status == InvoicePaymentStatus.paid)
        .fold<num>(0, (sum, invoice) => sum + invoice.total);
    final revenueText = _formatMoney(monthRevenue.round());

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
    final lowStockCount =
        inventory.where((item) => item.isLowStock).length;
    final revenuePoints = [
      for (final point in revenue.points)
        _RevenuePoint(label: point.label, value: point.revenue.round()),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tổng quan',
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
              // Ghi rõ kỳ: thẻ này tính tháng hiện tại, còn biểu đồ ngay dưới
              // cộng nhiều tháng — hai số khác nhau là đúng, không phải lệch.
              label: 'Doanh thu tháng này',
              value: revenueText,
              color: AppColors.accent,
            ),
            _KpiCard(
              icon: Icons.receipt_long_outlined,
              label: 'Hóa đơn',
              value: invoiceCount.toString(),
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
              value: inventory.length.toString(),
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
          revenuePoints: revenuePoints,
          totalText: _formatCompactMoney(
            revenuePoints.fold<int>(
              0,
              (total, point) => total + point.value,
            ),
          ),
        ),

      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Không tải được số liệu.\nKiểm tra kết nối mạng rồi thử lại.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: AppColors.accent),
              label: Text(
                'Thử lại',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
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
                      // Đếm theo số cột thật: view chỉ trả về những tháng đã có
                      // hóa đơn (tối đa 6), ghi cứng "6 tháng" sẽ sai khi ít hơn.
                      '${revenuePoints.length} tháng gần nhất',
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
          // Mỗi nhãn nằm giữa 1 ô bằng nhau -> thẳng hàng với tâm cột.
          Row(
            children: [
              for (final point in revenuePoints)
                Expanded(
                  child: Text(
                    point.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
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
    final mutedBarPaint = Paint()..color = AppColors.accentMuted;

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
