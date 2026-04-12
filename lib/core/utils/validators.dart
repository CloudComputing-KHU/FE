/// 입력값 검증용 정적 헬퍼.
class Validators {
  Validators._();

  static bool isNonEmpty(String? s) => s != null && s.trim().isNotEmpty;
}
