import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ThemeMode provider — persists light/dark preference
// ─────────────────────────────────────────────────────────────────────────────

const _kThemeKey = 'app_theme_mode';

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    return _fromString(saved);
  }

  /// Sets and persists a specific [ThemeMode].
  Future<void> setMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, _toString(mode));
  }

  /// Toggles between light and dark (ignores system).
  Future<void> toggle() async {
    final current = state.valueOrNull ?? ThemeMode.system;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }

  /// Returns `true` when the active mode is dark.
  ///
  /// Falls back to the system brightness when mode is [ThemeMode.system].
  bool isDark(BuildContext context) {
    final mode = state.valueOrNull ?? ThemeMode.system;
    if (mode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static ThemeMode _fromString(String? value) => switch (value) {
        'light'  => ThemeMode.light,
        'dark'   => ThemeMode.dark,
        _        => ThemeMode.system,
      };

  static String _toString(ThemeMode mode) => switch (mode) {
        ThemeMode.light  => 'light',
        ThemeMode.dark   => 'dark',
        _                => 'system',
      };
}

/// Provides the current [ThemeMode]. Watch this in [MaterialApp.themeMode].
///
/// ```dart
/// // In MaterialApp:
/// themeMode: ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system,
///
/// // Toggle from a button:
/// ref.read(themeModeProvider.notifier).toggle();
/// ```
final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
