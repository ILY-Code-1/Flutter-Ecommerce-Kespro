import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

/// Enum untuk status jadwal sewa
enum RentalStatus {
  booking('Booking'),
  onAir('On Air'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const RentalStatus(this.label);
  
  static RentalStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'booking': return RentalStatus.booking;
      case 'on_air': return RentalStatus.onAir;
      case 'completed': return RentalStatus.completed;
      case 'cancelled': return RentalStatus.cancelled;
      default: return RentalStatus.booking;
    }
  }
  
  String get dbValue {
    switch (this) {
      case RentalStatus.booking: return 'booking';
      case RentalStatus.onAir: return 'on_air';
      case RentalStatus.completed: return 'completed';
      case RentalStatus.cancelled: return 'cancelled';
    }
  }
}

/// Model untuk Jadwal Sewa
class RentalScheduleModel {
  final String id;
  final String? requestOrderId;
  final String catalogId;
  final DateTime startDate;
  final DateTime endDate;
  final RentalStatus status;
  final String? customerName;
  final String? customerContact;
  final String? eventLocation;
  final String? notes;
  final DateTime createdAt;
  
  // Joined fields
  final String? catalogName;
  final String? catalogImage;
  final double? catalogPrice;
  final String? namaEO;
  final String? orderStatus;

  RentalScheduleModel({
    required this.id,
    this.requestOrderId,
    required this.catalogId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.customerName,
    this.customerContact,
    this.eventLocation,
    this.notes,
    required this.createdAt,
    this.catalogName,
    this.catalogImage,
    this.catalogPrice,
    this.namaEO,
    this.orderStatus,
  });

  factory RentalScheduleModel.fromJson(Map<String, dynamic> json) {
    return RentalScheduleModel(
      id: json['id'],
      requestOrderId: json['request_order_id'],
      catalogId: json['catalog_id'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: RentalStatus.fromString(json['status'] ?? 'booking'),
      customerName: json['customer_name'],
      customerContact: json['customer_contact'],
      eventLocation: json['event_location'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      catalogName: json['catalog_name'],
      catalogImage: json['catalog_image'],
      catalogPrice: (json['catalog_price'] as num?)?.toDouble(),
      namaEO: json['nama_eo'],
      orderStatus: json['order_status'],
    );
  }

  String get formattedDateRange {
    final start = DateFormat('dd MMM').format(startDate);
    final end = DateFormat('dd MMM yyyy').format(endDate);
    return '$start - $end';
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return startDate.difference(now).inDays;
    }
    return 0;
  }

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isPast => DateTime.now().isAfter(endDate);
}

/// Controller untuk Jadwal Sewa Admin
class JadwalSewaController extends GetxController {
  final _supabase = Supabase.instance.client;

  // Data
  final schedules = <RentalScheduleModel>[].obs;
  final isLoading = false.obs;
  final selectedSchedule = Rxn<RentalScheduleModel>();

  // Filter
  final selectedStatus = Rxn<RentalStatus>();
  final selectedMonth = Rxn<DateTime>();

  // Form
  final editStatus = Rxn<RentalStatus>();
  final notesController = TextEditingController();
  final isSaving = false.obs;

  // For creating new schedule
  final catalogs = <Map<String, dynamic>>[].obs;
  final selectedCatalogId = RxnString();
  final startDateController = Rxn<DateTime>();
  final endDateController = Rxn<DateTime>();
  final customerNameController = TextEditingController();
  final customerContactController = TextEditingController();
  final eventLocationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
    fetchCatalogs();
  }

  @override
  void onClose() {
    notesController.dispose();
    customerNameController.dispose();
    customerContactController.dispose();
    eventLocationController.dispose();
    super.onClose();
  }

