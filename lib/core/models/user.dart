/// 로그인 사용자 등에 쓰는 최소 사용자 모델. 필드는 API에 맞게 확장합니다.
class User {
  const User({
    required this.id,
    required this.displayName,
  });

  final String id;
  final String displayName;
}
