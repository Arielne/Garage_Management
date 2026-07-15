import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_colors.dart';
import '../../core/app_routes.dart';
import '../../widgets/app_card.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  State<TechnicianProfileScreen> createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final _supabase = Supabase.instance.client;

  String _fullName = 'Đang tải...';
  String _roleName = 'Thợ sửa xe';
  bool _isLoading = true;

  int _todayJobs = 0;
  int _completedJobs = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final mechanicData = await _supabase
          .from('mechanics')
          .select('id, full_name')
          .eq('user_id', user.id)
          .maybeSingle();

      int todayCount = 0;
      int completedCount = 0;
      String fetchedName = 'Chưa cập nhật tên';

      if (mechanicData != null) {
        fetchedName = mechanicData['full_name'] ?? 'Chưa cập nhật tên';
        final mechanicId = mechanicData['id'];

        final workOrdersRes = await _supabase
            .from('work_orders')
            .select('id, status, created_at')
            .eq('employee_id', mechanicId);

        final List<dynamic> orders = workOrdersRes;
        final now = DateTime.now();

        for (var order in orders) {
          final status = order['status']?.toString().toLowerCase() ?? '';
          if (status == 'hoan_thanh' || status == 'da_ban_giao') {
            completedCount++;
          }

          if (order['created_at'] != null) {
            try {
              final createdAt = DateTime.parse(order['created_at']).toLocal();
              if (createdAt.year == now.year &&
                  createdAt.month == now.month &&
                  createdAt.day == now.day) {
                todayCount++;
              }
            } catch (_) {}
          }
        }
      }

      if (mounted) {
        setState(() {
          _fullName = fetchedName;
          _roleName = 'Thợ sửa xe';
          _todayJobs = todayCount;
          _completedJobs = completedCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fullName = 'Bắt được lỗi!';
          _roleName = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String avatarText = 'TH';
    if (_fullName != 'Đang tải...' && _fullName != 'Lỗi tải dữ liệu') {
      final parts = _fullName.trim().split(' ');
      if (parts.length >= 2) {
        avatarText = '${parts[0][0]}${parts.last[0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        avatarText = parts[0][0].toUpperCase();
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.textPrimary,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              avatarText,
                              style: GoogleFonts.sora(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fullName,
                            style: GoogleFonts.sora(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _roleName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 16),

                // 2. Ô thống kê
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('$_todayJobs', 'Phiếu hôm nay'),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    _buildStatItem('$_completedJobs', 'Đã hoàn thành'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Danh sách Menu Mới
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMenuItem(Icons.person_outline, 'Thông tin cá nhân', () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.technicianPersonalInfo,
                  );
                }),
                const Divider(height: 1, color: AppColors.divider),

                _buildMenuItem(
                  Icons.notifications_active_outlined,
                  'Thông báo & Nhận việc',
                  () {
                    Navigator.pushNamed(context, AppRoutes.notificationJobs);
                  },
                  iconColor: const Color(0xFFFF7A00), // Nhấn mạnh màu cam
                ),

                const Divider(height: 1, color: AppColors.divider),
                _buildMenuItem(Icons.help_outline, 'Trợ giúp', () {}),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                await _supabase.auth.signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.statusError),
              label: Text(
                'Đăng xuất',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.statusError,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.statusError.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textTertiary,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
