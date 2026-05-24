import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/models/photo_reaction.dart';

/// 사진별 부모 반응 API 클라이언트.
class PhotoReactionService {
  PhotoReactionService(this._dio);

  final Dio _dio;

  Future<List<PhotoReaction>> getReactions(String photoId) async {
    final response = await _dio.get<List<dynamic>>(
      ApiEndpoints.photoReactions(photoId),
    );
    return (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(PhotoReaction.fromJson)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<PhotoReaction> saveQuickReaction({
    required String photoId,
    required String label,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.photoQuickReaction(photoId),
      data: {'label': label},
    );
    return PhotoReaction.fromJson(response.data!);
  }

  Future<PhotoReaction> saveVoiceReaction({
    required String photoId,
    required String filePath,
    Uint8List? fileBytes,
    String? fileName,
    int? durationSeconds,
  }) async {
    final file = fileBytes == null
        ? await MultipartFile.fromFile(
            filePath,
            filename: fileName ?? filePath.split('/').last,
          )
        : MultipartFile.fromBytes(
            fileBytes,
            filename: fileName == null || fileName.isEmpty
                ? 'voice.m4a'
                : fileName,
          );
    final formData = FormData.fromMap({
      'file': file,
      'duration_seconds': ?durationSeconds,
    });
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.photoVoiceReaction(photoId),
      data: formData,
    );
    return PhotoReaction.fromJson(response.data!);
  }
}
