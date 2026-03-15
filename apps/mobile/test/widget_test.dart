import 'package:flutter_test/flutter_test.dart';

import 'package:techsupport_mobile/main.dart';

void main() {
  testWidgets('renders login experience', (WidgetTester tester) async {
    await tester.pumpWidget(const TechSupportMobileApp());

    expect(find.text('TechSupport'), findsOneWidget);
    expect(find.text('Demo merkeze geç'), findsOneWidget);
  });
}
