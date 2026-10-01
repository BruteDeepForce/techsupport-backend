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

  const widths = <double>[420, 1280];

  for (final width in widths) {
    for (final entry in pages.entries) {
      testWidgets('${entry.key} sayfası $width genişlikte hatasız yerleşir',
          (tester) async {
        tester.view.physicalSize = Size(width * 2, 1000 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          Builder(
            builder: (context) => MaterialApp(home: entry.value(context)),
          ),
        );
        // İlk kare + veri gelen sonraki kareler.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));

        expect(tester.takeException(), isNull);
      });
    }
  }
}

/// Uç noktaya göre beklenen boş yanıt gövdesi.
dynamic _emptyPayload(String path) {
  if (path.contains('/technicians/summary')) {
    return <dynamic>[];
  }
  if (path.contains('/metrics')) {
    return <dynamic>[];
  }
  if (path.contains('/operations') && !path.contains('summary')) {
    return {
      'items': <dynamic>[],
      'page': 1,
      'pageSize': 20,
      'total': 0,
    };
  }
  if (path.contains('/tickets') ||
      path.contains('/customers') ||
      path.contains('/devices') ||
      path.contains('/offers') ||
      path.contains('/stock') ||
      path.contains('/trade')) {
    return {
      'items': <dynamic>[],
      'page': 1,
      'pageSize': 20,
      'total': 0,
    };
  }
  return {
    'items': <dynamic>[],
    'page': 1,
    'pageSize': 20,
    'total': 0,
  };
}
