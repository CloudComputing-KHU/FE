import 'package:intl/intl.dart';

/// [DateTime]을 로케일 문자열로 표시할 때 사용합니다.
class DateFormatter {
  DateFormatter._();

  static String yMd(DateTime d) => DateFormat.yMd('ko').format(d);
}
