import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/utils/sizer.dart';
import 'store_map_info_sheet.dart';

class StoreMapContent extends StatefulWidget {
  const StoreMapContent({
    super.key,
    required this.storeLatLng,
    required this.userLatLng,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
  });

  final LatLng storeLatLng;
  final LatLng? userLatLng;
  final String storeName;
  final String storeAddress;
  final String storePhone;

  @override
  State<StoreMapContent> createState() => _StoreMapContentState();
}

class _StoreMapContentState extends State<StoreMapContent>
    with TickerProviderStateMixin {
  final _mapController = MapController();
  bool _fitted = false;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _fitBoundsIfNeeded();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final distance = widget.userLatLng != null
        ? LocationUtils.calculateDistance(
            widget.userLatLng!.latitude,
            widget.userLatLng!.longitude,
            widget.storeLatLng.latitude,
            widget.storeLatLng.longitude,
          )
        : null;

    final isDark = context.isDark;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.storeLatLng,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.soukconnect.app',
            ),
            if (widget.userLatLng != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [widget.userLatLng!, widget.storeLatLng],
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.4),
                    strokeWidth: 2,
                    isDotted: true,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (widget.userLatLng != null)
                  Marker(
                    point: widget.userLatLng!,
                    width: 80.w,
                    height: 80.w,
                    child: _UserMarker(pulseCtrl: _pulseCtrl),
                  ),
                Marker(
                  point: widget.storeLatLng,
                  width: 80.w,
                  height: 100.h,
                  child: _StoreMarker(name: widget.storeName),
                ),
              ],
            ),
          ],
        ),

        // Dark overlay for dark mode
        if (isDark)
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),

        // Back button
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8.h,
          left: 8.w,
          child: _MapButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => GoRouter.of(context).pop(),
          ),
        ),

        // Compass button
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8.h,
          right: 8.w,
          child: _MapButton(
            icon: Icons.north_rounded,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom,
            ),
          ),
        ),

        // Zoom controls
        Positioned(
          right: 8.w,
          top: MediaQuery.paddingOf(context).top + 64.h,
          child: Column(
            children: [
              _MapButton(
                icon: Icons.add_rounded,
                onTap: () => _mapController.move(
                  _mapController.camera.center,
                  (_mapController.camera.zoom + 0.5).clamp(3.0, 18.0),
                ),
              ),
              SizedBox(height: 8.h),
              _MapButton(
                icon: Icons.remove_rounded,
                onTap: () => _mapController.move(
                  _mapController.camera.center,
                  (_mapController.camera.zoom - 0.5).clamp(3.0, 18.0),
                ),
              ),
            ],
          ),
        ),

        // Bottom sheet
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: StoreMapInfoSheet(
            storeName: widget.storeName,
            storeAddress: widget.storeAddress,
            storePhone: widget.storePhone,
            distance: distance,
            storeLatLng: widget.storeLatLng,
          ),
        ),
      ],
    );
  }

  void _fitBoundsIfNeeded() {
    if (_fitted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.userLatLng != null) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds:
                LatLngBounds(widget.userLatLng!, widget.storeLatLng),
            padding: EdgeInsets.all(60.w),
          ),
        );
      }
      _fitted = true;
    });
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12.r),
      color: context.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          child: Icon(icon, size: 22.sp),
        ),
      ),
    );
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker({required this.pulseCtrl});

  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, __) {
        return SizedBox(
          width: 80.w,
          height: 80.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50.w * (0.8 + pulseCtrl.value * 0.4),
                height: 50.w * (0.8 + pulseCtrl.value * 0.4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 20.w,
                height: 20.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2196F3),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoreMarker extends StatelessWidget {
  const _StoreMarker({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.store_rounded,
              size: 22, color: Colors.white),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.r),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4),
            ],
          ),
          child: Text(
            name,
            style: AppTextStyles.labelSmall(color: AppColors.primary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
