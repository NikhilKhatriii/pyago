import '../../../home/domain/models/post_model.dart';
import '../../../../core/crdt/crdt_block.dart';
import 'collaboration_invite.dart';
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
    this.collaborators = const [],
    this.blocks = const [],
  });

  final String id;
  final String title;

  /// Flat body text — used by non-Story formats and preserved for backward
  /// compatibility. Story drafts store content in [blocks] instead and
  /// expose [resolvedBody] for publish/preview.
  final String body;

  final PostType type;
  final List<MediaAttachment> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DraftPublishState publishState;
  final List<CollaborationInvite> collaborators;

  /// CRDT structural blocks — populated for Story (one per chapter/sceneBreak).
  /// Empty for all other formats (they use the flat [body] field).
  final List<CrdtBlock> blocks;

  /// True when this draft uses CRDT blocks as its canonical content store.
  bool get isBlockBased => type == PostType.story && blocks.isNotEmpty;

  /// The authoritative body string for publish, preview, and word-count.
  /// For block-based Story drafts, reconstructs from CRDT resolved text.
  String get resolvedBody {
    if (!isBlockBased) return body;
    final buf = StringBuffer();
    final sorted = [...blocks]..sort((a, b) => a.order.compareTo(b.order));
    for (final block in sorted) {
      if (block.type == CrdtBlockType.sceneBreak) {
        buf.writeln('\n---\n');
      } else {
        if (block.title.isNotEmpty) buf.writeln('## ${block.title}');
        buf.writeln(block.resolvedText);
      }
    }
    return buf.toString().trimRight();
  }

  bool get isEmpty => title.isEmpty && resolvedBody.isEmpty && attachments.isEmpty;

  int get wordCount {
    final text = resolvedBody.trim();
    return text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
  }

  int get readingTimeMinutes => (wordCount / 200).ceil().clamp(1, 999);

  DraftModel copyWith({
    String? title,
    String? body,
    PostType? type,
    List<MediaAttachment>? attachments,
    DateTime? updatedAt,
    DraftPublishState? publishState,
    List<CollaborationInvite>? collaborators,
    List<CrdtBlock>? blocks,
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
      collaborators: collaborators ?? this.collaborators,
      blocks: blocks ?? this.blocks,
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
        'collaborators': collaborators.map((c) => c.toJson()).toList(),
        'blocks': blocks.map((b) => b.toJson()).toList(),
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
        collaborators: (json['collaborators'] as List? ?? [])
            .map((c) => CollaborationInvite.fromJson(c as Map<String, dynamic>))
            .toList(),
        blocks: (json['blocks'] as List? ?? [])
            .map((b) => CrdtBlock.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
}
