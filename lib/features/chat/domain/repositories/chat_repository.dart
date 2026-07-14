import '../../../../core/network/pagination.dart';
import '../../../../core/network/result.dart';
import '../models/chat_models.dart';

abstract interface class ChatRepository {
  Future<Result<List<ThreadModel>>> fetchThreads();

  Future<Result<Page<MessageModel>>> fetchMessages(String threadId, {String? cursor});

  /// Optimistic send: returns immediately with a `pending` message: the
  /// real send happens in the background and the caller listens on
  /// [events] for the resulting `sent`/`failed` update.
  Future<void> sendMessage(String threadId, String body);

  void setTyping(String threadId, bool isTyping);

  void markRead(String threadId, String upToMessageId);

  /// Live stream of message/typing/read-receipt events for a given
  /// thread — the UI reacts to this rather than polling.
  Stream<ChatEvent> eventsFor(String threadId);

  Future<void> connect();
  Future<void> disconnect();
}
