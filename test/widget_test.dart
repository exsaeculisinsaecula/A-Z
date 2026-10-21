import 'package:flutter_test/flutter_test.dart';
import 'package:a_z/main.dart';

void main() {
  testWidgets('앱이 뜬다', (tester) async {
    await tester.pumpWidget(const AzApp());
    // 상단 A-Z 제목
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Z'), findsOneWidget);
  });
}
