import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

/// The route to open once the splash animation and pause have finished.
/// Registered in main() before runApp.
class PostSplashRoute {
  final String name;

  /// Runs after navigation, for example to follow a notification that launched the app.
  final VoidCallback? afterNavigation;

  const PostSplashRoute(this.name, {this.afterNavigation});
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
    _controller.forward().whenComplete(_continue);
  }

  Future<void> _continue() async {
    await Future<void>.delayed(_hold);
    if (!mounted) return;
    final next = Get.find<PostSplashRoute>();
    Get.offAllNamed(next.name);
    next.afterNavigation?.call();
  }

  @override
  void dispose() {
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
