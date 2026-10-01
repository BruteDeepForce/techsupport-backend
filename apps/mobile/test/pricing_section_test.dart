import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techsupport_mobile/features/landing/presentation/widgets/pricing_section.dart';

void main() {
  const widths = <double>[420, 800, 950, 1200, 1600];

  for (final width in widths) {
    testWidgets('fiyatlandırma bölümü $width genişlikte hatasız yerleşir',
        (tester) async {
      tester.view.physicalSize = Size(width * 2, 1400 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PricingSection(onScrollToFaq: _noop),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Kurumsal'), findsOneWidget);
      expect(find.text('Demo Talep Et'), findsOneWidget);
    });
  }
}

void _noop() {}