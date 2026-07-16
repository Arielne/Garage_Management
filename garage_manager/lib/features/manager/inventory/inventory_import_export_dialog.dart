import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models.dart';
import '../../../theme/app_colors.dart';
import 'inventory_repository.dart';
import 'inventory_screen.dart';

class InventoryImportExportDialog extends ConsumerStatefulWidget {
  final InventoryItem? initialItem;
  final VoidCallback? onSuccess;

  const InventoryImportExportDialog({
    super.key,
    this.initialItem,
    this.onSuccess,
  });

  @override
  ConsumerState<InventoryImportExportDialog> createState() =>
      _InventoryImportExportDialogState();
}

class _InventoryImportExportDialogState
    extends ConsumerState<InventoryImportExportDialog> {
  late String _selectedItemId;
  TransactionType _transactionType = TransactionType.import;
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedItemId = widget.initialItem?.id ?? '';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitTransaction(List<InventoryItem> items) async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số lượng hợp lệ!')),
      );
      return;
    }

    final item = items.firstWhere(
      (e) => e.id == _selectedItemId,
      orElse: () => items.first,
    );

    if (_transactionType == TransactionType.export &&
        quantity > item.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không đủ số lượng để xuất! Tồn kho hiện tại: ${item.stockQuantity}',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final repo = ref.read(inventoryRepositoryProvider);
    final success = await repo.createTransaction(
      item,
      _transactionType,
      quantity,
      _noteController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã lưu giao dịch ${_transactionType == TransactionType.import ? "Nhập" : "Xuất"} kho!',
            ),
          ),
        );
        widget.onSuccess?.call();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi lưu giao dịch.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(inventoryItemsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: double.maxFinite,
        padding: const EdgeInsets.all(24),
        child: asyncItems.when(
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, s) => Center(child: Text('Lỗi: $e')),
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Text('Chưa có phụ tùng nào trong kho.'),
              );
            }
            if (_selectedItemId.isEmpty) {
              _selectedItemId = items.first.id;
            }

            return SingleChildScrollView(
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

                  // Item Selection
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
                        value: items.any((i) => i.id == _selectedItemId)
                            ? _selectedItemId
                            : items.first.id,
                        items: items
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(
                                  '${item.sku} - ${item.name}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (widget.initialItem != null)
                            ? null
                            : (value) {
                                setState(() {
                                  if (value != null) _selectedItemId = value;
                                });
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transaction Type
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

                  // Quantity
                  Text('Số lượng', style: _labelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Nhập số lượng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.borderSubtle,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
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
                        borderSide: const BorderSide(
                          color: AppColors.borderSubtle,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _submitTransaction(items),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Xác nhận',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
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
