import 'package:flutter_test/flutter_test.dart';
import 'package:womenz/main.dart';

void main() {
  testWidgets('WomenzApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WomenzApp());
    expect(find.byType(WomenzApp), findsOneWidget);
  });
}
