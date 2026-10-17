import 'package:get/get.dart';
import '../../data/repositories/challenge_repository.dart';
import '../controllers/challenge_detail_controller.dart';

class ChallengeDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChallengeDetailController>(() => ChallengeDetailController(ChallengeRepository()));
  }
}
