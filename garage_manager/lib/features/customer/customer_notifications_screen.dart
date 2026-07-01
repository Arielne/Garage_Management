import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/list_scaffold.dart';

class CustomerNotificationsScreen extends StatelessWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Thông báo',
      body: ListScaffold(
        children: [
          _buildNotificationItem(
            context,
            icon: Icons.local_offer,
            color: AppColors.accent,
            title: 'Tặng bạn mã giảm 20% 🎉',
            body: 'Cảm ơn bạn đã bảo dưỡng xe tại Garage. Dùng mã SUMMER20 để được giảm 20% phí nhân công cho lần sau nhé!',
            time: '2 giờ trước',
            isUnread: true,
          ),
          _buildNotificationItem(
            context,
            icon: Icons.build_circle,
            color: AppColors.statusDone,
            title: 'Xe của bạn đã xong',
            body: 'Honda SH 150i (59-X1 234.56) đã hoàn tất bảo dưỡng. Vui lòng đến garage để nhận xe.',
            time: 'Hôm qua',
            isUnread: true,
          ),
          _buildNotificationItem(
            context,
            icon: Icons.calendar_today,
            color: AppColors.statusWait,
            title: 'Nhắc lịch bảo dưỡng',
            body: 'Đã đến hạn thay nhớt định kỳ cho xe Exciter 150. Đặt lịch ngay hôm nay!',
            time: '3 ngày trước',
            isUnread: false,
          ),
          _buildNotificationItem(
            context,
            icon: Icons.local_offer,
            color: AppColors.textTertiary,
            title: 'Khuyến mãi tháng 6',
            body: 'Giảm 10% tất cả phụ tùng chính hãng Honda. Cơ hội duy nhất trong tháng.',
            time: '15/06/2026',
            isUnread: false,
          ),
        ],
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
  }) {
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
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                ),
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
