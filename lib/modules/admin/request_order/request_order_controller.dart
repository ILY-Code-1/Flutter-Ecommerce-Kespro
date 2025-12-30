import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../services/email_service.dart';

/// Enum untuk status request order
enum RequestOrderStatus {
  masuk('Masuk'),
  negosiasi('Negosiasi'),
  deal('Deal'),
  ditolak('Ditolak');

  final String label;
  const RequestOrderStatus(this.label);
  
  static RequestOrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'masuk': return RequestOrderStatus.masuk;
      case 'negosiasi': return RequestOrderStatus.negosiasi;
      case 'deal': return RequestOrderStatus.deal;
      case 'ditolak': return RequestOrderStatus.ditolak;
      default: return RequestOrderStatus.masuk;
    }
  }
}

/// Model untuk item dalam request order
class RequestOrderItem {
  final String catalogId;
  final String name;
  final double originalPrice;
  final double finalPrice;

  RequestOrderItem({
    required this.catalogId,
    required this.name,
    required this.originalPrice,
    required this.finalPrice,
  });

  factory RequestOrderItem.fromJson(Map<String, dynamic> json) {
    return RequestOrderItem(
      catalogId: json['catalog_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['final_price'] as num?)?.toDouble() ?? (json['original_price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catalog_id': catalogId,
      'name': name,
      'original_price': originalPrice,
      'final_price': finalPrice,
    };
  }

  String get formattedOriginalPrice {
    final formatted = originalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  String get formattedFinalPrice {
    final formatted = finalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}

/// Model untuk Request Order
class RequestOrderModel {
  final String id;
  final String namaEO;
  final String email;
  final String whatsapp;
  final DateTime tanggalMulai;
  final String lokasi;
  final String durasi;
  final String? catatan;
  final List<RequestOrderItem> items;
  final String? adminNotes;
  final String? productNotes;
  final RequestOrderStatus status;
  final DateTime createdAt;
  final String? invoiceId;
  final String? invoiceNumber;

  RequestOrderModel({
    required this.id,
    required this.namaEO,
    required this.email,
    required this.whatsapp,
    required this.tanggalMulai,
    required this.lokasi,
    required this.durasi,
    this.catatan,
    required this.items,
    this.adminNotes,
    this.productNotes,
    required this.status,
    required this.createdAt,
    this.invoiceId,
    this.invoiceNumber,
  });

  factory RequestOrderModel.fromJson(Map<String, dynamic> json) {
    List<RequestOrderItem> items = [];
    
    // Parse catalog_items from JSON string or array
    if (json['catalog_items'] != null) {
      dynamic catalogItems = json['catalog_items'];
      
      // If it's a string, parse it as JSON
      if (catalogItems is String) {
        try {
          final decoded = jsonDecode(catalogItems);
          if (decoded is List) {
            items = decoded.map((e) => RequestOrderItem.fromJson(e as Map<String, dynamic>)).toList();
          }
        } catch (e) {
          debugPrint('Error parsing catalog_items JSON string: $e');
        }
      } 
      // If it's already a list, use it directly
      else if (catalogItems is List) {
        items = catalogItems.map((e) => RequestOrderItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    }

    return RequestOrderModel(
      id: json['id'],
      namaEO: json['nama_eo'] ?? '',
      email: json['email'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      lokasi: json['lokasi'] ?? '',
      durasi: json['durasi'] ?? '',
      catatan: json['catatan'],
      items: items,
      adminNotes: json['admin_notes'],
      productNotes: json['product_notes'],
      status: RequestOrderStatus.fromString(json['status'] ?? 'masuk'),
      createdAt: DateTime.parse(json['created_at']),
      invoiceId: json['invoice_id'],
      invoiceNumber: json['invoice_number'],
    );
  }

  /// Calculate total from items
  double get totalOriginalPrice {
    return items.fold(0, (sum, item) => sum + item.originalPrice);
  }

  double get totalFinalPrice {
    return items.fold(0, (sum, item) => sum + item.finalPrice);
  }

  String get formattedOriginalPrice {
    final formatted = totalOriginalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  String get formattedPrice {
    final formatted = totalFinalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(tanggalMulai);
  }

  String get catalogNames {
    if (items.isEmpty) return '-';
    return items.map((item) => item.name).join(', ');
  }

  /// Check if there's any price difference
  bool get hasDiscount {
    return totalFinalPrice < totalOriginalPrice;
  }

  /// Check if invoice already created
  bool get hasInvoice => invoiceId != null && invoiceId!.isNotEmpty;
}

/// Controller untuk Request Order Admin
class RequestOrderController extends GetxController {
  final _supabase = Supabase.instance.client;

  // Data
  final orders = <RequestOrderModel>[].obs;
  final isLoading = false.obs;
  final selectedOrder = Rxn<RequestOrderModel>();

  // Filter
  final selectedMonth = Rxn<DateTime>();
  final availableMonths = <DateTime>[].obs;

  // Form controllers for editing
  final selectedStatus = Rxn<RequestOrderStatus>();
  final adminNotesController = TextEditingController();
  final productNotesController = TextEditingController();
  
  // Per-item price controllers
  final itemPriceControllers = <TextEditingController>[].obs;
  final editableItems = <RequestOrderItem>[].obs;

  // Saving state
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  @override
  void onClose() {
    _disposeItemControllers();
    adminNotesController.dispose();
    productNotesController.dispose();
    super.onClose();
  }

  void _disposeItemControllers() {
    for (var controller in itemPriceControllers) {
      controller.dispose();
    }
    itemPriceControllers.clear();
  }

  /// Fetch all orders from Supabase
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;

      List<dynamic> response;

      // Apply month filter
      if (selectedMonth.value != null) {
        final startOfMonth = DateTime(selectedMonth.value!.year, selectedMonth.value!.month, 1);
        final endOfMonth = DateTime(selectedMonth.value!.year, selectedMonth.value!.month + 1, 0, 23, 59, 59);
        response = await _supabase
            .from('v_request_orders_full')
            .select()
            .gte('created_at', startOfMonth.toIso8601String())
            .lte('created_at', endOfMonth.toIso8601String())
            .order('created_at', ascending: false);
      } else {
        response = await _supabase
            .from('v_request_orders_full')
            .select()
            .order('created_at', ascending: false);
      }

      orders.assignAll(response.map((e) => RequestOrderModel.fromJson(e)).toList());

      // Update available months
      _updateAvailableMonths();
    } catch (e) {
      _showError('Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateAvailableMonths() {
    final months = <DateTime>{};
    for (var order in orders) {
      months.add(DateTime(order.createdAt.year, order.createdAt.month));
    }
    availableMonths.assignAll(months.toList()..sort((a, b) => b.compareTo(a)));
  }

  /// Filter by month
  void filterByMonth(DateTime? month) {
    selectedMonth.value = month;
    fetchOrders();
  }

  /// Load order for detail/edit
  Future<void> loadOrderDetail(String orderId) async {
    try {
      isLoading.value = true;
      final response = await _supabase
          .from('v_request_orders_full')
          .select()
          .eq('id', orderId)
          .single();

      selectedOrder.value = RequestOrderModel.fromJson(response);
      
      // Populate form fields
      final order = selectedOrder.value!;
      selectedStatus.value = order.status;
      adminNotesController.text = order.adminNotes ?? '';
      productNotesController.text = order.productNotes ?? '';
      
      // Initialize item controllers and editable items
      _disposeItemControllers();
      editableItems.assignAll(order.items);
      
      for (var item in order.items) {
        final controller = TextEditingController(
          text: item.finalPrice.toStringAsFixed(0)
        );
        itemPriceControllers.add(controller);
      }
    } catch (e) {
      _showError('Gagal memuat detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update item price from controller
  void updateItemPrice(int index) {
    if (index < 0 || index >= editableItems.length) return;
    
    final priceText = itemPriceControllers[index].text;
    final newPrice = double.tryParse(priceText) ?? editableItems[index].finalPrice;
    
    editableItems[index] = RequestOrderItem(
      catalogId: editableItems[index].catalogId,
      name: editableItems[index].name,
      originalPrice: editableItems[index].originalPrice,
      finalPrice: newPrice,
    );
    
    // Trigger rebuild
    editableItems.refresh();
  }

  /// Update order
  Future<void> updateOrder() async {
    if (selectedOrder.value == null) return;

    try {
      isSaving.value = true;

      // Update all item prices from controllers
      for (int i = 0; i < editableItems.length; i++) {
        updateItemPrice(i);
      }

      // Convert items to JSON
      final itemsJson = jsonEncode(editableItems.map((item) => item.toJson()).toList());

      final updates = {
        'status': selectedStatus.value?.name ?? 'masuk',
        'catalog_items': itemsJson,
        'admin_notes': adminNotesController.text.isNotEmpty ? adminNotesController.text : null,
        'product_notes': productNotesController.text.isNotEmpty ? productNotesController.text : null,
      };

      await _supabase
          .from('request_orders')
          .update(updates)
          .eq('id', selectedOrder.value!.id);

      _showSuccess('Data berhasil diupdate');
      
      // Refresh data
      await loadOrderDetail(selectedOrder.value!.id);
      fetchOrders();
    } catch (e) {
      _showError('Gagal update: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Soft delete order
  Future<void> deleteOrder(RequestOrderModel order) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Request Order'),
        content: Text('Yakin ingin menghapus request dari "${order.namaEO}"?'),
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
          .from('request_orders')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', order.id);

      orders.removeWhere((o) => o.id == order.id);
      _showSuccess('Data berhasil dihapus');
    } catch (e) {
      _showError('Gagal menghapus: $e');
    }
  }

  /// Generate invoice from deal order
  Future<void> generateInvoice() async {
    if (selectedOrder.value == null) return;
    if (selectedOrder.value!.status != RequestOrderStatus.deal) {
      _showError('Invoice hanya dapat dibuat untuk status Deal');
      return;
    }
    if (selectedOrder.value!.invoiceId != null) {
      _showError('Invoice sudah dibuat sebelumnya');
      return;
    }

    try {
      isSaving.value = true;
      final order = selectedOrder.value!;

      // Create invoice via RPC
      await _supabase.rpc(
        'create_invoice_from_request',
        params: {'p_request_order_id': order.id},
      );

      // Refresh to get invoice number
      await loadOrderDetail(order.id);
      final updatedOrder = selectedOrder.value!;

      // Send email notification
      if (updatedOrder.invoiceNumber != null) {
        final emailSent = await _sendInvoiceCreatedEmail(updatedOrder);
        if (emailSent) {
          _showSuccess('Invoice berhasil dibuat dan email terkirim ke ${order.email}');
        } else {
          _showSuccess('Invoice berhasil dibuat (email gagal terkirim)');
        }
      } else {
        _showSuccess('Invoice berhasil dibuat');
      }
      
      fetchOrders();
    } catch (e) {
      _showError('Gagal membuat invoice: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Send email notification after invoice created
  Future<bool> _sendInvoiceCreatedEmail(RequestOrderModel order) async {
    try {
      // Convert items to list of maps for email
      final items = order.items.map((item) => {
        'name': item.name,
        'original_price': item.formattedOriginalPrice,
        'final_price': item.formattedFinalPrice,
      }).toList();
      
      final htmlContent = EmailService.generateOrderConfirmationHtml(
        orderId: order.id.substring(0, 8).toUpperCase(),
        customerName: order.namaEO,
        eventDate: order.formattedDate,
        eventLocation: order.lokasi,
        durasi: order.durasi,
        items: items,
        totalOriginal: order.formattedOriginalPrice,
        totalFinal: order.formattedPrice,
        invoiceNumber: order.invoiceNumber ?? '-',
      );

      return await EmailService.sendEmail(
        recipient: order.email,
        subject: 'Invoice ${order.invoiceNumber} - Kespro Event Hub',
        bodyHtml: htmlContent,
      );
    } catch (e) {
      debugPrint('Error sending email: $e');
      return false;
    }
  }

  /// Download single order PDF
  Future<void> downloadOrderPdf(RequestOrderModel order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: 'Detail Request Order'),
            pw.SizedBox(height: 20),
            _buildPdfRow('ID Request', order.id.substring(0, 8).toUpperCase()),
            _buildPdfRow('Nama EO', order.namaEO),
            _buildPdfRow('Email', order.email),
            _buildPdfRow('WhatsApp', order.whatsapp),
            _buildPdfRow('Tanggal Event', order.formattedDate),
            _buildPdfRow('Lokasi', order.lokasi),
            _buildPdfRow('Durasi', order.durasi),
            _buildPdfRow('Status', order.status.label),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('Produk & Harga:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 8),
            ...order.items.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ${item.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('  Harga Awal: ${item.formattedOriginalPrice}', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('  Harga Final: ${item.formattedFinalPrice}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            pw.SizedBox(height: 10),
            pw.Divider(),
            _buildPdfRow('Total Harga Awal', order.formattedOriginalPrice),
            _buildPdfRow('Total Harga Final', order.formattedPrice),
            if (order.catatan != null && order.catatan!.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Text('Catatan Customer:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(order.catatan!),
            ],
            if (order.adminNotes != null && order.adminNotes!.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Text('Catatan Admin:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(order.adminNotes!),
            ],
            pw.SizedBox(height: 20),
            pw.Text('Dicetak: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// Download all orders summary PDF
  Future<void> downloadAllOrdersPdf() async {
    final pdf = pw.Document();

    final monthLabel = selectedMonth.value != null
        ? DateFormat('MMMM yyyy').format(selectedMonth.value!)
        : 'Semua Waktu';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Ringkasan Request Order', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Periode: $monthLabel'),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['No', 'Tanggal', 'Nama EO', 'Email', 'Produk', 'Total', 'Status'],
            data: orders.asMap().entries.map((entry) {
              final i = entry.key;
              final o = entry.value;
              return [
                '${i + 1}',
                DateFormat('dd/MM/yy').format(o.createdAt),
                o.namaEO,
                o.email,
                o.catalogNames.length > 30 ? '${o.catalogNames.substring(0, 30)}...' : o.catalogNames,
                o.formattedPrice,
                o.status.label,
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Total: ${orders.length} request order'),
          pw.Text('Dicetak: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 120, child: pw.Text('$label:')),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  /// Navigate to detail
  void goToDetail(RequestOrderModel order) {
    loadOrderDetail(order.id);
    Get.toNamed('/admin/request-order/detail');
  }

  void goBack() {
    selectedOrder.value = null;
    // Use offNamed to clear stack and go back to dashboard
    Get.until((route) => route.settings.name == '/admin/dashboard' || route.isFirst);
  }

  void clearSelection() {
    selectedOrder.value = null;
  }

  /// Status colors
  Color getStatusColor(RequestOrderStatus status) {
    switch (status) {
      case RequestOrderStatus.masuk: return const Color(0xFF3B82F6);
      case RequestOrderStatus.negosiasi: return const Color(0xFFF59E0B);
      case RequestOrderStatus.deal: return const Color(0xFF22C55E);
      case RequestOrderStatus.ditolak: return const Color(0xFFEF4444);
    }
  }

  Color getStatusBgColor(RequestOrderStatus status) {
    switch (status) {
      case RequestOrderStatus.masuk: return const Color(0xFFDBEAFE);
      case RequestOrderStatus.negosiasi: return const Color(0xFFFEF3C7);
      case RequestOrderStatus.deal: return const Color(0xFFDCFCE7);
      case RequestOrderStatus.ditolak: return const Color(0xFFFEE2E2);
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
