import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import '../../features/home/domain/models/post_model.dart';

/// Service responsible for generating a C2PA-style content credential manifest for a published post.
class ContentCredentialService {
  static const _keyStorageKey = 'c2pa_private_key';
  final FlutterSecureStorage _secureStorage;

  ContentCredentialService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<String> _getOrCreatePrivateKey() async {
    var key = await _secureStorage.read(key: _keyStorageKey);
    if (key == null) {
      final generated = base64Url.encode(List<int>.generate(32, (_) => DateTime.now().microsecond % 256));
      await _secureStorage.write(key: _keyStorageKey, value: generated);
      key = generated;
    }
    return key;
  }

  /// Generate signed manifest JSON.
  Future<String> generateManifest(PostModel post) async {
    final privateKey = await _getOrCreatePrivateKey();
    final now = DateTime.now().toUtc().toIso8601String();
    final contentDigest = sha256.convert(utf8.encode(post.content)).toString();
    final manifest = {
      'author': post.authorNames.join(' & '),
      'created': now,
      'postId': post.id,
      'contentDigest': contentDigest,
      'aiInvolvement': 'none',
      'editHistory': {
        'draftCreation': now,
        'brewModeDurationSeconds': 0,
        'editingSessions': 1,
      },
    };
    final signature = sha256.convert(utf8.encode(jsonEncode(manifest) + privateKey)).toString();
    manifest['signature'] = signature;
    return jsonEncode(manifest);
  }

  Future<bool> verifyManifest(String manifestJson) async {
    final map = jsonDecode(manifestJson) as Map<String, dynamic>;
    final signature = map['signature'] as String?;
    map.remove('signature');
    final privateKey = await _getOrCreatePrivateKey();
    final expected = sha256.convert(utf8.encode(jsonEncode(map) + privateKey)).toString();
    return expected == signature;
  }
}
