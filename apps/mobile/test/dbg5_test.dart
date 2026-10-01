import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techsupport_mobile/core/network/api_client.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/admin_web_stock_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => call.method == 'read' ? 'test-token' : null,
    );
    ApiClient().dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final p = options.path;
        if (p.contains('categories') || p.contains('items') ||
            p.contains('experts') || p == '/api/technicians') {
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: <dynamic>[]));
          return;
        }
        handler.resolve(Response(requestOptions: options, statusCode: 200,
            data: {'items': <dynamic>[], 'page': 1, 'pageSize': 20, 'total': 0}));
      },
    ));
  });

  testWidgets('dbg', (tester) async {
    tester.view.physicalSize = const Size(420 * 2, 1000 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    final errs = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errs.add;
    await tester.pumpWidget(const MaterialApp(home: AdminWebStockPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    for (final d in errs) {
      final t = d.toString();
      if (t.contains('overflowed')) {
        debugPrint('CTX>>> ${d.informationCollector?.call().map((n) => n.toString()).firstOrNull}');
      }
    }
    FlutterError.onError = prev;
  });
}
