// ============================================================
// CORE: Dependency Injection — Service Locator
// lib/core/di/service_locator.dart
//
// Single source of truth for all dependencies.
// Repositories: LazySingleton (shared state, one instance).
// BLoCs:        Factory (fresh per page, no memory leak).
// ============================================================

import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/datasources/home_mock_datasource.dart'; // For HomeDataSource
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

// Transactions
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../../features/transactions/data/datasources/transaction_remote_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/add_transaction.dart';
import '../../features/transactions/domain/usecases/delete_transaction.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Call this once in [main] before [runApp].
/// All async setup (SharedPreferences) happens here.
Future<void> initDependencies() async {
  // ─── External Dependencies ────────────────────────────────
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(scopes: ['email', 'profile']),
  );

  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // SharedPreferences must be awaited before registration.
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // ─── Auth Feature ─────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(googleSignIn: sl(), prefs: sl()),
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
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionRemoteDataSourceImpl(supabase: sl()),
  );

  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  // Factory: fresh TransactionBloc per page.
  sl.registerFactory(
    () => TransactionBloc(
      repository: sl(),
      addTransaction: sl(),
      deleteTransaction: sl(),
    ),
  );

  // ─── Home Feature ─────────────────────────────────────────
  sl.registerLazySingleton<HomeDataSource>(
    () => HomeRemoteDataSourceImpl(
      supabase: sl(),
      authRepository: sl<AuthRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeDataSource>()),
  );

  // Factory: fresh HomeBloc per page.
  sl.registerFactory(
    () => HomeBloc(repository: sl()),
  );
}
