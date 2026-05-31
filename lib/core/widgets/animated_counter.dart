import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.targetValue,
    this.prefix,
    this.suffix,
    this.style,
    this.decimals = 0,
  });

  final double targetValue;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: targetValue),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          _format(value),
          style: style,
        );
      },
    );
  }

  String _format(double value) {
    final formatted = value.toStringAsFixed(decimals);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final withSpaces = intPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    final result =
        decimals > 0 ? '$withSpaces.${parts[1]}' : withSpaces;
    return '${prefix ?? ''}$result${suffix ?? ''}';
  }
}
