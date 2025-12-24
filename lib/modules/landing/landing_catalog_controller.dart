import 'package:get/get.dart';
import '../../data/models/catalog_model.dart';
import '../../data/repositories/catalog_repository.dart';

/// Controller untuk menampilkan katalog di Landing Page
/// 
/// Access Control:
/// - READ only: Public (hanya katalog aktif)
class LandingCatalogController extends GetxController {
  final CatalogRepository _repository = CatalogRepository();

  // State management
  final catalogs = <CatalogModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchActiveCatalogs();
  }

  /// Fetch katalog aktif untuk ditampilkan di landing page
  Future<void> fetchActiveCatalogs() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final items = await _repository.fetchActiveForLandingPage();
      catalogs.assignAll(items);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh katalog
  Future<void> refreshCatalogs() async {
    await fetchActiveCatalogs();
  }
}
