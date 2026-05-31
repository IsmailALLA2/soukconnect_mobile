import 'package:flutter/material.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

class StoreEmptyState extends StatefulWidget {
  const StoreEmptyState({super.key, this.onExtendRadius});

  final VoidCallback? onExtendRadius;

  @override
  State<StoreEmptyState> createState() => _StoreEmptyStateState();
}

class _StoreEmptyStateState extends State<StoreEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pinCtrl;
  late final Animation<Offset> _pinDrop;

  @override
  void initState() {
    super.initState();
    _pinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pinDrop = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pinCtrl, curve: Curves.bounceOut));
    _pinCtrl.forward();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppAnimations.fadeSlideIn(
            child: AnimatedBuilder(
              animation: _pinDrop,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _pinDrop.value.dy * 80.h),
                child: Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryDiagonal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          AppAnimations.fadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Aucun grossiste trouvé',
              style: AppTextStyles.titleSmall(
                color: context.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8.h),
          AppAnimations.fadeSlideIn(
            delay: const Duration(milliseconds: 450),
            child: Text(
              'Vous êtes le premier dans votre région !',
              style: AppTextStyles.bodyMedium(color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 28.h),
          if (widget.onExtendRadius != null)
            AppAnimations.fadeSlideIn(
              delay: const Duration(milliseconds: 600),
              child: OutlinedButton.icon(
                onPressed: widget.onExtendRadius,
                icon: const Icon(Icons.zoom_out_map_rounded, size: 20),
                label: const Text('Élargir la zone de recherche'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
