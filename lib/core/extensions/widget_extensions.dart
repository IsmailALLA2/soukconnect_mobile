import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Widget extensions
// ─────────────────────────────────────────────────────────────────────────────
//
// All methods return a new Widget, making them chainable:
//
//   Text('Hello')
//     .paddingSymmetric(h: 16, v: 8)
//     .onTap(() => print('tapped'))
//     .center()
//
// ─────────────────────────────────────────────────────────────────────────────

extension WidgetExtensions on Widget {
  // ── Padding ───────────────────────────────────────────────────────────────

  /// Wraps the widget with uniform [Padding] on all sides.
  ///
  /// ```dart
  /// Icon(Icons.star).paddingAll(8)
  /// ```
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Wraps the widget with symmetric [Padding].
  ///
  /// ```dart
  /// Text('Label').paddingSymmetric(h: 16, v: 8)
  /// ```
  Widget paddingSymmetric({double h = 0, double v = 0}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
        child: this,
      );

  /// Wraps the widget with directional [Padding].
  ///
  /// ```dart
  /// Text('Label').paddingOnly(left: 12, top: 4)
  /// ```
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
        child: this,
      );

  // ── Layout ────────────────────────────────────────────────────────────────

  /// Centers the widget inside a [Center].
  ///
  /// ```dart
  /// CircularProgressIndicator().center()
  /// ```
  Widget center() => Center(child: this);

  /// Wraps the widget in an [Expanded] with the given [flex] value.
  ///
  /// ```dart
  /// TextField().expanded()
  /// TextField().expanded(flex: 2)
  /// ```
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Wraps the widget in a [Flexible] with the given [flex] value.
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) =>
      Flexible(flex: flex, fit: fit, child: this);

  /// Gives the widget a fixed size via [SizedBox].
  ///
  /// ```dart
  /// myWidget.sized(width: 100, height: 50)
  /// ```
  Widget sized({double? width, double? height}) =>
      SizedBox(width: width, height: height, child: this);

  /// Constrains the widget's width to [maxWidth].
  Widget maxWidth(double maxWidth) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: this,
      );

  // ── Gesture ───────────────────────────────────────────────────────────────

  /// Wraps the widget in a [GestureDetector] for tap events.
  ///
  /// Set [opaque] to `false` if you want tap events to pass through
  /// transparent areas.
  ///
  /// ```dart
  /// Text('Login').onTap(() => context.go('/login'))
  /// ```
  Widget onTap(
    VoidCallback onTap, {
    bool opaque = true,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior:
            opaque ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
        child: this,
      );

  /// Wraps the widget in an [InkWell] for a ripple tap effect.
  ///
  /// ```dart
  /// Card(...).inkWell(() => doSomething(), borderRadius: 12)
  /// ```
  Widget inkWell(
    VoidCallback onTap, {
    double? borderRadius,
    Color? splashColor,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: splashColor,
          borderRadius:
              borderRadius != null ? BorderRadius.circular(borderRadius) : null,
          child: this,
        ),
      );

  // ── Visibility ────────────────────────────────────────────────────────────

  /// Hides the widget (keeps it in the tree but invisible) when [visible] is
  /// `false`.
  Widget visible(bool visible) =>
      Visibility(visible: visible, child: this);

  /// Removes the widget from the layout entirely when [show] is `false`
  /// (equivalent to `Visibility(maintainSize: false)`).
  Widget showIf(bool show) =>
      Visibility(visible: show, maintainState: false, child: this);

  // ── Decoration ───────────────────────────────────────────────────────────

  /// Clips the widget to a rounded rectangle.
  ///
  /// ```dart
  /// Image.network(url).rounded(12)
  /// ```
  Widget rounded(double radius) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: this,
      );

  /// Wraps the widget in a [DecoratedBox] with the given [decoration].
  Widget decorated(BoxDecoration decoration) =>
      DecoratedBox(decoration: decoration, child: this);

  // ── Opacity ───────────────────────────────────────────────────────────────

  /// Applies an [Opacity] widget with the given [opacity] (0.0–1.0).
  Widget opacity(double opacity) =>
      Opacity(opacity: opacity.clamp(0.0, 1.0), child: this);
}
