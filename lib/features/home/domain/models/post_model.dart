import 'package:equatable/equatable.dart';

enum PostType { thought, poetry, journal, article, story, voice, image, video }

extension PostTypeX on PostType {
  String get label => switch (this) {
        PostType.thought => 'Thought',
        PostType.poetry => 'Poetry',
        PostType.journal => 'Journal',
        PostType.article => 'Article',
        PostType.story => 'Story',
        PostType.voice => 'Voice',
        PostType.image => 'Image',
        PostType.video => 'Video',
      };
}

class PostModel extends Equatable {
  const PostModel({
    required this.id,
    required this.authorIds,
    required this.authorNames,
    required this.type,
    required this.content,
    this.title,
    this.authorAvatarUrl,
    this.readingTimeMinutes = 1,
    this.resonanceCount = 0,
    this.commentCount = 0,
    this.isBookmarked = false,
    required this.createdAt,
  });

  final String id;
  final List<String> authorIds;
  final List<String> authorNames;
  final String? authorAvatarUrl;

  String get authorName => authorNames.join(' & ');
  final PostType type;
  final String? title;
  final String content;
  final int readingTimeMinutes;
  final int resonanceCount;
  final int commentCount;
  final bool isBookmarked;
  final DateTime createdAt;

  PostModel copyWith({int? resonanceCount, bool? isBookmarked, int? commentCount}) {
    return PostModel(
      id: id,
      authorIds: authorIds,
      authorNames: authorNames,
      authorAvatarUrl: authorAvatarUrl,
      type: type,
      title: title,
      content: content,
      readingTimeMinutes: readingTimeMinutes,
      resonanceCount: resonanceCount ?? this.resonanceCount,
      commentCount: commentCount ?? this.commentCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorIds': authorIds,
        'authorNames': authorNames,
        'authorAvatarUrl': authorAvatarUrl,
        'type': type.name,
        'title': title,
        'content': content,
        'readingTimeMinutes': readingTimeMinutes,
        'resonanceCount': resonanceCount,
        'commentCount': commentCount,
        'isBookmarked': isBookmarked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final names = (json['authorNames'] as List<dynamic>?)?.cast<String>() ??
        (json['authorName'] != null ? [json['authorName'] as String] : []);
    final ids = (json['authorIds'] as List<dynamic>?)?.cast<String>() ?? [];
    return PostModel(
        id: json['id'] as String,
        authorIds: ids,
        authorNames: names,
        authorAvatarUrl: json['authorAvatarUrl'] as String?,
        type: PostType.values.byName(json['type'] as String),
        title: json['title'] as String?,
        content: json['content'] as String,
        readingTimeMinutes: json['readingTimeMinutes'] as int? ?? 1,
        resonanceCount: json['resonanceCount'] as int? ?? 0,
        commentCount: json['commentCount'] as int? ?? 0,
        isBookmarked: json['isBookmarked'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
  }

  @override
  List<Object?> get props =>
      [id, authorIds, authorNames, type, title, content, resonanceCount, commentCount, isBookmarked];
}
