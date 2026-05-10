/// 사진 전송 엔티티.
///
/// 백엔드 응답 (`POST /photos` 결과 / `GET /photos/history`) 매핑.
class Photo {
  const Photo({
    required this.id,
    required this.senderUserId,
    required this.receiverUserId,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    this.caption,
    this.scheduledAt,
    this.presignedUrl,
  });

  /// 사진 식별자 (BE의 `photo_id`)
  final String id;

  final String senderUserId;
  final String receiverUserId;

  /// 이미지 URL (또는 `s3://...` 키)
  final String imageUrl;

  /// S3 presigned URL — 7일간 유효한 임시 접근 URL.
  /// 화면 표시는 [displayUrl]을 사용 (presigned가 있으면 그것, 없으면 imageUrl).
  final String? presignedUrl;

  /// 캡션 (옵셔널)
  final String? caption;

  /// 예약 발송 시각 — 없으면 즉시 전송
  final DateTime? scheduledAt;

  /// 발송 상태: `sent`, `scheduled` 등
  final String status;

  final DateTime createdAt;

  /// 예약 전송 여부 편의 게터
  bool get isScheduled => status == 'scheduled';

  /// 화면에 띄울 URL — presigned URL이 있으면 그것, 없으면 imageUrl.
  String get displayUrl => presignedUrl ?? imageUrl;

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['photo_id'] as String,
      senderUserId: json['sender_user_id'] as String,
      receiverUserId: json['receiver_user_id'] as String,
      imageUrl: json['image_url'] as String,
      presignedUrl: json['presigned_url'] as String?,
      caption: json['caption'] as String?,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}