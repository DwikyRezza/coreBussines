import 'package:corebussiness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:corebussiness/core/di/service_locator.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (MethodCall methodCall) async {
        return true;
      },
    );
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await initDependencies();
  });

  testWidgets('CoreBusinessApp renders with injected router', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: Center(child: Text('CoreBusiness test shell')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(CoreBusinessApp(routerConfig: router));
    await tester.pump();

    expect(find.text('CoreBusiness test shell'), findsOneWidget);
  });
}

