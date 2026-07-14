import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../storage/hive_service.dart';
import 'connectivity_service.dart';

/// A single queued mutation waiting for connectivity — e.g. "publish
/// this post". Stored as JSON in the `outbox` Hive box so it survives
/// an app restart while offline.
class OutboxEntry {
  OutboxEntry({
    String? id,
    required this.kind,
    required this.payload,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String kind;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OutboxEntry.fromJson(Map<String, dynamic> json) => OutboxEntry(
        id: json['id'] as String,
        kind: json['kind'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

typedef OutboxHandler = Future<bool> Function(OutboxEntry entry);

/// Generic queue for actions that must survive being offline (right now:
/// publishing a post from the Create screen with zero connectivity).
/// Each `kind` of entry has a registered handler; when connectivity
/// returns, every pending entry is replayed in order and removed on
/// success. A failed replay is left in the queue and retried on the
/// next connectivity change, up to Hive's lifetime (i.e. indefinitely,
/// same as a real sync queue would).
class OfflineQueue {
  OfflineQueue({required HiveService hive, required ConnectivityService connectivity})
      : _hive = hive,
        _connectivity = connectivity;

  final HiveService _hive;
  final ConnectivityService _connectivity;
  final Map<String, OutboxHandler> _handlers = {};
  StreamSubscription<bool>? _sub;
  final _pendingCountController = StreamController<int>.broadcast();

  Stream<int> get pendingCount => _pendingCountController.stream;

  void registerHandler(String kind, OutboxHandler handler) {
    _handlers[kind] = handler;
  }

  void startWatchingConnectivity() {
    _sub ??= _connectivity.onStatusChange.listen((online) {
      if (online) processQueue();
    });
  }

  void dispose() {
    _sub?.cancel();
    _pendingCountController.close();
  }

  Future<void> enqueue(String kind, Map<String, dynamic> payload) async {
    final entry = OutboxEntry(kind: kind, payload: payload);
    await _hive.box(HiveService.outboxBox).put(entry.id, jsonEncode(entry.toJson()));
    _emitCount();
    if (await _connectivity.isOnline) {
      unawaited(processQueue());
    }
  }

  List<OutboxEntry> pendingEntries() {
    final box = _hive.box(HiveService.outboxBox);
    return box.values
        .map((raw) => OutboxEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> processQueue() async {
    final box = _hive.box(HiveService.outboxBox);
    for (final entry in pendingEntries()) {
      final handler = _handlers[entry.kind];
      if (handler == null) continue;
      try {
        final ok = await handler(entry);
        if (ok) await box.delete(entry.id);
      } catch (_) {
        // Leave it queued; next connectivity change retries.
      }
    }
    _emitCount();
  }

  void _emitCount() {
    if (!_pendingCountController.isClosed) {
      _pendingCountController.add(pendingEntries().length);
    }
  }
}

final offlineQueueProvider = Provider<OfflineQueue>((ref) {
  final queue = OfflineQueue(
    hive: ref.watch(hiveServiceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
  queue.startWatchingConnectivity();
  ref.onDispose(queue.dispose);
  return queue;
});
