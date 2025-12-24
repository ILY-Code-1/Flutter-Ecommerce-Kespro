import 'package:get/get.dart';
import 'jadwal_sewa_controller.dart';

class JadwalSewaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JadwalSewaController>(() => JadwalSewaController());
  }
}
