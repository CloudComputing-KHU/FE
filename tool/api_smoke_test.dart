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
import 'package:itda/services/quest_service.dart';
import 'package:itda/services/voice_upload_service.dart';

Future<void> main() async {
  print('=== ITDA API Smoke Test ===\n');

  final Dio dio = ApiClient.create();
  final questService = QuestService(dio);
  final voiceUploadService = VoiceUploadService(dio);

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

  // 2) POST /answers/health (텍스트 답변 제출)
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

  // 4) POST /answers/health/voice (음성 답변 업로드)
  try {
    print('[4] POST /answers/health/voice');
    const voicePath = 'test_voice.wav';
    if (!await File(voicePath).exists()) {
      print('    ⚠ $voicePath 파일이 없습니다. 더미 파일을 먼저 생성하세요.\n');
    } else {
      final result = await voiceUploadService.uploadVoice(
        type: 'health',
        userId: 'parent_001',
        questionId: 'q_health_today',
        filePath: voicePath,
      );
      print('    ✓ 성공');
      print('    answerId         : ${result.answerId}');
      print('    voiceStatus      : ${result.voiceStatus}');
      print('    voiceFileKey     : ${result.voiceFileKey}');
      print('    originalFilename : ${result.originalFilename}');
      print('    storedFilename   : ${result.storedFilename}');
      print('    fileSize         : ${result.fileSize} bytes');
      print('    contentType      : ${result.contentType}');
      print('    message          : ${result.message}\n');
    }
  } catch (e) {
    print('    ✗ 실패: $e\n');
  }

  print('=== 종료 ===');
}