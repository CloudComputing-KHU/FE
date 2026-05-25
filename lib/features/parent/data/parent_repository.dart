import 'package:dio/dio.dart';

import 'package:itda/core/api/api_client.dart';
import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/models/dementia_analysis.dart';
import 'package:itda/features/parent/data/parent_models.dart';
import 'package:itda/services/dementia_service.dart';

/// parent 기능 전체의 API 호출을 담당합니다.
/// UI 레이어는 이 클래스만 의존하고, Dio·엔드포인트 상수는 여기서만 씁니다.
class ParentRepository {
  ParentRepository()
    : _dio = ApiClient.create(),
      _dementia = DementiaService(ApiClient.create());

  final Dio _dio;
  final DementiaService _dementia;

  // ── Questions ──────────────────────────────────────────────────────────────

  /// 오늘의 질문 1개를 조회합니다.
  /// [type] : 'health' | 'meal' | 'mood'
  Future<ParentQuestion> fetchQuestion(String type) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.questions(type),
    );
    return ParentQuestion.fromJson(res.data!);
  }

  /// 오늘 질문 답변 진행 상태를 조회합니다.
  Future<ParentQuestionStatus> fetchTodayQuestionStatus() async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.questionStatusToday,
    );
    return ParentQuestionStatus.fromJson(res.data!);
  }

  // ── Answers ────────────────────────────────────────────────────────────────

  /// 선택형 답변을 제출합니다.
  Future<void> submitAnswer({
    required String type,
    required String questionId,
    required String answer,
  }) async {
    await _dio.post<void>(
      ApiEndpoints.answers(type),
      data: {
        'question_id': questionId,
        'answer_type': 'choice',
        'answer': answer,
      },
    );
  }

  /// 음성 파일을 업로드합니다.
  /// [filePath] : 로컬 파일 경로 (m4a / wav / mp3)
  Future<ParentVoiceUploadResult> uploadVoice({
    required String type,
    required String questionId,
    required String filePath,
  }) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'question_id': questionId,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: DioMediaType('audio', 'mp4'),
      ),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.voiceAnswer(type),
      data: formData,
    );
    return ParentVoiceUploadResult.fromJson(res.data!);
  }

  Future<DementiaAnalysisResponse> requestDementiaAnalysis(String answerId) {
    return _dementia.requestAnalysis(answerId: answerId);
  }

  // ── Photos ─────────────────────────────────────────────────────────────────

  /// 부모가 받은 사진 목록을 최신순으로 조회합니다.
  Future<List<ParentReceivedPhoto>> fetchReceivedPhotos() async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.receivedPhotos);
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(ParentReceivedPhoto.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 지난 사진 이력을 조회합니다.
  Future<List<ParentReceivedPhoto>> fetchPhotoHistory() async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.receivedPhotosHistory,
    );
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(ParentReceivedPhoto.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
