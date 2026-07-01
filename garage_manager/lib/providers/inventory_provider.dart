

import 'package:flutter/material.dart';
import '../models/part.dart';
import '../models/inventory_transaction.dart';
import '../services/inventory_supabase_service.dart';

class InventoryProvider with ChangeNotifier {
  final _service = InventorySupabaseService();

  List<Part> parts = [];
  List<Part> lowStockParts = [];
  List<InventoryTransaction> transactions = [];
  bool isLoading = false;


  Future<void> fetchParts({
    String query = '',
    double minPrice = 0,
    double maxPrice = 999999999, 
    bool inStockOnly = false,
  }) async {
    isLoading = true;
    notifyListeners(); 

    try {
      parts = await _service.searchAndFilterParts(
        query: query,
        minPrice: minPrice,
        maxPrice: maxPrice,
        inStockOnly: inStockOnly,
      );
    } catch (e) {
      debugPrint("Lỗi tải danh sách phụ tùng: $e");
    } finally {
      isLoading = false;
      notifyListeners(); 
    }
  }


  Future<void> handleImport(Part part, int quantity, {String? note}) async {
    try {
      await _service.importPart(part, quantity, note: note);
      await fetchParts(); 
      await fetchLowStockWarnings(); 
    } catch (e) {
      debugPrint("Lỗi nhập kho: $e");
      rethrow; 
    }
  }

  
  Future<void> handleExport(Part part, int quantity, {String? note}) async {
    try {
      await _service.exportPart(part, quantity, note: note);
      await fetchParts();
      await fetchLowStockWarnings();
    } catch (e) {
      debugPrint("Lỗi xuất kho: $e");
      rethrow; 
    }
  }


  Future<void> fetchLowStockWarnings() async {
    try {
      lowStockParts = await _service.getLowStockWarnings();
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi tải cảnh báo: $e");
    }
  }


  Future<void> fetchTransactions() async {
    try {
      transactions = await _service.getInventoryReports();
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi tải lịch sử: $e");
    }
  }


  Future<List<Part>> fetchCompatibleParts(String vehicleModelName) async {
    try {
      return await _service.getCompatibleParts(vehicleModelName);
    } catch (e) {
      debugPrint("Lỗi tra cứu tương thích: $e");
      return [];
    }
  }
}