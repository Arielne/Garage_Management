import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class CustomerPaymentScreen extends StatefulWidget {
  const CustomerPaymentScreen({super.key, required this.invoice});

  final Invoice invoice;

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  final _voucherController = TextEditingController();
  bool _isLoadingVoucher = false;
  bool _isProcessingPayment = false;
  VoucherModel? _appliedVoucher;
  int _discountAmount = 0;
  bool _showQR = false;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _applyVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isLoadingVoucher = true;
      _showQR = false; // Hide QR when voucher changes
    });

    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('vouchers')
          .select()
          .eq('code', code)
          .eq('active', true)
          .maybeSingle();

      if (!mounted) return;

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã voucher không hợp lệ hoặc đã bị vô hiệu hóa!')),
        );
        setState(() => _isLoadingVoucher = false);
        return;
      }

      final voucher = VoucherModel.fromJson(data);

      if (voucher.expiryDate != null && voucher.expiryDate!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã voucher đã hết hạn!')),
        );
        setState(() => _isLoadingVoucher = false);
        return;
      }

      // Check if user already used this voucher
      final user = supabase.auth.currentUser;
      if (user != null) {
        final usedData = await supabase
            .from('used_vouchers')
            .select('id')
            .eq('user_id', user.id)
            .eq('voucher_id', voucher.id)
            .maybeSingle();
            
        if (usedData != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bạn đã sử dụng mã voucher này rồi!')),
            );
            setState(() => _isLoadingVoucher = false);
          }
          return;
        }
      }

      // Calculate totals to check min order
      int totalParts = 0;
      int totalLabor = 0;
      for (final item in widget.invoice.lineItems) {
        final value = _parseMoney(item.totalText);
        if (item.type == InvoiceLineItemType.part) {
          totalParts += value;
        } else if (item.type == InvoiceLineItemType.service) {
          totalLabor += value;
        }
      }
      final int subtotal = totalParts + totalLabor;

      if (voucher.minOrder > 0 && subtotal < voucher.minOrder) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đơn hàng chưa đạt mức tối thiểu ${formatMoney(voucher.minOrder)}')),
        );
        setState(() => _isLoadingVoucher = false);
        return;
      }

      // Calculate discount
      int calculatedDiscount = 0;
      if (voucher.type == VoucherType.percent) {
        calculatedDiscount = (subtotal * (voucher.value / 100)).round();
      } else {
        calculatedDiscount = voucher.value.toInt();
      }

      setState(() {
        _appliedVoucher = voucher;
        _discountAmount = calculatedDiscount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Áp dụng mã thành công! Giảm ${formatMoney(calculatedDiscount)}'),
          backgroundColor: AppColors.statusDone,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kiểm tra mã: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingVoucher = false);
      }
    }
  }

  Future<void> _completePayment() async {
    setState(() => _isProcessingPayment = true);
    try {
      // In a real app, verify via webhook/API here.
      // Record voucher usage
      if (_appliedVoucher != null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          await Supabase.instance.client.from('used_vouchers').insert({
            'user_id': user.id,
            'voucher_id': _appliedVoucher!.id,
          });
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thành công!'),
            backgroundColor: AppColors.statusDone,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu lịch sử voucher: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Business logic calculation
    int totalParts = 0;
    int totalLabor = 0;

    for (final item in widget.invoice.lineItems) {
      final value = _parseMoney(item.totalText);
      if (item.type == InvoiceLineItemType.part) {
        totalParts += value;
      } else if (item.type == InvoiceLineItemType.service) {
        totalLabor += value;
      }
    }

    final int tax = (totalParts * 0.10).round();
    int finalTotal = totalParts + tax + totalLabor - _discountAmount;
    if (finalTotal < 0) finalTotal = 0;

    const accountNumber = '0396733726';
    const bankName = 'MBBank';
    final qrUrl = 'https://qr.sepay.vn/img?acc=$accountNumber&bank=$bankName&amount=$finalTotal&des=${Uri.encodeComponent(widget.invoice.code)}';

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: Text(
          'Thanh toán',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _RowItem(label: 'Mã hóa đơn', value: widget.invoice.code, isBold: true),
                  const Divider(height: 24),
                  _RowItem(label: 'Tiền phụ tùng', value: _formatMoney(totalParts)),
                  const SizedBox(height: 8),
                  _RowItem(label: 'Tiền công', value: _formatMoney(totalLabor)),
                  const SizedBox(height: 8),
                  _RowItem(label: 'Thuế (10% phụ tùng)', value: _formatMoney(tax)),
                  
                  // Voucher Section
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _voucherController,
                            decoration: const InputDecoration(
                              hintText: 'Nhập mã giảm giá...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_appliedVoucher != null)
                           IconButton(
                             icon: const Icon(Icons.close, size: 20, color: AppColors.statusError),
                             onPressed: () {
                               setState(() {
                                 _appliedVoucher = null;
                                 _discountAmount = 0;
                                 _voucherController.clear();
                                 _showQR = false; // Hide QR if voucher changes
                               });
                             },
                           )
                        else
                          TextButton(
                            onPressed: _isLoadingVoucher ? null : _applyVoucher,
                            child: _isLoadingVoucher 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                                : const Text('Áp dụng', style: TextStyle(color: AppColors.accent)),
                          ),
                      ],
                    ),
                  ),

                  if (_discountAmount > 0) ...[
                    const SizedBox(height: 16),
                    _RowItem(
                      label: 'Voucher giảm giá',
                      value: '-${_formatMoney(_discountAmount)}',
                      valueColor: AppColors.statusDone,
                    ),
                  ],

                  const Divider(height: 24),
                  _RowItem(
                    label: 'Tổng thanh toán',
                    value: _formatMoney(finalTotal),
                    isBold: true,
                    valueColor: AppColors.accent,
                    valueSize: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_showQR)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showQR = true;
                    });
                  },
                  icon: const Icon(Icons.qr_code, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: Text(
                    'Tạo mã QR Thanh toán',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else ...[
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Quét mã QR để thanh toán',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          qrUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Text(
                              'Không thể tải mã QR',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessingPayment ? null : _completePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusDone,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessingPayment
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Xác nhận đã thanh toán',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  int _parseMoney(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  String _formatMoney(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      buffer.write(raw[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return '$bufferđ';
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.valueSize,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final double? valueSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: valueSize ?? 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
