// ============================================================
// CORE: Error — Error Mapper Utility
// lib/core/error/error_mapper.dart
// ============================================================

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorMapper {
  /// Maps any caught [Object] (Exception, Error, etc.) to a corresponding [Failure].
  /// Provides polite, easy-to-understand Indonesian messages for the end-user.
  static Failure mapToFailure(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      return AuthFailure(message: _mapFirebaseAuthException(error));
    }

    if (error is FirebaseException) {
      return ServerFailure(
        message: _mapFirebaseException(error),
        statusCode: error.code.hashCode,
      );
    }

    if (error is TimeoutException) {
      return const ServerFailure(
        message:
            'Waktu pemrosesan habis (timeout). Silakan coba beberapa saat lagi.',
      );
    }

    if (error is FormatException) {
      return const UnexpectedFailure(
        message:
            'Gagal memproses data dari server. Silakan coba beberapa saat lagi.',
      );
    }

    if (error is StateError) {
      return const UnexpectedFailure(
        message:
            'Terjadi kesalahan sistem internal. Silakan muat ulang aplikasi.',
      );
    }

    if (error is AuthException) {
      return AuthFailure(message: error.message);
    }

    if (error is ServerException) {
      return ServerFailure(
        message: error.message,
        statusCode: error.statusCode,
      );
    }

    if (error is NetworkException) {
      return const NetworkFailure(
        message:
            'Koneksi internet terputus atau tidak stabil. Silakan periksa jaringan Anda.',
      );
    }

    if (error is CacheException) {
      return const CacheFailure(
        message:
            'Gagal membaca atau menyimpan data pada penyimpanan lokal perangkat Anda.',
      );
    }

    if (error is Failure) {
      return error;
    }

    // Keyword/string-based matching for nested/wrapped errors
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('network_error') ||
        errorString.contains('connection failed') ||
        errorString.contains('xmlhttprequest') ||
        errorString.contains('handshake_status')) {
      return const NetworkFailure(
        message:
            'Koneksi internet terputus atau tidak stabil. Silakan periksa jaringan Anda.',
      );
    }

    if (errorString.contains('timeout') ||
        errorString.contains('deadline-exceeded')) {
      return const ServerFailure(
        message:
            'Waktu pemrosesan habis (timeout). Silakan coba beberapa saat lagi.',
      );
    }

    if (errorString.contains('permission-denied') ||
        errorString.contains('permission denied')) {
      return const ServerFailure(
        message: 'Anda tidak memiliki izin untuk mengakses data ini.',
      );
    }

    if (errorString.contains('dibatalkan oleh pengguna') ||
        errorString.contains('sign-in canceled')) {
      return const AuthFailure(
        message: 'Proses masuk dibatalkan oleh pengguna.',
      );
    }

    if (errorString.contains('belum terdaftar')) {
      return const AuthFailure(
        message:
            'Akun ini belum terdaftar. Silakan daftar dahulu dengan akun Google tersebut.',
      );
    }

    if (errorString.contains('sudah pernah dibuat')) {
      return const AuthFailure(
        message:
            'Akun ini sudah pernah dibuat. Silakan masuk melalui menu Login dengan akun yang sama.',
      );
    }

    if (errorString.contains('gagal mendapatkan token google')) {
      return const AuthFailure(
        message: 'Gagal mendapatkan token masuk Google. Silakan coba kembali.',
      );
    }

    // Default Fallback
    return const UnexpectedFailure(
      message:
          'Terjadi kesalahan yang tidak terduga. Silakan coba beberapa saat lagi.',
    );
  }

  /// Maps specific Firebase Authentication Error codes to friendly Indonesian messages.
  static String _mapFirebaseAuthException(
      firebase_auth.FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Email atau kata sandi yang Anda masukkan salah. Silakan periksa kembali.';
      case 'user-disabled':
        return 'Akun Anda telah dinonaktifkan. Silakan hubungi layanan bantuan kami.';
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan. Silakan daftarkan akun baru.';
      case 'email-already-in-use':
        return 'Alamat email ini sudah digunakan oleh akun lain. Silakan gunakan email lain.';
      case 'operation-not-allowed':
        return 'Metode masuk ini saat ini tidak diaktifkan. Silakan hubungi layanan bantuan kami.';
      case 'weak-password':
        return 'Kata sandi Anda terlalu lemah. Silakan gunakan kata sandi yang lebih kuat.';
      case 'network-request-failed':
        return 'Gagal terhubung ke layanan masuk. Periksa koneksi internet Anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan masuk yang gagal. Silakan tunggu beberapa saat sebelum mencoba kembali.';
      case 'credential-already-in-use':
        return 'Akun Google ini sudah terhubung dengan pengguna lain.';
      case 'account-exists-with-different-credential':
        return 'Akun dengan email yang sama sudah terdaftar dengan metode masuk yang berbeda.';
      default:
        // Try parsing message or fallback to clean generic text
        if (exception.message != null && exception.message!.isNotEmpty) {
          final msgLower = exception.message!.toLowerCase();
          if (msgLower.contains('sign-in canceled') ||
              msgLower.contains('user cancel')) {
            return 'Proses masuk dibatalkan oleh pengguna.';
          }
        }
        return 'Terjadi kesalahan saat melakukan autentikasi. Silakan coba lagi.';
    }
  }

  /// Maps specific Cloud Firestore/Firebase Core codes to friendly Indonesian messages.
  static String _mapFirebaseException(FirebaseException exception) {
    switch (exception.code) {
      case 'permission-denied':
        return 'Anda tidak memiliki izin untuk mengakses atau mengubah data ini.';
      case 'unauthorized':
        return 'Gagal mengunggah berkas. Anda tidak memiliki izin untuk mengunggah gambar ke server (Storage Unauthorized).';
      case 'unavailable':
        return 'Layanan basis data sedang offline atau tidak tersedia. Data Anda disimpan secara lokal.';
      case 'cancelled':
        return 'Operasi dibatalkan secara sistem.';
      case 'not-found':
        return 'Data yang Anda cari tidak ditemukan di server.';
      case 'already-exists':
        return 'Data tersebut sudah terdaftar di sistem kami.';
      case 'deadline-exceeded':
        return 'Waktu pemrosesan data habis (timeout). Silakan coba lagi.';
      case 'resource-exhausted':
        return 'Batas penggunaan sistem telah terlampaui. Silakan coba beberapa saat lagi.';
      default:
        return 'Gagal memproses data di server (${exception.code}: ${exception.message ?? 'Unknown error'}). Silakan coba beberapa saat lagi.';
    }
  }
}
