import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/form_scaffold.dart';
import '../manager/services/service_repository.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  const AddServiceScreen({super.key});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _name = '';
  String _priceText = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      
      setState(() => _isLoading = true);
      
      try {
        final price = num.tryParse(_priceText) ?? 0;
        await ref.read(serviceRepositoryProvider).addService(_name, price);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Thêm Dịch vụ',
      body: Form(
        key: _formKey,
        child: FormScaffold(
          submitLabel: _isLoading ? 'Đang lưu...' : 'Lưu',
          onSubmit: _isLoading ? () {} : _submit,
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
              onSaved: (val) => _name = val ?? '',
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
              onSaved: (val) => _priceText = val ?? '0',
            ),
          ],
        ),
      ),
    );
  }
}
