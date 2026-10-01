import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techsupport_mobile/features/landing/presentation/widgets/ai_chat_preview.dart';

void main() {
  const widths = <double>[420, 1280];

  const cards = <AIChatPreviewCard>[
    AIChatPreviewCard(
      title: 'Teknisyen performansı',
      messages: [
        (
          'Bu ay hangi teknisyenler en çok iş tamamladı?',
          'Mert Yılmaz 46, Elif Demir 41.',
          true,
        ),
      ],
    ),
    AIChatPreviewCard(
      title: 'Stok uyarısı',
      messages: [
        (
          'Kritik seviyedeki parçaları listele.',
          '4 parça kritik seviyede.',
          true,
        ),
      ],
    ),
    AIChatPreviewCard(
      title: 'Muhasebe durumu',
      messages: [
        (
          'Vadesi geçen faturaları listele.',
          '3 fatura listeleniyor.',
          true,
        ),
      ],
    ),
    AIChatPreviewCard(
      title: 'Ticket ve operasyon',
      messages: [
        (
          'Yeni açılan ticketları göster.',
          'Son 24 saatte 7 ticket açıldı.',
          true,
        ),
      ],
    ),
  ];

  for (final width in widths) {
    testWidgets('kartlar bitene kadar bölüm ekranda sabit kalır ($width)',
        (tester) async {
      tester.view.physicalSize = Size(width * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: [
                  const SizedBox(height: 900),
                  AIChatPreviewStack(
                    scrollController: controller,
                    cards: cards,
                  ),
                  const SizedBox(height: 900),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final stackFinder = find
          .descendant(
              of: find.byType(AIChatPreviewStack), matching: find.byType(Stack))
          .first;

      // Kaydırma konumlarını ölçerek sabitlenen aralığı bul.
      const step = 20.0;
      final tops = <double, double>{};
      for (var offset = 0.0;
          offset <= controller.position.maxScrollExtent;
          offset += step) {
        controller.jumpTo(offset);
        await tester.pump();
        tops[offset] = tester.getRect(stackFinder).top;
      }

      // Konumu sabit kalan (kart değiştiren) aralık.
      final pinnedOffsets = <double>[];
      for (final entry in tops.entries) {
        final previous = tops[entry.key - step];
        if (previous == null) continue;
        if ((entry.value - previous).abs() < 0.5) pinnedOffsets.add(entry.key);
      }

      expect(pinnedOffsets, isNotEmpty,
          reason: 'bölüm kartlar boyunca ekranda sabit kalmalı');

      final pinnedTop = tops[pinnedOffsets.first]!;
      for (final offset in pinnedOffsets) {
        expect(tops[offset], closeTo(pinnedTop, 1),
            reason: 'sabitlenen aralıkta bölüm yerinde kalmalı ($offset)');
      }
      expect(tester.takeException(), isNull);

      // Kart sayısı - 1 kadar adım boyunca sabit kalmalı.
      expect(pinnedOffsets.length * step,
          closeTo((cards.length - 1) * 120.0, step * 2));

      // Sabitleme bittiğinde bölüm tekrar yukarı çıkmalı.
      final releaseOffset = pinnedOffsets.last + step;
      expect(tops[releaseOffset], isNotNull);
      expect(tops[releaseOffset]!, lessThan(pinnedTop),
          reason: 'kartlar bittikten sonra bölüm yukarı çıkmalı');
    });
  }

  testWidgets('tüm kartlar gösterilince bölüm serbest kalır', (tester) async {
    tester.view.physicalSize = const Size(1280 * 2, 1000 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: controller,
            child: Column(
              children: [
                const SizedBox(height: 900),
                AIChatPreviewStack(
                  scrollController: controller,
                  cards: cards,
                ),
                const SizedBox(height: 900),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final stackFinder = find
        .descendant(
            of: find.byType(AIChatPreviewStack), matching: find.byType(Stack))
        .first;
    final before = tester.getRect(stackFinder).top;

    // Kart değişimi için gereken mesafenin çok üstüne kaydır.
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -900),
        warnIfMissed: false);
    await tester.pump();

    final after = tester.getRect(stackFinder).top;
    expect(after, lessThan(before),
        reason: 'kartlar bittikten sonra bölüm yukarı çıkmalı');
    expect(tester.takeException(), isNull);
  });
}
