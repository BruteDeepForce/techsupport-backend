import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techsupport_mobile/core/network/api_client.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_accounting_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_customers_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_device_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_offers_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_operations_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_stock_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_team_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_tickets_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_trade_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/hr_pages/admin_web_hr_page.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/shared/admin_web_nav.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Token okuma kanalı; aksi halde her istek platform kanalında bekler.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => call.method == 'read' ? 'test-token' : null,
    );

    // Tüm GET istekleri boş sayfa döndürür; böylece sayfalar hata durumuna
    // düşmeden koyu temayı çizer ve yerleşim sorunları görünür olur.
    ApiClient().dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;
          if (path.contains('/dashboard')) {
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'summary': {
                  'tenantId': 'x',
                  'tenantName': 'Lineer Servis',
                  'totalCustomers': 3,
                  'totalOperations': 19,
                  'completedOperations': 8,
                  'failedOperations': 1,
                  'deliveredOperations': 4,
                  'openOperations': 7,
                },
                'metrics': <Map<String, dynamic>>[],
                'plannedOperations': <Map<String, dynamic>>[],
              },
            ));
            return;
          }
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _emptyPayload(path),
          ));
        },
      ),
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
  });

  final pages = <String, WidgetBuilder>{
    for (final item in adminNavItems()) item.label: item.pageBuilder,
  };

  // Admin paneli masaüstü içindir; 1100px altında sidebar çekmeceye düşer.
  // 1280 masaüstü ve 1600 geniş masaüstü hedeflenir.
  const widths = <double>[1280, 1600];

  for (final width in widths) {
    for (final entry in pages.entries) {
      testWidgets('${entry.key} sayfası $width genişlikte hatasız yerleşir',
          (tester) async {
        tester.view.physicalSize = Size(width * 2, 1000 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        // Sayfa, MaterialApp'in altında kurulmalı; aksi halde
        // Navigator.of(context) güvenli olmayan bir ancestor arar.
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) => entry.value(context)),
          ),
        );
        // İlk kare + veri gelen sonraki kareler.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));

        expect(tester.takeException(), isNull);

        // Ağaç sökülmeden önce sayfayı boşalt ve kareleri ilerlet; aksi
        // halde sayfadaki sonsuz animasyonlar (canlı göstergesi, caret)
        // söküm sırasında TickerMode'a deaktive edilmiş bir ağaca erişip
        // sonraki testin durumunu bozuyor.
        await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });
    }
  }
}

/// Doğrudan liste bekleyen uç noktalar.
const _listPaths = <String>[
  '/api/operations/tickets',
  '/api/operations/Get-all',
  '/api/stock/categories',
  '/api/stock/items',
  '/api/technicians',
  '/api/technicians/experts',
  '/api/customers',
  '/api/offer/offers/admin',
  '/api/offer/offers/customer',
  '/api/reports/metrics',
  '/api/reports/technicians/summary',
  '/api/hr/positions',
  '/api/hr/shifts/templates',
  '/api/hr/shifts/assignments',
  '/api/hr/rewards/records',
  '/api/hr/disciplines/records',
  '/api/hr/rewards',
  '/api/hr/disciplines',
  '/api/hr/settings/leave-deductions',
];

/// HR uç noktalarının beklediği özel boş gövdeler. Sayfa kendi boş durum
/// ekranını çizsin diye modelin zorunlu alanları doldurulur.
final Map<String, dynamic Function()> _customPayloads = {
  '/api/hr/employees': () => {
        'employees': <dynamic>[],
        'TotalCount': 0,
        'ActiveCount': 0,
        'PassiveCount': 0,
        'EmployeesOnLeaveCount': 0,
        'PendingLeavesCount': 0,
        'EmployeesWithPendingAdvanceRequestsCount': 0,
      },
  '/api/hr/leaves': () => {
        'allLeaves': <dynamic>[],
        'pendingLeaves': <dynamic>[],
        'approvedLeaves': <dynamic>[],
        'rejectedLeaves': <dynamic>[],
      },
  '/api/hr/settings/advance-settings/current': () => {
        'id': '',
        'title': '',
        'isActive': false,
        'advanceLimit': 0,
        'advanceDay': 0,
        'advanceMaturityDay': 0,
        'isMaturityAutomatic': false,
      },
};

/// Uç noktaya göre beklenen boş yanıt gövdesi.
///
/// Yanlış şema verildiğinde servis `as List` / `as Map` dönüşümünde patlar ve
/// sayfa hata durumuna düşer; yerleşim testi o zaman anlamsızlaşır.
dynamic _emptyPayload(String path) {
  for (final entry in _customPayloads.entries) {
    if (path.startsWith(entry.key)) return entry.value();
  }

  for (final listPath in _listPaths) {
    if (path.startsWith(listPath)) return <dynamic>[];
  }

  return {
    'items': <dynamic>[],
    'page': 1,
    'pageSize': 20,
    'total': 0,
  };
}
