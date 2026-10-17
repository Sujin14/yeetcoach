import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../navigation/app_page_route.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static const _cardShadow = Color(0x0D000000);
  static const _cardRadius = 12.0;
  static const _inputRadius = 8.0;
  static const _buttonRadius = 24.0;

  static final ThemeData light = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSurface,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      outline: AppColors.divider,
      outlineVariant: AppColors.divider,
    );

    final baseTheme = ThemeData(useMaterial3: true, colorScheme: colorScheme);
    final textTheme = _buildTextTheme(baseTheme.textTheme);

    OutlineInputBorder inputBorder(Color color, {double width = 1}) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: color, width: width),
        );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      textTheme: textTheme,
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shadowColor: _cardShadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.subtle),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.subtle),
        border: inputBorder(AppColors.divider),
        enabledBorder: inputBorder(AppColors.divider),
        focusedBorder: inputBorder(AppColors.primary, width: 1.5),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error, width: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: AppSpacing.lg),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  /// Inter for every style. Core scale: displayLarge for big metric numbers,
  /// titleMedium for card titles, bodyMedium for labels, bodySmall for captions.
  // Per-style GoogleFonts.inter is used because google_fonts' interTextTheme
  // returns material_ui's TextTheme, which is a different type from Flutter's.
  static TextTheme _buildTextTheme(TextTheme base) {
    TextStyle inter(TextStyle? style, {double? size, FontWeight? weight}) => GoogleFonts.inter(
          textStyle: style,
          fontSize: size ?? style?.fontSize,
          fontWeight: weight ?? style?.fontWeight,
        );

    return base
        .copyWith(
          displayLarge: inter(base.displayLarge, size: 32, weight: FontWeight.w700),
          displayMedium: inter(base.displayMedium),
          displaySmall: inter(base.displaySmall),
          headlineLarge: inter(base.headlineLarge, weight: FontWeight.w700),
          headlineMedium: inter(base.headlineMedium, weight: FontWeight.w700),
          headlineSmall: inter(base.headlineSmall, weight: FontWeight.w700),
          titleLarge: inter(base.titleLarge, weight: FontWeight.w700),
          titleMedium: inter(base.titleMedium, size: 16, weight: FontWeight.w600),
          titleSmall: inter(base.titleSmall, weight: FontWeight.w600),
          bodyLarge: inter(base.bodyLarge),
          bodyMedium: inter(base.bodyMedium, size: 14, weight: FontWeight.w400),
          bodySmall: inter(base.bodySmall, size: 12, weight: FontWeight.w400),
          labelLarge: inter(base.labelLarge),
          labelMedium: inter(base.labelMedium),
          labelSmall: inter(base.labelSmall),
        )
        .apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface);
  }
}
