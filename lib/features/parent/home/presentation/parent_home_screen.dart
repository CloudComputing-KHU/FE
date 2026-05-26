/// 부모 모드 홈. 인사·일일 퀘스트 진행·새 사진/건강 카드로 상세 화면에 진입합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/auth/auth_provider.dart';
import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/parent/data/parent_models.dart';
import 'package:itda/features/parent/home/presentation/parent_health_quest_screen.dart';
import 'package:itda/features/parent/home/presentation/parent_photo_quest_flow.dart';
import 'package:itda/features/parent/home/providers/parent_home_provider.dart';
import 'package:itda/features/parent/menu/presentation/parent_settings_screen.dart';
import 'package:itda/features/parent/menu/presentation/past_photos_screen.dart';
import 'package:itda/features/shared/providers/family_provider.dart';
import 'package:itda/features/shared/providers/photo_reaction_provider.dart';

/// 부모 홈 본문 텍스트 색.
const _pText = Color(0xFF2D1F0A);
const _pTextSub = Color(0xFF6B4F2A);

/// 퀘스트 완료 상태 카드 강조색.
const _questSuccessGreen = Color(0xFF3A7D3A);

class ParentHomeScreen extends ConsumerStatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  ConsumerState<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends ConsumerState<ParentHomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseCtrl;

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

  Future<void> _openPhoto(
    ParentReceivedPhoto photo,
    List<ParentReceivedPhoto> photos,
    String childName,
  ) async {
    if (photos.isEmpty) return;
    final queue = photos
        .map(
          (p) => ParentPendingPhoto(
            id: p.photoId,
            imageUrl: p.displayUrl,
            caption: p.caption ?? '',
            arrivedAt: _relativeTime(p.createdAt),
            dateLabel: _dateLabel(p.createdAt),
            isNew: true,
          ),
        )
        .toList();
    final idx = queue
        .indexWhere((p) => p.id == photo.photoId)
        .clamp(0, queue.length - 1);
    final openedPhotoIds = queue.map((p) => p.id).toSet();
    final result = await Navigator.of(context).push<ParentPhotoReactionResult?>(
      MaterialPageRoute<ParentPhotoReactionResult?>(
        builder: (_) => ParentPhotoQuestFlow(
          photos: queue,
          initialIndex: idx,
          childName: childName,
        ),
      ),
    );
    if (!mounted) return;
    ref.read(receivedPhotosProvider.notifier).removeByIds(openedPhotoIds);
    ref.invalidate(pastPhotosProvider);
    if (result != null && result.photoIds.isNotEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        final service = ref.read(photoReactionServiceProvider);
        for (final photoId in result.photoIds) {
          if (result.isVoice && result.voiceFilePath != null) {
            await service.saveVoiceReaction(
              photoId: photoId,
              filePath: result.voiceFilePath!,
              durationSeconds: result.durationSeconds,
            );
          } else {
            await service.saveQuickReaction(
              photoId: photoId,
              label: result.label,
            );
          }
          ref.invalidate(photoReactionsProvider(photoId));
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(result.isVoice ? '음성 반응이 저장됐어요!' : '반응이 저장됐어요!'),
          ),
        );
      } catch (_) {
        messenger.showSnackBar(
          const SnackBar(content: Text('반응 저장에 실패했어요. 다시 시도해 주세요.')),
        );
      }
    }
  }

  void _openPastPhotos() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const PastPhotosScreen()),
    );
  }

  void _openHealthQuest() {
    final status = ref.read(todayQuestionStatusProvider).valueOrNull;
    final step =
        status?.completedStep ?? ref.read(healthQuestStepProvider) ?? 0;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ParentHealthQuestScreen(
          stepIndex: step,
          onAnswered: (summary) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('「$summary」로 응답했어요.')));
          },
        ),
      ),
    );
  }

  Future<void> _refreshHome() async {
    await Future.wait([
      ref.read(receivedPhotosProvider.notifier).refresh(),
      ref.read(pastPhotosProvider.notifier).refresh(),
      ref.refresh(todayQuestionStatusProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(receivedPhotosProvider);
    final pastPhotosAsync = ref.watch(pastPhotosProvider);
    final questionStatusAsync = ref.watch(todayQuestionStatusProvider);
    final localHealthQuestCompleted = ref.watch(healthQuestStepProvider);
    final healthQuestCompleted = questionStatusAsync.maybeWhen(
      data: (status) => status.completedStep,
      orElse: () => localHealthQuestCompleted,
    );
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final family = ref.watch(familyMeProvider).valueOrNull;
    final childName = _nonEmptyName(family?.activeLink?.childName) ?? '자녀';
    final hasPastPhotos = pastPhotosAsync.maybeWhen(
      data: (photos) => photos.isNotEmpty,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: ItdaColors.orangePale,
      body: SafeArea(
        child: RefreshIndicator(
          color: ItdaColors.orange,
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height:
                    MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).top,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ParentV4Header(
                      welcomeName:
                          profile?.displayName ??
                          MockItdaData.parentWelcomeName,
                      onSettings: _openSettings,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: Column(
                          children: [
                            Expanded(
                              child: photosAsync.when(
                                loading: () => _BigPhotoCard(
                                  photoCount: 0,
                                  childName: childName,
                                  hasNewPhotos: false,
                                  hasPastPhotos: hasPastPhotos,
                                  pulseAnimation: null,
                                  onTapNewPhotos: null,
                                  onTapPastPhotos: _openPastPhotos,
                                ),
                                error: (_, _) => _BigPhotoCard(
                                  photoCount: 0,
                                  childName: childName,
                                  hasNewPhotos: false,
                                  hasPastPhotos: hasPastPhotos,
                                  pulseAnimation: null,
                                  onTapNewPhotos: null,
                                  onTapPastPhotos: _openPastPhotos,
                                ),
                                data: (photos) {
                                  final hasPhoto = photos.isNotEmpty;
                                  return _BigPhotoCard(
                                    photoCount: photos.length,
                                    childName: childName,
                                    hasNewPhotos: hasPhoto,
                                    hasPastPhotos: hasPastPhotos,
                                    pulseAnimation: hasPhoto
                                        ? _pulseCtrl
                                        : null,
                                    onTapNewPhotos: hasPhoto
                                        ? () => _openPhoto(
                                            photos.first,
                                            photos,
                                            childName,
                                          )
                                        : null,
                                    onTapPastPhotos: _openPastPhotos,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _BigHealthCard(
                                completedSteps: healthQuestCompleted,
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
            ],
          ),
        ),
      ),
    );
  }
}

String? _nonEmptyName(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

/// 상단 인사 한 줄과 설정 버튼.
class _ParentV4Header extends StatelessWidget {
  const _ParentV4Header({required this.welcomeName, required this.onSettings});

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
                  const TextSpan(text: '\n안녕하세요'),
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
                  child: Icon(
                    Icons.settings_rounded,
                    size: 24,
                    color: _pTextSub,
                  ),
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
    required this.hasPastPhotos,
    this.pulseAnimation,
    this.onTapNewPhotos,
    required this.onTapPastPhotos,
  });

  final int photoCount;
  final String childName;
  final bool hasNewPhotos;
  final bool hasPastPhotos;
  final Animation<double>? pulseAnimation;
  final VoidCallback? onTapNewPhotos;
  final VoidCallback onTapPastPhotos;

  @override
  Widget build(BuildContext context) {
    final onTap = hasNewPhotos || hasPastPhotos
        ? (hasNewPhotos ? onTapNewPhotos : onTapPastPhotos)
        : null;

    final borderColor = hasNewPhotos ? ItdaColors.orange : ItdaColors.border;
    final shadowColor = hasNewPhotos
        ? ItdaColors.orange.withValues(alpha: 0.18)
        : const Color(0x14000000);

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
                  child: hasNewPhotos
                      ? _buildNewPhotoColumn()
                      : hasPastPhotos
                      ? _buildPastPhotoColumn()
                      : _buildFirstVisitPhotoColumn(),
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
        const Text('📷', style: TextStyle(fontSize: 110, height: 1)),
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

  Widget _buildFirstVisitPhotoColumn() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('📷', style: TextStyle(fontSize: 110, height: 1)),
        SizedBox(height: 18),
        Text(
          '첫 사진을 기다려요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: _pText,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '자녀가 사진을 보내면\n여기서 바로 확인할 수 있어요.',
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
  const _PhotoBadge({required this.count, this.pulseAnimation});

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
  const _BigHealthCard({required this.completedSteps, required this.onTap});

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
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: _emojiSize, height: 1),
                  ),
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
        Expanded(child: _ProgressSegment(color: _colorForIndex(0))),
        const SizedBox(width: 6),
        Expanded(child: _ProgressSegment(color: _colorForIndex(1))),
        const SizedBox(width: 6),
        Expanded(child: _ProgressSegment(color: _colorForIndex(2))),
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

// ── 날짜 헬퍼 ──────────────────────────────────────────────────────────────

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  return '${diff.inDays}일 전';
}

String _dateLabel(DateTime dt) {
  return '${dt.month}월 ${dt.day}일';
}
