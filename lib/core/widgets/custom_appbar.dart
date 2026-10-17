import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

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
      elevation: 0,
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      actions: [
        if (showSearchToggle && showSearchBar != null && onSearchToggle != null)
          Obx(
            () => IconButton(
              icon: Icon(showSearchBar!.value ? Icons.close : Icons.search),
              onPressed: onSearchToggle,
              tooltip: 'Search',
            ),
          ),
        if (showProfileIcon)
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed(AppRoutes.settings),
            tooltip: 'Profile',
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
