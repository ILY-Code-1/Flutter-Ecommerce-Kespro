import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/order_repository.dart';

/// Controller untuk mengelola state Order dari landing page (Public user)
/// 
/// Access Control:
/// - CREATE: Public user only (from landing page)
/// - READ/UPDATE/DELETE: Handled by AdminOrderController
class OrderController extends GetxController {
  final OrderRepository _repository = OrderRepository();

  // Form fields
  final namaEO = ''.obs;
  final email = ''.obs;
  final selectedProducts = <String>[].obs;
  final tanggalMulai = Rxn<DateTime>();
  final lokasi = ''.obs;
  final durasi = ''.obs;
  final catatan = ''.obs;

  // State
  final isLoading = false.obs;
  final errorMessage = RxnString();

  final produkList = [
    'Backdrop',
    'Panggung',
    'Tenant/Booth',
    'Sound System',
    'Lighting',
    'Kursi & Meja',
    'Dekorasi',
    'Lainnya',
  ];

  final durasiList = [
    '1 Hari',
    '2-3 Hari',
    '1 Minggu',
    'Lebih dari 1 Minggu',
  ];

  /// Toggle product selection
  void toggleProduct(String product) {
    if (selectedProducts.contains(product)) {
      selectedProducts.remove(product);
    } else {
      selectedProducts.add(product);
    }
  }

  /// Submit order to Supabase (Public user - create order)
  Future<void> submitOrder() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      await _repository.create(
        customerName: namaEO.value,
        email: email.value,
        eventDate: tanggalMulai.value!,
        location: lokasi.value,
        duration: durasi.value,
        catalogItems: selectedProducts.toList(),
        totalPrice: 0, // Price calculated later by admin
        notes: catatan.value.isNotEmpty ? catatan.value : null,
      );

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
    if (namaEO.value.isEmpty) {
      _showError('Nama Event Organizer harus diisi');
      return false;
    }
    if (email.value.isEmpty) {
      _showError('Email harus diisi');
      return false;
    }
    if (selectedProducts.isEmpty) {
      _showError('Pilih minimal satu produk');
      return false;
    }
    if (tanggalMulai.value == null) {
      _showError('Tanggal mulai harus dipilih');
      return false;
    }
    if (lokasi.value.isEmpty) {
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
    namaEO.value = '';
    email.value = '';
    selectedProducts.clear();
    tanggalMulai.value = null;
    lokasi.value = '';
    durasi.value = '';
    catatan.value = '';
  }
}
