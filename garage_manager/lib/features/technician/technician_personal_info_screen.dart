import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class TechnicianPersonalInfoScreen extends StatefulWidget {
  const TechnicianPersonalInfoScreen({super.key});

  @override
  State<TechnicianPersonalInfoScreen> createState() =>
      _TechnicianPersonalInfoScreenState();
}

class _TechnicianPersonalInfoScreenState
    extends State<TechnicianPersonalInfoScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _mechanicData;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
  }

  // Kéo thông tin cá nhân từ bảng mechanics
  Future<void> _fetchInfo() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('mechanics')
          .select('full_name, phone, email') // Chỉ lấy các thông tin cần thiết
          .eq('user_id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _mechanicData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải thông tin cá nhân: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _mechanicData == null
          ? Center(
              child: Text(
                'Không tìm thấy thông tin thợ.',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      Icons.person_outline,
                      'Họ và tên',
                      _mechanicData!['full_name'] ?? 'Chưa cập nhật',
                    ),
                    const Divider(height: 32, color: AppColors.divider),

                    _buildInfoRow(
                      Icons.phone_outlined,
                      'Số điện thoại',
                      _mechanicData!['phone'] ?? 'Chưa cập nhật',
                    ),
                    const Divider(height: 32, color: AppColors.divider),

                    _buildInfoRow(
                      Icons.email_outlined,
                      'Email liên hệ',
                      _mechanicData!['email'] ?? 'Chưa cập nhật',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
