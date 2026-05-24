import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/models/photo.dart';

/// 잇다 백엔드의 사진 API 클라이언트 (dio 기반).
///
/// 백엔드 엔드포인트:
/// - `POST /photos` — 사진 전송 (즉시/예약, multipart)
/// - `GET /photos/history` — 사용자가 보낸 사진 내역
class PhotoApiService {
  PhotoApiService(this._dio);

  final Dio _dio;

  /// 사진 전송. [scheduledAt]이 없으면 즉시 전송, 있으면 예약 전송.
  Future<Photo> uploadPhoto({
    required String filePath,
    Uint8List? fileBytes,
    String? fileName,
    String? caption,
    DateTime? scheduledAt,
  }) async {
    final file = fileBytes == null
        ? await MultipartFile.fromFile(filePath)
        : MultipartFile.fromBytes(
            fileBytes,
            filename: fileName == null || fileName.isEmpty
                ? 'photo.jpg'
                : fileName,
          );

    final formData = FormData.fromMap({
      'file': file,
      'caption': ?caption,
      if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
    });

    final response = await _dio.post(ApiEndpoints.photos, data: formData);

    return Photo.fromJson(response.data as Map<String, dynamic>);
  }

  /// 본인이 보낸 사진 내역 조회 (최신순).
  Future<List<Photo>> getHistory() async {
    final response = await _dio.get(ApiEndpoints.photosHistory);
    final list = response.data as List<dynamic>;
    return list.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList();
  }
}
