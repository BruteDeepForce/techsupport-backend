import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techsupport_mobile/core/network/api_client.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_home_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/shared/admin_web_design.dart';

void main() {
  const widths = <double>[420, 900, 1280, 1600];

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // AuthInterceptor token okurken platform kanalını bekliyor; testte
    // kanalı boş bir token ile yanıtlayıp isteğin geçmesini sağlıyoruz.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => call.method == 'read' ? 'test-token' : null,
    );

    // Dashboard ağ isteğini test içinde karşılayıp sabit veri döndürüyoruz.
    // Dio singleton olduğu için interceptor yalnızca bir kez ekleniyor.
    ApiClient().dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path.endsWith('/api/reports/dashboard')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: _dashboardPayload,
              ),
            );
            return;
          }
          handler.next(options);
        },
      ),
    );
  });

  for (final width in widths) {
    testWidgets('admin dashboard $width genişlikte hatasız yerleşir',
        (tester) async {
      tester.view.physicalSize = Size(width * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminWebHomePage(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dashboard verileri gerçek özet alanlarından okunur',
      (tester) async {
    tester.view.physicalSize = const Size(1600 * 2, 1000 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminWebHomePage(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Özet: acik 7, tamamlanan 12, musteri 3.
    expect(find.text('7'), findsWidgets);
    expect(find.text('12'), findsWidgets);
    expect(find.text('3'), findsWidgets);

    // Tamamlanma orani: 12 / 19.
    expect(find.text('63%'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('koyu tema yardımcı bileşenleri hatasız çizilir', (tester) async {
    tester.view.physicalSize = const Size(1200 * 2, 1600 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AdminTechColors.canvas,
          body: SingleChildScrollView(
            child: Column(
              children: [
                const AdminTechBackdrop(
                  child: SizedBox(
                      height: 60,
                      child: AdminTechSparkline(values: [1, 4, 2, 8, 6])),
                ),
                const AdminTechRing(
                    progress: 0.63, centerLabel: '63%', caption: 'ORAN'),
                const AdminTechBars(
                    values: [3, 7, 2, 9], labels: ['Oca', 'Sub', 'Mar', 'Nis']),
                const AdminTechDistributionBar(segments: [
                  (label: 'A', value: 3, color: AdminTechColors.amber),
                  (label: 'B', value: 5, color: AdminTechColors.green),
                ]),
                const AdminTechPill(label: '7G', active: true),
                const AdminTechCard(
                    child: AdminTechPlaceholder(label: 'Bos durum')),
                const AdminTechSectionTitle(
                    title: 'Baslik', subtitle: 'Alt baslik'),
                const AdminTechPulseDot(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
  });
}

final _dashboardPayload = {
  'summary': {
    'tenantId': '11111111-1111-1111-1111-111111111111',
    'tenantName': 'Lineer Servis',
    'totalCustomers': 3,
    'totalOperations': 19,
    'completedOperations': 8,
    'failedOperations': 1,
    'deliveredOperations': 4,
    'openOperations': 7,
  },
  'metrics': [
    {
      'metricType': 'OperationCreated',
      'periodType': 'Monthly',
      'periodStart': _monthStart(0),
      'value': 4,
    },
    {
      'metricType': 'OperationCreated',
      'periodType': 'Monthly',
      'periodStart': _monthStart(1),
      'value': 9,
    },
    {
      'metricType': 'OperationCompleted',
      'periodType': 'Monthly',
      'periodStart': _monthStart(1),
      'value': 5,
    },
    {
      'metricType': 'CustomerCreated',
      'periodType': 'Monthly',
      'periodStart': _monthStart(1),
      'value': 2,
    },
    {
      'metricType': 'TicketCreated',
      'periodType': 'Monthly',
      'periodStart': _monthStart(1),
      'value': 11,
    },
  ],
  'plannedOperations': <Map<String, dynamic>>[],
};

/// Test verisi için ay içi ilk gün formatında tarih.
String _monthStart(int monthsAgo) {
  final now = DateTime.now();
  final month = DateTime(now.year, now.month - monthsAgo, 1);
  return '${month.year.toString().padLeft(4, '0')}-'
      '${month.month.toString().padLeft(2, '0')}-01';
}
