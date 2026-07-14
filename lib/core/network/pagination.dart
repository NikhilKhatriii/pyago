/// A single cursor-paginated response. Every list endpoint (feed, explore,
/// comments, chat history, notifications) returns this shape so the
/// presentation layer has one pagination pattern to reason about.
class Page<T> {
  const Page({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<T> items;

  /// Opaque cursor to pass as `after` on the next request. Null when
  /// [hasMore] is false.
  final String? nextCursor;

  final bool hasMore;

  Page<R> map<R>(R Function(T) transform) => Page<R>(
        items: items.map(transform).toList(),
        nextCursor: nextCursor,
        hasMore: hasMore,
      );

  static Page<T> empty<T>() => Page<T>(items: const [], nextCursor: null, hasMore: false);
}
