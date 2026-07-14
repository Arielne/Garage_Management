import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/form_scaffold.dart';
import '../vouchers/voucher_repository.dart';
import 'notification_repository.dart';

class PromoComposeScreen extends ConsumerStatefulWidget {
  const PromoComposeScreen({super.key});

  @override
  ConsumerState<PromoComposeScreen> createState() => _PromoComposeScreenState();
}

class _PromoComposeScreenState extends ConsumerState<PromoComposeScreen> {
  final _formKey = GlobalKey<FormState>();
  final String _sendTo = 'all';
  String _title = '';
  String _message = '';
  String _selectedVoucher = 'none';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      
      try {
        String finalMessage = _message;
        if (_selectedVoucher != 'none') {
          finalMessage += '\n\nMã Voucher: $_selectedVoucher';
        }
        await ref.read(notificationRepositoryProvider).sendPromoNotification(_title, finalMessage);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucherListAsync = ref.watch(voucherListProvider);

    return AppScaffold(
      title: 'Soạn thông báo KM',
      body: Form(
        key: _formKey,
        child: FormScaffold(
          submitLabel: _isLoading ? 'Đang gửi...' : 'Gửi',
          onSubmit: _isLoading ? () {} : _submit,
          children: [
            const Text(
              'Tiêu đề thông báo',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'VD: Tặng bạn mã giảm 20% 🎉',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Bắt buộc' : null,
              onSaved: (val) => _title = val ?? '',
            ),
            const SizedBox(height: 16),
            const Text(
              'Nội dung',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Nhập nội dung chi tiết...',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Bắt buộc' : null,
              onSaved: (val) => _message = val ?? '',
            ),
            const SizedBox(height: 16),
            const Text(
              'Đính kèm Voucher',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            voucherListAsync.when(
              data: (vouchers) {
                return DropdownButtonFormField<String>(
                  value: _selectedVoucher,
                  items: [
                    const DropdownMenuItem(value: 'none', child: Text('Không đính kèm')),
                    ...vouchers.where((v) => v.active).map((v) => DropdownMenuItem(
                          value: v.code,
                          child: Text('${v.code} - Giảm ${v.valueText}'),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVoucher = value ?? 'none';
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Lỗi tải voucher: $err'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gửi đến',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Tất cả khách hàng'),
                    value: 'all',
                    groupValue: _sendTo,
                    onChanged: null, // Disabled because it's the only option
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
