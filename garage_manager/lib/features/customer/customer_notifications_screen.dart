import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/list_scaffold.dart';
import '../manager/promotions/notification_repository.dart';

final usedVoucherCodesProvider = FutureProvider<Set<String>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) return {};
  
  // Get all used voucher IDs for this user
  final usedRows = await supabase.from('used_vouchers').select('voucher_id').eq('user_id', user.id);
  if (usedRows.isEmpty) return {};
  
  final List<dynamic> voucherIds = usedRows.map((r) => r['voucher_id']).toList();
  if (voucherIds.isEmpty) return {};

  // Get the codes for these vouchers
  final voucherRows = await supabase.from('vouchers').select('code').inFilter('id', voucherIds);
  return voucherRows.map((r) => r['code'].toString()).toSet();
});

class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationListAsync = ref.watch(notificationListProvider);
    final usedCodesAsync = ref.watch(usedVoucherCodesProvider);
    final Set<String> usedCodes = usedCodesAsync.value ?? {};

    return AppScaffold(
      title: 'Thông báo',
      body: notificationListAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('Chưa có thông báo nào.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(usedVoucherCodesProvider);
              return ref.refresh(notificationListProvider);
            },
            child: ListScaffold(
              children: notifications.map((notif) {
                return _buildNotificationItem(
                  context,
                  icon: Icons.notifications_active,
                  color: AppColors.accent,
                  title: notif.title,
                  body: notif.message,
                  time: notif.createdAtText,
                  isUnread: !notif.isRead,
                  usedCodes: usedCodes,
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

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    required String time,
    required bool isUnread,
    required Set<String> usedCodes,
  }) {
    String? voucherCode;
    String displayBody = body;
    const voucherPrefix = 'Mã Voucher: ';
    if (body.contains(voucherPrefix)) {
      final parts = body.split(voucherPrefix);
      displayBody = parts[0].trim();
      voucherCode = parts.length > 1 ? parts[1].trim() : null;
    }

    final isUsed = voucherCode != null && usedCodes.contains(voucherCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.surfaceCard : AppColors.bgApp,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? AppColors.accent.withValues(alpha: 0.3) : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  displayBody,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                ),
                if (voucherCode != null && voucherCode.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isUsed ? AppColors.bgApp : AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isUsed ? 'Mã đã sử dụng' : 'Mã: $voucherCode',
                          style: TextStyle(
                            fontFamily: isUsed ? null : 'Roboto Mono',
                            fontWeight: FontWeight.w600,
                            color: isUsed ? AppColors.textTertiary : AppColors.accent,
                            decoration: isUsed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (!isUsed) ...[
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: voucherCode!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã sao chép mã: $voucherCode'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Icon(Icons.copy, size: 18, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
