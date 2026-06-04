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

  Future<void> _openPhotoQuest(
    ParentReceivedPhoto photo,
    List<ParentReceivedPhoto> photos,
    String childName,
  ) async {
    if (photos.isEmpty) return;
    final idx = photos
        .indexWhere((p) => p.photoId == photo.photoId)
        .clamp(0, photos.length - 1);
    final pendingPhotos = photos.map(_toPendingPhoto).toList();
    final result = await Navigator.of(context).push<ParentPhotoReactionResult>(
      MaterialPageRoute<ParentPhotoReactionResult>(
        builder: (_) => ParentPhotoQuestFlow(
          photos: pendingPhotos,
          childName: childName,
          initialIndex: idx,
        ),
      ),
    );
    if (!mounted || result == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final reactionService = ref.read(photoReactionServiceProvider);
      for (final photoId in result.photoIds) {
        if (result.isVoice && result.voiceFilePath != null) {
          await reactionService.saveVoiceReaction(
            photoId: photoId,
            filePath: result.voiceFilePath!,
            fileBytes: result.voiceFileBytes,
            fileName: result.voiceFileName,
            contentType: result.voiceContentType,
            durationSeconds: result.durationSeconds,
          );
        } else if (result.isVoice && result.voiceFileBytes != null) {
          await reactionService.saveVoiceReaction(
            photoId: photoId,
            filePath: result.voiceFileName ?? 'voice.m4a',
            fileBytes: result.voiceFileBytes,
            fileName: result.voiceFileName,
            contentType: result.voiceContentType,
            durationSeconds: result.durationSeconds,
          );
        } else {
          await reactionService.saveQuickReaction(
            photoId: photoId,
            label: result.label,
          );
        }
        ref.invalidate(photoReactionsProvider(photoId));
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('답장 전송에 실패했어요: $error')));
      return;
    }
    if (result.photoIds.isNotEmpty) {
      ref.read(receivedPhotosProvider.notifier).removeByIds(result.photoIds);
    }
    ref.invalidate(pastPhotosProvider);
    messenger.showSnackBar(
      SnackBar(content: Text('「${result.label}」로 응답했어요.')),
    );
  }

  void _openPastPhotos() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const PastPhotosScreen()),
    );
  }

  void _showPhotoLockedMessage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('먼저 질문 3개만 답해주세요!')));
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
    final photoLocked = healthQuestCompleted < 3;

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
                                  locked: photoLocked,
                                  hasNewPhotos: false,
                                  hasPastPhotos: hasPastPhotos,
                                  pulseAnimation: null,
                                  onTapNewPhotos: photoLocked
                                      ? _showPhotoLockedMessage
                                      : null,
                                  onTapPastPhotos: photoLocked
                                      ? _showPhotoLockedMessage
                                      : _openPastPhotos,
                                ),
                                error: (_, _) => _BigPhotoCard(
                                  photoCount: 0,
                                  childName: childName,
                                  locked: photoLocked,
                                  hasNewPhotos: false,
                                  hasPastPhotos: hasPastPhotos,
                                  pulseAnimation: null,
                                  onTapNewPhotos: photoLocked
                                      ? _showPhotoLockedMessage
                                      : null,
                                  onTapPastPhotos: photoLocked
                                      ? _showPhotoLockedMessage
                                      : _openPastPhotos,
                                ),
                                data: (photos) {
                                  final pastPhotos =
                                      pastPhotosAsync.valueOrNull ??
                                      const <ParentReceivedPhoto>[];
                                  final allPhotos = _mergeReceivedPhotos(
                                    photos,
                                    pastPhotos,
                                  );
                                  final hasNewPhoto = photos.isNotEmpty;
                                  final hasAnyPhoto = allPhotos.isNotEmpty;
                                  return _BigPhotoCard(
                                    photoCount: allPhotos.length,
                                    childName: childName,
                                    locked: photoLocked,
                                    hasNewPhotos: hasNewPhoto,
                                    hasPastPhotos: hasPastPhotos || hasAnyPhoto,
                                    pulseAnimation: hasNewPhoto && !photoLocked
                                        ? _pulseCtrl
                                        : null,
                                    onTapNewPhotos: hasAnyPhoto
                                        ? photoLocked
                                              ? _showPhotoLockedMessage
                                              : () => _openPhotoQuest(
                                                  photos.first,
                                                  photos,
                                                  childName,
                                                )
                                        : null,
                                    onTapPastPhotos: photoLocked
                                        ? _showPhotoLockedMessage
                                        : _openPastPhotos,
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

ParentPendingPhoto _toPendingPhoto(ParentReceivedPhoto photo) {
  return ParentPendingPhoto(
    id: photo.photoId,
    imageUrl: photo.displayUrl,
    caption: photo.caption ?? '',
    arrivedAt: _formatArrivedAt(photo.createdAt),
    dateLabel: _formatDateLabel(photo.createdAt),
    isNew: photo.status == 'sent',
  );
}

String _formatDateLabel(DateTime date) {
  final local = date.toLocal();
  return '${local.month}월 ${local.day}일';
}

String _formatArrivedAt(DateTime date) {
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

List<ParentReceivedPhoto> _mergeReceivedPhotos(
  List<ParentReceivedPhoto> newPhotos,
  List<ParentReceivedPhoto> pastPhotos,
) {
  final byId = <String, ParentReceivedPhoto>{
    for (final photo in pastPhotos) photo.photoId: photo,
    for (final photo in newPhotos) photo.photoId: photo,
  };
  final merged = byId.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return merged;
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
    required this.locked,
    required this.hasNewPhotos,
    required this.hasPastPhotos,
    this.pulseAnimation,
    this.onTapNewPhotos,
    required this.onTapPastPhotos,
  });

  final int photoCount;
  final String childName;
  final bool locked;
  final bool hasNewPhotos;
  final bool hasPastPhotos;
  final Animation<double>? pulseAnimation;
  final VoidCallback? onTapNewPhotos;
  final VoidCallback onTapPastPhotos;

  @override
  Widget build(BuildContext context) {
    final hasAnyPhotos = hasNewPhotos || hasPastPhotos;
    final effectiveLocked = locked && hasNewPhotos;
    final onTap = effectiveLocked
        ? (onTapNewPhotos ?? onTapPastPhotos)
        : hasAnyPhotos
        ? (hasNewPhotos ? onTapNewPhotos : onTapPastPhotos)
        : null;

    final borderColor = effectiveLocked
        ? ItdaColors.border
        : hasNewPhotos
        ? ItdaColors.orange
        : ItdaColors.border;
    final shadowColor = hasNewPhotos && !effectiveLocked
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
              if (hasNewPhotos && !effectiveLocked)
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
                  child: effectiveLocked
                      ? _buildLockedPhotoColumn()
                      : hasNewPhotos
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
          '지금까지 받은 사진을\n볼 수 있어요!',
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

  Widget _buildLockedPhotoColumn() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_rounded, size: 104, color: ItdaColors.orangeDark),
        SizedBox(height: 18),
        Text(
          '사진이 도착했어요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: _pText,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '먼저 질문 3개만\n답해주세요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
          '오늘은 아직\n사진이 안왔어요.',
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

    final Widget visual;
    final String title;
    final String desc;
    if (done) {
      visual = const Text(
        '🌼',
        style: TextStyle(fontSize: _emojiSize, height: 1),
      );
      title = '모두 완료!';
      desc = '오늘의 질문에 모두\n답해주셨어요. 고마워요!';
    } else if (c == 2) {
      visual = const Text(
        '😊',
        style: TextStyle(fontSize: _emojiSize, height: 1),
      );
      title = '오늘 하루 어땠나요?';
      desc = '자녀가 궁금해하는\n오늘의 질문에 대답해주세요.';
    } else if (c == 1) {
      visual = const Text(
        '🍱',
        style: TextStyle(fontSize: _emojiSize, height: 1),
      );
      title = '오늘 하루 어땠나요?';
      desc = '자녀가 궁금해하는\n오늘의 질문에 대답해주세요.';
    } else {
      visual = const _QuestionPersonVisual(size: _emojiSize);
      title = '오늘 하루 어땠나요?';
      desc = '자녀가 궁금해하는\n오늘의 질문에 대답해주세요.';
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
                  visual,
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

class _QuestionPersonVisual extends StatelessWidget {
  const _QuestionPersonVisual({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: BoxDecoration(
              color: ItdaColors.orangePale,
              shape: BoxShape.circle,
              border: Border.all(
                color: ItdaColors.orange.withValues(alpha: 0.32),
                width: 3,
              ),
            ),
          ),
          Icon(
            Icons.person_rounded,
            size: size * 0.72,
            color: ItdaColors.orangeDark,
          ),
          Positioned(
            top: size * 0.02,
            right: size * 0.02,
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: ItdaColors.orange, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: ItdaColors.orange.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.question_mark_rounded,
                size: size * 0.22,
                color: ItdaColors.orangeDark,
              ),
            ),
          ),
        ],
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
