import 'package:equatable/equatable.dart';

enum MessageStatus { pending, sent, delivered, read, failed }

class MessageModel extends Equatable {
  const MessageModel({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.isMine = false,
  });

  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;
  final MessageStatus status;
  final bool isMine;

  MessageModel copyWith({MessageStatus? status}) => MessageModel(
        id: id,
        threadId: threadId,
        senderId: senderId,
        senderName: senderName,
        body: body,
        createdAt: createdAt,
        status: status ?? this.status,
        isMine: isMine,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'threadId': threadId,
        'senderId': senderId,
        'senderName': senderName,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'isMine': isMine,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        threadId: json['threadId'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: MessageStatus.values.byName(json['status'] as String? ?? 'sent'),
        isMine: json['isMine'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, threadId, body, status];
}

/// A discriminated event coming off the real-time channel: a new/updated
/// message, a typing indicator, or a read receipt. The UI reduces these
/// into `ChatThreadState` (see `chat_thread_provider.dart`).
sealed class ChatEvent {
  const ChatEvent(this.threadId);
  final String threadId;
}

class MessageEvent extends ChatEvent {
  const MessageEvent(super.threadId, this.message);
  final MessageModel message;
}

class TypingEvent extends ChatEvent {
  const TypingEvent(super.threadId, this.userName, this.isTyping);
  final String userName;
  final bool isTyping;
}

class ReadReceiptEvent extends ChatEvent {
  const ReadReceiptEvent(super.threadId, this.upToMessageId);
  final String upToMessageId;
}

class ThreadModel extends Equatable {
  const ThreadModel({
    required this.id,
    required this.title,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isCommunity = false,
  });

  final String id;
  final String title;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isCommunity;

  ThreadModel copyWith({String? lastMessage, DateTime? lastMessageAt, int? unreadCount}) => ThreadModel(
        id: id,
        title: title,
        avatarUrl: avatarUrl,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        isCommunity: isCommunity,
      );

  @override
  List<Object?> get props => [id, title, lastMessage, unreadCount];
}
