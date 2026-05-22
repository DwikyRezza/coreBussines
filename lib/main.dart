import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
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

  await dotenv.load(fileName: ".env");
  AppConfig.validate();

  await Firebase.initializeApp();

  await initDependencies();
  runApp(const CoreBusinessApp());
}

class CoreBusinessApp extends StatelessWidget {
  final GoRouter? routerConfig;

  const CoreBusinessApp({super.key, this.routerConfig});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(const AuthCheckCurrentUserRequested()),
      child: MaterialApp.router(
        title: 'CoreBusiness',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: routerConfig ?? appRouter,
      ),
    );
  }
}
