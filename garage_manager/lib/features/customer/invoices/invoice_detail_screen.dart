import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/plate_text.dart';
import '../../../widgets/status_chip.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(title: const Text('Chi tiết hóa đơn')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
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
                          PlateText(invoice.code, fontSize: 16),
                          const SizedBox(height: 8),
                          Text(
                            invoice.customerName,
                            style: GoogleFonts.sora(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: invoice.statusLabel,
                      status: _invoiceStatusToAppStatus(invoice.status),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(label: 'Biển số', value: invoice.vehiclePlate),
                const SizedBox(height: 10),
                _InfoRow(label: 'Ngày tạo', value: invoice.createdAtText),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hạng mục',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < invoice.lineItems.length; index++)
                  _InvoiceLineItemRow(
                    item: invoice.lineItems[index],
                    showDivider: index < invoice.lineItems.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                _TotalRow(label: 'Tạm tính', value: invoice.subtotalText),
                const SizedBox(height: 10),
                _TotalRow(
                  label: 'Giảm giá',
                  value: '-${invoice.discountAmountText}',
                  valueColor: AppColors.statusDone,
                ),
                const SizedBox(height: 10),
                _TotalRow(label: 'Thuế', value: invoice.taxText),
                const Divider(height: 28, color: AppColors.divider),
                _TotalRow(
                  label: 'Tổng cộng',
                  value: invoice.totalText,
                  isEmphasis: true,
                  valueColor: AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.robotoMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _InvoiceLineItemRow extends StatelessWidget {
  const _InvoiceLineItemRow({required this.item, required this.showDivider});

  final InvoiceLineItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: _typeBackground(item.type),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _typeLabel(item.type),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _typeForeground(item.type),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity} x ${item.unitPriceText}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.totalText,
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
    this.isEmphasis = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool isEmphasis;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isEmphasis ? 16 : 14,
              fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: isEmphasis ? 18 : 14,
            fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w700,
            color: valueColor,
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

String _typeLabel(InvoiceLineItemType type) {
  switch (type) {
    case InvoiceLineItemType.service:
      return 'Dịch vụ';
    case InvoiceLineItemType.part:
      return 'Phụ tùng';
  }
}

Color _typeBackground(InvoiceLineItemType type) {
  switch (type) {
    case InvoiceLineItemType.service:
      return AppColors.accentSoft;
    case InvoiceLineItemType.part:
      return AppColors.surfaceSunken;
  }
}

Color _typeForeground(InvoiceLineItemType type) {
  switch (type) {
    case InvoiceLineItemType.service:
      return AppColors.accent;
    case InvoiceLineItemType.part:
      return AppColors.textSecondary;
  }
}
