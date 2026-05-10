import 'package:flutter/material.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/parent/home/presentation/health_voice_record_sheet.dart';
import 'package:itda/features/parent/home/presentation/parent_photo_view_widgets.dart';

/// 부모 사진 확인 플로우. 캐러셀·빠른 반응·음성 녹음; 마지막 장에서만 확인을 활성화합니다.
class ParentPhotoQuestFlow extends StatefulWidget {
  ParentPhotoQuestFlow({
    super.key,
    required this.photos,
    this.initialIndex = 0,
  }) : assert(photos.isNotEmpty);

  final List<ParentPendingPhoto> photos;
  final int initialIndex;

  @override
  State<ParentPhotoQuestFlow> createState() => _ParentPhotoQuestFlowState();
}

class _ParentPhotoQuestFlowState extends State<ParentPhotoQuestFlow>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  AnimationController? _panelCtrl;
  Animation<Offset>? _photoSlide;
  Animation<double>? _photoFade;
  Animation<Offset>? _reactionSlide;
  Animation<double>? _reactionFade;
  late int _pageIndex;
  late Map<String, List<int>> _indicesByDate;

  static const _pTextSub = Color(0xFF6B4F2A);
  static const _pTextMuted = Color(0xFFA68856);

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialIndex.clamp(0, widget.photos.length - 1);
    _pageController = PageController(initialPage: _pageIndex);
    _rebuildDateIndex();
    _initPanelAnimations();
  }

  /// `initState`에서만 호출. `reassemble`에서 컨트롤러를 dispose·재생성하면
  /// 핫 리로드 중 `SlideTransition`과 충돌해 `Performing hot reload` 실패가 난다.
  void _initPanelAnimations() {
    _panelCtrl?.dispose();
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _panelCtrl = ctrl;
    final curved = CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic);
    _photoSlide = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.22, 0)).animate(curved);
    _photoFade = Tween<double>(begin: 1, end: 0).animate(curved);
    _reactionSlide = Tween<Offset>(begin: const Offset(0.22, 0), end: Offset.zero).animate(curved);
    _reactionFade = Tween<double>(begin: 0, end: 1).animate(curved);
  }

  void _rebuildDateIndex() {
    final map = <String, List<int>>{};
    for (var i = 0; i < widget.photos.length; i++) {
      final d = widget.photos[i].dateLabel;
      map.putIfAbsent(d, () => []).add(i);
    }
    _indicesByDate = map;
  }

  @override
  void dispose() {
    _panelCtrl?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _openReactionPanel() {
    _panelCtrl?.forward();
  }

  void _closeReactionPanel() {
    _panelCtrl?.reverse();
  }

  void _goPage(int i) {
    final last = widget.photos.length - 1;
    final next = i.clamp(0, last);
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  List<int> get _sameDayIndices {
    final label = widget.photos[_pageIndex].dateLabel;
    return _indicesByDate[label] ?? [_pageIndex];
  }

  int get _photoIdxInDay => _sameDayIndices.indexOf(_pageIndex);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ItdaColors.orangePale,
      body: SafeArea(
        child: Column(
          children: [
            ParentPhotoViewHeader(
              dateText: widget.photos[_pageIndex].dateLabel,
              dotCount: _sameDayIndices.length,
              activeDotIndex: _photoIdxInDay.clamp(0, _sameDayIndices.length - 1),
              onBack: () {
                final c = _panelCtrl;
                if (c != null && c.value > 0.01) {
                  _closeReactionPanel();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final c = _panelCtrl;
                  final slideP = _photoSlide;
                  final fadeP = _photoFade;
                  final slideR = _reactionSlide;
                  final fadeR = _reactionFade;
                  if (c == null ||
                      slideP == null ||
                      fadeP == null ||
                      slideR == null ||
                      fadeR == null) {
                    return const SizedBox.expand();
                  }
                  return ClipRect(
                    child: AnimatedBuilder(
                      animation: c,
                      builder: (context, _) {
                        final v = c.value;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            SlideTransition(
                              position: slideP,
                              child: FadeTransition(
                                opacity: fadeP,
                                child: IgnorePointer(
                                  ignoring: v > 0.35,
                                  child: _PhotoCarouselPane(
                                    photos: widget.photos,
                                    pageController: _pageController,
                                    pageIndex: _pageIndex,
                                    onPageChanged: (i) => setState(() => _pageIndex = i),
                                    onConfirm: _openReactionPanel,
                                    onPrev: () => _goPage(_pageIndex - 1),
                                    onNext: () => _goPage(_pageIndex + 1),
                                  ),
                                ),
                              ),
                            ),
                            SlideTransition(
                              position: slideR,
                              child: FadeTransition(
                                opacity: fadeR,
                                child: IgnorePointer(
                                  ignoring: v < 0.65,
                                  child: _ReactionPane(
                                    photos: widget.photos,
                                    onQuickReaction: (summary) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '반응 전송: $summary\n${MockItdaData.childDisplayName}에게 전달됐어요!',
                                          ),
                                        ),
                                      );
                                      Navigator.of(context).pop(
                                        widget.photos.map((p) => p.id).toSet(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoCarouselPane extends StatelessWidget {
  const _PhotoCarouselPane({
    required this.photos,
    required this.pageController,
    required this.pageIndex,
    required this.onPageChanged,
    required this.onConfirm,
    required this.onPrev,
    required this.onNext,
  });

  final List<ParentPendingPhoto> photos;
  final PageController pageController;
  final int pageIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onConfirm;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final atFirst = pageIndex <= 0;
    final atLast = pageIndex >= photos.length - 1;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemCount: photos.length,
              itemBuilder: (context, i) {
                return ParentPhotoHtmlCard(photo: photos[i]);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ParentPhotoNavButton(
                      label: '이전',
                      icon: Icons.chevron_left_rounded,
                      iconAfter: false,
                      onPressed: atFirst ? null : onPrev,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ParentPhotoNavButton(
                      label: '다음',
                      icon: Icons.chevron_right_rounded,
                      iconAfter: true,
                      onPressed: atLast ? null : onNext,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ConfirmQuestButton(onPressed: atLast ? onConfirm : null),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfirmQuestButton extends StatelessWidget {
  const _ConfirmQuestButton({required this.onPressed});

  /// 마지막 장까지 스와이프하기 전에는 `null` (HTML `.confirm-btn` 비활성)
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !enabled,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ItdaColors.orange, ItdaColors.orangeMid],
            ),
            boxShadow: [
              BoxShadow(
                color: ItdaColors.orange.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, size: 22, color: Colors.white.withValues(alpha: 0.95)),
                    const SizedBox(width: 10),
                    Text(
                      '다 봤어요 · 반응 남기기',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 하단 반응 패널: 썸네일, 빠른 반응 그리드, 목소리 답하기.
class _ReactionPane extends StatelessWidget {
  const _ReactionPane({
    required this.photos,
    required this.onQuickReaction,
  });

  final List<ParentPendingPhoto> photos;
  final ValueChanged<String> onQuickReaction;

  @override
  Widget build(BuildContext context) {
    final name = MockItdaData.childDisplayName;
    final presets = MockItdaData.parentPhotoQuickReactions;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: kParentPhotoPrimaryText,
                height: 1.3,
              ),
              children: [
                const TextSpan(text: '오늘 '),
                TextSpan(
                  text: name,
                  style: const TextStyle(color: ItdaColors.orangeDark),
                ),
                const TextSpan(text: '가 보낸\n사진들 어떠셨어요?'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$name에게 마음을 전해보세요',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _ParentPhotoQuestFlowState._pTextSub,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < photos.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _PreviewThumb(url: photos[i].imageUrl),
              ],
            ],
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              '💬 빠른 반응',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: kParentPhotoPrimaryText,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ReactionGridButton(
                      emoji: presets[0].emoji,
                      label: presets[0].label,
                      positive: presets[0].positive,
                      onTap: () => onQuickReaction(presets[0].label),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ReactionGridButton(
                      emoji: presets[1].emoji,
                      label: presets[1].label,
                      positive: presets[1].positive,
                      onTap: () => onQuickReaction(presets[1].label),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ReactionGridButton(
                      emoji: presets[2].emoji,
                      label: presets[2].label,
                      positive: presets[2].positive,
                      onTap: () => onQuickReaction(presets[2].label),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ReactionGridButton(
                      emoji: presets[3].emoji,
                      label: presets[3].label,
                      positive: presets[3].positive,
                      onTap: () => onQuickReaction(presets[3].label),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ItdaColors.orange, ItdaColors.orangeMid],
              ),
              boxShadow: [
                BoxShadow(
                  color: ItdaColors.orange.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => HealthVoiceRecordSheet.show(
                  context,
                  questionId: 'photo_voice',
                  questionType: 'health',
                ),
                borderRadius: BorderRadius.circular(18),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        '목소리로 전하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '편하게 말씀하시면 $name에게 전달돼요',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _ParentPhotoQuestFlowState._pTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewThumb extends StatelessWidget {
  const _PreviewThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [kParentPhotoShadowNavSoft],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: ItdaColors.orangeLight,
          alignment: Alignment.center,
          child: const Icon(Icons.image_outlined, size: 28, color: ItdaColors.textMuted),
        ),
      ),
    );
  }
}

class _ReactionGridButton extends StatelessWidget {
  const _ReactionGridButton({
    required this.emoji,
    required this.label,
    required this.positive,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool positive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = positive ? ItdaColors.success : ItdaColors.orange;
    final fg = positive ? ItdaColors.success : ItdaColors.orangeDark;
    final splash = positive ? ItdaColors.successLight : ItdaColors.orangeLight;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: splash.withValues(alpha: 0.5),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 3),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28, height: 1)),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: fg,
                      height: 1.25,
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
