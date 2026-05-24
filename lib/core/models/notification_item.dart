/// 알림 항목.
///
/// 백엔드 `GET /notifications` 응답 매핑.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  /// 알림 식별자 (BE의 `notification_id`)
  final String id;

  final String title;
  final String body;

  /// 알림에 딸린 부가 데이터 (사진 id, 분석 id 등). 형식은 알림 종류마다 다름.
  final Map<String, dynamic>? data;

  /// 읽음 여부
  final bool isRead;

  final DateTime createdAt;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['notification_id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
