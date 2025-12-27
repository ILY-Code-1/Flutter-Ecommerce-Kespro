import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../services/email_service.dart';

/// Enum untuk status pembayaran invoice
enum InvoicePaymentStatus {
  belumBayar('Belum Bayar'),
  sudahDp('Sudah DP'),
  lunas('Lunas');

  final String label;
  const InvoicePaymentStatus(this.label);
  
  static InvoicePaymentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'belum_bayar': return InvoicePaymentStatus.belumBayar;
      case 'sudah_dp': return InvoicePaymentStatus.sudahDp;
      case 'lunas': return InvoicePaymentStatus.lunas;
      default: return InvoicePaymentStatus.belumBayar;
    }
  }
  
  String get dbValue {
    switch (this) {
      case InvoicePaymentStatus.belumBayar: return 'belum_bayar';
      case InvoicePaymentStatus.sudahDp: return 'sudah_dp';
      case InvoicePaymentStatus.lunas: return 'lunas';
    }
  }
}

/// Model untuk Invoice
class InvoiceModel {
  final String id;
  final String requestOrderId;
  final String invoiceNumber;
  final String namaEO;
  final String email;
  final String whatsapp;
  final double subtotal;
  final double discount;
  final double tax;
  final double totalAmount;
  final InvoicePaymentStatus paymentStatus;
  final double dpAmount;
  final double paidAmount;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? paymentNotes;
  final DateTime createdAt;
  final DateTime? eventDate;
  final String? eventLocation;
  final String? durasi;
  final List<Map<String, dynamic>>? catalogDetails;

