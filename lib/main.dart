// ============================================================
// APP ENTRY POINT — main.dart
// lib/main.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  // Ensure widget binding is initialized before any async work
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style — light content on primary background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const CoreBusinessApp());
}

class CoreBusinessApp extends StatelessWidget {
  const CoreBusinessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CoreBusiness',
      debugShowCheckedModeBanner: false,

      // Material 3 Theme
      theme: AppTheme.lightTheme,

      // go_router configuration
      routerConfig: appRouter,
    );
  }
}
