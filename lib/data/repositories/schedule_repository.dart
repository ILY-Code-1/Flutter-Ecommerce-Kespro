import '../../core/config/supabase_config.dart';
import '../models/rental_schedule_model.dart';

/// Repository untuk operasi Jadwal Sewa dengan Supabase
/// 
/// Access Control:
/// - READ: Public & Admin
/// - CREATE/UPDATE/DELETE: Admin only (for future extension)
class ScheduleRepository {
  static const String _tableName = 'rental_schedules';

  /// Fetch semua jadwal sewa (Public & Admin)
  /// Includes joined catalog name
  Future<List<RentalScheduleModel>> fetchAll() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('*, catalogs(name)')
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => RentalScheduleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil jadwal sewa: $e');
    }
  }

  /// Fetch jadwal sewa by catalog ID (Public & Admin)
  Future<List<RentalScheduleModel>> fetchByCatalogId(String catalogId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('*, catalogs(name)')
          .eq('catalog_id', catalogId)
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => RentalScheduleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil jadwal sewa: $e');
    }
  }

  /// Fetch jadwal sewa dalam rentang tanggal (Public & Admin)
  Future<List<RentalScheduleModel>> fetchByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('*, catalogs(name)')
          .gte('start_date', startDate.toIso8601String())
          .lte('end_date', endDate.toIso8601String())
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => RentalScheduleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil jadwal sewa: $e');
    }
  }

  /// Fetch jadwal aktif saat ini (Public & Admin)
  Future<List<RentalScheduleModel>> fetchActive() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('*, catalogs(name)')
          .lte('start_date', now)
          .gte('end_date', now)
          .eq('status', RentalStatus.active.value)
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => RentalScheduleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil jadwal aktif: $e');
    }
  }

  /// Fetch jadwal mendatang (Public & Admin)
  Future<List<RentalScheduleModel>> fetchUpcoming() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('*, catalogs(name)')
          .gte('start_date', now)
          .inFilter('status', [RentalStatus.scheduled.value, RentalStatus.active.value])
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => RentalScheduleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil jadwal mendatang: $e');
    }
  }

  /// Check ketersediaan katalog pada tanggal tertentu (Public & Admin)
  Future<bool> checkAvailability({
    required String catalogId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('id')
          .eq('catalog_id', catalogId)
          .inFilter('status', [RentalStatus.scheduled.value, RentalStatus.active.value])
          .or('start_date.lte.${endDate.toIso8601String()},end_date.gte.${startDate.toIso8601String()}');

      return (response as List).isEmpty;
    } catch (e) {
      throw Exception('Gagal memeriksa ketersediaan: $e');
    }
  }

  // ==========================================
  // Admin-only operations (for future extension)
  // ==========================================

  /// Create jadwal sewa baru (Admin only)
  Future<RentalScheduleModel> create({
    required String catalogId,
    required DateTime startDate,
    required DateTime endDate,
    RentalStatus status = RentalStatus.scheduled,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert({
            'catalog_id': catalogId,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'status': status.value,
          })
          .select('*, catalogs(name)')
          .single();

      return RentalScheduleModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat jadwal sewa: $e');
    }
  }

  /// Update status jadwal (Admin only)
  Future<RentalScheduleModel> updateStatus({
    required String id,
    required RentalStatus status,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update({'status': status.value})
          .eq('id', id)
          .select('*, catalogs(name)')
          .single();

      return RentalScheduleModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate status jadwal: $e');
    }
  }

  /// Delete jadwal sewa (Admin only)
  Future<void> delete(String id) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus jadwal sewa: $e');
    }
  }
}
