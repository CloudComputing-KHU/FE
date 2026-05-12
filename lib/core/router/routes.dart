/// go_router 경로 상수 — 팀원 간 경로 문자열 오타 방지
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  /// 회원가입 (폼·BE 연동 확장)
  static const signUp = '/signup';
  /// 역할 선택 (자녀/부모)
  static const roleSelect = '/';
  static const child = '/child';
  static const parent = '/parent';
}
