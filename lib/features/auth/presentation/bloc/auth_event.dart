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
  final bool isRegister;
  const AuthGoogleSignInRequested({this.isRegister = false});

  @override
  List<Object?> get props => [isRegister];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthCheckCurrentUserRequested extends AuthEvent {
  const AuthCheckCurrentUserRequested();
}
