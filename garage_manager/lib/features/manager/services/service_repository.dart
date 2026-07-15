import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models.dart';

class ServiceRepository {
  ServiceRepository(this._client);
  final SupabaseClient _client;

  Future<List<ServiceModel>> getServices() async {
    final rows = await _client.from('services').select().order('name');
    return rows.map((row) => ServiceModel.fromJson(row)).toList();
  }

  Future<void> addService(String name, num laborPrice) async {
    await _client.from('services').insert({
      'name': name,
      'labor_price': laborPrice,
    });
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(Supabase.instance.client);
});

final serviceListProvider = FutureProvider<List<ServiceModel>>((ref) {
  return ref.watch(serviceRepositoryProvider).getServices();
});
