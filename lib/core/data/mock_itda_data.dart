/// 부모가 사진에 남기는 빠른 반응 프리셋(이모지·라벨). 자유 텍스트 입력은 없습니다.
class ParentPhotoQuickReactionPreset {
  const ParentPhotoQuickReactionPreset({
    required this.emoji,
    required this.label,
    required this.positive,
  });

  final String emoji;
  final String label;
  /// `true`면 초록 테두리, `false`면 주황 테두리 (부모 UI와 동일)
  final bool positive;
}

/// 데모·UI 목업용 정적 데이터. 백엔드 연동 후 DTO·리포지토리로 대체합니다.
class MockItdaData {
  static const String parentDisplayName = '어머니';
  static const String childDisplayName = '민지';

  /// 부모 홈 상단 인사 이름.
  static const String parentWelcomeName = '영자';
  static const String parentHomeQuestQuestion = '오늘 약은\n드셨어요?';
  static const String parentHomeQuestQuestionMeal = '오늘 식사는\n잘 하셨어요?';
  static const String parentHomeQuestQuestionMood = '오늘 기분은\n어떠세요?';

  /// 자녀 대시보드 상단 인사 한 줄.
  static const String dashboardGreetingLine =
      '어머니께서 오늘 건강 퀘스트를\n모두 완료하셨어요. 안부 사진내보세요!';

  static const List<DashboardSummaryTile> dashboardSummaryTiles = [
    DashboardSummaryTile(
      label: '응답 완료',
      value: '3',
      unit: '/3',
      sub: '오늘 퀘스트',
      variant: SummaryVariant.orange,
    ),
    DashboardSummaryTile(
      label: '건강 점수',
      value: '87',
      unit: '점',
      sub: '전주 대비 +5',
      variant: SummaryVariant.green,
    ),
    DashboardSummaryTile(
      label: '위험 알림',
      value: '2',
      unit: '건',
      sub: '확인 필요',
      variant: SummaryVariant.coral,
    ),
    DashboardSummaryTile(
      label: '연속 기록',
      value: '12',
      unit: '일',
      sub: '꾸준히 🔥',
      variant: SummaryVariant.purple,
    ),
  ];

  static const List<String> dashboardChartLabels = [
    '4/4', '4/5', '4/6', '4/7', '4/8', '4/9', '4/10',
  ];
  static const List<double> dashboardChartScores = [82, 85, 80, 84, 83, 85, 87];

  static const List<DashboardRiskAlert> dashboardRiskAlerts = [
    DashboardRiskAlert(
      danger: true,
      title: '발화 속도 저하 감지',
      desc: '최근 3일간 어머니의 음성 응답 속도가 평소보다 느려지고 있어요.',
      time: '2시간 전 · 음성 분석',
    ),
    DashboardRiskAlert(
      danger: false,
      title: '수면 관련 부정 응답 2회',
      desc: '"잘 못 잤다"는 응답이 이번 주 2번 있었어요.',
      time: '오늘 오전 · 퀘스트 분석',
    ),
  ];

  static const List<DashboardTodayQuest> dashboardTodayQuests = [
    DashboardTodayQuest(q: '오늘 약 드셨어요?', positive: true),
    DashboardTodayQuest(q: '아침 식사 하셨어요?', positive: true),
    DashboardTodayQuest(q: '어제 잘 주무셨어요?', positive: false),
  ];

  static const List<Map<String, String>> recentChildFeed = [
    {'title': '사진 전송 완료', 'subtitle': '오늘 점심 식사 — 예약 18:00', 'time': '오늘 14:20'},
    {'title': '알림', 'subtitle': '일일 건강 리포트가 도착했습니다', 'time': '어제 09:00'},
    {'title': '사진 전송 완료', 'subtitle': '산책 중 — 즉시 전송', 'time': '어제 17:05'},
  ];

  static const Map<String, String> healthSummary = {
    'mood': '양호',
    'sleep': '평소 대비 안정적',
    'activity': '어제 대비 +12%',
    'note': '최근 음성 응답에서 머뭇거림이 소폭 증가했습니다. 가벼운 대화를 권장합니다.',
  };

  static const List<double> weeklyMoodTrend = [3.2, 3.5, 3.1, 3.8, 3.6, 3.9, 3.7];

  static const List<Map<String, String>> questResults = [
    {'q': '오늘 기분은 어떠세요?', 'a': '괜찮아요', 'date': '4/10'},
    {'q': '어제 잠은 잘 주무셨나요?', 'a': '조금 짧았어요', 'date': '4/9'},
    {'q': '점심은 드셨나요?', 'a': '네, 다 먹었어요', 'date': '4/8'},
  ];

