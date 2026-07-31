import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';

/// Custom GoRouter page transitions — fade + subtle slide.
class EngHossamPageTransitions {
  EngHossamPageTransitions._();

  /// Fade + slight upward slide (default site feel).
  static CustomTransitionPage<T> fadeSlide<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = AppConstants.animNormal,
    Offset beginOffset = const Offset(0, 0.04),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Horizontal slide from the right (drill-in pages).
  static CustomTransitionPage<T> slideFromRight<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = AppConstants.animNormal,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Soft scale + fade for modals / overlays.
  static CustomTransitionPage<T> scaleFade<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = AppConstants.animNormal,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

/// Convenience builder for GoRouter `pageBuilder`.
Page<void> buildFadeSlidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return EngHossamPageTransitions.fadeSlide(
    key: state.pageKey,
    child: child,
  );
}
