import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_theme.dart';
import '../utils/sizer.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = _color(type);
    final icon = _icon(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: _SnackbarContent(message: message, color: color, icon: icon),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          padding: EdgeInsets.zero,
          duration: duration,
        ),
      );
  }

  static Color _color(SnackbarType type) => switch (type) {
        SnackbarType.success => AppColors.success,
        SnackbarType.error => AppColors.error,
        SnackbarType.warning => AppColors.warning,
        SnackbarType.info => AppColors.info,
      };

  static IconData _icon(SnackbarType type) => switch (type) {
        SnackbarType.success => Icons.check_circle_rounded,
        SnackbarType.error => Icons.error_rounded,
        SnackbarType.warning => Icons.warning_amber_rounded,
        SnackbarType.info => Icons.info_rounded,
      };
}

class _SnackbarContent extends StatefulWidget {
  const _SnackbarContent({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  State<_SnackbarContent> createState() => _SnackbarContentState();
}

class _SnackbarContentState extends State<_SnackbarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 22.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    widget.message,
                    style: AppTextStyles.bodyMedium(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            AnimatedBuilder(
              animation: _progressCtrl,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: 1 - _progressCtrl.value,
                  backgroundColor: widget.color.withValues(alpha: 0.15),
                  color: widget.color,
                  minHeight: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
