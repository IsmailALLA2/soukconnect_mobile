import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

class StoreMapInfoSheet extends StatelessWidget {
  const StoreMapInfoSheet({
    super.key,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    this.distance,
    required this.storeLatLng,
  });

  final String storeName;
  final String storeAddress;
  final String storePhone;
  final double? distance;
  final LatLng storeLatLng;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.28,
      minChildSize: 0.12,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              20.w, 12.h, 20.w,
              MediaQuery.paddingOf(context).bottom + 12.h,
            ),
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryDiagonal,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      storeName.isNotEmpty ? storeName[0].toUpperCase() : 'S',
                      style: AppTextStyles.titleMedium(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: AppTextStyles.titleSmall(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          storeAddress,
                          style: AppTextStyles.bodySmall(
                            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (distance != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${distance!.toStringAsFixed(1)} km',
                        style: AppTextStyles.labelSmall(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              if (distance != null) ...[
                Row(
                  children: [
                    _DurationTile(
                      icon: Icons.directions_walk_rounded,
                      label: 'À pied',
                      duration: _formatDuration((distance! / 5) * 60),
                    ),
                    SizedBox(width: 8.w),
                    _DurationTile(
                      icon: Icons.directions_car_rounded,
                      label: 'En voiture',
                      duration: _formatDuration((distance! / 40) * 60),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],
              _InfoRow(
                icon: Icons.location_on_rounded,
                child: Text(
                  storeAddress,
                  style: AppTextStyles.bodyMedium(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              _InfoRow(
                icon: Icons.phone_rounded,
                child: GestureDetector(
                  onTap: () => _launchPhone(context),
                  child: Text(
                    storePhone,
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.primary,
                    ).copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton.icon(
                  onPressed: () => _openGoogleMaps(context),
                  icon: const Icon(Icons.map_rounded),
                  label: Text("Itinéraire Google Maps"),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(double minutes) {
    final mins = minutes.round();
    if (mins < 60) return '${mins} min';
    return '${mins ~/ 60}h ${mins % 60}min';
  }

  Future<void> _launchPhone(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: storePhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openGoogleMaps(BuildContext context) async {
    final uri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/dir/',
      queryParameters: {
        'api': '1',
        'destination': '${storeLatLng.latitude},${storeLatLng.longitude}',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.child});
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: context.colorScheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16.sp, color: AppColors.grey500),
          ),
          SizedBox(width: 8.w),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DurationTile extends StatelessWidget {
  const _DurationTile({
    required this.icon,
    required this.label,
    required this.duration,
  });
  final IconData icon;
  final String label;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: context.colorScheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: context.colorScheme.onSurface),
            SizedBox(width: 6.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  duration,
                  style: AppTextStyles.bodySmall(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
