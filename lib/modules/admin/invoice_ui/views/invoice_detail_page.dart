import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../themes/app_theme.dart';
import '../../dashboard/widgets/admin_sidebar.dart';
import '../invoice_ui_controller.dart';

class InvoiceDetailPage extends GetView<InvoiceUIController> {
  const InvoiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: isMobile || isTablet ? const Drawer(child: AdminSidebar()) : null,
      body: Row(
        children: [
          if (!isMobile && !isTablet) const AdminSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, isMobile, isTablet),
                Expanded(child: _buildContent(isMobile)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          if (isMobile || isTablet)
            IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
          IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: controller.goBack, tooltip: 'Kembali'),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.receipt_rounded, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          const Text('Detail Invoice', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
      }

      final invoice = controller.selectedInvoice.value;
      if (invoice == null) {
        return const Center(child: Text('Data tidak ditemukan'));
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(invoice, isMobile),
                const Divider(height: 32),
                _buildEditSection(invoice),
                const SizedBox(height: 24),
                _buildActionButtons(invoice, isMobile),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInfoSection(InvoiceModel invoice, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(invoice.invoiceNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildStatusBadge(invoice.paymentStatus),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Nama EO', invoice.namaEO),
        _buildInfoRow('Email', invoice.email),
        _buildInfoRow('WhatsApp', invoice.whatsapp),
        if (invoice.eventDate != null) _buildInfoRow('Tanggal Event', invoice.formattedDate),
        if (invoice.eventLocation != null) _buildInfoRow('Lokasi', invoice.eventLocation!),
        if (invoice.durasi != null) _buildInfoRow('Durasi', invoice.durasi!),
        _buildInfoRow('Produk', invoice.catalogNames),
        const Divider(height: 24),
        _buildInfoRow('Total', invoice.formattedTotal, isBold: true, color: AppTheme.primaryColor),
        if (invoice.paidAmount > 0) _buildInfoRow('Terbayar', invoice.formattedPaidAmount),
        if (invoice.remainingAmount > 0) _buildInfoRow('Sisa', invoice.formattedRemainingAmount, color: Colors.red),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color ?? const Color(0xFF2D3748), fontSize: isBold ? 18 : 14))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(InvoicePaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: controller.getStatusBgColor(status), borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: TextStyle(color: controller.getStatusColor(status), fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEditSection(InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Edit Status Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        const SizedBox(height: 16),

        // Status Dropdown
        Obx(() => DropdownButtonFormField<InvoicePaymentStatus>(
          value: controller.selectedStatus.value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: InvoicePaymentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
          onChanged: (v) => controller.selectedStatus.value = v,
        )),

        const SizedBox(height: 12),
        Text(
          'Catatan: Saat status diubah ke "Lunas", tanggal pembayaran akan otomatis diset hari ini.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildActionButtons(InvoiceModel invoice, bool isMobile) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Save Button
        Obx(() => ElevatedButton.icon(
          onPressed: controller.isSaving.value ? null : controller.updateStatus,
          icon: controller.isSaving.value
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.save_rounded, color: Colors.white),
          label: const Text('Simpan', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )),

        // Download PDF
        ElevatedButton.icon(
          onPressed: () => controller.downloadInvoicePdf(invoice),
          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
          label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // Send Invoice Email
        Obx(() => ElevatedButton.icon(
          onPressed: controller.isSaving.value ? null : () => controller.sendInvoiceEmail(invoice),
          icon: controller.isSaving.value
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.email_rounded, color: Colors.white),
          label: Text('Kirim ke ${invoice.email}', style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )),
      ],
    );
  }
}
