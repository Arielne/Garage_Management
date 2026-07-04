import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../core/app_routes.dart';
import '../../widgets/app_card.dart';

class TechnicianProfileScreen extends StatelessWidget {
  const TechnicianProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Technician Avatar & Name Card
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.accentSoft,
                  child: const Icon(
                    Icons.engineering_outlined,
                    size: 32,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trần Trung Thực',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mã nhân viên: T889',
                        style: GoogleFonts.robotoMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          _buildMenuSection(
            title: 'Công việc',
            items: [
              _MenuItem(
                icon: Icons.history_outlined,
                title: 'Lịch sử sửa chữa',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.assignment_turned_in_outlined,
                title: 'Thống kê hiệu suất',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildMenuSection(
            title: 'Hệ thống',
            items: [
              _MenuItem(
                icon: Icons.notifications_none_outlined,
                title: 'Thông báo của tôi',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                titleColor: AppColors.statusError,
                showTrailing: false,
                onTap: () {
                  // Confirm sign out
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surfaceCard,
                      title: Text(
                        'Đăng xuất',
                        style: GoogleFonts.sora(fontWeight: FontWeight.w700),
                      ),
                      content: const Text(
                        'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản thợ không?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Hủy',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.login,
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'Đăng xuất',
                            style: TextStyle(
                              color: AppColors.statusError,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: item.titleColor ?? AppColors.textPrimary,
                      size: 22,
                    ),
                    title: Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.titleColor ?? AppColors.textPrimary,
                      ),
                    ),
                    trailing: item.showTrailing
                        ? const Icon(
                            Icons.chevron_right,
                            color: AppColors.textTertiary,
                            size: 20,
                          )
                        : null,
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: AppColors.divider),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.titleColor,
    this.showTrailing = true,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color? titleColor;
  final bool showTrailing;
  final VoidCallback onTap;
}
