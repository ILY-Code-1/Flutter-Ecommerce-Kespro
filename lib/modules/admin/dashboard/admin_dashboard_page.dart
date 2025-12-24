import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_theme.dart';
import '../../../data/models/catalog_model.dart';
import 'admin_dashboard_controller.dart';
import 'widgets/admin_sidebar.dart';
import '../catalog/catalog_controller.dart';
import '../request_order/request_order_controller.dart';
import '../invoice_ui/invoice_ui_controller.dart';

class AdminDashboardPage extends GetView<AdminDashboardController> {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 768
          ? const Drawer(child: AdminSidebar())
          : null,
      floatingActionButton: Obx(() {
        // Tampilkan FAB hanya untuk Katalog
        if (controller.selectedMenuIndex.value == 1) {
          return FloatingActionButton(
            onPressed: () {
              final catalogController = Get.find<CatalogController>();
              catalogController.goToAddCatalog();
            },
            backgroundColor: const Color(0xFF22C55E),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          );
        }
        return const SizedBox.shrink();
      }),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          return Row(
            children: [
              if (!isMobile) const AdminSidebar(),
              Expanded(
                child: Obx(() => _buildContent(context, isMobile)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile) {
    // Render content berdasarkan menu yang dipilih
    switch (controller.selectedMenuIndex.value) {
      case 0: // Beranda
        return _buildBerandaContent(context, isMobile);
      case 1: // Katalog
        _ensureCatalogController();
        return _buildCatalogContent(context, isMobile);
      case 2: // Request Order
        _ensureRequestOrderController();
        return _buildRequestOrderContent(context, isMobile);
      case 3: // Invoice
        _ensureInvoiceController();
        return _buildInvoiceContent(context, isMobile);
      default:
        return _buildBerandaContent(context, isMobile);
    }
  }

  void _ensureCatalogController() {
    if (!Get.isRegistered<CatalogController>()) {
      Get.put(CatalogController());
    }
  }

  void _ensureRequestOrderController() {
    if (!Get.isRegistered<RequestOrderController>()) {
      Get.put(RequestOrderController());
    }
  }

  void _ensureInvoiceController() {
    if (!Get.isRegistered<InvoiceUIController>()) {
      Get.put(InvoiceUIController());
    }
  }

  Widget _buildBerandaContent(BuildContext context, bool isMobile) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0F4FF),
            Color(0xFFE8F4FD),
            Color(0xFFF5F0FF),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isMobile, 'Dashboard', 'Selamat datang di admin panel'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(isMobile),
                  const SizedBox(height: 24),
                  _buildStatCards(isMobile),
                  const SizedBox(height: 32),
                  _buildRecentActivity(isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CATALOG CONTENT ====================
  Widget _buildCatalogContent(BuildContext context, bool isMobile) {
    final catalogController = Get.find<CatalogController>();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F4FF), Color(0xFFE8F4FD), Color(0xFFF5F0FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isMobile, 'Manajemen Katalog', 'Kelola katalog produk sewa'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Obx(() {
                if (catalogController.catalogItems.isEmpty) {
                  return _buildEmptyState('Katalog', Icons.inventory_2_outlined);
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: catalogController.catalogItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = catalogController.catalogItems[index];
                    return _buildCatalogCard(item, isMobile, catalogController);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogCard(CatalogModel item, bool isMobile, CatalogController catalogController) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => catalogController.goToDetailCatalog(item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isMobile ? 56 : 72,
                height: isMobile ? 56 : 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(item.imageUrl!, fit: BoxFit.cover),
                      )
                    : Icon(
                        Icons.image_rounded,
                        color: AppTheme.primaryColor.withValues(alpha: 0.5),
                        size: isMobile ? 28 : 36,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
                    const SizedBox(height: 4),
                    Text(item.formattedPrice, style: TextStyle(fontSize: isMobile ? 13 : 14, color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionBtn(Icons.edit_rounded, const Color(0xFF4F46E5), () => catalogController.goToDetailCatalog(item)),
                  const SizedBox(width: 8),
                  _buildActionBtn(Icons.delete_rounded, Colors.red.shade400, () => catalogController.deleteCatalog(item)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== REQUEST ORDER CONTENT ====================
  Widget _buildRequestOrderContent(BuildContext context, bool isMobile) {
    final orderController = Get.find<RequestOrderController>();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F4FF), Color(0xFFE8F4FD), Color(0xFFF5F0FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isMobile, 'Request Order', 'Kelola permintaan order'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Obx(() {
                  if (orderController.orders.isEmpty) {
                    return _buildEmptyState('Request Order', Icons.receipt_long_rounded);
                  }
                  return _buildOrderTable(orderController, isMobile);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTable(RequestOrderController orderController, bool isMobile) {
    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orderController.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orderController.orders[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFE6FBFF), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3748))),
                    _buildStatusBadge(order.status.label, orderController.getStatusColor(order.status), orderController.getStatusBgColor(order.status)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(order.namaEO, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2D3748))),
                const SizedBox(height: 4),
                Text(order.email, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildActionBtn(Icons.visibility_rounded, AppTheme.accentColor, () => orderController.goToDetail(order)),
                ),
              ],
            ),
          );
        },
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFE6FBFF)),
        columns: const [
          DataColumn(label: Text('ID Request', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Nama Event Organizer', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
        rows: orderController.orders.map((order) {
          return DataRow(cells: [
            DataCell(Text(order.id, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(order.namaEO)),
            DataCell(Text(order.email)),
            DataCell(_buildStatusBadge(order.status.label, orderController.getStatusColor(order.status), orderController.getStatusBgColor(order.status))),
            DataCell(_buildActionBtn(Icons.visibility_rounded, AppTheme.accentColor, () => orderController.goToDetail(order))),
          ]);
        }).toList(),
      ),
    );
  }

  // ==================== INVOICE CONTENT ====================
  Widget _buildInvoiceContent(BuildContext context, bool isMobile) {
    final invoiceController = Get.find<InvoiceUIController>();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F4FF), Color(0xFFE8F4FD), Color(0xFFF5F0FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isMobile, 'Invoice', 'Kelola invoice pelanggan'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.blue.shade600, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Daftar invoice untuk konfirmasi pembayaran via WhatsApp.',
                              style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      if (invoiceController.invoices.isEmpty) {
                        return _buildEmptyState('Invoice', Icons.receipt_rounded);
                      }
                      return _buildInvoiceTable(invoiceController, isMobile);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTable(InvoiceUIController invoiceController, bool isMobile) {
    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: invoiceController.invoices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final invoice = invoiceController.invoices[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFE6FBFF), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3748))),
                    _buildStatusBadge(invoice.paymentStatus.label, invoiceController.getStatusColor(invoice.paymentStatus), invoiceController.getStatusBgColor(invoice.paymentStatus)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(invoice.namaEO, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2D3748))),
                const SizedBox(height: 4),
                Text(invoice.email, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text(invoice.formattedTotal, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildActionBtn(Icons.visibility_rounded, AppTheme.accentColor, () => invoiceController.goToDetail(invoice)),
                ),
              ],
            ),
          );
        },
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFE6FBFF)),
        columns: const [
          DataColumn(label: Text('ID Invoice', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Nama Event Organizer', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
        rows: invoiceController.invoices.map((invoice) {
          return DataRow(cells: [
            DataCell(Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(invoice.namaEO)),
            DataCell(Text(invoice.email)),
            DataCell(_buildStatusBadge(invoice.paymentStatus.label, invoiceController.getStatusColor(invoice.paymentStatus), invoiceController.getStatusBgColor(invoice.paymentStatus))),
            DataCell(_buildActionBtn(Icons.visibility_rounded, AppTheme.accentColor, () => invoiceController.goToDetail(invoice))),
          ]);
        }).toList(),
      ),
    );
  }

  // ==================== SHARED WIDGETS ====================
  Widget _buildStatusBadge(String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 48, color: AppTheme.primaryColor.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            Text('Belum Ada $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
            const SizedBox(height: 8),
            Text('Data $title akan muncul di sini', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 16 : 24,
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
          if (isMobile)
            Builder(
              builder: (context) => Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 24),
                  color: AppTheme.primaryColor,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 22 : 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang di Kespro Event Hub!',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola event dan pesanan dengan mudah melalui dashboard admin.',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCards(bool isMobile) {
    final stats = [
      _StatData(
        value: '14',
        label: 'Total Orderan',
        icon: Icons.shopping_bag_rounded,
        color: const Color(0xFF4F46E5),
        bgColor: const Color(0xFFEEF2FF),
      ),
      _StatData(
        value: '4',
        label: 'Menunggu',
        icon: Icons.hourglass_top_rounded,
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFEF3C7),
      ),
      _StatData(
        value: '10',
        label: 'Selesai',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFD1FAE5),
      ),
      _StatData(
        value: '3',
        label: 'Produk Aktif',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFFEC4899),
        bgColor: const Color(0xFFFCE7F3),
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard(stats[0])),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(stats[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(stats[2])),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(stats[3])),
            ],
          ),
        ],
      );
    }

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: stats.map((stat) => _buildStatCard(stat)).toList(),
    );
  }

  Widget _buildStatCard(_StatData stat) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: stat.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: stat.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(bool isMobile) {
    final activities = [
      _ActivityData(
        title: 'Pesanan baru #1024',
        subtitle: 'Sewa Tenda untuk acara pernikahan',
        time: '5 menit yang lalu',
        icon: Icons.add_shopping_cart_rounded,
        color: const Color(0xFF4F46E5),
      ),
      _ActivityData(
        title: 'Pembayaran diterima',
        subtitle: 'Invoice #INV-2024-001 telah lunas',
        time: '1 jam yang lalu',
        icon: Icons.payment_rounded,
        color: const Color(0xFF10B981),
      ),
      _ActivityData(
        title: 'Penyewaan selesai',
        subtitle: 'Order #1020 dikembalikan',
        time: '3 jam yang lalu',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFFF59E0B),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: activities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              return Column(
                children: [
                  _buildActivityItem(activity),
                  if (index < activities.length - 1)
                    Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                      indent: 68,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(_ActivityData activity) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activity.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  _StatData({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _ActivityData {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  _ActivityData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}
