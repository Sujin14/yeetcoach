import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

/// Full-screen photo with a dark scrim, the YeetCoach heading at the top,
/// and [child] followed by [footer] sitting directly on the photo at the bottom.
class AuthScaffold extends StatelessWidget {
  final Widget child;
  final Widget footer;
  final String? tagline;

  const AuthScaffold({
    super.key,
    required this.child,
    required this.footer,
    this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final textTheme = AppTheme.light.textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      // The photo sits outside the Scaffold so it doesn't resize when the keyboard opens.
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/coach_bg.webp', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 48.h, 24.w, 32.h),
                          child: Column(
                            children: [
                              Text(
                                'YeetCoach',
                                style: textTheme.titleLarge?.copyWith(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              if (tagline != null) ...[
                                SizedBox(height: 8.h),
                                Text(
                                  tagline!,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: screenHeight * 0.4),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 12.h + bottomInset),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              child,
                              SizedBox(height: 8.h),
                              footer,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