  static const Map<String, String> voiceRiskAlert = {
    'level': '관찰',
    'title': '음성·발화 패턴 알림',
    'body':
        'AI 분석 결과, 발화 속도 저하와 짧은 멈춤이 이전 주 대비 늘었습니다. '
        '치매 전조 가능성은 낮으나, 정기 검진·대화 빈도 점검을 권장합니다.',
  };

  static List<ParentPendingPhoto> pendingPhotos = [
    ParentPendingPhoto(
      id: '1',
      imageUrl: 'https://picsum.photos/seed/itda_parent_1/900/700',
      caption: '벚꽃이 폈어요',
      arrivedAt: '방금 전',
      dateLabel: '4월 10일',
      isNew: true,
    ),
    ParentPendingPhoto(
      id: '2',
      imageUrl: 'https://picsum.photos/seed/itda_parent_2/900/700',
      caption: '점심 먹어요',
      arrivedAt: '10분 전',
      dateLabel: '4월 10일',
      isNew: true,
    ),
    ParentPendingPhoto(
      id: '3',
      imageUrl: 'https://picsum.photos/seed/itda_parent_3/900/700',
      caption: '꽃 샀어요',
      arrivedAt: '오늘 09:15',
      dateLabel: '4월 10일',
      isNew: true,
    ),
  ];

  /// 지난 사진 보기 데모 — 날짜별로 넘겨 보며 확인 (최신 날짜가 앞쪽 인덱스)
  static List<ParentPendingPhoto> pastArchivePhotos = [
    ParentPendingPhoto(
      id: 'past_1',
      imageUrl: 'https://picsum.photos/seed/itda_past_91/900/700',
      caption: '카페 왔어요',
      arrivedAt: '어제 18:30',
      dateLabel: '4월 9일',
      isNew: false,
    ),
    ParentPendingPhoto(
      id: 'past_2',
      imageUrl: 'https://picsum.photos/seed/itda_past_92/900/700',
      caption: '산책했어요',
      arrivedAt: '어제 12:10',
      dateLabel: '4월 9일',
      isNew: false,
    ),
    ParentPendingPhoto(
      id: 'past_3',
      imageUrl: 'https://picsum.photos/seed/itda_past_81/900/700',
      caption: '저녁 차렸어요',
      arrivedAt: '4월 8일',
      dateLabel: '4월 8일',
      isNew: false,
    ),
    ParentPendingPhoto(
      id: 'past_4',
      imageUrl: 'https://picsum.photos/seed/itda_past_71/900/700',
      caption: '병원 다녀왔어요',
      arrivedAt: '4월 7일',
      dateLabel: '4월 7일',
      isNew: false,
    ),
    ParentPendingPhoto(
      id: 'past_5',
      imageUrl: 'https://picsum.photos/seed/itda_past_72/900/700',
      caption: 'TV 봤어요',
      arrivedAt: '4월 7일 저녁',
      dateLabel: '4월 7일',
      isNew: false,
    ),
  ];

  static const List<String> quickReplies = [
    '고마워요',
    '잘 봤어요',
    '다음에 또 보내줘요',
    '건강히 지내세요',
    '사랑해요',
  ];

  static const String parentQuestQuestion = '이 사진, 기분 좋은 하루였나요?';
  static const List<String> parentQuestChoices = ['네, 좋았어요', '그냥 그랬어요', '조금 피곤했어요'];

  /// 부모 사진 반응 — 빠른 반응 4종 (자녀 소통 탭·부모 플로우 공통)
  static const List<ParentPhotoQuickReactionPreset> parentPhotoQuickReactions = [
    ParentPhotoQuickReactionPreset(emoji: '😊', label: '너무 좋아요', positive: true),
    ParentPhotoQuickReactionPreset(emoji: '🥰', label: '고마워요', positive: true),
    ParentPhotoQuickReactionPreset(emoji: '💛', label: '보고싶어요', positive: false),
    ParentPhotoQuickReactionPreset(emoji: '👏', label: '잘했어요', positive: false),
  ];

  static ParentPhotoQuickReactionPreset? reactionPresetForLabel(String label) {
    for (final p in parentPhotoQuickReactions) {
      if (p.label == label) return p;
    }
    return null;
  }

