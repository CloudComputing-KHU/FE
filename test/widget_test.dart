import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/app.dart';

void main() {
  testWidgets('초기 화면에 로그인 폼이 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ItdaApp()));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('로그인'), findsWidgets);
    expect(find.text('이메일'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);
  });
}
