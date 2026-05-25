import 'package:dio/dio.dart';

import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/models/answer_item.dart';
import 'package:itda/core/models/quest.dart';

/// 일일 퀘스트 / 답변 API 클라이언트.
///
/// 백엔드 엔드포인트:
/// - `GET /questions/{type}` — 오늘의 질문 조회
/// - `POST /answers/{type}` — 텍스트(선택형) 답변 저장
/// - `GET /answers/{type}` — 사용자 답변 목록 조회
/// - 음성 답변 업로드는 부모 영역(현기님 담당)에서 처리
class QuestService {
  QuestService(this._dio);

  final Dio _dio;

  /// 오늘의 퀘스트 질문 조회.
  ///
  /// [type]은 `health`, `meal`, `mood` 중 하나.
  Future<Quest> getTodayQuestion(String type) async {
    final response = await _dio.get(ApiEndpoints.questions(type));
    return Quest.fromJson(response.data as Map<String, dynamic>);
  }

  /// 선택형(텍스트) 답변 저장.
  ///
  /// 음성 답변은 부모 영역(ParentRepository.submitVoice)에서 처리합니다.
  Future<void> submitAnswer({
    required String type,
    required String questionId,
    required String answer,
  }) async {
    await _dio.post(
      ApiEndpoints.answers(type),
      data: {
        'question_id': questionId,
        'answer': answer,
        'answer_type': 'choice',
      },
    );
  }

  /// 사용자의 답변 목록 조회 (자녀가 부모 답변 확인용).
  ///
  /// 최신 시간순으로 정렬되어 옵니다.
  Future<List<AnswerItem>> getAnswers({required String type}) async {
    final response = await _dio.get(ApiEndpoints.answers(type));
    final list = response.data as List<dynamic>;
    return list
        .map((e) => AnswerItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
