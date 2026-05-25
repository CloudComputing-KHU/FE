import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/parent/home/providers/parent_home_provider.dart';
import 'package:itda/services/voice_service.dart';

/// 건강 질문 화면 — 「목소리로 답하기」 시 올라오는 녹음 바텀시트
class HealthVoiceRecordSheet extends ConsumerStatefulWidget {
  const HealthVoiceRecordSheet({
    super.key,
    required this.questionId,
    required this.questionType,
    this.recordOnly = false,
  });

  final String questionId;
  final String questionType;
  final bool recordOnly;

  static Future<bool?> show(
    BuildContext context, {
    required String questionId,
    String? questionType,
  }) {
    final type = questionType ?? 'health';
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) =>
          HealthVoiceRecordSheet(questionId: questionId, questionType: type),
    );
  }

  static Future<VoiceRecordResult?> recordFile(BuildContext context) {
    return showModalBottomSheet<VoiceRecordResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) => const HealthVoiceRecordSheet(
        questionId: 'photo_voice',
        questionType: 'photo',
        recordOnly: true,
      ),
    );
  }

  @override
  ConsumerState<HealthVoiceRecordSheet> createState() =>
      _HealthVoiceRecordSheetState();
}

class VoiceRecordResult {
  const VoiceRecordResult({
    required this.filePath,
    required this.durationSeconds,
  });

  final String filePath;
  final int durationSeconds;
}

class _HealthVoiceRecordSheetState extends ConsumerState<HealthVoiceRecordSheet>
    with SingleTickerProviderStateMixin {
  final _voice = VoiceService();
  late final AnimationController _waveCtrl;
  Timer? _tickTimer;
  bool _recording = false;
  bool _busy = false;
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('웹에서는 녹음 대신 빠른 답변 버튼을 이용해 주세요.')),
      );
      Navigator.of(context).pop();
      return;
    }
    final ok = await _voice.ensureMicPermission();
    if (!mounted) return;
    if (!ok) {
      final micStatus = await Permission.microphone.status;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            micStatus.isPermanentlyDenied
                ? '마이크가 꺼져 있어요. 설정에서 잇다 → 마이크를 허용해 주세요.'
                : '마이크 권한이 필요합니다. 허용을 눌러 주세요.',
          ),
          action: SnackBarAction(
            label: '설정 열기',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      Navigator.of(context).pop();
      return;
    }
    await _voice.startRecording();
    if (!mounted) return;
    setState(() => _recording = true);
    _stopwatch.start();
    _waveCtrl.repeat();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() {});
    });
  }

  String get _timerLabel {
    final d = _stopwatch.elapsed;
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _resetRecording() async {
    if (_busy || !_recording) return;
    setState(() => _busy = true);
    await _voice.stopRecording();
    _stopwatch.reset();
    if (!mounted) return;
    await _voice.startRecording();
    _stopwatch.start();
    _waveCtrl.repeat();
    setState(() {
      _busy = false;
      _recording = true;
    });
  }

  Future<void> _send() async {
    if (_busy) return;
    setState(() => _busy = true);
    _tickTimer?.cancel();
    _waveCtrl.stop();
    final path = await _voice.stopRecording();
    _stopwatch.stop();
    if (!mounted) return;
    setState(() => _recording = false);
    if (path != null) {
      if (widget.recordOnly) {
        Navigator.of(context).pop(
          VoiceRecordResult(
            filePath: path,
            durationSeconds: _stopwatch.elapsed.inSeconds,
          ),
        );
        return;
      }
      final ok = await submitParentVoice(
        ref: ref,
        type: widget.questionType,
        questionId: widget.questionId,
        filePath: path,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '음성 답변이 전송됐어요!' : '전송에 실패했어요. 다시 시도해 주세요.'),
        ),
      );
      Navigator.of(context).pop(ok);
      return;
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('녹음 파일을 저장하지 못했어요.')));
    }
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _waveCtrl.dispose();
    unawaited(_disposeRecorder());
    super.dispose();
  }

  Future<void> _disposeRecorder() async {
    try {
      await _voice.stopRecording();
    } catch (_) {}
    await _voice.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final radius = 24.0;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 20 + bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _MicRings(recording: _recording && !_busy),
                  const SizedBox(height: 16),
                  Text(
                    _timerLabel,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _waveCtrl,
                    builder: (context, _) {
                      return SizedBox(
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(28, (i) {
                            final t = _waveCtrl.value * 2 * math.pi;
                            final h =
                                6 +
                                26 * (0.5 + 0.5 * math.sin(t + i * 0.42)).abs();
                            return Container(
                              width: 3,
                              height: h.clamp(6.0, 40.0),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: ItdaColors.orange.withValues(
                                  alpha: 0.55,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Material(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(26),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(26),
                          onTap: _busy ? null : _resetRecording,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Text(
                              '다시하기',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: ItdaColors.orange,
                        borderRadius: BorderRadius.circular(29),
                        elevation: 4,
                        shadowColor: ItdaColors.orange.withValues(alpha: 0.45),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(29),
                          onTap: _busy ? null : _send,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            child: _busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '보내기',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
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

class _MicRings extends StatelessWidget {
  const _MicRings({required this.recording});

  final bool recording;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (final r in <double>[72, 58, 44])
          Container(
            width: r,
            height: r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200.withValues(
                alpha: 0.35 + (72 - r) * 0.004,
              ),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
          ),
        Icon(
          Icons.mic_rounded,
          size: 30,
          color: recording ? ItdaColors.orangeDark : Colors.grey.shade600,
        ),
      ],
    );
  }
}
