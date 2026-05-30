import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../providers/location_provider.dart';
import '../providers/store_provider.dart';
import '../widgets/widgets.dart';

class StoreMapPage extends HookConsumerWidget {
  const StoreMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = GoRouterState.of(context).pathParameters['storeId']!;
    final storeAsync = ref.watch(storeDetailProvider(storeId));
    final locationAsync = ref.watch(locationNotifierProvider);

    return Scaffold(
      body: storeAsync.when(
        loading: () => const _MapLoading(),
        error: (e, _) => _MapError(message: e.toString()),
        data: (store) {
          if (!store.hasLocation) {
            return _NoLocationError(storeName: store.name);
          }

          final storeLatLng = LatLng(store.lat!, store.lng!);
          final userPos = locationAsync.valueOrNull;
          final userLatLng = userPos != null
              ? LatLng(userPos.latitude, userPos.longitude)
              : null;

          return StoreMapContent(
            storeLatLng: storeLatLng,
            userLatLng: userLatLng,
            storeName: store.name,
            storeAddress: store.address,
            storePhone: store.phone,
          );
        },
      ),
    );
  }
}

class _MapLoading extends StatelessWidget {
  const _MapLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _MapError extends StatelessWidget {
  const _MapError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                'Impossible de charger la carte',
                style: AppTextStyles.titleSmall(color: context.colorScheme.onSurface),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                style: AppTextStyles.bodyMedium(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoLocationError extends StatelessWidget {
  const _NoLocationError({required this.storeName});
  final String storeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_rounded, size: 48.sp, color: AppColors.grey400),
              SizedBox(height: 16.h),
              Text(
                storeName,
                style: AppTextStyles.titleSmall(color: context.colorScheme.onSurface),
              ),
              SizedBox(height: 8.h),
              Text(
                'Cette boutique n\'a pas encore défini sa position GPS.',
                style: AppTextStyles.bodyMedium(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
