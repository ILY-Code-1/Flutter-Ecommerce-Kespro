import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/rental_schedule_model.dart';
import '../../../data/repositories/schedule_repository.dart';

/// Controller untuk mengelola state Jadwal Sewa di Admin Dashboard
/// 
/// Access Control:
/// - READ: Public & Admin
/// - CREATE/UPDATE/DELETE: Admin only (for future extension)
class ScheduleController extends GetxController {
  final ScheduleRepository _repository = ScheduleRepository();

  // State management
  final schedules = <RentalScheduleModel>[].obs;
  final activeSchedules = <RentalScheduleModel>[].obs;
  final upcomingSchedules = <RentalScheduleModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // Filter state
  final selectedCatalogId = RxnString();
  final selectedDateRange = Rxn<DateTimeRange>();

  @override
  void onInit() {
    super.onInit();
    fetchAllSchedules();
  }

  /// Fetch semua jadwal sewa (Public & Admin)
  Future<void> fetchAllSchedules() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final items = await _repository.fetchAll();
      schedules.assignAll(items);
    } catch (e) {
      errorMessage.value = e.toString();
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch jadwal aktif saat ini (Public & Admin)
  Future<void> fetchActiveSchedules() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchActive();
      activeSchedules.assignAll(items);
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch jadwal mendatang (Public & Admin)
  Future<void> fetchUpcomingSchedules() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchUpcoming();
      upcomingSchedules.assignAll(items);
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter berdasarkan katalog
  Future<void> filterByCatalog(String? catalogId) async {
    selectedCatalogId.value = catalogId;
    if (catalogId == null) {
      fetchAllSchedules();
      return;
    }

    try {
      isLoading.value = true;
      final items = await _repository.fetchByCatalogId(catalogId);
      schedules.assignAll(items);
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter berdasarkan rentang tanggal
  Future<void> filterByDateRange(DateTimeRange? range) async {
    selectedDateRange.value = range;
    if (range == null) {
      fetchAllSchedules();
      return;
    }

    try {
      isLoading.value = true;
      final items = await _repository.fetchByDateRange(
        startDate: range.start,
        endDate: range.end,
      );
      schedules.assignAll(items);
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Check ketersediaan katalog (Public & Admin)
  Future<bool> checkAvailability({
    required String catalogId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _repository.checkAvailability(
        catalogId: catalogId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _showErrorSnackbar(e.toString());
      return false;
    }
  }

  /// Clear filters
  void clearFilters() {
    selectedCatalogId.value = null;
    selectedDateRange.value = null;
    fetchAllSchedules();
  }

  // ==========================================
  // Admin-only operations (for future extension)
  // ==========================================

  /// Create jadwal sewa baru (Admin only)
  Future<void> createSchedule({
    required String catalogId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      isLoading.value = true;
      
      // Check availability first
      final isAvailable = await checkAvailability(
        catalogId: catalogId,
        startDate: startDate,
        endDate: endDate,
      );

      if (!isAvailable) {
        _showErrorSnackbar('Katalog tidak tersedia pada tanggal tersebut');
        return;
      }

      final newSchedule = await _repository.create(
        catalogId: catalogId,
        startDate: startDate,
        endDate: endDate,
      );

      schedules.insert(0, newSchedule);
      _showSuccessSnackbar('Jadwal sewa berhasil dibuat');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Update status jadwal (Admin only)
  Future<void> updateScheduleStatus(String scheduleId, RentalStatus newStatus) async {
    try {
      isLoading.value = true;
      final updatedSchedule = await _repository.updateStatus(
        id: scheduleId,
        status: newStatus,
      );

      final index = schedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        schedules[index] = updatedSchedule;
      }

      _showSuccessSnackbar('Status jadwal berhasil diupdate');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete jadwal sewa (Admin only)
  void deleteSchedule(RentalScheduleModel schedule) {
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
                'Hapus Jadwal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus jadwal "${schedule.catalogName ?? 'ini'}"?',
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
                      onPressed: () => _confirmDelete(schedule),
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

  /// Execute delete after confirmation
  Future<void> _confirmDelete(RentalScheduleModel schedule) async {
    try {
      Get.back(); // Close dialog
      isLoading.value = true;
      await _repository.delete(schedule.id);
      schedules.removeWhere((s) => s.id == schedule.id);
      _showSuccessSnackbar('Jadwal berhasil dihapus');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
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
