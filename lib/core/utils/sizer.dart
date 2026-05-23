import 'package:flutter/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sizer — pure-Dart responsive utility
// Base design size: 390 × 844 (iPhone 14)
//
// Usage:
//   Wrap your MaterialApp with SizerInit:
//     SizerInit(child: MaterialApp(...))
//
//   Then use the num extensions anywhere:
//     16.sp  → responsive font size
//     24.w   → responsive width
//     48.h   → responsive height
//     12.r   → responsive radius / border-radius
// ─────────────────────────────────────────────────────────────────────────────

/// Base design canvas dimensions (iPhone 14 logical pixels).
const double _baseWidth = 390.0;
const double _baseHeight = 844.0;

/// Internal screen size cache — populated once by [SizerInit].
double _screenWidth = _baseWidth;
double _screenHeight = _baseHeight;

/// Initialises [_screenWidth] and [_screenHeight] from the current
/// [MediaQueryData]. Must be placed above [MaterialApp] in the widget tree.
class SizerInit extends StatefulWidget {
  const SizerInit({super.key, required this.child});

  final Widget child;

  @override
  State<SizerInit> createState() => _SizerInitState();
}

class _SizerInitState extends State<SizerInit> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Refresh cached values when the screen metrics change (rotation, etc.).
  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    if (mounted) {
      setState(() {
        _screenWidth = size.width;
        _screenHeight = size.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Prefer LayoutBuilder dimensions so we always have real values.
        if (constraints.maxWidth > 0) {
          _screenWidth = constraints.maxWidth;
        }
        if (constraints.maxHeight > 0) {
          _screenHeight = constraints.maxHeight;
        }
        return MediaQuery(
          data: MediaQuery.of(context),
          child: widget.child,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scale helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Horizontal scale factor (width-based).
double get _scaleW => _screenWidth / _baseWidth;

/// Vertical scale factor (height-based).
double get _scaleH => _screenHeight / _baseHeight;

/// Diagonal scale factor — used for font sizes & radii to stay balanced
/// on both portrait and landscape orientations.
double get _scaleDiag =>
    (_scaleW + _scaleH) / 2;

// ─────────────────────────────────────────────────────────────────────────────
// num extensions
// ─────────────────────────────────────────────────────────────────────────────

extension SizerExtension on num {
  /// Responsive **font size**.
  ///
  /// Scales proportionally to the average of width & height ratios so text
  /// remains legible on both small phones and tablets.
  ///
  /// ```dart
  /// Text('Hello', style: TextStyle(fontSize: 16.sp))
  /// ```
  double get sp => this * _scaleDiag;

  /// Responsive **width** — scales with the horizontal axis only.
  ///
  /// ```dart
  /// SizedBox(width: 24.w)
  /// ```
  double get w => this * _scaleW;

  /// Responsive **height** — scales with the vertical axis only.
  ///
  /// ```dart
  /// SizedBox(height: 48.h)
  /// ```
  double get h => this * _scaleH;

  /// Responsive **radius / border-radius** — uses the same diagonal scale
  /// as [sp] so rounded corners stay visually consistent.
  ///
  /// ```dart
  /// BorderRadius.circular(12.r)
  /// ```
  double get r => this * _scaleDiag;
}
