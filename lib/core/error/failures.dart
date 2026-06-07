// ============================================================
// CORE: Error — Failure Types
// lib/core/error/failures.dart
// ============================================================

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Tidak ada koneksi internet.'});
}

class CacheFailure extends Failure {
  const CacheFailure(
      {super.message = 'Terjadi kesalahan pada penyimpanan lokal.'});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(
      {super.message = 'Terjadi kesalahan yang tidak terduga.'});
}
