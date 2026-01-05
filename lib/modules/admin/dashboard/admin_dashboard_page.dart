import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
              Expanded(child: Obx(() => _buildContent(context, isMobile))),
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
          colors: [Color(0xFFF0F4FF), Color(0xFFE8F4FD), Color(0xFFF5F0FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            context,
            isMobile,
            'Dashboard',
            'Selamat datang di admin panel',
          ),
          // Month filter and refresh
          _buildDashboardActions(isMobile),
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

  Widget _buildDashboardActions(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month filter
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DateTime?>(
                  value: controller.selectedMonth.value,
                  hint: const Text('Pilih Bulan'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Semua Bulan'),
                    ),
                    ...List.generate(12, (i) {
                      final date = DateTime(
                        DateTime.now().year,
                        DateTime.now().month - i,
                      );
                      return DropdownMenuItem(
                        value: date,
                        child: Text(DateFormat('MMMM yyyy').format(date)),
                      );
                    }),
                  ],
                  onChanged: controller.changeMonth,
                ),
              ),
            ),
          ),
          // Refresh button
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isLoadingStats.value
                  ? null
                  : controller.refreshDashboard,
              icon: controller.isLoadingStats.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh, size: 18, color: Colors.white),
              label: Text(
                isMobile ? '' : 'Refresh',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
          _buildHeader(
            context,
            isMobile,
            'Manajemen Katalog',
            'Kelola katalog produk sewa',
          ),
          // Action bar with refresh button
          _buildCatalogActionBar(catalogController, isMobile),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Obx(() {
                if (catalogController.catalogItems.isEmpty) {
                  return _buildEmptyState(
                    'Katalog',
                    Icons.inventory_2_outlined,
                  );
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

  Widget _buildCatalogCard(
    CatalogModel item,
    bool isMobile,
    CatalogController catalogController,
  ) {
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
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.formattedPrice,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionBtn(
                    Icons.edit_rounded,
                    const Color(0xFF4F46E5),
                    () => catalogController.goToDetailCatalog(item),
                  ),
                  const SizedBox(width: 8),
                  _buildActionBtn(
                    Icons.delete_rounded,
                    Colors.red.shade400,
                    () => catalogController.deleteCatalog(item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogActionBar(
    CatalogController catalogController,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() => ElevatedButton.icon(
            onPressed: catalogController.isLoading.value
                ? null
                : catalogController.fetchCatalogs,
            icon: catalogController.isLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, size: 18, color: Colors.white),
            label: Text(
              isMobile ? '' : 'Refresh',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )),
        ],
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
          _buildHeader(
            context,
            isMobile,
            'Request Order',
            'Kelola permintaan order',
          ),
          // Filter & Actions Bar
          _buildOrderFilterBar(orderController, isMobile),
          Expanded(
            child: SingleChildScrollView(
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
                child: Obx(() {
                  if (orderController.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (orderController.orders.isEmpty) {
                    return _buildEmptyState(
                      'Request Order',
                      Icons.receipt_long_rounded,
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary
                      _buildOrderSummary(orderController),
                      const SizedBox(height: 16),
                      _buildOrderTable(orderController, isMobile),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderFilterBar(
    RequestOrderController orderController,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 12,
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        children: [
          // Month Filter
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DateTime?>(
                  value: orderController.selectedMonth.value,
                  hint: const Text('Filter Bulan'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Semua Bulan'),
                    ),
                    ...List.generate(12, (i) {
                      final date = DateTime(
                        DateTime.now().year,
                        DateTime.now().month - i,
                      );
                      return DropdownMenuItem(
                        value: date,
                        child: Text(DateFormat('MMMM yyyy').format(date)),
                      );
                    }),
                  ],
                  onChanged: orderController.filterByMonth,
                ),
              ),
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: orderController.fetchOrders,
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: orderController.downloadAllOrdersPdf,
                icon: const Icon(
                  Icons.picture_as_pdf,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Download PDF',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(RequestOrderController orderController) {
    final total = orderController.orders.length;
    final masuk = orderController.orders
        .where((o) => o.status == RequestOrderStatus.masuk)
        .length;
    final negosiasi = orderController.orders
        .where((o) => o.status == RequestOrderStatus.negosiasi)
        .length;
    final deal = orderController.orders
        .where((o) => o.status == RequestOrderStatus.deal)
        .length;
    final ditolak = orderController.orders
        .where((o) => o.status == RequestOrderStatus.ditolak)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', total.toString(), Colors.grey.shade700),
          _buildSummaryItem('Masuk', masuk.toString(), const Color(0xFF3B82F6)),
          _buildSummaryItem(
            'Negosiasi',
            negosiasi.toString(),
            const Color(0xFFF59E0B),
          ),
          _buildSummaryItem('Deal', deal.toString(), const Color(0xFF22C55E)),
          _buildSummaryItem(
            'Ditolak',
            ditolak.toString(),
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildOrderTable(
    RequestOrderController orderController,
    bool isMobile,
  ) {
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
                      order.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    _buildStatusBadge(
                      order.status.label,
                      orderController.getStatusColor(order.status),
                      orderController.getStatusBgColor(order.status),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  order.namaEO,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildActionBtn(
                    Icons.visibility_rounded,
                    AppTheme.accentColor,
                    () => orderController.goToDetail(order),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    
    // Desktop/Web view - Custom responsive full-width table
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE6FBFF),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'ID Request',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nama Event Organizer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Aksi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ...orderController.orders.asMap().entries.map((entry) {
            final index = entry.key;
            final order = entry.value;
            final isLast = index == orderController.orders.length - 1;
            
            return Container(
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : const Color(0xFFF9FAFB),
                border: Border(
                  bottom: BorderSide(
                    color: isLast ? Colors.transparent : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                borderRadius: isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(12))
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      order.id,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF2D3748),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      order.namaEO,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2D3748),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      order.email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _buildStatusBadge(
                        order.status.label,
                        orderController.getStatusColor(order.status),
                        orderController.getStatusBgColor(order.status),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: _buildActionBtn(
                        Icons.visibility_rounded,
                        AppTheme.accentColor,
                        () => orderController.goToDetail(order),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
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
          _buildHeader(
            context,
            isMobile,
            'Invoice',
            'Kelola invoice pelanggan',
          ),
          // Filter & Actions Bar
          _buildInvoiceFilterBar(invoiceController, isMobile),
          Expanded(
            child: SingleChildScrollView(
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
                child: Obx(() {
                  if (invoiceController.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (invoiceController.invoices.isEmpty) {
                    return _buildEmptyState('Invoice', Icons.receipt_rounded);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary
                      _buildInvoiceSummary(invoiceController),
                      const SizedBox(height: 16),
                      _buildInvoiceTable(invoiceController, isMobile),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceFilterBar(
    InvoiceUIController invoiceController,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 12,
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        children: [
          // Month Filter
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DateTime?>(
                  value: invoiceController.selectedMonth.value,
                  hint: const Text('Filter Bulan'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Semua Bulan'),
                    ),
                    ...List.generate(12, (i) {
                      final date = DateTime(
                        DateTime.now().year,
                        DateTime.now().month - i,
                      );
                      return DropdownMenuItem(
                        value: date,
                        child: Text(DateFormat('MMMM yyyy').format(date)),
                      );
                    }),
                  ],
                  onChanged: invoiceController.filterByMonth,
                ),
              ),
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: invoiceController.fetchInvoices,
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: invoiceController.downloadAllInvoicesPdf,
                icon: const Icon(
                  Icons.picture_as_pdf,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Download PDF',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummary(InvoiceUIController invoiceController) {
    final total = invoiceController.invoices.length;
    final belumBayar = invoiceController.invoices
        .where((i) => i.paymentStatus == InvoicePaymentStatus.belumBayar)
        .length;
    final sudahDp = invoiceController.invoices
        .where((i) => i.paymentStatus == InvoicePaymentStatus.sudahDp)
        .length;
    final lunas = invoiceController.invoices
        .where((i) => i.paymentStatus == InvoicePaymentStatus.lunas)
        .length;
    final totalAmount = invoiceController.invoices.fold<double>(
      0,
      (sum, i) => sum + i.totalAmount,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', total.toString(), Colors.grey.shade700),
          _buildSummaryItem(
            'Belum Bayar',
            belumBayar.toString(),
            const Color(0xFFEF4444),
          ),
          _buildSummaryItem(
            'Sudah DP',
            sudahDp.toString(),
            const Color(0xFFF59E0B),
          ),
          _buildSummaryItem('Lunas', lunas.toString(), const Color(0xFF22C55E)),
          _buildSummaryItem(
            'Nilai Total',
            'Rp ${(totalAmount / 1000000).toStringAsFixed(1)}jt',
            AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTable(
    InvoiceUIController invoiceController,
    bool isMobile,
  ) {
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
                    _buildStatusBadge(
                      invoice.paymentStatus.label,
                      invoiceController.getStatusColor(invoice.paymentStatus),
                      invoiceController.getStatusBgColor(invoice.paymentStatus),
                    ),
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
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
                  child: _buildActionBtn(
                    Icons.visibility_rounded,
                    AppTheme.accentColor,
                    () => invoiceController.goToDetail(invoice),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    
    // Desktop/Web view - Custom responsive full-width table
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE6FBFF),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'ID Invoice',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nama Event Organizer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Aksi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ...invoiceController.invoices.asMap().entries.map((entry) {
            final index = entry.key;
            final invoice = entry.value;
            final isLast = index == invoiceController.invoices.length - 1;
            
            return Container(
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : const Color(0xFFF9FAFB),
                border: Border(
                  bottom: BorderSide(
                    color: isLast ? Colors.transparent : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                borderRadius: isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(12))
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      invoice.invoiceNumber,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF2D3748),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      invoice.namaEO,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2D3748),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      invoice.email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      invoice.formattedTotal,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _buildStatusBadge(
                        invoice.paymentStatus.label,
                        invoiceController.getStatusColor(invoice.paymentStatus),
                        invoiceController.getStatusBgColor(invoice.paymentStatus),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: _buildActionBtn(
                        Icons.visibility_rounded,
                        AppTheme.accentColor,
                        () => invoiceController.goToDetail(invoice),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ==================== SHARED WIDGETS ====================
  Widget _buildStatusBadge(String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
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
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
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
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada $title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data $title akan muncul di sini',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isMobile,
    String title,
    String subtitle,
  ) {
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
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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
    return Obx(() {
      if (controller.isLoadingStats.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final stats = [
        _StatData(
          value: controller.totalOrders.value.toString(),
          label: 'Total Orderan',
          icon: Icons.shopping_bag_rounded,
          color: const Color(0xFF4F46E5),
          bgColor: const Color(0xFFEEF2FF),
        ),
        _StatData(
          value: controller.pendingOrders.value.toString(),
          label: 'Menunggu',
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFEF3C7),
        ),
        _StatData(
          value: controller.completedOrders.value.toString(),
          label: 'Selesai (Deal)',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
          bgColor: const Color(0xFFD1FAE5),
        ),
        _StatData(
          value: controller.totalActiveCatalogs.value.toString(),
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

      // Desktop/Web view - cards sama rata dan memenuhi layar
      return Row(
        children: [
          Expanded(child: _buildStatCard(stats[0])),
          const SizedBox(width: 20),
          Expanded(child: _buildStatCard(stats[1])),
          const SizedBox(width: 20),
          Expanded(child: _buildStatCard(stats[2])),
          const SizedBox(width: 20),
          Expanded(child: _buildStatCard(stats[3])),
        ],
      );
    });
  }

  Widget _buildStatCard(_StatData stat) {
    return Container(
      width: double.infinity,
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
            child: Icon(stat.icon, color: stat.color, size: 24),
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
            TextButton.icon(
              onPressed: controller.fetchActivities,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingActivities.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.activities.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada aktivitas',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
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
              children: controller.activities.asMap().entries.map((entry) {
                final index = entry.key;
                final activity = entry.value;
                return Column(
                  children: [
                    _buildActivityItemFromData(activity),
                    if (index < controller.activities.length - 1)
                      Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                        indent: 68,
                      ),
                  ],
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActivityItemFromData(ActivityItem activity) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activity.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activity.icon, color: activity.iconColor, size: 22),
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
                  activity.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            activity.formattedTime,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
