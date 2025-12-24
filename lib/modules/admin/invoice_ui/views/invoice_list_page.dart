import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../themes/app_theme.dart';
import '../../dashboard/widgets/admin_sidebar.dart';
import '../invoice_ui_controller.dart';

/// Halaman daftar Invoice di Admin Dashboard
/// Menampilkan tabel invoice dengan status badge dan aksi
class InvoiceListPage extends GetView<InvoiceUIController> {
  const InvoiceListPage({super.key});

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
          // Sidebar untuk desktop
          if (!isMobile && !isTablet) const AdminSidebar(),
          
          // Content area
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, isMobile, isTablet),
                Expanded(
                  child: _buildContent(isMobile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isMobile || isTablet)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_rounded,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Invoice',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Daftar invoice digunakan untuk konfirmasi pembayaran via WhatsApp guna meningkatkan kepercayaan saat negosiasi.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Table header info
            Row(
              children: [
                Icon(
                  Icons.list_alt_rounded,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daftar Invoice',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Obx(() => Text(
                  '${controller.invoices.length} invoice',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                )),
              ],
            ),
            const SizedBox(height: 20),
            
            // Table
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
                );
              }

              if (controller.invoices.isEmpty) {
                return _buildEmptyState();
              }

              return _buildTable(isMobile);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada invoice',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(bool isMobile) {
    if (isMobile) {
      return _buildMobileList();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFE6FBFF)),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFFF0FDFF);
          }
          return Colors.white;
        }),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
          fontSize: 14,
        ),
        dataTextStyle: const TextStyle(
          color: Color(0xFF4A5568),
          fontSize: 14,
        ),
        columnSpacing: 32,
        horizontalMargin: 16,
        columns: const [
          DataColumn(label: Text('ID Invoice')),
          DataColumn(label: Text('Nama Event Organizer')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: controller.invoices.map((invoice) {
          return DataRow(
            cells: [
              DataCell(Text(
                invoice.invoiceNumber,
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
              DataCell(Text(invoice.namaEO)),
              DataCell(Text(invoice.email)),
              DataCell(_buildStatusBadge(invoice.paymentStatus)),
              DataCell(_buildActionButton(invoice)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invoice = controller.invoices[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE6FBFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  _buildStatusBadge(invoice.paymentStatus),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                invoice.namaEO,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                invoice.email,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                invoice.formattedTotal,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: _buildActionButton(invoice),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(InvoicePaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: controller.getStatusBgColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: controller.getStatusColor(status),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButton(InvoiceModel invoice) {
    return IconButton(
      onPressed: () => controller.goToDetail(invoice),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.visibility_rounded,
          color: AppTheme.accentColor,
          size: 18,
        ),
      ),
      tooltip: 'Lihat Detail',
    );
  }
}
