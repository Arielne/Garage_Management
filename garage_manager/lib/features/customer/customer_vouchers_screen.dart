import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class CustomerVouchersScreen extends StatefulWidget {
  const CustomerVouchersScreen({super.key});

  @override
  State<CustomerVouchersScreen> createState() => _CustomerVouchersScreenState();
}

class _CustomerVouchersScreenState extends State<CustomerVouchersScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    try {
      final supabase = Supabase.instance.client;
      // Fetch active vouchers
      final response = await supabase
          .from('vouchers')
          .select()
          .eq('active', true)
          .order('expiry_date', ascending: true);

      if (mounted) {
        setState(() {
          _vouchers = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading vouchers: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(num value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0)
        .format(value)
        .replaceAll(RegExp(r'\s+'), '');
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Không thời hạn';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: const Text('Voucher của tôi'),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _vouchers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.confirmation_number_outlined, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có voucher nào khả dụng',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vouchers.length,
                  itemBuilder: (context, index) {
                    final voucher = _vouchers[index];
                    final code = voucher['code'] ?? '';
                    final type = voucher['type'] ?? 'percent';
                    final value = voucher['value'] ?? 0;
                    final minOrder = voucher['min_order'] ?? 0;
                    final expiryDate = voucher['expiry_date'];

                    final discountText = type == 'percent'
                        ? 'Giảm $value%'
                        : 'Giảm ${_formatCurrency(value)}';

                    final isExpired = expiryDate != null &&
                        DateTime.tryParse(expiryDate)?.isBefore(DateTime.now()) == true;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Stack(
                        children: [
                          AppCard(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: isExpired ? AppColors.textTertiary : AppColors.accent,
                                    width: 6,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Left Gift/Ticket Icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isExpired ? AppColors.borderSubtle : AppColors.accentSoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.local_offer_outlined,
                                      color: isExpired ? AppColors.textSecondary : AppColors.accent,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Center Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isExpired ? AppColors.borderSubtle : AppColors.accentSoft,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: isExpired ? AppColors.textTertiary : AppColors.accent.withOpacity(0.3),
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                              child: Text(
                                                code,
                                                style: GoogleFonts.spaceMono(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: isExpired ? AppColors.textSecondary : AppColors.accent,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              discountText,
                                              style: GoogleFonts.sora(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Đơn tối thiểu: ${_formatCurrency(minOrder)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Hạn dùng: ${_formatDate(expiryDate)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: isExpired ? AppColors.statusError : AppColors.textTertiary,
                                            fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Decorative Ticket notches
                          Positioned(
                            left: -10,
                            top: 36,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: AppColors.bgApp,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
