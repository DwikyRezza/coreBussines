// ============================================================
// FEATURE: Auth — BLoC Events
// lib/features/auth/presentation/bloc/auth_event.dart
// ============================================================

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthCheckCurrentUserRequested extends AuthEvent {
  const AuthCheckCurrentUserRequested();
}
