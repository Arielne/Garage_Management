import 'package:flutter/material.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/form_scaffold.dart';

class CreateVoucherScreen extends StatefulWidget {
  const CreateVoucherScreen({super.key});

  @override
  State<CreateVoucherScreen> createState() => _CreateVoucherScreenState();
}

class _CreateVoucherScreenState extends State<CreateVoucherScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Tạo mã giảm giá',
      body: Form(
        key: _formKey,
        child: FormScaffold(
          submitLabel: 'Lưu',
          onSubmit: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context);
            }
          },
          children: [
            const Text(
              'Mã voucher (VD: SUMMER20)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Nhập mã voucher',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tên chương trình',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Nhập tên chương trình',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loại giảm giá',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: 'percent',
                        items: const [
                          DropdownMenuItem(value: 'percent', child: Text('Phần trăm (%)')),
                          DropdownMenuItem(value: 'amount', child: Text('Số tiền (VNĐ)')),
                        ],
                        onChanged: (value) {},
                        decoration: const InputDecoration(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giá trị',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Nhập giá trị',
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Bắt buộc' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Hạn sử dụng',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'DD/MM/YYYY',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              readOnly: true,
              onTap: () async {
                await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Mô tả điều kiện',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập điều kiện áp dụng...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
