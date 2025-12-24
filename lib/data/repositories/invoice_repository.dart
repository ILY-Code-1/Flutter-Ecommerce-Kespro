import '../../core/config/supabase_config.dart';
import '../models/invoice_model.dart';

/// Repository untuk operasi CRUD Invoice dengan Supabase
/// 
/// Access Control:
/// - All operations: Admin only
class InvoiceRepository {
  static const String _tableName = 'invoices';

  /// Fetch semua invoices (Admin only)
  Future<List<InvoiceModel>> fetchAll() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('issued_date', ascending: false);

      return (response as List)
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data invoice: $e');
    }
  }

  /// Fetch invoices by payment status (Admin only)
  Future<List<InvoiceModel>> fetchByStatus(PaymentStatus status) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('payment_status', status.value)
          .order('issued_date', ascending: false);

      return (response as List)
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data invoice: $e');
    }
  }

  /// Fetch invoice by ID (Admin only)
  Future<InvoiceModel?> fetchById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return InvoiceModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail invoice: $e');
    }
  }

  /// Fetch invoice by order ID (Admin only)
  Future<InvoiceModel?> fetchByOrderId(String orderId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('order_id', orderId)
          .maybeSingle();

      if (response == null) return null;
      return InvoiceModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil invoice untuk order: $e');
    }
  }

  /// Create invoice baru (Admin only)
  /// Returns the created invoice
  Future<InvoiceModel> create({
    required String orderId,
    required String invoiceNumber,
    required double amount,
    PaymentStatus paymentStatus = PaymentStatus.unpaid,
    DateTime? issuedDate,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert({
            'order_id': orderId,
            'invoice_number': invoiceNumber,
            'amount': amount,
            'payment_status': paymentStatus.value,
            'issued_date': (issuedDate ?? DateTime.now()).toIso8601String(),
          })
          .select()
          .single();

      return InvoiceModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat invoice: $e');
    }
  }

  /// Update invoice (Admin only)
  Future<InvoiceModel> update({
    required String id,
    String? invoiceNumber,
    double? amount,
    PaymentStatus? paymentStatus,
    DateTime? issuedDate,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (invoiceNumber != null) updateData['invoice_number'] = invoiceNumber;
      if (amount != null) updateData['amount'] = amount;
      if (paymentStatus != null) updateData['payment_status'] = paymentStatus.value;
      if (issuedDate != null) updateData['issued_date'] = issuedDate.toIso8601String();

      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return InvoiceModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate invoice: $e');
    }
  }

  /// Update payment status only (Admin only)
  Future<InvoiceModel> updatePaymentStatus({
    required String id,
    required PaymentStatus status,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update({'payment_status': status.value})
          .eq('id', id)
          .select()
          .single();

      return InvoiceModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate status pembayaran: $e');
    }
  }

  /// Delete invoice (Admin only)
  Future<void> delete(String id) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus invoice: $e');
    }
  }

  /// Generate invoice number (Admin only)
  /// Format: INV-YYYY-XXXX
  Future<String> generateInvoiceNumber() async {
    try {
      final year = DateTime.now().year;
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('invoice_number')
          .like('invoice_number', 'INV-$year-%')
          .order('invoice_number', ascending: false)
          .limit(1);

      int nextNumber = 1;
      if ((response as List).isNotEmpty) {
        final lastNumber = response[0]['invoice_number'] as String;
        final parts = lastNumber.split('-');
        if (parts.length == 3) {
          nextNumber = int.parse(parts[2]) + 1;
        }
      }

      return 'INV-$year-${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      // Fallback to timestamp-based number
      return 'INV-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 10000}';
    }
  }
}
