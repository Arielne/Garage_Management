import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models.dart';

class NotificationRepository {
  NotificationRepository(this._client);
  final SupabaseClient _client;

  Future<List<AppNotification>> getNotifications() async {
    final user = _client.auth.currentUser;
    if (user == null) return []; // Should be logged in

    // Find the customer.id for this user_id
    final customerData = await _client
        .from('customers')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (customerData == null) {
      // Not a registered customer yet, show only global notifications
      final rows = await _client
          .from('notifications')
          .select()
          .isFilter('customer_id', null)
          .order('created_at', ascending: false);
      return rows.map((row) => AppNotification.fromJson(row)).toList();
    }

    final customerId = customerData['id'];

    // Show global notifications (customer_id is null) OR specific to this customer
    final rows = await _client
        .from('notifications')
        .select()
        .or('customer_id.is.null,customer_id.eq.$customerId')
        .order('created_at', ascending: false);
        
    return rows.map((row) => AppNotification.fromJson(row)).toList();
  }

  Future<void> sendPromoNotification(String title, String message, {String? customerId}) async {
    await _client.from('notifications').insert({
      'title': title,
      'message': message,
      'customer_id': customerId,
      'is_read': false,
    });
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(Supabase.instance.client);
});

final notificationListProvider = FutureProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).getNotifications();
});
