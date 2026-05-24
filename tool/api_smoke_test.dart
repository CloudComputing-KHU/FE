/// API 연동 스모크 테스트 스크립트.
///
/// 실행 방법:
/// ```
/// dart --define=API_BASE_URL=http://127.0.0.1:8000 run tool/api_smoke_test.dart
/// ```
library;

import 'dart:io';

import 'package:dio/dio.dart';

import 'package:itda/core/api/api_client.dart';
import 'package:itda/services/photo_api_service.dart';
import 'package:itda/services/quest_service.dart';
import 'package:itda/services/notification_service.dart';

Future<void> main() async {
  print('=== ITDA API Smoke Test ===\n');

  final Dio dio = ApiClient.create();
  final questService = QuestService(dio);
  final photoApiService = PhotoApiService(dio);
  final notificationService = NotificationService(dio);

  // 1) GET /questions/health
  try {
    print('[1] GET /questions/health');
    final quest = await questService.getTodayQuestion('health');
    print('    ✓ 성공');
    print('    id          : ${quest.id}');
    print('    type        : ${quest.type}');
    print('    question    : ${quest.question}');
    print('    options     : ${quest.options}');
    print('    allowVoice  : ${quest.allowVoice}\n');
  } catch (e) {
    print('    ✗ 실패: $e\n');
  }

  // 2) POST /answers/health
  try {
    print('[2] POST /answers/health');
    await questService.submitAnswer(
      type: 'health',
      userId: 'parent_001',
      questionId: 'q_health_today',
      answer: '네, 먹었어요',
    );
    print('    ✓ 성공\n');
  } catch (e) {
    print('    ✗ 실패: $e\n');
  }

  // 3) GET /answers/health?user_id=parent_001
  try {
    print('[3] GET /answers/health?user_id=parent_001');
    final answers = await questService.getAnswers(
      type: 'health',
      userId: 'parent_001',
    );
    print('    ✓ 성공');
    print('    count: ${answers.length}');
    for (final a in answers.take(3)) {
      print('    - [${a.answerType}] ${a.answer ?? a.voiceFileKey ?? "(empty)"} '
          '@ ${a.createdAt}');
    }
    print('');
  } catch (e) {
    print('    ✗ 실패: $e\n');
  }

  // [4] 음성 업로드는 부모 담당자(현기님) 영역으로 이관됨

  // 5) POST /photos
  try {
    print('[5] POST /photos');
    const photoPath = 'test_photo.jpg';
    if (!await File(photoPath).exists()) {
      print('    ⚠ $photoPath 파일이 없습니다.\n');
    } else {
      final photo = await photoApiService.uploadPhoto(
        senderUserId: 'child_001',
        receiverUserId: 'parent_001',
        filePath: photoPath,
        caption: '점심 먹어요 🍱',
      );
      print('    ✓ 성공');
      print('    photoId          : ${photo.id}');
      print('    status           : ${photo.status}');
      print('    imageUrl         : ${photo.imageUrl}');
      print('    caption          : ${photo.caption}\n');
    }
  } catch (e) {
    print('    ✗ 실패 (S3 키 미설정 시 502 정상): $e\n');
  }

  // 6) GET /photos/history?user_id=child_001
  try {
    print('[6] GET /photos/history?user_id=child_001');
    final history = await photoApiService.getHistory('child_001');
    print('    ✓ 성공');
    print('    count: ${history.length}');
    for (final p in history.take(3)) {
      print('    - [${p.status}] ${p.caption ?? "(no caption)"} @ ${p.createdAt}');
    }
    print('');
  } catch (e) {
    print('    ✗ 실패: $e\n');
  }


  // 7) GET /notifications
  try {
    print('[7] GET /notifications');
    final notis = await notificationService.getNotifications();
    print('    ✓ 성공');
    print('    count: ${notis.length}');
    for (final n in notis.take(3)) {
      print('    - [${n.isRead ? "읽음" : "안읽음"}] ${n.title} @ ${n.createdAt}');
    }
    print('');
  } catch (e) {
    print('    ✗ 실패 (인증 필요 시 401/403 정상): $e\n');
  }

  // 8) POST /devices/register
  try {
    print('[8] POST /devices/register');
    await notificationService.registerDevice('dummy_fcm_token_for_test');
    print('    ✓ 성공\n');
  } catch (e) {
    print('    ✗ 실패 (인증 필요 시 401/403 정상): $e\n');
  }

  print('=== 종료 ===');
}
