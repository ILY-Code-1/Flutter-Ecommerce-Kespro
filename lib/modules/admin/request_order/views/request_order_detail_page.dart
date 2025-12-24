import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../themes/app_theme.dart';
import '../../dashboard/widgets/admin_sidebar.dart';
import '../request_order_controller.dart';

class RequestOrderDetailPage extends GetView<RequestOrderController> {
  const RequestOrderDetailPage({super.key});

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
            child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          const Text('Detail Order', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
      }

      final order = controller.selectedOrder.value;
      if (order == null) {
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
                _buildInfoSection(order, isMobile),
                const Divider(height: 32),
                _buildEditSection(order),
                const SizedBox(height: 24),
                _buildActionButtons(order, isMobile),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInfoSection(RequestOrderModel order, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Request #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildStatusBadge(order.status),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Nama EO', order.namaEO),
        _buildInfoRow('Email', order.email),
        _buildInfoRow('WhatsApp', order.whatsapp),
        _buildInfoRow('Tanggal Event', order.formattedDate),
        _buildInfoRow('Lokasi', order.lokasi),
        _buildInfoRow('Durasi', order.durasi),
        _buildInfoRow('Produk', order.catalogNames),
        
        // Price section with discount info
        _buildInfoRow('Harga Awal', order.formattedOriginalPrice),
        if (order.hasDiscount) ...[
          _buildDiscountRow(order),
          _buildInfoRow('Harga Final', order.formattedPrice, color: const Color(0xFF22C55E)),
        ] else
          _buildInfoRow('Harga Final', order.formattedPrice),
        
        if (order.catatan != null && order.catatan!.isNotEmpty)
          _buildInfoRow('Catatan Customer', order.catatan!),
        
        // Invoice info
        if (order.hasInvoice) ...[
          const SizedBox(height: 8),
          _buildInvoiceInfo(order),
        ],
      ],
    );
  }

  Widget _buildDiscountRow(RequestOrderModel order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text('Diskon', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500))),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '-${order.formattedDiscount}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceInfo(RequestOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice Sudah Dibuat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                Text('No. Invoice: ${order.invoiceNumber}', style: TextStyle(fontSize: 13, color: Colors.green.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? const Color(0xFF2D3748)))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RequestOrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: controller.getStatusBgColor(status), borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: TextStyle(color: controller.getStatusColor(status), fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEditSection(RequestOrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Edit Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        const SizedBox(height: 16),

        // Status Dropdown
        const Text('Status', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<RequestOrderStatus>(
          value: controller.selectedStatus.value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: RequestOrderStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
          onChanged: (v) => controller.selectedStatus.value = v,
        )),
        const SizedBox(height: 16),

        // Final Price
        const Text('Harga Final', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller.finalPriceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixText: 'Rp ',
          ),
        ),
        const SizedBox(height: 16),

        // Admin Notes
        const Text('Catatan Admin', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller.adminNotesController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            hintText: 'Catatan internal untuk admin...',
          ),
        ),
        const SizedBox(height: 16),

        // Product Notes
        const Text('Keterangan Produk', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller.productNotesController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            hintText: 'Keterangan tambahan tentang produk...',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(RequestOrderModel order, bool isMobile) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Save Button
        Obx(() => ElevatedButton.icon(
          onPressed: controller.isSaving.value ? null : controller.updateOrder,
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
          onPressed: () => controller.downloadOrderPdf(order),
          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
          label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // Generate Invoice (only when status is deal and no invoice yet)
        if (order.status == RequestOrderStatus.deal && order.invoiceId == null)
          Obx(() => ElevatedButton.icon(
            onPressed: controller.isSaving.value ? null : controller.generateInvoice,
            icon: controller.isSaving.value
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.receipt_long_rounded, color: Colors.white),
            label: const Text('Generate Invoice', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )),
      ],
    );
  }
}
