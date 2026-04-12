import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// multipart/form-data 사진 업로드 (백엔드 URL은 환경에 맞게 설정)
class PhotoUploadService {
  PhotoUploadService({this.baseUrl = 'https://api.example.com/v1/photos'});

  final String baseUrl;

  Future<PhotoUploadResult> uploadXFile({
    required XFile file,
    required String caption,
    DateTime? scheduledAt,
  }) async {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme) {
      return PhotoUploadResult(
        ok: false,
        statusCode: 0,
        message: '유효하지 않은 업로드 URL입니다. PhotoUploadService.baseUrl을 설정하세요.',
      );
    }

    try {
      final bytes = await file.readAsBytes();
      final request = http.MultipartRequest('POST', uri);
      request.fields['caption'] = caption;
      if (scheduledAt != null) {
        request.fields['scheduledAt'] = scheduledAt.toUtc().toIso8601String();
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: file.name.isEmpty ? 'photo.jpg' : file.name,
        ),
      );

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      final ok = streamed.statusCode >= 200 && streamed.statusCode < 300;
      return PhotoUploadResult(
        ok: ok,
        statusCode: streamed.statusCode,
        message: ok ? '전송 완료' : (body.isEmpty ? '서버 오류' : body),
      );
    } on Object catch (e) {
      return PhotoUploadResult(
        ok: false,
        statusCode: 0,
        message: e.toString().contains('SocketException')
            ? '네트워크에 연결할 수 없습니다. 데모 URL이므로 로컬에서는 실패할 수 있어요.'
            : e.toString(),
      );
    }
  }
}

class PhotoUploadResult {
  PhotoUploadResult({
    required this.ok,
    required this.statusCode,
    required this.message,
  });

  final bool ok;
  final int statusCode;
  final String message;
}
