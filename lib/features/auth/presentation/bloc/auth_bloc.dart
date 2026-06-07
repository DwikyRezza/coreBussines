// ============================================================
// FEATURE: Auth — BLoC
// lib/features/auth/presentation/bloc/auth_bloc.dart
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final AuthRepository _authRepository;

  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required AuthRepository authRepository,
  })  : _signInWithGoogle = signInWithGoogle,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthCheckCurrentUserRequested>(_onCheckCurrentUser);
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Guard: ignore if already loading (prevents double submit)
    if (state is AuthLoading) return;

    emit(const AuthLoading());

    final result = await _signInWithGoogle(
        SignInWithGoogleParams(isRegister: event.isRegister));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthLoading) return;

    emit(const AuthLoading());
    final result = await _authRepository.signOut();
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckCurrentUser(
    AuthCheckCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }
}
