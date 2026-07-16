import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models.dart';
import '../../../theme/app_colors.dart';
import 'inventory_repository.dart';
import 'inventory_screen.dart';

class SelectPartForWorkOrderDialog extends ConsumerStatefulWidget {
  final int workOrderId;
  final VoidCallback? onSuccess;

  const SelectPartForWorkOrderDialog({
    super.key, 
    required this.workOrderId, 
    this.onSuccess,
  });

  @override
  ConsumerState<SelectPartForWorkOrderDialog> createState() => _SelectPartForWorkOrderDialogState();
}

class _SelectPartForWorkOrderDialogState extends ConsumerState<SelectPartForWorkOrderDialog> {
  String? _selectedItemId;
  final _quantityController = TextEditingController(text: '1');
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitTransaction(List<InventoryItem> items) async {
    if (_selectedItemId == null) return;
    
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số lượng hợp lệ!')),
      );
      return;
    }

    final item = items.firstWhere((e) => e.id == _selectedItemId);

    if (quantity > item.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không đủ số lượng để thêm! Tồn kho hiện tại: ${item.stockQuantity}')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final repo = ref.read(inventoryRepositoryProvider);
    final success = await repo.exportForWorkOrder(item, quantity, widget.workOrderId);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm phụ tùng vào phiếu sửa chữa!')),
        );
        // Làm mới danh sách kho để UI cập nhật số lượng tồn
        ref.invalidate(inventoryItemsProvider);
        widget.onSuccess?.call();
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi thêm phụ tùng.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(inventoryItemsProvider);
    final labelStyle = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: double.maxFinite,
        padding: const EdgeInsets.all(24),
        child: asyncItems.when(
          loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
          error: (e, s) => Center(child: Text('Lỗi: $e')),
          data: (allItems) {
            // Chỉ hiển thị các món còn tồn kho
            final items = allItems.where((i) => i.stockQuantity > 0).toList();

            if (items.isEmpty) {
              return const Center(child: Text('Kho hiện tại đã hết hàng hoàn toàn.'));
            }
            if (_selectedItemId == null || !items.any((i) => i.id == _selectedItemId)) {
              _selectedItemId = items.first.id;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thêm Phụ Tùng',
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
                Text('Chọn phụ tùng (Trong kho)', style: labelStyle),
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
                      items: items.map((item) => DropdownMenuItem(
                        value: item.id,
                        child: Text('${item.sku} - ${item.name} (Còn: ${item.stockQuantity})', overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value != null) _selectedItemId = value;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Quantity input
                Text('Số lượng', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Actions
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _submitTransaction(items),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Thêm vào phiếu',
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
