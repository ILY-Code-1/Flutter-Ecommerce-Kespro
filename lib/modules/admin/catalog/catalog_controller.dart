import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/catalog_model.dart';
import '../../../data/repositories/catalog_repository.dart';

/// Controller untuk mengelola state katalog (Admin only untuk CRUD)
/// 
/// Access Control:
/// - READ: Public & Admin
/// - CREATE/UPDATE/DELETE: Admin only
class CatalogController extends GetxController {
  final CatalogRepository _repository = CatalogRepository();

  // State management
  final catalogItems = <CatalogModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  // Form fields untuk add/edit
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Image state
  final selectedImageUrl = RxnString(); // URL gambar yang sudah ada (untuk edit)
  final selectedFileName = RxnString(); // Nama file yang dipilih
  final selectedFileBytes = Rxn<Uint8List>(); // Bytes file yang dipilih

  // Currently editing item
  final editingItemId = RxnString();
  final editingImageUrl = RxnString(); // URL gambar lama saat edit

  @override
  void onInit() {
    super.onInit();
    fetchCatalogs();
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// Fetch semua katalog dari Supabase
  Future<void> fetchCatalogs() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final items = await _repository.fetchAll();
      catalogItems.assignAll(items);
    } catch (e) {
      errorMessage.value = e.toString();
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate ke halaman tambah katalog
  void goToAddCatalog() {
    clearForm();
    Get.toNamed(AppRoutes.catalogAdd);
  }

  /// Navigate ke halaman detail/edit katalog
  void goToDetailCatalog(CatalogModel item) {
    clearForm();
    editingItemId.value = item.id;
    nameController.text = item.name;
    priceController.text = item.priceEstimation.toStringAsFixed(0);
    descriptionController.text = item.description ?? '';
    selectedImageUrl.value = item.imageUrl;
    editingImageUrl.value = item.imageUrl; // Simpan URL lama
    Get.toNamed(AppRoutes.catalogDetail);
  }

  /// Pick image menggunakan file_picker
  Future<void> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Penting untuk web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.bytes != null) {
          // Validasi ukuran file (max 5MB)
          if (file.bytes!.length > 5 * 1024 * 1024) {
            _showErrorSnackbar('Ukuran file maksimal 5MB');
            return;
          }

          selectedFileName.value = file.name;
          selectedFileBytes.value = file.bytes;
          selectedImageUrl.value = null; // Clear URL lama jika ada file baru

          _showSuccessSnackbar('Gambar berhasil dipilih: ${file.name}');
        }
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memilih gambar: $e');
    }
  }

  /// Remove selected image
  void removeImage() {
    selectedFileName.value = null;
    selectedFileBytes.value = null;
    selectedImageUrl.value = null;
  }

  /// Tambah katalog baru (Admin only)
  Future<void> addCatalog() async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;

      // Parse harga
      final price = double.tryParse(
        priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      ) ?? 0;

      // Upload gambar jika ada
      String? imageUrl;
      if (selectedFileBytes.value != null && selectedFileName.value != null) {
        imageUrl = await _repository.uploadImage(
          fileName: selectedFileName.value!,
          fileBytes: selectedFileBytes.value!,
        );
      }

      // Create catalog
      final newItem = await _repository.create(
        name: nameController.text.trim(),
        priceEstimation: price,
        imageUrl: imageUrl,
        description: descriptionController.text.trim().isNotEmpty 
            ? descriptionController.text.trim() 
            : null,
      );

      catalogItems.insert(0, newItem);
      clearForm();
      
      // Kembali ke daftar katalog
      Get.offNamed(AppRoutes.catalog);
      _showSuccessSnackbar('Katalog berhasil ditambahkan');
    } catch (e) {
      _showErrorSnackbar('Gagal menambah katalog: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Update katalog (Admin only)
  Future<void> updateCatalog() async {
    if (!_validateForm()) return;
    if (editingItemId.value == null) return;

    try {
      isSaving.value = true;

      // Parse harga
      final price = double.tryParse(
        priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      ) ?? 0;

      // Handle image upload/update
      String? imageUrl = selectedImageUrl.value;
      
      if (selectedFileBytes.value != null && selectedFileName.value != null) {
        // Upload gambar baru dan hapus yang lama
        imageUrl = await _repository.updateImage(
          oldImageUrl: editingImageUrl.value,
          fileName: selectedFileName.value!,
          fileBytes: selectedFileBytes.value!,
        );
      }

      // Update catalog
      final updatedItem = await _repository.update(
        id: editingItemId.value!,
        name: nameController.text.trim(),
        priceEstimation: price,
        imageUrl: imageUrl,
        description: descriptionController.text.trim().isNotEmpty 
            ? descriptionController.text.trim() 
            : null,
      );

      final index = catalogItems.indexWhere((item) => item.id == editingItemId.value);
      if (index != -1) {
        catalogItems[index] = updatedItem;
      }

      clearForm();
      
      // Kembali ke daftar katalog
      Get.offNamed(AppRoutes.catalog);
      _showSuccessSnackbar('Katalog berhasil diupdate');
    } catch (e) {
      _showErrorSnackbar('Gagal mengupdate katalog: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Hapus katalog dengan konfirmasi (Admin only)
  void deleteCatalog(CatalogModel item) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 36,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hapus Katalog',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus "${item.name}"?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmDelete(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ya, Hapus',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Execute soft delete after confirmation
  Future<void> _confirmDelete(CatalogModel item) async {
    try {
      Get.back(); // Close dialog
      isLoading.value = true;
      await _repository.softDelete(item.id);
      catalogItems.removeWhere((i) => i.id == item.id);
      _showSuccessSnackbar('Katalog berhasil dihapus');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle status aktif katalog
  Future<void> toggleCatalogActive(CatalogModel item) async {
    try {
      isLoading.value = true;
      final updatedItem = await _repository.toggleActive(item.id, !item.isActive);
      final index = catalogItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        catalogItems[index] = updatedItem;
      }
      _showSuccessSnackbar(
        updatedItem.isActive 
          ? 'Katalog diaktifkan' 
          : 'Katalog dinonaktifkan'
      );
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Check apakah ada gambar yang dipilih atau URL gambar
  bool get hasImage => 
      selectedFileBytes.value != null || 
      (selectedImageUrl.value != null && selectedImageUrl.value!.isNotEmpty);

  /// Get display name untuk gambar
  String? get imageDisplayName {
    if (selectedFileName.value != null) return selectedFileName.value;
    if (selectedImageUrl.value != null) return 'Gambar tersimpan';
    return null;
  }

  /// Clear form fields
  void clearForm() {
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    selectedImageUrl.value = null;
    selectedFileName.value = null;
    selectedFileBytes.value = null;
    editingItemId.value = null;
    editingImageUrl.value = null;
  }

  /// Cancel dan kembali
  void cancel() {
    clearForm();
    Get.back();
  }

  /// Validate form fields
  bool _validateForm() {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nama dan harga produk harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
      return false;
    }
    return true;
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Sukses',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade700,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade700,
    );
  }
}
