import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techsupport_mobile/features/landing/presentation/landing_page.dart';

void main() {
  const widths = <double>[420, 900, 1280];

  for (final width in widths) {
    testWidgets('landing sayfası $width genişlikte hatasız yerleşir',
        (tester) async {
      tester.view.physicalSize = Size(width * 2, 2400 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: LandingPage(),
        ),
      );
      await tester.pump();

      // Bölüm animasyonlarının (100ms gecikmeli görünürlük) ve
      // 800ms'lik geçişlerin tamamlanmasını bekle.
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });
  }
}