import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/form_scaffold.dart';

class PromoComposeScreen extends StatefulWidget {
  const PromoComposeScreen({super.key});

  @override
  State<PromoComposeScreen> createState() => _PromoComposeScreenState();
}

class _PromoComposeScreenState extends State<PromoComposeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _sendTo = 'all';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Soạn thông báo KM',
      body: Form(
        key: _formKey,
        child: FormScaffold(
          submitLabel: 'Gửi',
          onSubmit: () {
            if (_formKey.currentState?.validate() ?? false) {
              // Send promotion
              Navigator.pop(context);
            }
          },
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
            ),
            const SizedBox(height: 16),
            const Text(
              'Đính kèm Voucher',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: 'SUMMER20',
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Không đính kèm')),
                DropdownMenuItem(value: 'SUMMER20', child: Text('SUMMER20 - Giảm 20% nhân công')),
                DropdownMenuItem(value: 'OIL50K', child: Text('OIL50K - Giảm 50K thay nhớt')),
              ],
              onChanged: (value) {},
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
                    onChanged: (value) => setState(() => _sendTo = value!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Khách hàng VIP'),
                    value: 'vip',
                    groupValue: _sendTo,
                    onChanged: (value) => setState(() => _sendTo = value!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Khách chưa đến > 3 tháng'),
                    value: 'inactive',
                    groupValue: _sendTo,
                    onChanged: (value) => setState(() => _sendTo = value!),
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
