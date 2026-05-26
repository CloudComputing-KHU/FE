import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/parent/home/presentation/health_voice_record_sheet.dart';
import 'package:itda/features/parent/home/providers/parent_home_provider.dart';
import 'package:itda/shared/widgets/round_white_icon_button.dart';

const _pText = Color(0xFF2D1F0A);
const _pTextSub = Color(0xFF6B4F2A);
const _greenBorder = Color(0xFF3A7D3A);
const _greenText = Color(0xFF2D5A2D);

/// 부모 홈의 건강 질문 카드와 동일한 내용을 전체 화면으로 표시
///
/// [stepIndex] 0=건강, 1=식사, 2=기분, 3 이상=오늘 모두 완료(조회만)
class ParentHealthQuestScreen extends ConsumerWidget {
  /// [onAnswered] 생략 시 빠른 답변 후 추가 동작 없음 (no-op).
  factory ParentHealthQuestScreen({
    Key? key,
    int stepIndex = 0,
    ValueChanged<String>? onAnswered,
  }) {
    return ParentHealthQuestScreen._(
      key: key,
      stepIndex: stepIndex,
      onAnswered: onAnswered ?? _noopOnAnswered,
    );
  }

  const ParentHealthQuestScreen._({
    super.key,
    required this.stepIndex,
    required this.onAnswered,
  });

  static void _noopOnAnswered(String _) {}

  /// 현재 퀘스트 단계 (홈 카드 `healthQuestStepProvider`와 동기)
  final int stepIndex;

  /// 빠른 답변 선택 후 호출
  final ValueChanged<String> onAnswered;

