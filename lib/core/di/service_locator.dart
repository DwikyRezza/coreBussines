// ============================================================
// CORE: Dependency Injection — Service Locator
// lib/core/di/service_locator.dart
//
// Single source of truth for all dependencies.
// Repositories: LazySingleton (shared state, one instance).
// BLoCs:        Factory (fresh per page, no memory leak).
// ============================================================

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/local_storage_service.dart';
import '../config/app_config.dart';
import '../services/app_lock_controller.dart';
import '../services/business_context_service.dart';
import '../services/scan_usage_limiter.dart';
import '../theme/theme_controller.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/datasources/home_datasource.dart'; // For HomeDataSource
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

// Analytics
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';

// Transactions
import '../../features/transactions/data/datasources/ai_receipt_scanner.dart';
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../../features/transactions/data/datasources/transaction_remote_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/add_transaction.dart';
import '../../features/transactions/domain/usecases/delete_transaction.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';

// Schedule
import '../../features/schedule/data/datasources/schedule_local_datasource.dart';

// Notifications
import '../../features/notifications/data/datasources/notification_local_datasource.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/data/services/notification_service.dart';
import '../../features/notifications/data/services/weekly_summary_notification_service.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';

// Security
import '../../features/settings/data/datasources/app_lock_local_datasource.dart';
import '../../features/settings/data/repositories/app_lock_repository_impl.dart';
import '../../features/settings/domain/repositories/app_lock_repository.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Call this once in [main] before [runApp].
/// All async setup (SharedPreferences) happens here.
Future<void> initDependencies() async {
  // ─── External Dependencies ────────────────────────────────
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      serverClientId: AppConfig.googleWebClientId.isEmpty
          ? null
          : AppConfig.googleWebClientId,
      scopes: ['email', 'profile'],
    ),
  );

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());

  // SharedPreferences must be awaited before registration.
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Storage Service
  sl.registerLazySingleton<LocalStorageService>(
      () => LocalStorageService(sl()));
  sl.registerLazySingleton<BusinessContextService>(
    () => BusinessContextService(
      auth: sl(),
      firestore: sl(),
      localStorage: sl(),
    ),
  );
  sl.registerLazySingleton<ThemeController>(() => ThemeController(sl()));
  sl.registerLazySingleton<ScanUsageLimiter>(() => ScanUsageLimiter(sl()));
  sl.registerLazySingleton<AppLockLocalDataSource>(
    () => AppLockLocalDataSourceImpl(
      secureStorage: sl(),
      localAuthentication: sl(),
    ),
  );
  sl.registerLazySingleton<AppLockRepository>(
    () => AppLockRepositoryImpl(sl()),
  );
  final appLockController = AppLockController(sl());
  await appLockController.load();
  sl.registerLazySingleton<AppLockController>(() => appLockController);

  // ─── Auth Feature ─────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
      prefs: sl(),
    ),
  );

  // AuthRepositoryImpl is NOT const (has StreamController) — use factory init.
  sl.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<AuthRepository>(() => sl<AuthRepositoryImpl>());

  sl.registerLazySingleton(() => SignInWithGoogle(sl()));

  // Factory: fresh AuthBloc instance per page mount.
  sl.registerFactory(
    () => AuthBloc(
      signInWithGoogle: sl(),
      authRepository: sl(),
    ),
  );

  // ─── Transactions Feature ─────────────────────────────────
  sl.registerLazySingleton<AiReceiptScanner>(
    () => AiReceiptScanner(),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(prefs: sl()),
  );

  // ─── Schedule Feature ─────────────────────────────────────
  sl.registerLazySingleton<ScheduleLocalDataSource>(
    () => ScheduleLocalDataSourceImpl(prefs: sl()),
  );

  // ─── Notifications Feature ───────────────────────────────
  sl.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      firestore: sl(),
      businessContext: sl(),
    ),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WeeklySummaryNotificationService>(
    () => WeeklySummaryNotificationService(
      firestore: sl(),
      businessContext: sl(),
      notificationRepository: sl(),
    ),
  );

  final notificationService = NotificationService();
  await notificationService.initialize();
  sl.registerLazySingleton<NotificationService>(() => notificationService);

  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(
      auth: sl(),
      firestore: sl(),
      localStorage: sl(),
      storage: sl(),
      businessContext: sl(),
    ),
  );

  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      localStorage: sl(),
    ),
  );

  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  sl.registerFactory(
    () => TransactionBloc(
      repository: sl(),
      addTransaction: sl(),
      deleteTransaction: sl(),
      scanner: sl(),
    ),
  );

  // ─── Home Feature ─────────────────────────────────────────
  sl.registerLazySingleton<HomeDataSource>(
    () => HomeRemoteDataSourceImpl(
      auth: sl(),
      firestore: sl(),
      authRepository: sl<AuthRepositoryImpl>(),
      localStorage: sl(),
    ),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeDataSource>(), sl()),
  );

  // Factory: fresh HomeBloc per page.
  sl.registerFactory(
    () => HomeBloc(repository: sl()),
  );

  // ─── Analytics Feature ────────────────────────────────────
  sl.registerFactory(
    () => AnalyticsBloc(transactionRepository: sl()),
  );
}
