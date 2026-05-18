// ============================================================
// CORE: Storage — Local Storage Service
// lib/core/storage/local_storage_service.dart
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const String _keyActiveBusinessId = 'active_business_id';
  static const String _keyCurrency = 'active_currency';
  static const String _keyLanguage = 'active_language';

  // ─── Business ─────────────────────────────────────────────
  String? get activeBusinessId => _prefs.getString(_keyActiveBusinessId);
  Future<void> setActiveBusinessId(String id) => _prefs.setString(_keyActiveBusinessId, id);
  Future<void> clearActiveBusinessId() => _prefs.remove(_keyActiveBusinessId);

  // ─── Preferences ─────────────────────────────────────────
  String get activeCurrency => _prefs.getString(_keyCurrency) ?? 'IDR';
  Future<void> setActiveCurrency(String currency) => _prefs.setString(_keyCurrency, currency);

  String get activeLanguage => _prefs.getString(_keyLanguage) ?? 'id_ID';
  Future<void> setActiveLanguage(String lang) => _prefs.setString(_keyLanguage, lang);

  // ─── Generic JSON Caching ──────────────────────────────
  String? getCachedJson(String key) => _prefs.getString(key);
  Future<void> setCachedJson(String key, String jsonString) => _prefs.setString(key, jsonString);
  Future<void> remove(String key) => _prefs.remove(key);
  Future<void> clearAll() => _prefs.clear();
}
