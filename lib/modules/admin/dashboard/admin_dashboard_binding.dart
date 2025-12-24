import 'package:get/get.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // permanent: true agar controller tidak dihapus saat navigate ke halaman lain
    Get.put<AdminDashboardController>(AdminDashboardController(), permanent: true);
  }
}
