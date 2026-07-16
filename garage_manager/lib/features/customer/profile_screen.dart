import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_colors.dart';
import '../../core/app_routes.dart';
import '../../widgets/app_card.dart';
import 'edit_personal_info_screen.dart';
import 'edit_address_screen.dart';
import 'customer_vouchers_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../manager/customers/customer_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Local state for user profile information
  bool _isLoading = true;
  String _name = '';
  String _phone = '';
  String _email = '';
  String _address = '123 Đường Ba Tháng Hai, Quận 10, TP. Hồ Chí Minh';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        final profile = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null && mounted) {
          setState(() {
            _name = profile['full_name'] ?? 'Khách hàng';
            _phone = profile['phone'] ?? '';
            _email = profile['email'] ?? '';
            _isLoading = false;
          });
          return;
        }
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgApp,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // User Avatar & Name Card
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.accentSoft,
                  child: const Icon(
                    Icons.person,
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
                        _name,
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _phone,
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
            title: 'Tài khoản',
            items: [
              _MenuItem(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                subtitle: _email,
                onTap: () async {
                  final result = await Navigator.push<Map<String, String>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPersonalInfoScreen(
                        initialName: _name,
                        initialPhone: _phone,
                        initialEmail: _email,
                      ),
                    ),
                  );

                  if (result != null) {
                    try {
                      final supabase = Supabase.instance.client;
                      final user = supabase.auth.currentUser;
                      if (user != null) {
                        await supabase.from('profiles').update({
                          'full_name': result['name'],
                          'phone': result['phone'],
                          'email': result['email'],
                        }).eq('id', user.id);
                        
                        await supabase.from('customers').update({
                          'full_name': result['name'],
                          'phone': result['phone'],
                          'email': result['email'],
                        }).eq('user_id', user.id);

                        // Refresh customer list in riverpod state
                        ref.read(customerProvider.notifier).loadCustomers();
                      }
                    } catch (e) {
                      print('Error updating profile: $e');
                    }
                    setState(() {
                      _name = result['name'] ?? _name;
                      _phone = result['phone'] ?? _phone;
                      _email = result['email'] ?? _email;
                    });
                  }
                },
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                title: 'Địa chỉ của tôi',
                subtitle: _address,
                onTap: () async {
                  final result = await Navigator.push<Map<String, String>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAddressScreen(
                        initialAddress: _address,
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _address = result['address'] ?? _address;
                    });
                  }
                },
              ),
              _MenuItem(
                icon: Icons.confirmation_number_outlined,
                title: 'Ví Voucher của tôi',
                subtitle: 'Xem khuyến mãi & giảm giá',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomerVouchersScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildMenuSection(
            title: 'Hệ thống',
            items: [
              _MenuItem(
                icon: Icons.notifications_none_outlined,
                title: 'Cài đặt thông báo',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.help_outline,
                title: 'Trợ giúp & Liên hệ',
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
                      content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Hủy',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            try {
                              await Supabase.instance.client.auth.signOut();
                            } catch (_) {}
                            navigator.pushNamedAndRemoveUntil(
                              AppRoutes.login,
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'Đăng xuất',
                            style: TextStyle(color: AppColors.statusError, fontWeight: FontWeight.bold),
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

  Widget _buildMenuSection({required String title, required List<_MenuItem> items}) {
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
                    leading: Icon(item.icon, color: item.titleColor ?? AppColors.textPrimary, size: 22),
                    title: Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.titleColor ?? AppColors.textPrimary,
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: item.showTrailing
                        ? const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20)
                        : null,
                    onTap: item.onTap,
                  ),
                  if (!isLast) const Divider(height: 1, color: AppColors.divider),
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
    this.subtitle,
    this.titleColor,
    this.showTrailing = true,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final bool showTrailing;
  final VoidCallback onTap;
}
