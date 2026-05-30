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

class _StoreMapContentState extends State<StoreMapContent> {
  final _mapController = MapController();
  bool _fitted = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _fitBoundsIfNeeded();

    final distance = widget.userLatLng != null
        ? LocationUtils.calculateDistance(
            widget.userLatLng!.latitude,
            widget.userLatLng!.longitude,
            widget.storeLatLng.latitude,
            widget.storeLatLng.longitude,
          )
        : null;

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
            MarkerLayer(
              markers: [
                if (widget.userLatLng != null)
                  Marker(
                    point: widget.userLatLng!,
                    child: const _UserMarker(),
                  ),
                Marker(
                  point: widget.storeLatLng,
                  child: const _StoreMarker(),
                ),
              ],
            ),
          ],
        ),

        Positioned(
          top: MediaQuery.paddingOf(context).top + 8.h,
          left: 8.w,
          child: _BackButton(),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: StoreMapInfoSheet(
            storeName: widget.storeName,
            storeAddress: widget.storeAddress,
            storePhone: widget.storePhone,
            distance: distance,
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
            bounds: LatLngBounds(widget.userLatLng!, widget.storeLatLng),
            padding: EdgeInsets.all(60.w),
          ),
        );
      }
      _fitted = true;
    });
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: const BoxDecoration(
            color: Color(0xFF2196F3),
            shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 3)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
          ),
          child: Text(
            'Vous êtes ici',
            style: AppTextStyles.labelSmall(color: const Color(0xFF2196F3)),
          ),
        ),
      ],
    );
  }
}

class _StoreMarker extends StatelessWidget {
  const _StoreMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, size: 40.sp, color: AppColors.primary),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
          ),
          child: Text(
            'Magasin',
            style: AppTextStyles.labelSmall(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12.r),
      color: context.colorScheme.surface,
      child: InkWell(
        onTap: () => GoRouter.of(context).pop(),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          child: Icon(Icons.arrow_back_rounded, size: 22.sp),
        ),
      ),
    );
  }
}
