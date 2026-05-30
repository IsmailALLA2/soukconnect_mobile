import 'dart:math' as math;

// ─────────────────────────────────────────────────────────────────────────────
// LocationUtils — pure Dart geolocation helpers, no external packages
// ─────────────────────────────────────────────────────────────────────────────

abstract class LocationUtils {
  /// Earth's mean radius in kilometres.
  static const double _earthRadiusKm = 6371.0;

  /// Calculates the great-circle distance in kilometres between two GPS
  /// coordinates using the Haversine formula.
  ///
  /// All parameters are in decimal degrees.
  ///
  /// Accuracy: within ~0.5 % for distances up to 1 000 km — more than
  /// sufficient for the SoukConnect nearby-store radius.
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    // Convert degrees → radians
    final phi1    = _toRadians(lat1);
    final phi2    = _toRadians(lat2);
    final deltaPhi    = _toRadians(lat2 - lat1);
    final deltaLambda = _toRadians(lng2 - lng1);

    // Haversine formula
    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(deltaLambda / 2) *
            math.sin(deltaLambda / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  static double _toRadians(double degrees) => degrees * (math.pi / 180.0);
}
