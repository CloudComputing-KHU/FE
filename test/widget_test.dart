import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/app.dart';

void main() {
  testWidgets('스플래시 후 역할 선택에 자녀/부모가 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ItdaApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('자녀용'), findsOneWidget);
    expect(find.text('부모용'), findsOneWidget);
  });
}
