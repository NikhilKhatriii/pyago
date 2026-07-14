import 'dart:async';
import 'dart:math';

import 'package:pyago/core/network/mock/mock_engine.dart';
import 'package:pyago/core/network/pagination.dart';
import 'package:pyago/core/network/result.dart';
import 'package:pyago/features/chat/domain/models/chat_models.dart';
import 'package:pyago/features/chat/domain/repositories/chat_repository.dart';

/// Realistic in-memory fake chat backend. Behaves like a real real-time
/// service would: messages arrive on a `Stream<ChatEvent>` (not polled),
/// sends go through a pending → sent/failed lifecycle, the other party
/// "types" before replying, and read receipts land a moment after the
/// thread is opened.
///
/// Swap seam: replace with an `HttpChatRepository` that pairs `ApiClient`
/// (for history) with `WebSocketRealtimeChannel` (for [eventsFor]) and
/// update the single override in `chat_provider.dart`.
class MockChatRepository implements ChatRepository {
  MockChatRepository({MockEngine? engine}) : _engine = engine ?? MockEngine() {
    _seed();
  }

  final MockEngine _engine;
  final _random = Random();

  late List<ThreadModel> _threads;
  final Map<String, List<MessageModel>> _messages = {};
  final Map<String, StreamController<ChatEvent>> _controllers = {};
  final Map<String, Timer> _replyTimers = {};

  StreamController<ChatEvent> _controllerFor(String threadId) =>
      _controllers.putIfAbsent(threadId, () => StreamController<ChatEvent>.broadcast());

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {
    for (final c in _controllers.values) {
      await c.close();
    }
    for (final t in _replyTimers.values) {
      t.cancel();
    }
  }

  @override
  Stream<ChatEvent> eventsFor(String threadId) => _controllerFor(threadId).stream;

  @override
  Future<Result<List<ThreadModel>>> fetchThreads() async {
    await _engine.latency(multiplier: 0.5);
    return Result.success(List.unmodifiable(_threads));
  }

  @override
  Future<Result<Page<MessageModel>>> fetchMessages(String threadId, {String? cursor}) async {
    await _engine.latency(multiplier: 0.6);
    final all = List<MessageModel>.from((_messages[threadId] ?? []).reversed);
    final page = _engine.paginate(all, cursor: cursor, pageSize: 20);
    return Result.success(page);
  }

  @override
  Future<void> sendMessage(String threadId, String body) async {
    final pending = MessageModel(
      id: 'm_${DateTime.now().microsecondsSinceEpoch}',
      threadId: threadId,
      senderId: 'me',
      senderName: 'You',
      body: body,
      createdAt: DateTime.now(),
      status: MessageStatus.pending,
      isMine: true,
    );
    _messages.putIfAbsent(threadId, () => []).add(pending);
    _controllerFor(threadId).add(MessageEvent(threadId, pending));

    await _engine.latency(multiplier: 0.3);
    final failed = _random.nextDouble() < 0.05;
    final resolved = pending.copyWith(status: failed ? MessageStatus.failed : MessageStatus.sent);
    _replaceMessage(threadId, resolved);
    _controllerFor(threadId).add(MessageEvent(threadId, resolved));

    if (!failed) {
      _updateThreadPreview(threadId, body);
      _scheduleSimulatedReply(threadId);
    }
  }

  void _scheduleSimulatedReply(String threadId) {
    _replyTimers[threadId]?.cancel();
    final thread = _threads.firstWhere((t) => t.id == threadId, orElse: () => _threads.first);

    // Typing indicator, then a reply — mimics a real counterpart typing.
    _controllerFor(threadId).add(TypingEvent(threadId, thread.title, true));
    _replyTimers[threadId] = Timer(Duration(milliseconds: 1200 + _random.nextInt(1600)), () {
      _controllerFor(threadId).add(TypingEvent(threadId, thread.title, false));
      final reply = MessageModel(
        id: 'm_${DateTime.now().microsecondsSinceEpoch}_r',
        threadId: threadId,
        senderId: threadId,
        senderName: thread.title,
        body: _replyPool[_random.nextInt(_replyPool.length)],
        createdAt: DateTime.now(),
        status: MessageStatus.delivered,
      );
      _messages.putIfAbsent(threadId, () => []).add(reply);
      _controllerFor(threadId).add(MessageEvent(threadId, reply));
      _updateThreadPreview(threadId, reply.body, incrementUnread: true);
    });
  }

  @override
  void setTyping(String threadId, bool isTyping) {
    // In a real transport this would send a lightweight event upstream;
    // in the mock, the counterpart's own typing/reply cycle is what the
    // UI observes, so there's nothing further to simulate here.
  }

  @override
  void markRead(String threadId, String upToMessageId) {
    _controllerFor(threadId).add(ReadReceiptEvent(threadId, upToMessageId));
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      _threads[index] = _threads[index].copyWith(unreadCount: 0);
    }
  }

  void _replaceMessage(String threadId, MessageModel message) {
    final list = _messages[threadId];
    if (list == null) return;
    final index = list.indexWhere((m) => m.id == message.id);
    if (index != -1) list[index] = message;
  }

  void _updateThreadPreview(String threadId, String preview, {bool incrementUnread = false}) {
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index == -1) return;
    final current = _threads[index];
    _threads[index] = current.copyWith(
      lastMessage: preview,
      lastMessageAt: DateTime.now(),
      unreadCount: incrementUnread ? current.unreadCount + 1 : current.unreadCount,
    );
  }

  static const _replyPool = [
    "That really landed with me — thank you for sharing it.",
    "I've been thinking about this all day.",
    "Same. It's been a strange week over here too.",
    "Can I ask what prompted this one?",
    "Sending you a bit of quiet today.",
  ];

  void _seed() {
    final now = DateTime.now();
    _threads = [
      ThreadModel(
        id: 't1',
        title: 'Maya Osei',
        lastMessage: 'That line about the river really stuck with me.',
        lastMessageAt: now.subtract(const Duration(minutes: 10)),
        unreadCount: 1,
      ),
      ThreadModel(
        id: 't2',
        title: 'Quiet Writers',
        lastMessage: 'New prompt posted for this week.',
        lastMessageAt: now.subtract(const Duration(hours: 3)),
        isCommunity: true,
      ),
      ThreadModel(
        id: 't3',
        title: 'Daniel Cruz',
        lastMessage: 'Thanks for the feedback on my draft!',
        lastMessageAt: now.subtract(const Duration(days: 1)),
      ),
    ];
    _messages['t1'] = [
      MessageModel(
        id: 'm1', threadId: 't1', senderId: 't1', senderName: 'Maya Osei',
        body: "Hey — I read your piece from this morning.",
        createdAt: now.subtract(const Duration(minutes: 40)), status: MessageStatus.read,
      ),
      MessageModel(
        id: 'm2', threadId: 't1', senderId: 't1', senderName: 'Maya Osei',
        body: 'That line about the river really stuck with me.',
        createdAt: now.subtract(const Duration(minutes: 10)), status: MessageStatus.delivered,
      ),
    ];
  }
}
