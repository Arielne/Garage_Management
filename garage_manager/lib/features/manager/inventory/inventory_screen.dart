import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models.dart';
import '../../../theme/app_colors.dart';
import 'inventory_import_export_dialog.dart';
import 'inventory_report_dialog.dart';
import 'inventory_repository.dart';

// Provide the inventory items asynchronously
final inventoryItemsProvider = FutureProvider.autoDispose<List<InventoryItem>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getItems();
});

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';
  String _selectedVehicle = 'Tất cả';

  // Extract all unique vehicles for the filter based on loaded items
  List<String> _getVehicleList(List<InventoryItem> items) {
    final Set<String> vehicles = {'Tất cả'};
    for (var item in items) {
      vehicles.addAll(item.compatibleVehicles);
    }
    return vehicles.toList();
  }

  List<InventoryItem> _getFilteredItems(List<InventoryItem> items) {
    return items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            item.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesVehicle = _selectedVehicle == 'Tất cả' || item.compatibleVehicles.contains(_selectedVehicle);
      return matchesSearch && matchesVehicle;
    }).toList();
  }

  int _getLowStockCount(List<InventoryItem> items) {
    return items.where((item) => item.isLowStock).length;
  }

  void _showImportExportDialog(BuildContext context, [InventoryItem? item]) {
    showDialog(
      context: context,
      builder: (ctx) => InventoryImportExportDialog(
        initialItem: item,
        onSuccess: () {
          // Refresh data
          ref.invalidate(inventoryItemsProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(inventoryItemsProvider);

    return asyncItems.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Đã xảy ra lỗi: $error')),
      data: (items) {
        final filteredItems = _getFilteredItems(items);
        final lowStockCount = _getLowStockCount(items);
        final vehicleList = _getVehicleList(items);

        // Make sure selected vehicle is still in the list, otherwise reset to 'Tất cả'
        if (!vehicleList.contains(_selectedVehicle)) {
          _selectedVehicle = 'Tất cả';
        }

        return Column(
          children: [
            // Low Stock Alert
            if (lowStockCount > 0)
              Container(
                color: Colors.red.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cảnh báo: Có $lowStockCount phụ tùng/bộ kit đang sắp hết hàng!',
                        style: GoogleFonts.inter(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Logic to filter low stock only could go here
                      },
                      child: Text(
                        'Xem ngay',
                        style: GoogleFonts.inter(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),

            // Search & Filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm phụ tùng, mã SKU...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderSubtle),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedVehicle,
                          items: vehicleList.map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v, overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicle = value ?? 'Tất cả';
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const InventoryReportDialog(),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Lịch sử'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showImportExportDialog(context),
                    icon: const Icon(Icons.add_box_outlined),
                    label: const Text('Nhập / Xuất'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(inventoryItemsProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _buildInventoryCard(item);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isLowStock ? Colors.red.shade300 : AppColors.borderSubtle,
          width: item.isLowStock ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgApp,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.category == InventoryCategory.kit ? Icons.build_circle : Icons.handyman,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${item.sku}',
                      style: GoogleFonts.inter(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.priceText,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isLowStock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Tồn kho: ${item.stockQuantity}',
                      style: GoogleFonts.inter(
                        color: item.isLowStock ? Colors.red[700] : Colors.green[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.two_wheeler, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.compatibleVehicles.join(', '),
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showImportExportDialog(context, item),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Cập nhật tồn kho',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
