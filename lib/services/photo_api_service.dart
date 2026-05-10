import 'package:dio/dio.dart';

import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/models/photo.dart';

/// 잇다 백엔드의 사진 API 클라이언트 (dio 기반).
///
/// 백엔드 엔드포인트:
/// - `POST /photos` — 사진 전송 (즉시/예약, multipart)
/// - `GET /photos/history?user_id=...` — 사용자가 보낸 사진 내역
///
/// 기존 `PhotoUploadService.uploadXFile`(http + image_picker 기반)은
/// 화면(`photo_upload_screen.dart`)이 그대로 사용하고 있어 보존하며,
/// 신규 BE 명세 연동은 본 클래스에서 담당합니다. UI 통합 시점에
/// 양쪽을 일원화할 예정입니다.
class PhotoApiService {
  PhotoApiService(this._dio);

  final Dio _dio;

  /// 사진 전송. [scheduledAt]이 없으면 즉시 전송, 있으면 예약 전송.
  Future<Photo> uploadPhoto({
    required String senderUserId,
    required String receiverUserId,
    required String filePath,
    String? caption,
    DateTime? scheduledAt,
  }) async {
    final formData = FormData.fromMap({
      'sender_user_id': senderUserId,
      'receiver_user_id': receiverUserId,
      'file': await MultipartFile.fromFile(filePath),
      if (caption != null) 'caption': caption,
      if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
    });

    final response = await _dio.post(
      ApiEndpoints.photos,
      data: formData,
    );

    return Photo.fromJson(response.data as Map<String, dynamic>);
  }

  /// 본인이 보낸 사진 내역 조회 (최신순).
  Future<List<Photo>> getHistory(String userId) async {
    final response = await _dio.get(
      ApiEndpoints.photosHistory,
      queryParameters: {'user_id': userId},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Photo.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}