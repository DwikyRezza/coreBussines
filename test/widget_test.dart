import 'package:corebussiness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
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

    expect(find.text('CoreBusiness test shell'), findsOneWidget);
  });
}
