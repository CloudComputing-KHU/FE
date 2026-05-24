/// 사진 반응 엔티티.
///
/// 백엔드 응답:
/// - `GET /photos/{photo_id}/reactions`
/// - `POST /photos/{photo_id}/reactions/quick`
/// - `POST /photos/{photo_id}/reactions/voice`
class PhotoReaction {
  const PhotoReaction({
    required this.reactionId,
    required this.photoId,
    required this.userId,
    required this.reactionType,
    required this.createdAt,
    this.label,
    this.voiceUrl,
    this.presignedUrl,
    this.durationSeconds,
  });

  final String reactionId;
  final String photoId;
  final String userId;
  final String reactionType;
  final String? label;
  final String? voiceUrl;
  final String? presignedUrl;
  final int? durationSeconds;
  final DateTime createdAt;

  bool get isVoice => reactionType == 'voice';

  String get displayLabel {
    final value = label?.trim();
    if (value != null && value.isNotEmpty) return value;
    return isVoice ? '목소리 반응' : '반응';
  }

  String get durationLabel {
    final seconds = durationSeconds ?? 0;
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    return '$minutes:${remain.toString().padLeft(2, '0')}';
  }

  String? get displayVoiceUrl => presignedUrl ?? voiceUrl;

  factory PhotoReaction.fromJson(Map<String, dynamic> json) {
    return PhotoReaction(
      reactionId: json['reaction_id'] as String? ?? '',
      photoId: json['photo_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      reactionType: json['reaction_type'] as String? ?? 'quick',
      label: json['label'] as String?,
      voiceUrl: json['voice_url'] as String?,
      presignedUrl: json['presigned_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
