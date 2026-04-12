/// 음성 녹음·데모 분석 요청 UI. 앱 라우터에는 아직 등록되어 있지 않습니다.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/services/voice_analysis.dart';
import 'package:itda/services/voice_service.dart';
import 'package:itda/shared/widgets/itda_chrome.dart';

String _basename(String path) {
  final n = path.replaceAll('\\', '/');
  final i = n.lastIndexOf('/');
  return i < 0 ? n : n.substring(i + 1);
}

class VoiceRecordingScreen extends StatefulWidget {
  const VoiceRecordingScreen({super.key, this.onRoleSwitch});

  final VoidCallback? onRoleSwitch;

  @override
  State<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen> {
  final _voice = VoiceService();
  bool _recording = false;
  String? _lastPath;
  bool _busy = false;

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('웹에서는 녹음 대신 빠른 답장 버튼을 이용해 주세요.')),
      );
      return;
    }

    if (_recording) {
      final path = await _voice.stopRecording();
      setState(() {
        _recording = false;
        _lastPath = path;
      });
      if (path != null) await _uploadAndAnalyze(path);
      return;
    }

    final ok = await _voice.ensureMicPermission();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마이크 권한이 필요합니다.')),
      );
      return;
    }
    await _voice.startRecording();
    setState(() => _recording = true);
  }

  Future<void> _uploadAndAnalyze(String path) async {
    setState(() => _busy = true);
    final r = await triggerVoiceAnalysisUploadFromPath(path);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.message)),
    );
  }

  void _sendQuick(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('답장 전송(데모): $text')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ItdaColors.orangePale,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItdaShellHeader(
                style: ItdaHeaderStyle.parent,
                onRoleSwitch: widget.onRoleSwitch,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  children: [
                    const ItdaSectionHeader(title: '말씀으로 응답', titleSize: 18),
                    const SizedBox(height: 10),
                    Text(
                      '버튼을 누르면 녹음이 시작되고, 다시 누르면 종료 후 업로드·분석이 진행돼요.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ItdaColors.textSub),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Semantics(
                        button: true,
                        label: _recording ? '녹음 종료' : '녹음 시작',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _recording
                                  ? [ItdaColors.danger, ItdaColors.coral1]
                                  : [ItdaColors.orange, ItdaColors.orangeMid],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_recording ? ItdaColors.danger : ItdaColors.orange).withValues(alpha: 0.4),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _busy ? null : _toggleRecord,
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: Icon(
                                  _recording ? Icons.stop_rounded : Icons.mic_rounded,
                                  size: 56,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _recording ? '녹음 중… 다시 눌러 종료' : '탭하여 녹음',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (_lastPath != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '마지막 파일: ${_basename(_lastPath!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ItdaColors.textMuted),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    const ItdaSectionHeader(title: '버튼식 자동완성 답장', titleSize: 18),
                    const SizedBox(height: 10),
                    Text(
                      '타이핑 없이 자주 쓰는 문구를 보내요.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ItdaColors.textSub),
                    ),
                    const SizedBox(height: 16),
                    ItdaPanel(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: MockItdaData.quickReplies.map((q) {
                          return Material(
                            color: ItdaColors.orangeLight.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => _sendQuick(q),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Text(
                                  q,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: ItdaColors.orangeDark,
                                      ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_busy)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator(color: ItdaColors.orange)),
            ),
        ],
      ),
    );
  }
}
