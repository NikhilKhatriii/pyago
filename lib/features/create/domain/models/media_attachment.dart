enum MediaKind { image, video, audio }

enum MediaUploadStatus { pending, compressing, uploading, done, failed }

class MediaAttachment {
  const MediaAttachment({
    required this.id,
    required this.kind,
    required this.localPath,
    this.remoteUrl,
    this.thumbnailPath,
    this.progress = 0.0,
    this.status = MediaUploadStatus.pending,
  });

  final String id;
  final MediaKind kind;
  final String localPath;
  final String? remoteUrl;
  final String? thumbnailPath;

  /// 0.0–1.0, meaningful while [status] is compressing/uploading.
  final double progress;
  final MediaUploadStatus status;

  MediaAttachment copyWith({
    String? remoteUrl,
    String? thumbnailPath,
    double? progress,
    MediaUploadStatus? status,
  }) {
    return MediaAttachment(
      id: id,
      kind: kind,
      localPath: localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'localPath': localPath,
        'remoteUrl': remoteUrl,
        'thumbnailPath': thumbnailPath,
        'progress': progress,
        'status': status.name,
      };

  factory MediaAttachment.fromJson(Map<String, dynamic> json) => MediaAttachment(
        id: json['id'] as String,
        kind: MediaKind.values.byName(json['kind'] as String),
        localPath: json['localPath'] as String,
        remoteUrl: json['remoteUrl'] as String?,
        thumbnailPath: json['thumbnailPath'] as String?,
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        status: MediaUploadStatus.values.byName(json['status'] as String? ?? 'done'),
      );
}
