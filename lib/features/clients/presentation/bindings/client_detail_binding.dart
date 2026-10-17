import 'package:get/get.dart';
import 'package:yeetcoach/features/calls/data/repositories/call_repository.dart';
import 'package:yeetcoach/features/clients/data/repositories/client_insights_repository.dart';
import 'package:yeetcoach/features/clients/data/repositories/client_profile_repository.dart';
import 'package:yeetcoach/features/coach/data/repositories/coach_repository.dart';
import 'package:yeetcoach/features/training/data/repositories/training_repository.dart';
import '../controllers/client_detail_controller.dart';

class ClientDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientDetailController>(
      () => ClientDetailController(
        ClientProfileRepository(),
        CallRepository(),
        CoachRepository(),
        ClientInsightsRepository(),
        TrainingRepository(),
      ),
    );
  }
}
