// ============================================================
// FEATURE: Auth — Use Case: Sign In With Google
// lib/features/auth/domain/usecases/sign_in_with_google.dart
// ============================================================

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle implements UseCase<UserEntity, SignInWithGoogleParams> {
  final AuthRepository _repository;

  const SignInWithGoogle(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithGoogleParams params) {
    return _repository.signInWithGoogle(isRegister: params.isRegister);
  }
}

class SignInWithGoogleParams {
  final bool isRegister;
  const SignInWithGoogleParams({this.isRegister = false});
}