  InvoiceModel({
    required this.id,
    required this.requestOrderId,
    required this.invoiceNumber,
    required this.namaEO,
    required this.email,
    required this.whatsapp,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.totalAmount,
    required this.paymentStatus,
    this.dpAmount = 0,
    this.paidAmount = 0,
    this.paymentDate,
    this.paymentMethod,
    this.paymentNotes,
    required this.createdAt,
    this.eventDate,
    this.eventLocation,
    this.durasi,
    this.catalogDetails,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>>? catalogDetails;
    if (json['catalog_details'] != null && json['catalog_details'] is List) {
      catalogDetails = (json['catalog_details'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }

    return InvoiceModel(
      id: json['id'],
      requestOrderId: json['request_order_id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      namaEO: json['nama_eo'] ?? '',
      email: json['email'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      paymentStatus: InvoicePaymentStatus.fromString(json['payment_status'] ?? 'belum_bayar'),
      dpAmount: (json['dp_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      paymentDate: json['payment_date'] != null ? DateTime.parse(json['payment_date']) : null,
      paymentMethod: json['payment_method'],
      paymentNotes: json['payment_notes'],
      createdAt: DateTime.parse(json['created_at']),
      eventDate: json['event_date'] != null ? DateTime.parse(json['event_date']) : null,
      eventLocation: json['event_location'],
      durasi: json['durasi'],
      catalogDetails: catalogDetails,
    );
  }

  String get formattedTotal {
    final formatted = totalAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(createdAt);
  }

  String get catalogNames {
    if (catalogDetails == null || catalogDetails!.isEmpty) return '-';
    return catalogDetails!.map((c) => c['name']).join(', ');
  }

  double get remainingAmount => totalAmount - paidAmount;

  /// Check if there's a discount
  bool get hasDiscount => discount > 0;

  /// Calculate discount percentage based on subtotal
  double get discountPercentage {
    if (!hasDiscount || subtotal == 0) return 0;
    return (discount / subtotal) * 100;
  }

  String get formattedDiscount {
    if (!hasDiscount) return '';
    return '${discountPercentage.toStringAsFixed(1)}%';
  }

  String get formattedSubtotal {
    final formatted = subtotal.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  String get formattedPaidAmount {
    final formatted = paidAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  String get formattedRemainingAmount {
    final formatted = remainingAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}

/// Controller untuk Invoice Admin
class InvoiceUIController extends GetxController {
  final _supabase = Supabase.instance.client;

  // Data
  final invoices = <InvoiceModel>[].obs;
  final isLoading = false.obs;
  final selectedInvoice = Rxn<InvoiceModel>();

  // Filter
  final selectedMonth = Rxn<DateTime>();

  // Form
  final selectedStatus = Rxn<InvoicePaymentStatus>();
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvoices();
  }

  /// Fetch all invoices
  Future<void> fetchInvoices() async {
    try {
      isLoading.value = true;

      List<dynamic> response;
      
      if (selectedMonth.value != null) {
        final startOfMonth = DateTime(selectedMonth.value!.year, selectedMonth.value!.month, 1);
        final endOfMonth = DateTime(selectedMonth.value!.year, selectedMonth.value!.month + 1, 0, 23, 59, 59);
        response = await _supabase
            .from('v_invoices_full')
            .select()
            .gte('created_at', startOfMonth.toIso8601String())
            .lte('created_at', endOfMonth.toIso8601String())
            .order('created_at', ascending: false);
      } else {
        response = await _supabase
            .from('v_invoices_full')
            .select()
            .order('created_at', ascending: false);
      }

      invoices.assignAll(response.map((e) => InvoiceModel.fromJson(e)).toList());
    } catch (e) {
      _showError('Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter by month
  void filterByMonth(DateTime? month) {
    selectedMonth.value = month;
    fetchInvoices();
  }

  /// Load invoice detail
  Future<void> loadInvoiceDetail(String invoiceId) async {
    try {
      isLoading.value = true;
      final response = await _supabase
          .from('v_invoices_full')
          .select()
          .eq('id', invoiceId)
          .single();

      selectedInvoice.value = InvoiceModel.fromJson(response);
      selectedStatus.value = selectedInvoice.value!.paymentStatus;
    } catch (e) {
      _showError('Gagal memuat detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update invoice status
  Future<void> updateStatus() async {
    if (selectedInvoice.value == null || selectedStatus.value == null) return;

    try {
      isSaving.value = true;

      final updates = {
        'payment_status': selectedStatus.value!.dbValue,
        if (selectedStatus.value == InvoicePaymentStatus.lunas)
          'payment_date': DateTime.now().toIso8601String(),
        if (selectedStatus.value == InvoicePaymentStatus.lunas)
          'paid_amount': selectedInvoice.value!.totalAmount,
      };

      await _supabase
          .from('invoices')
          .update(updates)
          .eq('id', selectedInvoice.value!.id);

      _showSuccess('Status berhasil diupdate');
      await loadInvoiceDetail(selectedInvoice.value!.id);
      fetchInvoices();
    } catch (e) {
      _showError('Gagal update: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Soft delete invoice
  Future<void> deleteInvoice(InvoiceModel invoice) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Invoice'),
        content: Text('Yakin ingin menghapus invoice "${invoice.invoiceNumber}"?'),
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
          .from('invoices')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', invoice.id);

      invoices.removeWhere((i) => i.id == invoice.id);
      _showSuccess('Invoice berhasil dihapus');
    } catch (e) {
      _showError('Gagal menghapus: $e');
    }
  }

  /// Download single invoice PDF
  Future<void> downloadInvoicePdf(InvoiceModel invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('INVOICE', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
                    pw.Text(invoice.invoiceNumber, style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Kespro Event Hub', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Event Property Service'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(invoice.namaEO),
            pw.Text(invoice.email),
            pw.Text(invoice.whatsapp),
            pw.SizedBox(height: 20),
            pw.Text('Event Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            if (invoice.eventDate != null) pw.Text('Tanggal: ${DateFormat('dd MMM yyyy').format(invoice.eventDate!)}'),
            if (invoice.eventLocation != null) pw.Text('Lokasi: ${invoice.eventLocation}'),
            if (invoice.durasi != null) pw.Text('Durasi: ${invoice.durasi}'),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('Items:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            if (invoice.catalogDetails != null)
              ...invoice.catalogDetails!.map((c) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(c['name'] ?? ''),
                    pw.Text('Rp ${(c['price_estimation'] as num?)?.toStringAsFixed(0) ?? '0'}'),
                  ],
                ),
              )),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),
            // Subtotal
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal'),
                pw.Text(invoice.formattedSubtotal),
              ],
            ),
            // Discount if any
            if (invoice.hasDiscount) ...[
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Diskon (${invoice.formattedDiscount})', style: const pw.TextStyle(color: PdfColors.red)),
                  pw.Text('-Rp ${invoice.discount.toStringAsFixed(0)}', style: const pw.TextStyle(color: PdfColors.red)),
                ],
              ),
            ],
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text(invoice.formattedTotal, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Status'),
                pw.Text(invoice.paymentStatus.label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Text('Dicetak: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// Download all invoices summary PDF
  Future<void> downloadAllInvoicesPdf() async {
    final pdf = pw.Document();

    final monthLabel = selectedMonth.value != null
        ? DateFormat('MMMM yyyy').format(selectedMonth.value!)
        : 'Semua Waktu';

    final totalAmount = invoices.fold<double>(0, (sum, i) => sum + i.totalAmount);
    final totalPaid = invoices.fold<double>(0, (sum, i) => sum + i.paidAmount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Ringkasan Invoice', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Periode: $monthLabel'),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['No', 'No. Invoice', 'Tanggal', 'Nama EO', 'Total', 'Status'],
            data: invoices.asMap().entries.map((entry) {
              final i = entry.key;
              final inv = entry.value;
              return [
                '${i + 1}',
                inv.invoiceNumber,
                inv.formattedDate,
                inv.namaEO,
                inv.formattedTotal,
                inv.paymentStatus.label,
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Total Invoice: ${invoices.length}'),
          pw.Text('Total Nilai: Rp ${totalAmount.toStringAsFixed(0)}'),
          pw.Text('Total Terbayar: Rp ${totalPaid.toStringAsFixed(0)}'),
          pw.SizedBox(height: 10),
          pw.Text('Dicetak: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  void goToDetail(InvoiceModel invoice) {
    loadInvoiceDetail(invoice.id);
    Get.toNamed('/admin/invoice/detail');
  }

  void goBack() {
    selectedInvoice.value = null;
    Get.until((route) => route.settings.name == '/admin/dashboard' || route.isFirst);
  }

  void clearSelection() {
    selectedInvoice.value = null;
  }

  Color getStatusColor(InvoicePaymentStatus status) {
    switch (status) {
      case InvoicePaymentStatus.belumBayar: return const Color(0xFFEF4444);
      case InvoicePaymentStatus.sudahDp: return const Color(0xFFF59E0B);
      case InvoicePaymentStatus.lunas: return const Color(0xFF22C55E);
    }
  }

  Color getStatusBgColor(InvoicePaymentStatus status) {
    switch (status) {
      case InvoicePaymentStatus.belumBayar: return const Color(0xFFFEE2E2);
      case InvoicePaymentStatus.sudahDp: return const Color(0xFFFEF3C7);
      case InvoicePaymentStatus.lunas: return const Color(0xFFDCFCE7);
    }
  }

  /// Send invoice email to customer
  Future<void> sendInvoiceEmail(InvoiceModel invoice) async {
    try {
      isSaving.value = true;

      // Prepare items for email template
      final items = invoice.catalogDetails?.map((c) => {
        'name': c['name'] ?? '',
        'price': (c['price_estimation'] as num?)?.toStringAsFixed(0) ?? '0',
      }).toList() ?? [];

      final htmlContent = EmailService.generateInvoiceEmailHtml(
        invoiceNumber: invoice.invoiceNumber,
        customerName: invoice.namaEO,
        eventDate: invoice.eventDate != null 
            ? DateFormat('dd MMMM yyyy').format(invoice.eventDate!) 
            : '-',
        eventLocation: invoice.eventLocation ?? '-',
        durasi: invoice.durasi ?? '-',
        items: items,
        subtotal: invoice.formattedSubtotal,
        discount: invoice.hasDiscount ? 'Rp ${invoice.discount.toStringAsFixed(0)}' : '',
        total: invoice.formattedTotal,
        paymentStatus: invoice.paymentStatus.label,
        hasDiscount: invoice.hasDiscount,
      );

      final success = await EmailService.sendEmail(
        recipient: invoice.email,
        subject: 'Invoice ${invoice.invoiceNumber} - Kespro Event Hub',
        bodyHtml: htmlContent,
      );

      if (success) {
        _showSuccess('Invoice berhasil dikirim ke ${invoice.email}');
      } else {
        _showError('Gagal mengirim email. Silakan coba lagi.');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      isSaving.value = false;
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
