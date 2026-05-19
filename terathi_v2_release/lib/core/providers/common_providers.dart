import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── SharedPreferences instance provider ──────────────────────────────
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at app start');
});

// ── Language Provider (persisted) ─────────────────────────────────────
class LanguageNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;
  static const _key = 'app_language';

  LanguageNotifier(this._prefs) : super(_prefs.getString(_key) ?? 'ar');

  void setLanguage(String lang) {
    state = lang;
    _prefs.setString(_key, lang);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

// ── Theme Provider (persisted) ────────────────────────────────────────
class ThemeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'dark_mode';

  ThemeNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  void toggle(bool val) {
    state = val;
    _prefs.setBool(_key, val);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

// ── Settings Providers (persisted) ───────────────────────────────────
class _StringPrefNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;
  final String _key;
  _StringPrefNotifier(this._prefs, this._key, String def)
      : super(_prefs.getString(_key) ?? def);
  void set(String v) { state = v; _prefs.setString(_key, v); }
}

class _BoolPrefNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  final String _key;
  _BoolPrefNotifier(this._prefs, this._key, bool def)
      : super(_prefs.getBool(_key) ?? def);
  void set(bool v) { state = v; _prefs.setBool(_key, v); }
}

final videoQualityProvider = StateNotifierProvider<_StringPrefNotifier, String>((ref) {
  return _StringPrefNotifier(ref.watch(sharedPreferencesProvider), 'video_quality', 'HD');
});

final wifiOnlyProvider = StateNotifierProvider<_BoolPrefNotifier, bool>((ref) {
  return _BoolPrefNotifier(ref.watch(sharedPreferencesProvider), 'wifi_only', true);
});

final notificationsEnabledProvider = StateNotifierProvider<_BoolPrefNotifier, bool>((ref) {
  return _BoolPrefNotifier(ref.watch(sharedPreferencesProvider), 'notifications', true);
});

final newMonumentsProvider = StateNotifierProvider<_BoolPrefNotifier, bool>((ref) {
  return _BoolPrefNotifier(ref.watch(sharedPreferencesProvider), 'notif_new', true);
});

final specialOffersProvider = StateNotifierProvider<_BoolPrefNotifier, bool>((ref) {
  return _BoolPrefNotifier(ref.watch(sharedPreferencesProvider), 'notif_offers', false);
});
