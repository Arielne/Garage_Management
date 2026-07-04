import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/models.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(supabaseClientProvider));
});

class InventoryRepository {
  final SupabaseClient _client;

  InventoryRepository(this._client);

  Future<List<InventoryItem>> getItems() async {
    try {
      final response = await _client.from('inventory_items').select();
      return (response as List<dynamic>).map((json) {
        return InventoryItem(
          id: json['id'],
          name: json['name'],
          sku: json['sku'],
          category: json['category'] == 'kit' ? InventoryCategory.kit : InventoryCategory.part,
          stockQuantity: json['stock_quantity'],
          minStockWarning: json['min_stock_warning'],
          priceText: json['price_text'],
          compatibleVehicles: List<String>.from(json['compatible_vehicles']),
        );
      }).toList();
    } catch (e) {
      print('Error fetching inventory items: $e');
      return [];
    }
  }

  Future<List<InventoryTransaction>> getTransactions() async {
    try {
      final response = await _client.from('inventory_transactions').select().order('date_text', ascending: false);
      return (response as List<dynamic>).map((json) {
        return InventoryTransaction(
          id: json['id'].toString(),
          itemId: json['item_id'],
          itemName: json['item_name'],
          type: json['type'] == 'import' ? TransactionType.import : TransactionType.export,
          quantity: json['quantity'],
          dateText: json['date_text'],
          note: json['note'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching inventory transactions: $e');
      return [];
    }
  }

  Future<bool> createTransaction(InventoryItem item, TransactionType type, int quantity, String note) async {
    try {
      final now = DateTime.now();
      final dateText = DateFormat('dd/MM/yyyy HH:mm').format(now);

      // Insert transaction
      await _client.from('inventory_transactions').insert({
        'item_id': item.id,
        'item_name': item.name,
        'type': type == TransactionType.import ? 'import' : 'export',
        'quantity': quantity,
        'date_text': dateText,
        'note': note,
      });

      // Update stock
      final newQuantity = type == TransactionType.import 
          ? item.stockQuantity + quantity 
          : item.stockQuantity - quantity;
          
      await _client.from('inventory_items').update({
        'stock_quantity': newQuantity,
      }).eq('id', item.id);

      return true;
    } catch (e) {
      print('Error creating transaction: $e');
      return false;
    }
  }
}
