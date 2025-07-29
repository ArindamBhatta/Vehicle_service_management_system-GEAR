import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_riverpod/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  final supabaseClient = Supabase.instance.client;
  return ImageUploadService(supabaseClient);
});

class ImageUploadService {
  final SupabaseClient _client;

  ImageUploadService(this._client);
  Future<String> uploadImage(XFile file, String bucket, String path) async {
    try {
      final fileExt = file.name.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExt)) {
        throw Exception(
          'Invalid image format. Supported formats: JPG, PNG, GIF, WEBP',
        );
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$path/$fileName';

      final mimeTypes = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'gif': 'image/gif',
        'webp': 'image/webp',
      };
      final contentType = mimeTypes[fileExt] ?? 'image/jpeg';

      Uint8List? fileBytes;

      if (kIsWeb) {
        final originalBytes = await file.readAsBytes();
        fileBytes = await FlutterImageCompress.compressWithList(
          originalBytes,
          minWidth: 800,
          minHeight: 800,
          quality: 85,
          format: CompressFormat.jpeg,
        );
      } else {
        fileBytes = await FlutterImageCompress.compressWithFile(
          file.path,
          minWidth: 800,
          minHeight: 800,
          quality: 85,
          format: CompressFormat.jpeg,
        );
      }

      if (fileBytes == null) {
        throw Exception('Failed to compress image');
      }

      await _client.storage
          .from(bucket)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      return _client.storage.from(bucket).getPublicUrl(filePath);
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        'Error uploading image',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
