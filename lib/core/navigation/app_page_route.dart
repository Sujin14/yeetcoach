import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The app's screen transition: a fade with a slight upward slide.
abstract final class AppPageTransition {
  static const duration = Duration(milliseconds: 250);
  static const curve = Curves.easeOut;

  static final _curveTween = CurveTween(curve: curve);
  static final _slideTween = Tween(begin: const Offset(0, 0.04), end: Offset.zero);

  /// [animation] is the route's uncurved 0→1 animation.
  static Widget build(Animation<double> animation, Widget child) {
    final curved = animation.drive(_curveTween);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: curved.drive(_slideTween), child: child),
    );
  }
}

/// A route using [AppPageTransition], for screens pushed with [Navigator] directly.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder, super.settings, super.fullscreenDialog})
      : super(
          transitionDuration: AppPageTransition.duration,
          reverseTransitionDuration: AppPageTransition.duration,
          pageBuilder: (context, _, _) => builder(context),
          transitionsBuilder: (_, animation, _, child) => AppPageTransition.build(animation, child),
        );
}

/// [AppPageTransition] for [PageTransitionsTheme], used by MaterialPageRoute-based navigation.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppPageTransition.duration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      AppPageTransition.build(animation, child);
}

/// [AppPageTransition] for GetX routes, which ignore [ThemeData.pageTransitionsTheme].
// GetPage routes default to a linear curve, so the animation arrives uncurved.
class AppGetTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      AppPageTransition.build(animation, child);
}
