import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/models.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});

class InventoryRepository {
  final _supabase = Supabase.instance.client;

  Future<List<InventoryItem>> getItems() async {
    try {
      final response = await _supabase
          .from('parts')
          .select()
          .order('id')
          .timeout(const Duration(seconds: 10), onTimeout: () {
            throw Exception("Kết nối Supabase bị timeout sau 10s. Vui lòng kiểm tra lại URL và Key.");
          });
      
      return (response as List).map<InventoryItem>((row) {
        final id = int.tryParse(row['id'].toString()) ?? 0;
        final stockQty = int.tryParse(row['stock_qty'].toString()) ?? 0;
        final minStock = int.tryParse(row['min_stock'].toString()) ?? 0;
        final categoryStr = row['category']?.toString();
        final price = row['price'] ?? 0;
        final compatibleModelsRaw = row['compatible_models'];

        List<String> compatibleVehicles = [];
        if (compatibleModelsRaw != null) {
          if (compatibleModelsRaw is List) {
            compatibleVehicles = compatibleModelsRaw.map((e) => e.toString()).toList();
          }
        }

        InventoryCategory cat = InventoryCategory.part;
        if (categoryStr == 'kit') {
          cat = InventoryCategory.kit;
        }

        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
        final priceText = currencyFormatter.format(price);

        return InventoryItem(
          id: id.toString(),
          name: row['name']?.toString() ?? 'Không tên',
          sku: 'PT${id.toString().padLeft(4, '0')}',
          category: cat,
          stockQuantity: stockQty,
          minStockWarning: minStock,
          priceText: priceText,
          rawPrice: price,
          compatibleVehicles: compatibleVehicles,
        );
      }).toList();
    } catch (e, stackTrace) {
      print('Error in getItems: $e');
      print('StackTrace: $stackTrace');
      throw Exception('Lỗi lấy dữ liệu kho: $e');
    }
  }

  Future<List<InventoryTransaction>> getTransactions() async {
    final response = await _supabase.from('stock_transactions')
        .select('*, parts(name)')
        .order('date', ascending: false);
    
    return response.map<InventoryTransaction>((row) {
      final id = row['id'] as int;
      final typeStr = row['type'] as String;
      final partId = row['part_id'] as int;
      
      String partName = 'Unknown';
      if (row['parts'] != null) {
        if (row['parts'] is Map) {
          partName = row['parts']['name'] as String? ?? 'Unknown';
        } else if (row['parts'] is List && (row['parts'] as List).isNotEmpty) {
          partName = (row['parts'] as List)[0]['name'] as String? ?? 'Unknown';
        }
      }
      
      final dateRaw = row['date'] as String;
      final date = DateTime.parse(dateRaw).toLocal();
      final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
      
      TransactionType type = TransactionType.import;
      if (typeStr == 'xuat') {
        type = TransactionType.export;
      }

      return InventoryTransaction(
        id: id.toString(),
        itemId: partId.toString(),
        itemName: partName,
        type: type,
        quantity: row['quantity'] as int,
        dateText: dateFormatter.format(date),
        note: row['note'] as String? ?? '',
      );
    }).toList();
  }

  Future<bool> createTransaction(InventoryItem item, TransactionType type, int quantity, String note) async {
    final typeStr = type == TransactionType.import ? 'nhap' : 'xuat';
    final partId = int.parse(item.id);

    try {
      await _supabase.from('stock_transactions').insert({
        'part_id': partId,
        'type': typeStr,
        'quantity': quantity,
        'note': note,
      });

      final newQuantity = type == TransactionType.import 
          ? item.stockQuantity + quantity 
          : item.stockQuantity - quantity;
          
      await _supabase.from('parts').update({
        'stock_qty': newQuantity
      }).eq('id', partId);

      return true;
    } catch (e) {
      print('Error creating transaction: $e');
      return false;
    }
  }

  Future<bool> exportForWorkOrder(InventoryItem item, int quantity, int workOrderId) async {
    final partId = int.tryParse(item.id) ?? 0;

    try {
      // 1. Thêm record vào work_order_parts
      await _supabase.from('work_order_parts').insert({
        'work_order_id': workOrderId,
        'part_id': partId,
        'name': item.name,
        'quantity': quantity,
        'unit_price': item.rawPrice,
      });

      // 2. Ghi log vào stock_transactions
      await _supabase.from('stock_transactions').insert({
        'part_id': partId,
        'type': 'xuat',
        'quantity': quantity,
        'note': 'Xuất cho phiếu sửa chữa PH-$workOrderId',
      });

      // 3. Trừ tồn kho
      final newQuantity = item.stockQuantity - quantity;
      await _supabase.from('parts').update({
        'stock_qty': newQuantity
      }).eq('id', partId);

      return true;
    } catch (e) {
      print('Error exportForWorkOrder: $e');
      return false;
    }
  }
}
