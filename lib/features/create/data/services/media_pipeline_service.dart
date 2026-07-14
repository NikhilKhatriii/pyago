import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/media_attachment.dart';

/// Handles picking image/video/audio and the compress → upload lifecycle
/// for the Create editor.
///
/// There is no real media backend yet, so [processAndUpload] *simulates*
/// compression and upload progress rather than doing either for real —
/// but it does so through the same [MediaAttachment] status/progress
/// shape a real implementation would use (see the class doc on
/// `MockEngine` for why this matters): swapping in real
/// `flutter_image_compress` + `ApiClient.uploadFile` later changes only
/// this method's body, not any provider or widget that consumes it.
class MediaPipelineService {
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  final _random = Random();

  Future<MediaAttachment?> pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file == null) return null;
    return MediaAttachment(id: const Uuid().v4(), kind: MediaKind.image, localPath: file.path);
  }

  Future<MediaAttachment?> captureImage() async {
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (file == null) return null;
    return MediaAttachment(id: const Uuid().v4(), kind: MediaKind.image, localPath: file.path);
  }

  Future<MediaAttachment?> pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return null;
    return MediaAttachment(id: const Uuid().v4(), kind: MediaKind.video, localPath: file.path);
  }

  Future<bool> canRecordAudio() => _recorder.hasPermission();

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/pyago_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
  }

  Future<MediaAttachment?> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) return null;
    return MediaAttachment(id: const Uuid().v4(), kind: MediaKind.audio, localPath: path);
  }

  Future<bool> isRecording() => _recorder.isRecording();

  /// Emits progressively-updated copies of [attachment] as it moves
  /// through compressing → uploading → done, so the editor can show a
  /// real (if simulated) progress indicator per attachment.
  Stream<MediaAttachment> processAndUpload(MediaAttachment attachment) async* {
    var current = attachment.copyWith(status: MediaUploadStatus.compressing, progress: 0);
    yield current;
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)));

    current = current.copyWith(status: MediaUploadStatus.uploading, progress: 0);
    yield current;
    const steps = 8;
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: 120 + _random.nextInt(160)));
      current = current.copyWith(progress: i / steps);
      yield current;
    }

    current = current.copyWith(
      status: MediaUploadStatus.done,
      progress: 1,
      remoteUrl: attachment.localPath, // no real backend yet — see swap-seam note above
      thumbnailPath: attachment.kind == MediaKind.image ? attachment.localPath : null,
    );
    yield current;
  }

  void dispose() {
    _recorder.dispose();
  }
}

final mediaPipelineServiceProvider = Provider<MediaPipelineService>((ref) {
  final service = MediaPipelineService();
  ref.onDispose(service.dispose);
  return service;
});
