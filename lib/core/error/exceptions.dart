// ============================================================
// CORE: Error — Exception Types
// lib/core/error/exceptions.dart
// ============================================================

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Tidak ada koneksi internet.'});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error.'});

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}
