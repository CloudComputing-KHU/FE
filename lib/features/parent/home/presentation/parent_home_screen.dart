/// 부모 모드 홈. 인사·일일 퀘스트 진행·새 사진/건강 카드로 상세 화면에 진입합니다.
library;

import 'package:flutter/material.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/parent/home/presentation/parent_health_quest_screen.dart';
import 'package:itda/features/parent/home/presentation/parent_photo_quest_flow.dart';
import 'package:itda/features/parent/menu/presentation/parent_settings_screen.dart';
import 'package:itda/features/parent/menu/presentation/past_photos_screen.dart';

/// 부모 홈 본문 텍스트 색.
const _pText = Color(0xFF2D1F0A);
const _pTextSub = Color(0xFF6B4F2A);
/// 퀘스트 완료 상태 카드 강조색.
const _questSuccessGreen = Color(0xFF3A7D3A);

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> with SingleTickerProviderStateMixin {
  late List<ParentPendingPhoto> _photos;
  AnimationController? _pulseCtrl;
  /// 오늘 건강·퀘스트 답변 완료 수 (0~3), 카드 상태 UI용
  int _healthQuestCompleted = 0;

  void _initPulse() {
    _pulseCtrl?.dispose();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void initState() {
    super.initState();
    _photos = List<ParentPendingPhoto>.from(MockItdaData.pendingPhotos);
    _initPulse();
  }

  @override
  void dispose() {
    _pulseCtrl?.dispose();
    super.dispose();
  }

  void _openSettings() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ParentSettingsScreen()),
    );
  }

  Future<void> _openPhoto(ParentPendingPhoto photo) async {
    if (_photos.isEmpty) return;
    final queue = List<ParentPendingPhoto>.from(_photos);
    final idx = queue.indexWhere((p) => p.id == photo.id).clamp(0, queue.length - 1);
    final removedIds = await Navigator.of(context).push<Set<String>?>(
      MaterialPageRoute<Set<String>?>(
        builder: (_) => ParentPhotoQuestFlow(photos: queue, initialIndex: idx),
      ),
    );
    if (!mounted) return;
    if (removedIds != null && removedIds.isNotEmpty) {
      setState(() => _photos.removeWhere((p) => removedIds.contains(p.id)));
    }
  }

  void _openPastPhotos() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const PastPhotosScreen()),
    );
  }

  void _openHealthQuest() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ParentHealthQuestScreen(
          stepIndex: _healthQuestCompleted,
          onAnswered: (summary) {
            if (!mounted) return;
            setState(() {
              if (_healthQuestCompleted < 3) {
                _healthQuestCompleted++;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('「$summary」로 응답했어요.')),
            );
          },
        ),
      ),
    );
  }

  ParentPendingPhoto? get _firstPhoto => _photos.isEmpty ? null : _photos.first;

  @override
  Widget build(BuildContext context) {
    final photoCount = _photos.length;
    final hasPhoto = _firstPhoto != null;

    return Scaffold(
      backgroundColor: ItdaColors.orangePale,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ParentV4Header(
              welcomeName: MockItdaData.parentWelcomeName,
              onSettings: _openSettings,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  children: [
                    Expanded(
                      child: _BigPhotoCard(
                        photoCount: photoCount,
                        childName: MockItdaData.childDisplayName,
                        hasNewPhotos: hasPhoto,
                        pulseAnimation: _pulseCtrl,
                        onTapNewPhotos: hasPhoto ? () => _openPhoto(_firstPhoto!) : null,
                        onTapPastPhotos: _openPastPhotos,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _BigHealthCard(
                        completedSteps: _healthQuestCompleted,
                        onTap: _openHealthQuest,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 상단 인사 한 줄과 설정 버튼.
class _ParentV4Header extends StatelessWidget {
  const _ParentV4Header({
    required this.welcomeName,
    required this.onSettings,
  });

  final String welcomeName;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _pText,
                  height: 1.15,
                ),
                children: [
                  TextSpan(
                    text: '$welcomeName님',
                    style: const TextStyle(color: ItdaColors.orangeDark),
                  ),
                  const TextSpan(text: ' 안녕하세요'),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: ItdaColors.orange.withValues(alpha: 0.1),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSettings,
                borderRadius: BorderRadius.circular(14),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.settings_rounded, size: 24, color: _pTextSub),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigPhotoCard extends StatelessWidget {
  const _BigPhotoCard({
    required this.photoCount,
    required this.childName,
    required this.hasNewPhotos,
    this.pulseAnimation,
    this.onTapNewPhotos,
    required this.onTapPastPhotos,
  });

  final int photoCount;
  final String childName;
  final bool hasNewPhotos;
  final Animation<double>? pulseAnimation;
  final VoidCallback? onTapNewPhotos;
  final VoidCallback onTapPastPhotos;

  @override
  Widget build(BuildContext context) {
    final onTap = hasNewPhotos ? onTapNewPhotos : onTapPastPhotos;

    final borderColor = hasNewPhotos ? ItdaColors.orange : ItdaColors.border;
    final shadowColor =
        hasNewPhotos ? ItdaColors.orange.withValues(alpha: 0.18) : const Color(0x14000000);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (hasNewPhotos)
                Positioned(
                  top: 16,
                  left: 16,
                  child: _PhotoBadge(
                    count: photoCount,
                    pulseAnimation: pulseAnimation,
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: hasNewPhotos ? _buildNewPhotoColumn() : _buildPastPhotoColumn(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewPhotoColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🌸', style: TextStyle(fontSize: 110, height: 1)),
        const SizedBox(height: 18),
        const Text(
          '사진 보기',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: _pText,
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _pTextSub,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: childName,
                style: const TextStyle(
                  color: ItdaColors.orangeDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const TextSpan(text: '가 보낸\n새 사진이 도착했어요!'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPastPhotoColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🍱', style: TextStyle(fontSize: 110, height: 1)),
        const SizedBox(height: 18),
        const Text(
          '이전 사진',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: _pText,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '어제 받은 사진을\n볼까요?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _pTextSub,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _PhotoBadge extends StatelessWidget {
  const _PhotoBadge({
    required this.count,
    this.pulseAnimation,
  });

  final int count;
  final Animation<double>? pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ItdaColors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pulseAnimation != null)
              AnimatedBuilder(
                animation: pulseAnimation!,
                builder: (_, _) {
                  return Opacity(
                    opacity: 0.4 + pulseAnimation!.value * 0.6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              '새 사진 $count장',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 건강 일일 퀘스트 진행 카드(0/3 ~ 3/3).
class _BigHealthCard extends StatelessWidget {
  const _BigHealthCard({
    required this.completedSteps,
    required this.onTap,
  });

  /// 완료한 답변 수 (0~3)
  final int completedSteps;
  final VoidCallback onTap;

  /// `_BigPhotoCard` 이모지와 동일
  static const _emojiSize = 110.0;

  @override
  Widget build(BuildContext context) {
    final done = completedSteps >= 3;
    final c = completedSteps.clamp(0, 3);

    final String emoji;
    final String title;
    final String desc;
    if (done) {
      emoji = '🌼';
      title = '모두 완료!';
      desc = '오늘의 질문에 모두\n답해주셨어요. 고마워요!';
    } else if (c == 2) {
      emoji = '😊';
      title = '기분 질문';
      desc = '오늘의 기분 질문에\n답해주세요';
    } else if (c == 1) {
      emoji = '🍱';
      title = '식사 질문';
      desc = '오늘의 식사 질문에\n답해주세요';
    } else {
      emoji = '💊';
      title = '건강 질문';
      desc = '오늘의 건강 질문에\n답해주세요';
    }

    final titleColor = done ? _questSuccessGreen : _pText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: done ? ItdaColors.successLight : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: done ? _questSuccessGreen : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: ItdaColors.orange.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: _emojiSize, height: 1)),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _pTextSub,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: _HealthQuestProgressRow(
                      completedSteps: c,
                      allDone: done,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthQuestProgressRow extends StatelessWidget {
  const _HealthQuestProgressRow({
    required this.completedSteps,
    required this.allDone,
  });

  final int completedSteps;
  final bool allDone;

  Color _colorForIndex(int i) {
    if (allDone) return _questSuccessGreen;
    if (i < completedSteps) return _questSuccessGreen;
    if (i == completedSteps) return ItdaColors.orange;
    return ItdaColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProgressSegment(color: _colorForIndex(0)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _ProgressSegment(color: _colorForIndex(1)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _ProgressSegment(color: _colorForIndex(2)),
        ),
      ],
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  const _ProgressSegment({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
