// ============================================================
// CORE: Use Case — Base Interface
// lib/core/usecases/usecase.dart
// ============================================================

import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases.
/// [T] = return type, [Params] = input parameters.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Marker class for use cases with no parameters.
class NoParams {
  const NoParams();
}
