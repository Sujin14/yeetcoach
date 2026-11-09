import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeetcoach/shared/widgets/shimmer_sweep.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: AppTheme.light.textTheme.labelLarge!.copyWith(
        color: AppColors.onPrimary,
      ),
    );

    return ElevatedButton(
      // Keep enabled colours while loading; ignore taps via empty callback.
      onPressed: isLoading ? () {} : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.onPrimary,
        foregroundColor: AppColors.onPrimary,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      ),
      child: isLoading
          ? ShimmerSweep(
              baseColor: AppColors.onPrimary.withValues(alpha: 0.45),
              highlightColor: AppColors.onPrimary,
              child: label,
            )
          : label,
    );
  }
}
