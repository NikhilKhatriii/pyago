import 'package:equatable/equatable.dart';

/// Design decision: comments are **flat**, not threaded. Pyago's product
/// stance is thoughtful, low-pressure discussion rather than sprawling
/// nested debate — a flat list keeps the affordance simple and keeps
/// the UI legible at the reading-time/word-count scale posts are
/// written at. Revisit if community feedback asks for reply-to-reply.
class CommentModel extends Equatable {
  const CommentModel({
    required this.id,
    required this.postId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.body,
    required this.createdAt,
    this.status = CommentStatus.sent,
  });

  final String id;
  final String postId;
  final String authorName;
  final String? authorAvatarUrl;
  final String body;
  final DateTime createdAt;
  final CommentStatus status;

  CommentModel copyWith({CommentStatus? status}) => CommentModel(
        id: id,
        postId: postId,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        body: body,
        createdAt: createdAt,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'authorName': authorName,
        'authorAvatarUrl': authorAvatarUrl,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id'] as String,
        postId: json['postId'] as String,
        authorName: json['authorName'] as String,
        authorAvatarUrl: json['authorAvatarUrl'] as String?,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [id, postId, body, status];
}

enum CommentStatus { pending, sent, failed }
