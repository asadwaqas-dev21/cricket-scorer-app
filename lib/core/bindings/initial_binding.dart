import 'package:get/get.dart';
import '../../features/app_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController(), permanent: true);
  }
}
