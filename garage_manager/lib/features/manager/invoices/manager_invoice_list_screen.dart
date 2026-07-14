import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_routes.dart';
import '../../../core/models.dart';
import '../../../features/customer/invoices/invoice_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/invoice_card.dart';
import '../../../widgets/status_chip.dart';

/// D9: Danh sách toàn bộ hóa đơn của quản lý.
/// Dữ liệu lấy từ Supabase qua invoiceListProvider (loading/error/data).
class ManagerInvoiceListScreen extends ConsumerWidget {
  const ManagerInvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoiceListProvider);

    return invoicesAsync.when(
      // Loading page: spinner màu accent trong lúc chờ Supabase.
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (error, stackTrace) => Center(
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
                'Không tải được hóa đơn.\nKiểm tra kết nối mạng rồi thử lại.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref.invalidate(invoiceListProvider),
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
      ),
      data: (invoices) {
        final paidCount = invoices
            .where((invoice) => invoice.status == InvoicePaymentStatus.paid)
            .length;
        final pendingCount = invoices.length - paidCount;

        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () => ref.refresh(invoiceListProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        label: 'Tổng hóa đơn',
                        value: invoices.length.toString(),
                      ),
                    ),
                    Container(width: 1, height: 44, color: AppColors.divider),
                    Expanded(
                      child: _SummaryItem(
                        label: 'Đã thanh toán',
                        value: paidCount.toString(),
                        valueColor: AppColors.statusDone,
                      ),
                    ),
                    Container(width: 1, height: 44, color: AppColors.divider),
                    Expanded(
                      child: _SummaryItem(
                        label: 'Chờ xử lý',
                        value: pendingCount.toString(),
                        valueColor: AppColors.statusWait,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Danh sách hóa đơn',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (invoices.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: Text(
                      'Chưa có hóa đơn nào',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              for (final invoice in invoices)
                InvoiceCard(
                  code: invoice.code,
                  customerName: invoice.customerName,
                  vehiclePlate: invoice.vehiclePlate,
                  totalText: invoice.totalText,
                  statusLabel: invoice.statusLabel,
                  status: _invoiceStatusToAppStatus(invoice.status),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.invoiceDetail, arguments: invoice);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

AppStatus _invoiceStatusToAppStatus(InvoicePaymentStatus status) {
  switch (status) {
    case InvoicePaymentStatus.paid:
      return AppStatus.done;
    case InvoicePaymentStatus.unpaid:
      return AppStatus.error;
    case InvoicePaymentStatus.processing:
      return AppStatus.wait;
  }
}
