import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_router.dart';

/// Push notification integration point.
///
/// In the dev/mock flavor there is no real push backend (no Firebase
/// project files are checked in), so this service only drives **local**
/// notifications — but it's wired exactly the way FCM foreground/
/// background handling would be, so adding a real `firebase_messaging`
/// dependency later is additive:
///
/// 1. Add `firebase_messaging` + platform config (`google-services.json`
///    / `GoogleService-Info.plist`).
/// 2. In `initialize()`, subscribe to `FirebaseMessaging.onMessage` and
///    call [showLocal] from the handler (foreground case), and set
///    `FirebaseMessaging.onMessageOpenedApp`/`getInitialMessage` to call
///    [_handlePayload] (background/terminated tap case) — the payload
///    contract (`type`/`id` keys) below already matches what a real FCM
///    data payload would carry.
class PushNotificationService {
  PushNotificationService(this._router);

  final GoRouter _router;
  final _plugin = FlutterLocalNotificationsPlugin();
  int _nextId = 0;

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _handlePayload(payload);
      },
    );
  }

  /// Shows a local notification for the given [type]/[id] pair — e.g.
  /// `type: 'chat'` deep-links to `/chat/{id}`, `type: 'comment'` to
  /// `/post/{id}/comments`. Used both as the dev fallback for what would
  /// otherwise be a push notification, and for genuinely local events
  /// (e.g. "your queued post just published").
  Future<void> showLocal({required String title, required String body, required String type, required String id}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pyago_default',
        'Pyago notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(_nextId++, title, body, details, payload: '$type:$id');
  }

  void _handlePayload(String payload) {
    final parts = payload.split(':');
    if (parts.length != 2) return;
    final type = parts[0];
    final id = parts[1];
    switch (type) {
      case 'chat':
        _router.push('/chat/$id');
      case 'comment':
        // The post object itself isn't available from a cold deep link;
        // the comments screen route requires it via `extra` today, so a
        // real implementation would fetch-by-id first. Logged for now.
        if (kDebugMode) debugPrint('[push] would deep-link to post $id comments');
      default:
        if (kDebugMode) debugPrint('[push] unknown notification type: $type');
    }
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final router = ref.watch(appRouterProvider);
  final service = PushNotificationService(router);
  // Fire-and-forget: plugin init is cheap and failures are non-fatal
  // (worst case, local notifications silently don't show).
  unawaited(service.initialize());
  return service;
});
