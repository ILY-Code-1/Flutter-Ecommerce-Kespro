import 'package:get/get.dart';
import 'catalog_controller.dart';

/// Binding untuk modul Katalog - menginisialisasi CatalogController
class CatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatalogController>(() => CatalogController());
  }
}
