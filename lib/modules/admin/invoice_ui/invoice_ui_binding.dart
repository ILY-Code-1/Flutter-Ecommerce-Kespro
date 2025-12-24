import 'package:get/get.dart';
import 'invoice_ui_controller.dart';

class InvoiceUIBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceUIController>(() => InvoiceUIController());
  }
}
