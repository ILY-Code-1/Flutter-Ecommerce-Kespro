import 'package:get/get.dart';
import 'request_order_controller.dart';

class RequestOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestOrderController>(() => RequestOrderController());
  }
}
