enum PostVisibility { public, private, followersOnly }

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final DateTime createdAt;
  final PostVisibility visibility;
  final int likes;
  final int comments;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.visibility = PostVisibility.public,
    this.likes = 0,
    this.comments = 0,
  });
}
