import 'package:flutter_test/flutter_test.dart';

import 'package:techsupport_mobile/main.dart';

void main() {
  testWidgets('renders login and opens password reset flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TechSupportMobileApp());

    expect(find.text('Lineer Destek'), findsOneWidget);
    expect(find.text('Şifrenizi mi unuttunuz?'), findsOneWidget);

    await tester.tap(find.text('Şifrenizi mi unuttunuz?'));
    await tester.pumpAndSettle();

    expect(find.text('Şifrenizi yenileyin'), findsOneWidget);
    expect(find.text('Kod gönder'), findsOneWidget);
  });
}
