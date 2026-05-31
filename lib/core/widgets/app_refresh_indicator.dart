import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_theme.dart';

/// Brand-styled pull-to-refresh with "Actualisation…" text.
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: context.colorScheme.surface,
      displacement: 60,
      onRefresh: onRefresh,
      child: Stack(
        children: [
          child,
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Text(
                  'Actualisation…',
                  style: AppTextStyles.labelSmall(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
