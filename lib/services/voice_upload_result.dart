/// 음성 업로드·분석 데모 호출의 결과.
class VoiceUploadResult {
  VoiceUploadResult({
    required this.ok,
    required this.message,
    this.bytes,
  });

  final bool ok;
  final String message;
  final int? bytes;
}