  /// Fetch all schedules
  Future<void> fetchSchedules() async {
    try {
      isLoading.value = true;

      List<dynamic> response;
      
      if (selectedStatus.value != null && selectedMonth.value != null) {
        final startOfMonth = DateTime(selectedMonth.value!.year, selectedMonth.value!.month, 1);
        final endOfMonth = DateTime(selectedMonth.value!.year, selectedMonth.value!.month + 1, 0);
        response = await _supabase
            .from('v_rental_schedules_full')
            .select()
            .eq('status', selectedStatus.value!.dbValue)
            .gte('start_date', startOfMonth.toIso8601String().split('T')[0])
            .lte('start_date', endOfMonth.toIso8601String().split('T')[0])
            .order('start_date', ascending: true);
      } else if (selectedStatus.value != null) {
        response = await _supabase
            .from('v_rental_schedules_full')
            .select()
            .eq('status', selectedStatus.value!.dbValue)
            .order('start_date', ascending: true);
      } else if (selectedMonth.value != null) {
        final startOfMonth = DateTime(selectedMonth.value!.year, selectedMonth.value!.month, 1);
        final endOfMonth = DateTime(selectedMonth.value!.year, selectedMonth.value!.month + 1, 0);
        response = await _supabase
            .from('v_rental_schedules_full')
            .select()
            .gte('start_date', startOfMonth.toIso8601String().split('T')[0])
            .lte('start_date', endOfMonth.toIso8601String().split('T')[0])
            .order('start_date', ascending: true);
      } else {
        response = await _supabase
            .from('v_rental_schedules_full')
            .select()
            .order('start_date', ascending: true);
      }

      schedules.assignAll(response.map((e) => RentalScheduleModel.fromJson(e)).toList());
    } catch (e) {
      _showError('Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch catalogs for dropdown
  Future<void> fetchCatalogs() async {
    try {
      final response = await _supabase
          .from('catalogs')
          .select('id, name')
          .isFilter('deleted_at', null)
          .eq('is_active', true);
      catalogs.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint('Error fetching catalogs: $e');
    }
  }

  /// Filter
  void filterByStatus(RentalStatus? status) {
    selectedStatus.value = status;
    fetchSchedules();
  }

  void filterByMonth(DateTime? month) {
    selectedMonth.value = month;
    fetchSchedules();
  }

  /// Load schedule detail
  Future<void> loadScheduleDetail(String scheduleId) async {
    try {
      isLoading.value = true;
      final response = await _supabase
          .from('v_rental_schedules_full')
          .select()
          .eq('id', scheduleId)
          .single();

      selectedSchedule.value = RentalScheduleModel.fromJson(response);
      editStatus.value = selectedSchedule.value!.status;
      notesController.text = selectedSchedule.value!.notes ?? '';
    } catch (e) {
      _showError('Gagal memuat detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update schedule status
  Future<void> updateSchedule() async {
    if (selectedSchedule.value == null) return;

    try {
      isSaving.value = true;

      await _supabase
          .from('rental_schedules')
          .update({
            'status': editStatus.value?.dbValue ?? 'booking',
            'notes': notesController.text.isNotEmpty ? notesController.text : null,
          })
          .eq('id', selectedSchedule.value!.id);

      _showSuccess('Data berhasil diupdate');
      await loadScheduleDetail(selectedSchedule.value!.id);
      fetchSchedules();
    } catch (e) {
      _showError('Gagal update: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Create new schedule (manual)
  Future<void> createSchedule() async {
    if (selectedCatalogId.value == null ||
        startDateController.value == null ||
        endDateController.value == null) {
      _showError('Lengkapi semua field yang wajib diisi');
      return;
    }

    try {
      isSaving.value = true;

      await _supabase.from('rental_schedules').insert({
        'catalog_id': selectedCatalogId.value,
        'start_date': startDateController.value!.toIso8601String().split('T')[0],
        'end_date': endDateController.value!.toIso8601String().split('T')[0],
        'status': 'booking',
        'customer_name': customerNameController.text.isNotEmpty ? customerNameController.text : null,
        'customer_contact': customerContactController.text.isNotEmpty ? customerContactController.text : null,
        'event_location': eventLocationController.text.isNotEmpty ? eventLocationController.text : null,
        'notes': notesController.text.isNotEmpty ? notesController.text : null,
      });

      _showSuccess('Jadwal berhasil ditambahkan');
      clearForm();
      fetchSchedules();
      Get.back();
    } catch (e) {
      _showError('Gagal menambah jadwal: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Soft delete schedule
  Future<void> deleteSchedule(RentalScheduleModel schedule) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Yakin ingin menghapus jadwal untuk "${schedule.catalogName}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _supabase
          .from('rental_schedules')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', schedule.id);

      schedules.removeWhere((s) => s.id == schedule.id);
      _showSuccess('Jadwal berhasil dihapus');
    } catch (e) {
      _showError('Gagal menghapus: $e');
    }
  }

  void clearForm() {
    selectedCatalogId.value = null;
    startDateController.value = null;
    endDateController.value = null;
    customerNameController.clear();
    customerContactController.clear();
    eventLocationController.clear();
    notesController.clear();
  }

  void goToDetail(RentalScheduleModel schedule) {
    loadScheduleDetail(schedule.id);
    Get.toNamed('/admin/jadwal-sewa/detail');
  }

  void goBack() {
    selectedSchedule.value = null;
    Get.back();
  }

  /// Status colors
  Color getStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.booking: return const Color(0xFF3B82F6);
      case RentalStatus.onAir: return const Color(0xFF22C55E);
      case RentalStatus.completed: return const Color(0xFF6B7280);
      case RentalStatus.cancelled: return const Color(0xFFEF4444);
    }
  }

  Color getStatusBgColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.booking: return const Color(0xFFDBEAFE);
      case RentalStatus.onAir: return const Color(0xFFDCFCE7);
      case RentalStatus.completed: return const Color(0xFFF3F4F6);
      case RentalStatus.cancelled: return const Color(0xFFFEE2E2);
    }
  }

  void _showSuccess(String message) {
    Get.snackbar('Sukses', message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade700);
  }

  void _showError(String message) {
    Get.snackbar('Error', message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700);
  }
}
