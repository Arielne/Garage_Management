import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models.dart';

class NotificationRepository {
  NotificationRepository(this._client);
  final SupabaseClient _client;

  Future<List<AppNotification>> getNotifications() async {
    final rows = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false);
    return rows.map((row) => AppNotification.fromJson(row)).toList();
  }

  Future<void> sendPromoNotification(String title, String message) async {
    await _client.from('notifications').insert({
      'title': title,
      'message': message,
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
