import '../../../home/domain/models/post_model.dart';
import 'media_attachment.dart';

enum DraftPublishState { draft, queuedForPublish, published, failed }

/// Structured draft content — replaces the Phase 1 raw `"title|||body"`
/// string join. Markdown body + attachments both survive an app
/// restart via the offline draft store (Hive `drafts` box).
class DraftModel {
  const DraftModel({
    required this.id,
    this.title = '',
    this.body = '',
    this.type = PostType.thought,
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.publishState = DraftPublishState.draft,
  });

  final String id;
  final String title;
  final String body;
  final PostType type;
  final List<MediaAttachment> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DraftPublishState publishState;

  bool get isEmpty => title.isEmpty && body.isEmpty && attachments.isEmpty;

  int get wordCount => body.trim().isEmpty ? 0 : body.trim().split(RegExp(r'\s+')).length;
  int get readingTimeMinutes => (wordCount / 200).ceil().clamp(1, 999);

  DraftModel copyWith({
    String? title,
    String? body,
    PostType? type,
    List<MediaAttachment>? attachments,
    DateTime? updatedAt,
    DraftPublishState? publishState,
  }) {
    return DraftModel(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      publishState: publishState ?? this.publishState,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'publishState': publishState.name,
      };

  factory DraftModel.fromJson(Map<String, dynamic> json) => DraftModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        type: PostType.values.byName(json['type'] as String? ?? 'thought'),
        attachments: (json['attachments'] as List? ?? [])
            .map((a) => MediaAttachment.fromJson(a as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        publishState: DraftPublishState.values.byName(json['publishState'] as String? ?? 'draft'),
      );
}
