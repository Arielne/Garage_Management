import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models.dart';
import '../../../theme/app_colors.dart';
import 'inventory_repository.dart';

final inventoryTransactionsProvider = FutureProvider.autoDispose<List<InventoryTransaction>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getTransactions();
});

class InventoryReportDialog extends ConsumerWidget {
  const InventoryReportDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTransactions = ref.watch(inventoryTransactionsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        width: double.maxFinite,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lịch Sử Nhập / Xuất Kho',
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
              child: asyncTransactions.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Lỗi: $e')),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Center(child: Text('Chưa có giao dịch nào.'));
                  }
                  return ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (ctx, idx) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isImport = tx.type == TransactionType.import;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        leading: CircleAvatar(
                          backgroundColor: isImport ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          child: Icon(
                            isImport ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isImport ? Colors.green[700] : Colors.orange[700],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          tx.itemName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${isImport ? "Nhập" : "Xuất"} ${tx.quantity} đơn vị',
                              style: GoogleFonts.inter(
                                color: isImport ? Colors.green[700] : Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (tx.note.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Ghi chú: ${tx.note}', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                            ]
                          ],
                        ),
                        trailing: Text(
                          tx.dateText,
                          style: GoogleFonts.inter(
                            color: AppColors.textTertiary,
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
