import 'package:flutter_test/flutter_test.dart';
import 'package:a_z/main.dart';

void main() {
  testWidgets('앱이 뜬다', (tester) async {
    await tester.pumpWidget(const AzApp());
    expect(find.text('A-Z 보관함'), findsOneWidget);
  });
}
