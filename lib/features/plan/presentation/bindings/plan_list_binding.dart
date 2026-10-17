import 'package:get/get.dart';
import '../../data/datasources/firestore_plan_service.dart';
import '../../data/repositories/plan_repository_impl.dart';
import '../controllers/plan_list_controller.dart';

class PlanListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlanListController>(
      () => PlanListController(PlanRepositoryImpl(FirestorePlanService())),
    );
  }
}
