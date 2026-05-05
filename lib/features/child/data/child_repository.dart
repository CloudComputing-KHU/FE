import 'package:itda/core/api/api_client.dart';
import 'package:itda/core/models/answer_item.dart';
import 'package:itda/core/models/photo.dart';
import 'package:itda/core/models/quest.dart';
import 'package:itda/services/photo_api_service.dart';
import 'package:itda/services/quest_service.dart';

/// 자녀 기능 전체의 API 호출을 담당합니다.
/// UI 레이어는 이 클래스만 의존하고, 내부적으로 [QuestService]·[PhotoApiService]를 사용합니다.
class ChildRepository {
  ChildRepository()
      : _quest = QuestService(ApiClient.create()),
        _photo = PhotoApiService(ApiClient.create());

  final QuestService _quest;
  final PhotoApiService _photo;

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
}