import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models.dart';

class VoucherRepository {
  VoucherRepository(this._client);
  final SupabaseClient _client;

  Future<List<VoucherModel>> getVouchers() async {
    final rows = await _client.from('vouchers').select().order('id', ascending: false);
    return rows.map((row) => VoucherModel.fromJson(row)).toList();
  }

  Future<void> createVoucher(VoucherModel voucher) async {
    await _client.from('vouchers').insert({
      'code': voucher.code,
      'type': voucher.type == VoucherType.percent ? 'percent' : 'amount',
      'value': voucher.value,
      'min_order': voucher.minOrder,
      'expiry_date': voucher.expiryDate?.toIso8601String(),
      'active': voucher.active,
    });
  }

  Future<void> deleteVoucher(int id) async {
    await _client.from('vouchers').update({'active': false}).eq('id', id);
  }

  Future<void> reactivateVoucher(int id) async {
    await _client.from('vouchers').update({'active': true}).eq('id', id);
  }
}

final voucherRepositoryProvider = Provider<VoucherRepository>((ref) {
  return VoucherRepository(Supabase.instance.client);
});

final voucherListProvider = FutureProvider<List<VoucherModel>>((ref) {
  return ref.watch(voucherRepositoryProvider).getVouchers();
});
