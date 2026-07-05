import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models.dart';
import '../../../core/fake_data.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});

class InventoryRepository {
  Future<List<InventoryItem>> getItems() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return demoInventoryItems;
  }

  Future<List<InventoryTransaction>> getTransactions() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return demoInventoryTransactions;
  }

  Future<bool> createTransaction(InventoryItem item, TransactionType type, int quantity, String note) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
