import 'package:get/get.dart';
import 'package:yeetcoach/features/clients/data/repositories/client_profile_repository.dart';
import 'package:yeetcoach/features/coach/data/repositories/coach_repository.dart';
import 'package:yeetcoach/features/training/data/repositories/training_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../controllers/coach_dashboard_controller.dart';

class CoachDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoachDashboardController>(
      () => CoachDashboardController(
        TrainingRepository(),
        ClientProfileRepository(),
        CoachRepository(),
        DashboardRepository(),
      ),
    );
  }
}
