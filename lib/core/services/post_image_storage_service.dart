import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Uploads post photos to Firebase Storage and returns public download URLs.
class PostImageStorageService {
  PostImageStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  static const _maxBytes = 2 * 1024 * 1024;
  static const _uploadTimeout = Duration(seconds: 90);

  /// Uploads [bytes] to `posts/{postId}/photo.jpg` and returns the URL.
  Future<String> uploadPostImage({
    required Uint8List bytes,
    required String postId,
  }) async {
    if (bytes.isEmpty) {
      throw PostImageStorageException('Photo file is empty.');
    }

    if (bytes.length > _maxBytes) {
      throw PostImageStorageException('Photo is too large (max 2 MB).');
    }

    final ref = _storage.ref().child('posts/$postId/photo.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    try {
      final task = ref.putData(bytes, metadata);
      await task.timeout(
        _uploadTimeout,
        onTimeout: () {
          task.cancel();
          throw PostImageStorageException('Upload timed out. Check your connection.');
        },
      );
      return ref.getDownloadURL().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw PostImageStorageException(
          'Could not get photo URL. Please try again.',
        ),
      );
    } on PostImageStorageException {
      rethrow;
    } on FirebaseException catch (e) {
      throw PostImageStorageException(e.message ?? 'Storage upload failed.');
    } on TimeoutException {
      throw PostImageStorageException('Upload timed out. Check your connection.');
    }
  }
}

class PostImageStorageException implements Exception {
  PostImageStorageException(this.message);
  final String message;

  @override
  String toString() => message;
}
