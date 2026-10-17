import 'package:get/get.dart';
import '../../data/repositories/challenge_repository.dart';
import '../controllers/challenges_controller.dart';

class ChallengesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChallengesController>(() => ChallengesController(ChallengeRepository()));
  }
}
