import 'package:flutter_test/flutter_test.dart';
import 'package:womenz/main.dart';

void main() {
  testWidgets('Womenz app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WomenzApp());
  });
}
