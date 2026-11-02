import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/services/call_accept_handler.dart';
import 'package:yeetcoach/core/services/call_native_service.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';

/// The route to open once the splash animation and pause have finished.
/// Registered in main() before runApp.
class PostSplashRoute {
  final String name;

  /// Runs after navigation, for example to follow a notification that launched the app.
  final VoidCallback? afterNavigation;

  PostSplashRoute(this.name, {this.afterNavigation});
}

/// First Flutter screen: logo, name and tagline animate in, then the app continues.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 1400);
  static const _hold = Duration(milliseconds: 800);

  late final AnimationController _controller;
  late final CurvedAnimation _logo;
  late final CurvedAnimation _title;
  late final CurvedAnimation _tagline;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _controller = AnimationController(vsync: this, duration: _total);
    _logo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 600 / 1400, curve: Curves.easeOut),
    );
    _title = CurvedAnimation(
      parent: _controller,
      curve: const Interval(400 / 1400, 900 / 1400, curve: Curves.easeOut),
    );
    _tagline = CurvedAnimation(
      parent: _controller,
      curve: const Interval(700 / 1400, 1100 / 1400, curve: Curves.easeOut),
    );
    CallNativeService.coldStartCall.addListener(_onColdStartCall);
    _leaveIfCallIsWaiting();
    _controller.forward().whenComplete(_continue);
  }

  void _onColdStartCall() {
    if (CallNativeService.coldStartCall.value != null) {
      _leave();
    }
  }

  /// A native Accept that launched the process should not wait on the splash animation.
  Future<void> _leaveIfCallIsWaiting() async {
    final pending =
        CallNativeService.coldStartCall.value ?? await CallNativeService.consumePendingAcceptedCall();
    if (pending == null) return;
    CallNativeService.coldStartCall.value ??= pending;
    _leave();
  }

  Future<void> _continue() async {
    await Future<void>.delayed(_hold);
    _leave();
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateAway());
  }

  /// Runs after the current frame so GetX navigation never hits a locked navigator.
  void _navigateAway() {
    if (!mounted) return;
    final next = Get.find<PostSplashRoute>();
    logDebug(
      '[YeetCall] splash leaving — coldStartCall=${CallNativeService.coldStartCall.value?.callId}',
    );
    Get.offAllNamed(next.name);
    CallNativeService.homeReady = true;

    final pending = CallNativeService.coldStartCall.value;
    if (next.name == AppRoutes.home && pending != null) {
      CallNativeService.coldStartCall.value = null;
      // Same post-frame callback as offAllNamed — no second deferral.
      handleAcceptedCall(pending);
      return;
    }

    // Coach isn't at home yet (login/onboarding) — drop the deferred accept.
    CallNativeService.coldStartCall.value = null;
    next.afterNavigation?.call();
  }

  @override
  void dispose() {
    CallNativeService.coldStartCall.removeListener(_onColdStartCall);
    _logo.dispose();
    _title.dispose();
    _tagline.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.splash,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _logo,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1).animate(_logo),
                  child: Image.asset(
                    'assets/images/yeetcoach_icon.png',
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeTransition(
                opacity: _title,
                child: AnimatedBuilder(
                  animation: _title,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, 20 * (1 - _title.value)),
                    child: child,
                  ),
                  child: Text(
                    'YeetCoach',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FadeTransition(
                opacity: _tagline,
                child: Text(
                  'Your coaching companion',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
