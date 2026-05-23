// ─────────────────────────────────────────────────────────────────────────────
// String extensions
// ─────────────────────────────────────────────────────────────────────────────

extension StringExtensions on String {
  // ── Validation ────────────────────────────────────────────────────────────

  /// Returns `true` for valid Moroccan mobile numbers.
  ///
  /// Accepted formats (with or without country code):
  ///   • `0612345678`
  ///   • `+212612345678`
  ///   • `00212612345678`
  ///
  /// Rules: starts with 06 or 07 (after stripping prefix), followed by
  /// exactly 8 digits.
  bool get isValidPhone {
    // Strip common whitespace / dashes used for readability.
    final cleaned = replaceAll(RegExp(r'[\s\-]'), '');

    const pattern =
        r'^(?:(?:\+|00)212|0)(6|7)\d{8}$';
    return RegExp(pattern).hasMatch(cleaned);
  }

  /// Returns `true` for a syntactically valid e-mail address.
  ///
  /// Follows RFC-5322 simplified rules — good enough for form validation.
  bool get isValidEmail {
    const pattern =
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(trim());
  }

  // ── Transformation ────────────────────────────────────────────────────────

  /// Returns the string with the very first character uppercased and the
  /// rest lowercased.
  ///
  /// ```dart
  /// 'hELLO wORLD'.capitalize // → 'Hello world'
  /// ```
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Returns the string with each word's first character uppercased.
  ///
  /// ```dart
  /// 'bonjour monde'.titleCase // → 'Bonjour Monde'
  /// ```
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((w) => w.capitalize).join(' ');
  }

  /// Converts Western/Latin digits (0-9) to their Eastern Arabic equivalents
  /// (٠–٩), commonly used in Moroccan Arabic UI.
  ///
  /// ```dart
  /// '2024'.toArabicNumbers // → '٢٠٢٤'
  /// ```
  String get toArabicNumbers {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic  = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    var result = this;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], arabic[i]);
    }
    return result;
  }

  /// Converts Eastern Arabic digits back to Western ones.
  ///
  /// ```dart
  /// '٢٠٢٤'.toWesternNumbers // → '2024'
  /// ```
  String get toWesternNumbers {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic  = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    var result = this;
    for (var i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], western[i]);
    }
    return result;
  }

  // ── Convenience ───────────────────────────────────────────────────────────

  /// `true` when [trim] produces an empty string.
  bool get isBlank => trim().isEmpty;

  /// `true` when [trim] is not empty.
  bool get isNotBlank => trim().isNotEmpty;

  /// Truncates the string to [maxLength] chars and appends [ellipsis] if
  /// truncation occurred.
  ///
  /// ```dart
  /// 'Long product name here'.truncate(10) // → 'Long produ…'
  /// ```
  String truncate(int maxLength, {String ellipsis = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
}
