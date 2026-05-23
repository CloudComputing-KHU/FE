import 'package:itda/core/api/api_client.dart';
import 'package:itda/core/models/answer_item.dart';
import 'package:itda/core/models/dementia_analysis.dart';
import 'package:itda/core/models/photo.dart';
import 'package:itda/core/models/quest.dart';
import 'package:itda/services/dementia_service.dart';
import 'package:itda/services/photo_api_service.dart';
import 'package:itda/services/quest_service.dart';

/// 자녀 기능 전체의 API 호출을 담당합니다.
/// UI 레이어는 이 클래스만 의존하고, 내부적으로 [QuestService]·[PhotoApiService]·[DementiaService]를 사용합니다.
class ChildRepository {
  ChildRepository()
    : _quest = QuestService(ApiClient.create()),
      _photo = PhotoApiService(ApiClient.create()),
      _dementia = DementiaService(ApiClient.create());

  final QuestService _quest;
  final PhotoApiService _photo;
  final DementiaService _dementia;

  // ── 자녀가 부모 상태 확인 ────────────────────────────────────────────────

  /// 부모가 받은 오늘의 질문을 조회합니다.
  /// [type] : 'health' | 'meal' | 'mood'
  Future<Quest> fetchQuestion(String type) {
    return _quest.getTodayQuestion(type);
  }

  /// 부모가 남긴 답변 목록을 최신순으로 조회합니다.
  Future<List<AnswerItem>> fetchParentAnswers({
    required String type,
    required String parentUserId,
  }) {
    return _quest.getAnswers(type: type, userId: parentUserId);
  }

  // ── 자녀가 사진 보내기 ──────────────────────────────────────────────────

  /// 부모에게 사진을 전송합니다. [scheduledAt]이 없으면 즉시 전송.
  Future<Photo> sendPhoto({
    required String childUserId,
    required String parentUserId,
    required String filePath,
    String? caption,
    DateTime? scheduledAt,
  }) {
    return _photo.uploadPhoto(
      senderUserId: childUserId,
      receiverUserId: parentUserId,
      filePath: filePath,
      caption: caption,
      scheduledAt: scheduledAt,
    );
  }

  /// 자녀가 보낸 사진 이력을 최신순으로 조회합니다.
  Future<List<Photo>> fetchSentPhotos(String childUserId) {
    return _photo.getHistory(childUserId);
  }

  // ── 치매 위험 분석 ───────────────────────────────────────────────────────

  /// 부모의 음성 답변에 대한 치매 위험 분석을 요청합니다.
  /// 비동기 분석이라 즉시 [DementiaAnalysisResponse]를 반환하며 status는 `pending`입니다.
  Future<DementiaAnalysisResponse> requestDementiaAnalysis({
    required String answerId,
  }) {
    return _dementia.requestAnalysis(answerId: answerId);
  }

  /// 분석 결과 단건 상세 조회.
  Future<DementiaAnalysisResult> fetchDementiaAnalysis(String analysisId) {
    return _dementia.getAnalysis(analysisId);
  }

  /// 로그인 사용자의 치매 분석 이력을 최신순으로 조회합니다.
  Future<List<DementiaAnalysisItem>> fetchParentDementiaHistory() {
    return _dementia.getUserAnalyses();
  }
}
