

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/part.dart';
import '../models/inventory_transaction.dart';

class InventorySupabaseService {
  final _supabase = Supabase.instance.client;




  Future<void> importPart(Part part, int quantity, {String? note}) async {
    final newStock = part.stockQty + quantity;
    

    await _supabase.from('parts').update({'stock_qty': newStock}).eq('id', part.id as Object);
    

    final transaction = InventoryTransaction(
      partId: part.id!,
      type: 'nhap', 
      quantity: quantity,
      note: note,
    );
    await _supabase.from('stock_transactions').insert(transaction.toMap());
  }


  Future<void> exportPart(Part part, int quantity, {String? note}) async {
    if (part.stockQty < quantity) throw Exception('Số lượng tồn kho không đủ để xuất!');
    
    final newStock = part.stockQty - quantity;
    

    await _supabase.from('parts').update({'stock_qty': newStock}).eq('id', part.id as Object);
    

    final transaction = InventoryTransaction(
      partId: part.id!,
      type: 'xuat', 
      quantity: quantity,
      note: note,
    );
    await _supabase.from('stock_transactions').insert(transaction.toMap());
  }


  Future<List<Part>> getLowStockWarnings() async {
    final response = await _supabase
        .from('parts')
        .select()
        .filter('stock_qty', 'lte', 'min_stock'); 
    
    return (response as List).map((json) => Part.fromMap(json)).toList();
  }


  Future<List<InventoryTransaction>> getInventoryReports() async {
    final response = await _supabase
        .from('stock_transactions')
        .select()
        .order('date', ascending: false); 
        
    return (response as List).map((json) => InventoryTransaction.fromMap(json)).toList();
  }

 
  Future<List<Part>> getCompatibleParts(String vehicleModelName) async {
    final response = await _supabase
        .from('parts')
        .select()
        .contains('compatible_models', [vehicleModelName]);

    return (response as List).map((json) => Part.fromMap(json)).toList();
  }


  Future<List<Part>> searchAndFilterParts({
    required String query,
    required double minPrice,
    required double maxPrice,
    required bool inStockOnly,
  }) async {
    var filterRequest = _supabase
        .from('parts')
        .select()
        .ilike('name', '%$query%') 
        .gte('price', minPrice)    
        .lte('price', maxPrice);   

    if (inStockOnly) {
      filterRequest = filterRequest.gt('stock_qty', 0); 
    }

    final response = await filterRequest;
    return (response as List).map((json) => Part.fromMap(json)).toList();
  }
}