import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_routes.dart';
import '../../core/fake_data.dart';
import '../../core/models.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/invoice_card.dart';
import '../../widgets/status_chip.dart';

class ManagerInvoiceListScreen extends StatelessWidget {
  const ManagerInvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paidCount = demoInvoices
        .where((invoice) => invoice.status == InvoicePaymentStatus.paid)
        .length;
    final pendingCount = demoInvoices.length - paidCount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Tổng hóa đơn',
                  value: demoInvoices.length.toString(),
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
        for (final invoice in demoInvoices)
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
