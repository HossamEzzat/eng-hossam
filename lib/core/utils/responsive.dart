import 'package:flutter/material.dart';

/// Breakpoint helpers for Eng. Hossam responsive layouts.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

class Responsive {
  Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= Breakpoints.mobile && width < Breakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

  /// True for tablet or larger (≥ 600).
  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.mobile;

  /// True for desktop-ish (≥ 900).
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Pick a value based on screen size.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= Breakpoints.desktop) return desktop;
    if (w >= Breakpoints.mobile) return tablet ?? desktop;
    return mobile;
  }
}

extension ResponsiveContext on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  bool get isWide => Responsive.isWide(this);
  bool get isTabletOrLarger => Responsive.isTabletOrLarger(this);
}
