import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models.dart';
import '../../../core/fake_data.dart';
import '../../../theme/app_colors.dart';

class InventoryReportDialog extends StatelessWidget {
  const InventoryReportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Báo Cáo Nhập / Xuất Kho',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: demoInventoryTransactions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tx = demoInventoryTransactions[index];
                  final isImport = tx.type == TransactionType.import;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isImport ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isImport ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isImport ? Colors.green[700] : Colors.orange[700],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.itemName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ngày: ${tx.dateText}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              if (tx.note.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  tx.note,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isImport ? "+" : "-"}${tx.quantity}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isImport ? Colors.green[700] : Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
