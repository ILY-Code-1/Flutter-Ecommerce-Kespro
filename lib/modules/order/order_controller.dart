import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/catalog_model.dart';
import '../../data/repositories/catalog_repository.dart';

/// Controller untuk mengelola state Order dari landing page (Public user)
class OrderController extends GetxController {
  final CatalogRepository _catalogRepository = CatalogRepository();
  final _supabase = Supabase.instance.client;

  // Form controllers
  final namaEOController = TextEditingController();
  final emailController = TextEditingController();
  final whatsappController = TextEditingController();
  final lokasiController = TextEditingController();
  final catatanController = TextEditingController();

  // Form fields (reactive)
  final tanggalMulai = Rxn<DateTime>();
  final durasi = ''.obs;
  final selectedCatalogIds = <String>{}.obs;

  // Data
  final catalogs = <CatalogModel>[].obs;
  final isLoadingCatalogs = false.obs;

  // State
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // Success data untuk halaman success
  final lastOrderData = Rxn<Map<String, dynamic>>();

  final durasiList = [
    '1 Hari',
    '2-3 Hari',
    '1 Minggu',
    'Lebih dari 1 Minggu',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadCatalogs();
    _checkPreselectedCatalog();
  }

  @override
  void onClose() {
    namaEOController.dispose();
    emailController.dispose();
    whatsappController.dispose();
    lokasiController.dispose();
    catatanController.dispose();
    super.onClose();
  }

  /// Load catalogs dari Supabase
  Future<void> _loadCatalogs() async {
    try {
      isLoadingCatalogs.value = true;
      final items = await _catalogRepository.fetchActiveForLandingPage();
      catalogs.assignAll(items);
    } catch (e) {
      debugPrint('Error loading catalogs: $e');
    } finally {
      isLoadingCatalogs.value = false;
    }
  }

