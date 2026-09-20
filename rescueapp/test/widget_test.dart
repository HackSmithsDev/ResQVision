import 'package:flutter_test/flutter_test.dart';
import 'package:resueapp/app/app.dart';

void main() {
  testWidgets('Resue app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ResueApp());
  });
}