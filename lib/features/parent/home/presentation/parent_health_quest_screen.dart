import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/parent/home/presentation/health_voice_record_sheet.dart';
import 'package:itda/features/parent/home/providers/parent_home_provider.dart';
import 'package:itda/shared/widgets/round_white_icon_button.dart';

const _pText = Color(0xFF2D1F0A);
const _pTextSub = Color(0xFF6B4F2A);
const _greenBorder = Color(0xFF3A7D3A);

/// 부모 홈의 건강 질문 카드와 동일한 내용을 전체 화면으로 표시
///
/// [stepIndex] 0=건강, 1=식사, 2=기분, 3 이상=오늘 모두 완료(조회만)
class ParentHealthQuestScreen extends ConsumerWidget {
  /// [onAnswered] 생략 시 답변 후 추가 동작 없음 (no-op).
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

  /// 답변 후 호출
  final ValueChanged<String> onAnswered;

  Future<void> _openVoice(
    BuildContext context,
    String questionId,
    String type,
  ) async {
    final ok = await HealthVoiceRecordSheet.show(
      context,
      questionId: questionId,
      questionType: type,
    );
    if (!context.mounted || ok != true) return;
    onAnswered('음성 답변');
    _advanceAfterAnswer(context);
  }

  void _advanceAfterAnswer(BuildContext context) {
    final nextStep = stepIndex + 1;
    if (nextStep >= 3) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => ParentHealthQuestScreen(stepIndex: nextStep),
      ),
    );
  }

  static String _appBarTitleForStep(int step) {
    switch (step.clamp(0, 2)) {
      case 1:
        return '오늘의 식사 질문';
      case 2:
        return '이번 주 계획 질문';
      case 0:
      default:
        return '병원·약국 질문';
    }
  }

  /// API 실패 시 표시할 폴백 질문 텍스트
  static String _fallbackQuestionText(int step) {
    switch (step) {
      case 1:
        return '오늘 아침이나\n점심은요?';
      case 2:
        return '이번 주 계획이\n있으세요?';
      default:
        return '최근 병원이나\n약국에 가셨어요?';
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

    // API에서 질문 텍스트를 가져옵니다.
    final questionAsync = ref.watch(questionProvider(type));
    final canAnswer = questionAsync.maybeWhen(
      loading: () => false,
      orElse: () => true,
    );

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
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 28 + bottomInset),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            questionAsync.when(
                              loading: () => const SizedBox(
                                height: 128,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: ItdaColors.orange,
                                  ),
                                ),
                              ),
                              error: (_, _) => Text(
                                _fallbackQuestionText(step),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  height: 1.3,
                                  color: _pText,
                                  letterSpacing: 0,
                                ),
                              ),
                              data: (_) => Text(
                                _displayQuestionText(step),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  height: 1.3,
                                  color: _pText,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 56),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 520,
                                ),
                                child: _VoiceAnswerButton(
                                  enabled: canAnswer,
                                  onTap: () {
                                    final qId =
                                        questionAsync.valueOrNull?.questionId ??
                                        type;
                                    _openVoice(context, qId, type);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              canAnswer ? '버튼을 누르고 편하게 말씀해주세요' : '질문을 불러오고 있어요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _pTextSub,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _VoiceAnswerButton extends StatelessWidget {
  const _VoiceAnswerButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(24),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_rounded, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Text(
                    '음성으로 답하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
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

String _displayQuestionText(int step) {
  switch (step.clamp(0, 2)) {
    case 1:
      return '오늘 아침이나\n점심엔 뭘 드셨어요?';
    case 2:
      return '이번 주에\n계획이 있으세요?';
    case 0:
    default:
      return '최근 병원이나\n약국에 다녀오셨어요?';
  }
}

String _fallbackQuestionTextForStep(int step) {
  switch (step.clamp(0, 2)) {
    case 1:
      return '오늘 아침이나\n점심은요?';
    case 2:
      return '이번 주 계획이\n있으세요?';
    case 0:
    default:
      return '최근 병원이나\n약국에 가셨어요?';
  }
}
