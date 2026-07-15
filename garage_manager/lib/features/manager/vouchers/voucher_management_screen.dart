import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/discount_card.dart';
import '../../../widgets/list_scaffold.dart';
import '../../forms/create_voucher_form.dart';
import 'voucher_repository.dart';

class VoucherManagementScreen extends ConsumerWidget {
  const VoucherManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherListAsync = ref.watch(voucherListProvider);

    return AppScaffold(
      title: 'Quản lý Voucher',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateVoucherScreen()),
          );
          ref.invalidate(voucherListProvider);
        },
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tạo mã', style: TextStyle(color: Colors.white)),
      ),
      body: voucherListAsync.when(
        data: (vouchers) {
          if (vouchers.isEmpty) {
            return const Center(child: Text('Chưa có voucher nào.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(voucherListProvider),
            child: ListScaffold(
              children: vouchers.map((voucher) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DiscountCard(
                    title: 'Giảm ${voucher.valueText}',
                    code: voucher.code,
                    description: 'Đơn tối thiểu: ${voucher.minOrderText}',
                    expiration: voucher.expiryDateText,
                    isActive: voucher.active,
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận vô hiệu hóa'),
                          content: Text('Bạn có chắc muốn vô hiệu hóa mã ${voucher.code}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Vô hiệu hóa', style: TextStyle(color: AppColors.statusError)),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirm == true) {
                        try {
                          await ref.read(voucherRepositoryProvider).deleteVoucher(voucher.id);
                          ref.invalidate(voucherListProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã vô hiệu hóa voucher')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: $e')),
                            );
                          }
                        }
                      }
                    },
                    onReactivate: () async {
                      try {
                        await ref.read(voucherRepositoryProvider).reactivateVoucher(voucher.id);
                        ref.invalidate(voucherListProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã khôi phục voucher')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e')),
                          );
                        }
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
