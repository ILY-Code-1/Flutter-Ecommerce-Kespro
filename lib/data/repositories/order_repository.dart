import '../../core/config/supabase_config.dart';
import '../models/order_model.dart';

/// Repository untuk operasi Order dengan Supabase
/// 
/// Access Control:
/// - CREATE: Public user (from landing page only)
/// - READ: Admin only (via dashboard)
/// - UPDATE/DELETE: Admin only (via dashboard)
class OrderRepository {
  static const String _tableName = 'orders';

  /// Fetch semua orders (Admin only)
  Future<List<OrderModel>> fetchAll() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data order: $e');
    }
  }

  /// Fetch orders by status (Admin only)
  Future<List<OrderModel>> fetchByStatus(OrderStatus status) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('status', status.value)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data order: $e');
    }
  }

  /// Fetch order by ID (Admin only)
  Future<OrderModel?> fetchById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail order: $e');
    }
  }

  /// Create order baru (Public user - dari landing page)
  /// Returns the created order
  Future<OrderModel> create({
    required String customerName,
    required String email,
    required DateTime eventDate,
    required String location,
    required String duration,
    required List<String> catalogItems,
    required double totalPrice,
    String? notes,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert({
            'customer_name': customerName,
            'email': email,
            'event_date': eventDate.toIso8601String(),
            'location': location,
            'duration': duration,
            'catalog_items': catalogItems,
            'total_price': totalPrice,
            'notes': notes,
            'status': OrderStatus.pending.value,
          })
          .select()
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat order: $e');
    }
  }

  /// Update status order (Admin only)
  /// Returns the updated order
  Future<OrderModel> updateStatus({
    required String id,
    required OrderStatus status,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update({'status': status.value})
          .eq('id', id)
          .select()
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate status order: $e');
    }
  }

  /// Update order details (Admin only)
  Future<OrderModel> update({
    required String id,
    String? customerName,
    String? email,
    DateTime? eventDate,
    String? location,
    String? duration,
    List<String>? catalogItems,
    double? totalPrice,
    String? notes,
    OrderStatus? status,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (customerName != null) updateData['customer_name'] = customerName;
      if (email != null) updateData['email'] = email;
      if (eventDate != null) updateData['event_date'] = eventDate.toIso8601String();
      if (location != null) updateData['location'] = location;
      if (duration != null) updateData['duration'] = duration;
      if (catalogItems != null) updateData['catalog_items'] = catalogItems;
      if (totalPrice != null) updateData['total_price'] = totalPrice;
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status.value;

      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate order: $e');
    }
  }

  /// Delete order (Admin only)
  Future<void> delete(String id) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus order: $e');
    }
  }

  /// Get order statistics (Admin only)
  Future<Map<String, int>> getStatistics() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('status');

      final orders = response as List;
      final stats = <String, int>{
        'total': orders.length,
        'pending': 0,
        'confirmed': 0,
        'in_progress': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final order in orders) {
        final status = order['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Gagal mengambil statistik order: $e');
    }
  }
}
