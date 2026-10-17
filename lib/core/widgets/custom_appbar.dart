import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearchToggle;
  final RxBool? showSearchBar;
  final VoidCallback? onSearchToggle;
  final bool showProfileIcon;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showSearchToggle = false,
    this.showSearchBar,
    this.onSearchToggle,
    this.showProfileIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Text(title, style: AppTheme.light.textTheme.titleLarge),
      actions: [
        if (showSearchToggle && showSearchBar != null && onSearchToggle != null)
          Obx(
            () => IconButton(
              icon: Icon(
                showSearchBar!.value ? Icons.close : Icons.search,
                color: AppColors.primary,
              ),
              onPressed: onSearchToggle,
              tooltip: 'Search',
            ),
          ),
        if (showProfileIcon)
          IconButton(
            icon: Icon(Icons.person, color: AppColors.primary),
            onPressed: () => Get.toNamed(AppRoutes.settings),
            tooltip: 'Profile',
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
