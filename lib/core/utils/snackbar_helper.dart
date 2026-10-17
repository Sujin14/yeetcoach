import 'package:get/get.dart';
import '../theme/app_colors.dart';

void showErrorSnackbar(
  String message, {
  SnackPosition position = SnackPosition.BOTTOM,
}) {
  Get.snackbar(
    'Error',
    message,
    backgroundColor: AppColors.error,
    colorText: AppColors.onPrimary,
    snackPosition: position,
  );
}

void showSuccessSnackbar(
  String message, {
  SnackPosition position = SnackPosition.BOTTOM,
}) {
  Get.snackbar(
    'Success',
    message,
    backgroundColor: AppColors.primary,
    colorText: AppColors.onPrimary,
    snackPosition: position,
  );
}
