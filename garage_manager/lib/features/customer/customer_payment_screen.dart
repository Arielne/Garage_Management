import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class CustomerPaymentScreen extends StatelessWidget {
  const CustomerPaymentScreen({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    // Business logic calculation
    int totalParts = 0;
    int totalLabor = 0;

    for (final item in invoice.lineItems) {
      final value = _parseMoney(item.totalText);
      if (item.type == InvoiceLineItemType.part) {
        totalParts += value;
      } else if (item.type == InvoiceLineItemType.service) {
        totalLabor += value;
      }
    }

    final int tax = (totalParts * 0.10).round();
    final int finalTotal = totalParts + tax + totalLabor;

    const accountNumber = '0396733726';
    const bankName = 'MBBank';
    final qrUrl = 'https://qr.sepay.vn/img?acc=$accountNumber&bank=$bankName&amount=$finalTotal&des=${Uri.encodeComponent(invoice.code)}';

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: Text(
          'Thanh toán',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Quét mã QR để thanh toán',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        qrUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Text(
                            'Không thể tải mã QR',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _RowItem(label: 'Mã hóa đơn', value: invoice.code, isBold: true),
                  const Divider(height: 24),
                  _RowItem(label: 'Tiền phụ tùng (đồ)', value: _formatMoney(totalParts)),
                  const SizedBox(height: 8),
                  _RowItem(label: 'Thuế (10% phụ tùng)', value: _formatMoney(tax)),
                  const SizedBox(height: 8),
                  _RowItem(label: 'Tiền công (dịch vụ)', value: _formatMoney(totalLabor)),
                  const Divider(height: 24),
                  _RowItem(
                    label: 'Tổng thanh toán',
                    value: _formatMoney(finalTotal),
                    isBold: true,
                    valueColor: AppColors.accent,
                    valueSize: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // In a real app, we would verify via webhook/API here.
                  // For now, we simulate returning after payment.
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Hoàn tất thanh toán',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.valueSize,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final double? valueSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: valueSize ?? 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