  /// 소통 타임라인: 자녀 사진·캡션과 부모의 빠른 반응·음성만 (자유 텍스트 채팅 없음).
  static final List<ChildCommEntry> childCommTimeline = [
    ChildCommDateDivider('2026년 4월 10일'),
    ChildCommSentPhoto(
      imageUrls: const ['https://picsum.photos/seed/itda_comm_1/480/480'],
      caption: '벚꽃이 폈어요 🌸',
      time: '오후 2:11',
    ),
    ChildCommParentQuickReaction(
      label: '너무 좋아요',
      time: '오후 2:12',
    ),
    ChildCommSentPhoto(
      imageUrls: const [
        'https://picsum.photos/seed/itda_comm_2a/400/400',
        'https://picsum.photos/seed/itda_comm_2b/400/400',
        'https://picsum.photos/seed/itda_comm_2c/400/400',
      ],
      caption: '점심이랑 산책이에요',
      time: '오후 2:13',
    ),
    ChildCommParentQuickReaction(
      label: '고마워요',
      time: '오후 2:13',
    ),
    ChildCommParentVoiceNote(
      time: '오후 2:14',
      durationLabel: '0:18',
    ),
    ChildCommSentPhoto(
      imageUrls: const [
        'https://picsum.photos/seed/itda_comm_5a/300/300',
        'https://picsum.photos/seed/itda_comm_5b/300/300',
        'https://picsum.photos/seed/itda_comm_5c/300/300',
        'https://picsum.photos/seed/itda_comm_5d/300/300',
        'https://picsum.photos/seed/itda_comm_5e/300/300',
      ],
      caption: '주말 한번에 보내요',
      time: '오후 3:02',
    ),
    ChildCommDateDivider('2026년 4월 9일'),
    ChildCommSentPhoto(
      imageUrls: const ['https://picsum.photos/seed/itda_comm_3/480/480'],
      caption: '산책 나왔어요',
      time: '오후 5:05',
    ),
    const ChildCommParentPending(),
  ];
}

/// 소통 탭 타임라인 한 줄 (날짜 구분선 / 자녀 사진 / 부모 반응)
sealed class ChildCommEntry {
  const ChildCommEntry();
}

final class ChildCommDateDivider extends ChildCommEntry {
  const ChildCommDateDivider(this.label);
  final String label;
}

final class ChildCommSentPhoto extends ChildCommEntry {
  ChildCommSentPhoto({
    required this.imageUrls,
    this.caption = '',
    required this.time,
  }) : assert(imageUrls.isNotEmpty);

  /// 한 번에 보낸 사진 URL들 (1장이면 길이 1)
  final List<String> imageUrls;
  final String caption;
  final String time;
}

final class ChildCommParentQuickReaction extends ChildCommEntry {
  const ChildCommParentQuickReaction({
    required this.label,
    required this.time,
  });
  /// `MockItdaData.parentPhotoQuickReactions`의 `label`과 일치
  final String label;
  final String time;
}

final class ChildCommParentVoiceNote extends ChildCommEntry {
  const ChildCommParentVoiceNote({
    required this.time,
    this.durationLabel = '0:24',
  });
  final String time;
  final String durationLabel;
}

/// 부모의 빠른 반응·음성이 아직 도착하지 않은 타임라인 슬롯.
final class ChildCommParentPending extends ChildCommEntry {
  const ChildCommParentPending({this.time = '—'});
  final String time;
}

class ParentPendingPhoto {
  ParentPendingPhoto({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.arrivedAt,
    this.dateLabel = '4월 10일',
    this.isNew = true,
  });

  final String id;
  final String imageUrl;
  final String caption;
  final String arrivedAt;
  /// 캐러셀 헤더에 쓰는 날짜 라벨. 같은 날짜끼리 페이지 인디케이터를 묶을 때 사용합니다.
  final String dateLabel;
  final bool isNew;
  bool viewed = false;
}

enum SummaryVariant { orange, green, coral, purple }

class DashboardSummaryTile {
  const DashboardSummaryTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.sub,
    required this.variant,
  });

  final String label;
  final String value;
  final String unit;
  final String sub;
  final SummaryVariant variant;
}

class DashboardRiskAlert {
  const DashboardRiskAlert({
    required this.danger,
    required this.title,
    required this.desc,
    required this.time,
  });

  final bool danger;
  final String title;
  final String desc;
  final String time;
}

class DashboardTodayQuest {
  const DashboardTodayQuest({required this.q, required this.positive});

  final String q;
  final bool positive;
}
