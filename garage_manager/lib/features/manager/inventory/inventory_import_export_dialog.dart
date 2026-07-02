import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models.dart';
import '../../../core/fake_data.dart';
import '../../../theme/app_colors.dart';

class InventoryImportExportDialog extends StatefulWidget {
  final InventoryItem? initialItem;

  const InventoryImportExportDialog({super.key, this.initialItem});

  @override
  State<InventoryImportExportDialog> createState() => _InventoryImportExportDialogState();
}

class _InventoryImportExportDialogState extends State<InventoryImportExportDialog> {
  late String _selectedItemId;
  TransactionType _transactionType = TransactionType.import;
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedItemId = widget.initialItem?.id ?? demoInventoryItems.first.id;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cập Nhật Kho',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            

            Text('Phụ tùng / Bộ kit', style: _labelStyle),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderSubtle),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedItemId,
                  items: demoInventoryItems.map((item) => DropdownMenuItem(
                    value: item.id,
                    child: Text('${item.sku} - ${item.name}', overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (widget.initialItem != null) ? null : (value) {
                    setState(() {
                      if (value != null) _selectedItemId = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),


            Text('Loại giao dịch', style: _labelStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Nhập'),
                    value: TransactionType.import,
                    groupValue: _transactionType,
                    onChanged: (val) {
                      setState(() {
                        if (val != null) _transactionType = val;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Xuất'),
                    value: TransactionType.export,
                    groupValue: _transactionType,
                    onChanged: (val) {
                      setState(() {
                        if (val != null) _transactionType = val;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),


            Text('Số lượng', style: _labelStyle),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập số lượng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Note
            Text('Ghi chú', style: _labelStyle),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Nhập hàng đợt mới, hoặc xuất sửa xe...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),


            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã lưu giao dịch ${_transactionType == TransactionType.import ? "Nhập" : "Xuất"} kho!')),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Xác nhận',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontSize: 14,
  );
}
