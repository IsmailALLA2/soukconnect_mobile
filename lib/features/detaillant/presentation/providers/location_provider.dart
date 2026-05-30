import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/failure.dart';

part 'location_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LocationNotifier — manages GPS permission + current position
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
class LocationNotifier extends _$LocationNotifier {
  @override
  Future<Position?> build() => _fetchLocation();

  // ── Public actions ────────────────────────────────────────────────────────

  /// Re-requests the current position (e.g. after the user grants permission
  /// or pulls to refresh on the NearbyStoresPage).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchLocation);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<Position?> _fetchLocation() async {
    // 1. Check device location services are on.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServicesDisabledFailure();
    }

    // 2. Check / request permission.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionDeniedFailure();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionPermanentlyDeniedFailure();
    }

    // 3. Fetch position — high accuracy for nearby-store radius calc.
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }
}
