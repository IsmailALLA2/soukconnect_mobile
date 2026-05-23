import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Locale provider — persists the selected locale via shared_preferences
// ─────────────────────────────────────────────────────────────────────────────

/// The SharedPreferences key used to persist the chosen locale.
const _kLocaleKey = 'app_locale';

/// All locales supported by the app.
const List<Locale> appSupportedLocales = [
  Locale('fr'), // French — default
  Locale('ar'), // Arabic
];

/// Default locale.
const Locale _defaultLocale = Locale('fr');

// ─── Notifier ────────────────────────────────────────────────────────────────

class LocaleNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLocaleKey);
    if (saved == null) return _defaultLocale;

    // Validate against supported locales.
    final match = appSupportedLocales.where((l) => l.languageCode == saved);
    return match.isNotEmpty ? match.first : _defaultLocale;
  }

  /// Switches the app locale and persists the choice.
  Future<void> setLocale(Locale locale) async {
    assert(
      appSupportedLocales.contains(locale),
      'Locale $locale is not in appSupportedLocales',
    );
    state = AsyncData(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  /// Toggles between fr ↔ ar (handy for a quick-switch button).
  Future<void> toggle() async {
    final current = state.valueOrNull ?? _defaultLocale;
    final next = current.languageCode == 'fr' ? const Locale('ar') : const Locale('fr');
    await setLocale(next);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Provides the current [Locale]. Watch this in [MaterialApp.locale].
final localeProvider = AsyncNotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