  void _pickQuick(
    BuildContext context,
    WidgetRef ref,
    String summary,
    String questionId,
  ) async {
    final type = questTypeForStep(stepIndex);
    final ok = await submitParentAnswer(
      ref: ref,
      type: type,
      questionId: questionId,
      answer: summary,
    );
    if (!context.mounted) return;
    Navigator.of(context).pop();
    onAnswered(summary);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변 저장에 실패했어요. 다시 시도해 주세요.')),
      );
    }
  }

  Future<void> _openVoice(
    BuildContext context,
    String questionId,
    String type,
  ) {
    return HealthVoiceRecordSheet.show(
      context,
      questionId: questionId,
      questionType: type,
    );
  }

  static String _appBarTitleForStep(int step) {
    switch (step.clamp(0, 2)) {
      case 1:
        return '오늘의 식사 질문';
      case 2:
        return '오늘의 기분 질문';
      case 0:
      default:
        return '오늘의 건강 질문';
    }
  }

  /// API 실패 시 표시할 폴백 질문 텍스트
  static String _fallbackQuestionText(int step) {
    switch (step) {
      case 1:
        return '오늘 식사는\n잘 하셨어요?';
      case 2:
        return '오늘 기분은\n어떠세요?';
      default:
        return '오늘 약은\n드셨어요?';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    if (stepIndex >= 3) {
      return Scaffold(
        backgroundColor: ItdaColors.orangePale,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RoundWhiteIconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icons.chevron_left_rounded,
                        label: '뒤로가기',
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 120),
                        child: Text(
                          '오늘의 질문',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: ItdaColors.orangeDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🌼',
                          style: TextStyle(fontSize: 84, height: 1),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '모두 완료!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            color: _greenBorder,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '오늘의 질문에 모두\n답해주셨어요. 고마워요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                            color: _pTextSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12 + bottomInset),
            ],
          ),
        ),
      );
    }

    final step = stepIndex.clamp(0, 2);
    final type = questTypeForStep(step);
    final appBarTitle = _appBarTitleForStep(step);
    final quicks = _quickSpecsForStep(step);

    // API에서 질문 텍스트를 가져옵니다.
    final questionAsync = ref.watch(questionProvider(type));

    return Scaffold(
      backgroundColor: ItdaColors.orangePale,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RoundWhiteIconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icons.chevron_left_rounded,
                      label: '뒤로가기',
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 120),
                      child: Text(
                        appBarTitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ItdaColors.orangeDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: questionAsync.when(
                          loading: () => const CircularProgressIndicator(
                            color: ItdaColors.orange,
                          ),
                          error: (_, _) => Text(
                            _fallbackQuestionText(step),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                              color: _pText,
                              letterSpacing: -0.8,
                            ),
                          ),
                          data: (q) => Text(
                            q.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                              color: _pText,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '빠른 답변',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _pText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _QuickReplyCell(
                          borderColor: quicks[0].borderColor,
                          onTap: () {
                            final qId =
                                questionAsync.valueOrNull?.questionId ?? type;
                            _pickQuick(context, ref, quicks[0].summary, qId);
                          },
                          child: Text(
                            quicks[0].label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              height: 1.28,
                              color: quicks[0].textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickReplyCell(
                          borderColor: quicks[1].borderColor,
                          onTap: () {
                            final qId =
                                questionAsync.valueOrNull?.questionId ?? type;
                            _pickQuick(context, ref, quicks[1].summary, qId);
                          },
                          child: Text(
                            quicks[1].label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              height: 1.28,
                              color: quicks[1].textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _QuickReplyCell(
                          borderColor: quicks[2].borderColor,
                          onTap: () {
                            final qId =
                                questionAsync.valueOrNull?.questionId ?? type;
                            _pickQuick(context, ref, quicks[2].summary, qId);
                          },
                          child: Text(
                            quicks[2].label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              height: 1.28,
                              color: quicks[2].textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickReplyCell(
                          borderColor: quicks[3].borderColor,
                          onTap: () {
                            final qId =
                                questionAsync.valueOrNull?.questionId ?? type;
                            _pickQuick(context, ref, quicks[3].summary, qId);
                          },
                          child: Text(
                            quicks[3].label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              height: 1.28,
                              color: quicks[3].textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: ItdaColors.orange,
                      boxShadow: [
                        BoxShadow(
                          color: ItdaColors.orange.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final qId =
                              questionAsync.valueOrNull?.questionId ?? type;
                          _openVoice(context, qId, type);
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mic_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                '목소리로 답하기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '버튼을 누르고 편하게 말씀해주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _pTextSub,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 파일 레벨 헬퍼 ─────────────────────────────────────────────────────────

List<_QuestQuickSpec> _quickSpecsForStep(int step) {
  switch (step.clamp(0, 2)) {
    case 1:
      return const [
        _QuestQuickSpec(
          summary: '네, 잘 먹었어요',
          label: '네, 잘\n먹었어요',
          borderColor: _greenBorder,
          textColor: _greenText,
        ),
        _QuestQuickSpec(
          summary: '아직 안 먹었어요',
          label: '아직 안\n먹었어요',
          borderColor: ItdaColors.danger,
          textColor: ItdaColors.danger,
        ),
        _QuestQuickSpec(
          summary: '간단히 먹었어요',
          label: '간단히\n먹었어요',
          borderColor: ItdaColors.border,
          textColor: _pText,
        ),
        _QuestQuickSpec(
          summary: '기억이 안 나요',
          label: '기억이 안\n나요',
          borderColor: ItdaColors.border,
          textColor: _pText,
        ),
      ];
    case 2:
      return const [
        _QuestQuickSpec(
          summary: '좋아요',
          label: '좋아요',
          borderColor: _greenBorder,
          textColor: _greenText,
        ),
        _QuestQuickSpec(
          summary: '괜찮아요',
          label: '괜찮아요',
          borderColor: ItdaColors.border,
          textColor: _pText,
        ),
        _QuestQuickSpec(
          summary: '좀 피곤해요',
          label: '좀\n피곤해요',
          borderColor: ItdaColors.border,
          textColor: _pText,
        ),
        _QuestQuickSpec(
          summary: '안 좋아요',
          label: '안 좋아요',
          borderColor: ItdaColors.danger,
          textColor: ItdaColors.danger,
        ),
      ];
    case 0:
    default:
      return const [
        _QuestQuickSpec(
          summary: '네, 먹었어요',
          label: '네, 먹었어요',
          borderColor: _greenBorder,
          textColor: _greenText,
        ),
        _QuestQuickSpec(
          summary: '아직 안 먹었어요',
          label: '아직 안\n먹었어요',
          borderColor: ItdaColors.danger,
          textColor: ItdaColors.danger,
        ),
        _QuestQuickSpec(
          summary: '약이 없어요',
          label: '약이 없어요',
          borderColor: ItdaColors.border,
          textColor: _pText,
        ),
        _QuestQuickSpec(
          summary: '기억이 안 나요',
          label: '기억이 안\n나요',
          borderColor: ItdaColors.border,
          textColor: _pText,
        ),
      ];
  }
}

class _QuestQuickSpec {
  const _QuestQuickSpec({
    required this.summary,
    required this.label,
    required this.borderColor,
    required this.textColor,
  });

  final String summary;
  final String label;
  final Color borderColor;
  final Color textColor;
}

class _QuickReplyCell extends StatefulWidget {
  const _QuickReplyCell({
    required this.borderColor,
    required this.onTap,
    required this.child,
  });

  final Color borderColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_QuickReplyCell> createState() => _QuickReplyCellState();
}

class _QuickReplyCellState extends State<_QuickReplyCell> {
  bool _pressed = false;

  static const _shadowSoft = BoxShadow(
    color: Color(0x1AEF9F27),
    blurRadius: 12,
    offset: Offset(0, 3),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        widget.onTap();
        setState(() => _pressed = false);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(minHeight: 108),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.borderColor, width: 3),
            boxShadow: const [_shadowSoft],
          ),
          alignment: Alignment.center,
          child: DefaultTextStyle.merge(
            textAlign: TextAlign.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