  /// Check jika ada catalog yang di-preselect dari landing page
  void _checkPreselectedCatalog() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final catalogId = args['catalogId'] as String?;
      if (catalogId != null) {
        selectedCatalogIds.add(catalogId);
      }
    }
  }

  /// Toggle catalog selection
  void toggleCatalog(String catalogId) {
    if (selectedCatalogIds.contains(catalogId)) {
      selectedCatalogIds.remove(catalogId);
    } else {
      selectedCatalogIds.add(catalogId);
    }
  }

  /// Check if catalog is selected
  bool isCatalogSelected(String catalogId) {
    return selectedCatalogIds.contains(catalogId);
  }

  /// Get selected catalogs
  List<CatalogModel> get selectedCatalogs {
    return catalogs.where((c) => selectedCatalogIds.contains(c.id)).toList();
  }

  /// Calculate total estimation
  double get totalEstimation {
    return selectedCatalogs.fold(0, (sum, c) => sum + c.priceEstimation);
  }

  /// Format total as Rupiah
  String get formattedTotal {
    final formatted = totalEstimation.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  /// Validate WhatsApp number (Indonesian format)
  bool _isValidWhatsApp(String number) {
    // Remove spaces and dashes
    final cleaned = number.replaceAll(RegExp(r'[\s\-]'), '');
    
    // Check if starts with 08, +62, or 62
    if (cleaned.startsWith('08')) {
      return cleaned.length >= 10 && cleaned.length <= 13;
    }
    if (cleaned.startsWith('+62')) {
      return cleaned.length >= 12 && cleaned.length <= 15;
    }
    if (cleaned.startsWith('62')) {
      return cleaned.length >= 11 && cleaned.length <= 14;
    }
    return false;
  }

  /// Format WhatsApp to 62xxx format
  String _formatWhatsApp(String number) {
    final cleaned = number.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (cleaned.startsWith('08')) {
      return '62${cleaned.substring(1)}';
    }
    if (cleaned.startsWith('62')) {
      return cleaned;
    }
    return cleaned;
  }

  /// Submit order to Supabase
  Future<void> submitOrder() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final formattedWhatsapp = _formatWhatsApp(whatsappController.text);

      // Prepare data
      final orderData = {
        'nama_eo': namaEOController.text.trim(),
        'email': emailController.text.trim(),
        'whatsapp': formattedWhatsapp,
        'tanggal_mulai': tanggalMulai.value!.toIso8601String().split('T')[0],
        'lokasi': lokasiController.text.trim(),
        'durasi': durasi.value,
        'catatan': catatanController.text.trim().isNotEmpty 
            ? catatanController.text.trim() 
            : null,
        'catalog_ids': selectedCatalogIds.toList(),
        'total_estimation': totalEstimation,
        'status': 'masuk',
      };

      // Insert to Supabase
      final response = await _supabase
          .from('request_orders')
          .insert(orderData)
          .select()
          .single();

      // Store order data for success page
      lastOrderData.value = {
        'id': response['id'],
        'nama_eo': namaEOController.text.trim(),
        'email': emailController.text.trim(),
        'whatsapp': formattedWhatsapp,
        'tanggal_mulai': tanggalMulai.value,
        'lokasi': lokasiController.text.trim(),
        'durasi': durasi.value,
        'catatan': catatanController.text.trim(),
        'catalogs': selectedCatalogs.map((c) => {
          'name': c.name,
          'price': c.formattedPrice,
        }).toList(),
        'total': formattedTotal,
      };

      // Clear form
      clearForm();

      // Navigate to success page
      Get.toNamed('/success');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal mengirim order: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate form before submit
  bool _validateForm() {
    if (namaEOController.text.trim().isEmpty) {
      _showError('Nama Event Organizer harus diisi');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showError('Email harus diisi');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showError('Format email tidak valid');
      return false;
    }
    if (whatsappController.text.trim().isEmpty) {
      _showError('Nomor WhatsApp harus diisi');
      return false;
    }
    if (!_isValidWhatsApp(whatsappController.text.trim())) {
      _showError('Format nomor WhatsApp tidak valid.\nContoh: 08123456789 atau 6281234567890');
      return false;
    }
    if (selectedCatalogIds.isEmpty) {
      _showError('Pilih minimal satu produk');
      return false;
    }
    if (tanggalMulai.value == null) {
      _showError('Tanggal mulai harus dipilih');
      return false;
    }
    if (lokasiController.text.trim().isEmpty) {
      _showError('Lokasi harus diisi');
      return false;
    }
    if (durasi.value.isEmpty) {
      _showError('Durasi harus dipilih');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade700,
    );
  }

  /// Clear form fields
  void clearForm() {
    namaEOController.clear();
    emailController.clear();
    whatsappController.clear();
    lokasiController.clear();
    catatanController.clear();
    selectedCatalogIds.clear();
    tanggalMulai.value = null;
    durasi.value = '';
  }

  /// Generate WhatsApp message for success page
  String generateWhatsAppMessage() {
    final data = lastOrderData.value;
    if (data == null) return '';

    final catalogList = (data['catalogs'] as List)
        .map((c) => '• ${c['name']} (${c['price']})')
        .join('\n');

    final tanggal = data['tanggal_mulai'] as DateTime;
    final formattedDate = '${tanggal.day}/${tanggal.month}/${tanggal.year}';

    final message = '''
Halo Admin Kespro Event Hub! 👋

Saya ingin konfirmasi request order berikut:

📋 *DATA PEMESAN*
Nama: ${data['nama_eo']}
Email: ${data['email']}
WhatsApp: ${data['whatsapp']}

📦 *PRODUK YANG DIPESAN*
$catalogList

📍 *DETAIL EVENT*
Tanggal: $formattedDate
Lokasi: ${data['lokasi']}
Durasi: ${data['durasi']}
${data['catatan']?.isNotEmpty == true ? 'Catatan: ${data['catatan']}' : ''}

💰 *TOTAL ESTIMASI*
${data['total']}

Mohon informasi lebih lanjut mengenai ketersediaan dan proses selanjutnya. Terima kasih! 🙏
''';

    return Uri.encodeComponent(message.trim());
  }

  /// Get WhatsApp URL
  String getWhatsAppUrl(String adminNumber) {
    final message = generateWhatsAppMessage();
    return 'https://wa.me/$adminNumber?text=$message';
  }
}
