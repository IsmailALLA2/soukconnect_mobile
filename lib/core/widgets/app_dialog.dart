import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_theme.dart';
import '../utils/sizer.dart';

enum DialogType { danger, warning, info }

class AppDialog {
  AppDialog._();

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    DialogType type = DialogType.danger,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => _AnimatedConfirmDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        type: type,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
  }
}

class _AnimatedConfirmDialog extends StatefulWidget {
  const _AnimatedConfirmDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.type,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;
  final DialogType type;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_AnimatedConfirmDialog> createState() => _AnimatedConfirmDialogState();
}

class _AnimatedConfirmDialogState extends State<_AnimatedConfirmDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(widget.type);
    final icon = _icon(widget.type);
    final isDark = context.isDark;

    return FadeTransition(
      opacity: _fade,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
          surfaceTintColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                widget.title,
                style: AppTextStyles.titleMedium(
                  color: context.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                widget.message,
                style: AppTextStyles.bodyMedium(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(widget.cancelLabel),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            Navigator.of(context).pop(true);
                            widget.onConfirm();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: Text(
                              widget.confirmLabel,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelLarge(color: AppColors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _color(DialogType type) => switch (type) {
        DialogType.danger => AppColors.error,
        DialogType.warning => AppColors.warning,
        DialogType.info => AppColors.info,
      };

  IconData _icon(DialogType type) => switch (type) {
        DialogType.danger => Icons.error_outline_rounded,
        DialogType.warning => Icons.warning_amber_rounded,
        DialogType.info => Icons.info_outline_rounded,
      };
}
