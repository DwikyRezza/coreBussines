import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  if (kIsWeb) {
    AppConfig.validateForWeb();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        appId: AppConfig.firebaseAppId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
        authDomain: AppConfig.firebaseAuthDomain,
        storageBucket: AppConfig.firebaseStorageBucket,
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await initDependencies();
  runApp(const CoreBusinessApp());
}

class CoreBusinessApp extends StatelessWidget {
  final GoRouter? routerConfig;

  const CoreBusinessApp({super.key, this.routerConfig});

  @override
  Widget build(BuildContext context) {
    final themeController = sl<ThemeController>();

    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(const AuthCheckCurrentUserRequested()),
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          final platformBrightness =
              WidgetsBinding.instance.platformDispatcher.platformBrightness;
          final isDark = themeController.themeMode == ThemeMode.dark ||
              (themeController.themeMode == ThemeMode.system &&
                  platformBrightness == Brightness.dark);

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor:
                  isDark ? const Color(0xFF101218) : Colors.white,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp.router(
            title: 'CoreBusiness',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: routerConfig ?? appRouter,
          );
        },
      ),
    );
  }
}
