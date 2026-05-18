import 'package:flutter_test/flutter_test.dart';
import 'package:lofi_radio_flutter/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const LofiRadioApp());
    expect(find.text('Lofi Radio'), findsOneWidget);
  });
}
