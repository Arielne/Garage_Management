import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';
import 'plate_text.dart';
import 'status_chip.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.code,
    required this.customerName,
    required this.vehiclePlate,
    required this.totalText,
    required this.statusLabel,
    required this.status,
    this.onTap,
  });

  final String code;
  final String customerName;
  final String vehiclePlate;
  final String totalText;
  final String statusLabel;
  final AppStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: PlateText(code)),
              StatusChip(label: statusLabel, status: status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            customerName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            vehiclePlate,
            style: GoogleFonts.robotoMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            totalText,
            style: GoogleFonts.robotoMono(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
