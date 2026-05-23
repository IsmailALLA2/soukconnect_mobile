import 'package:flutter/material.dart';
import 'package:soukconnect_mobile/core/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BuildContext extensions
// ─────────────────────────────────────────────────────────────────────────────

extension ContextExtensions on BuildContext {
  // ── Screen dimensions ────────────────────────────────────────────────────

  /// Logical width of the current screen.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Logical height of the current screen.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // ── Theme helpers ─────────────────────────────────────────────────────────

  /// The nearest [ThemeData] in the widget tree.
  ThemeData get theme => Theme.of(this);

  /// Shortcut for [ThemeData.colorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Shortcut for [ThemeData.textTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns `true` when the current [ThemeData] brightness is dark.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── Localization ─────────────────────────────────────────────────────────

  /// Translates [key] using the nearest [AppLocalizations] delegate.
  ///
  /// Falls back to the key itself if no localization is found, so the UI
  /// never breaks during development.
  ///
  /// ```dart
  /// Text(context.tr('welcome_title'))
  /// ```
  /// Shortcut to the generated [AppLocalizations] instance.
  ///
  /// Use this for type-safe, IDE-autocompleted access:
  /// ```dart
  /// Text(context.l10n.login)
  /// ```
  AppLocalizations get l10n => AppLocalizations.of(this);

  // ── Navigation helpers ───────────────────────────────────────────────────

  /// Pops the current route off the navigator stack.
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Pushes a [route] onto the navigator stack.
  Future<T?> push<T>(Route<T> route) => Navigator.of(this).push(route);

  // ── Misc ─────────────────────────────────────────────────────────────────

  /// Device pixel ratio of the current window.
  double get pixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// Current [EdgeInsets] representing the system UI intrusions (notch, etc.).
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  /// Bottom safe-area height (useful above bottom nav bars).
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;
}
