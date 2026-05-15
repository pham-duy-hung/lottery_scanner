import 'package:flutter_test/flutter_test.dart';
import 'package:lottery_scanner/main.dart';

void main() {
  testWidgets('Home screen loads with language toggle', (tester) async {
    await tester.pumpWidget(const LotteryScannerApp());
    await tester.pumpAndSettle();

    expect(find.text('VI'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('Quét vé ngay'), findsOneWidget);
  });
}
