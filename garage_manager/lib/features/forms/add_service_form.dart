import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/form_scaffold.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Thêm Dịch vụ',
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
              'Tên dịch vụ',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Nhập tên dịch vụ',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nhóm dịch vụ',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: 'maintenance',
              items: const [
                DropdownMenuItem(value: 'maintenance', child: Text('Bảo dưỡng định kỳ')),
                DropdownMenuItem(value: 'cleaning', child: Text('Vệ sinh')),
                DropdownMenuItem(value: 'repair', child: Text('Sửa chữa lớn')),
                DropdownMenuItem(value: 'parts', child: Text('Thay phụ tùng')),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đơn giá công (VNĐ)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Nhập số tiền',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Thời gian ước tính (phút)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'VD: 30',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mô tả chi tiết',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Nhập mô tả các công đoạn...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
