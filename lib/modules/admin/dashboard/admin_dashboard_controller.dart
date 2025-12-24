import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_theme.dart';

/// Model untuk aktivitas
class ActivityItem {
  final String id;
  final String type; // 'order', 'invoice', 'catalog'
  final String title;
  final String description;
  final DateTime timestamp;
  final String? status;

  ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.status,
  });

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('dd MMM yyyy').format(timestamp);
  }

  IconData get icon {
    switch (type) {
      case 'order': return Icons.shopping_cart_rounded;
      case 'invoice': return Icons.receipt_long_rounded;
      case 'catalog': return Icons.inventory_2_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'order': return const Color(0xFF3B82F6);
      case 'invoice': return const Color(0xFF22C55E);
      case 'catalog': return const Color(0xFFF59E0B);
      default: return Colors.grey;
    }
  }
}

class AdminDashboardController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  final selectedMenuIndex = 0.obs;

  final menuItems = [
    'Beranda',
    'Katalog',
    'Request Order',
    'Invoice',
    'Logout',
  ];

  // Dashboard Stats - default bulan ini
  final selectedMonth = Rxn<DateTime>();
  final isLoadingStats = false.obs;
  
  // Stats data
  final totalOrders = 0.obs;
  final pendingOrders = 0.obs; // status: masuk, negosiasi
  final completedOrders = 0.obs; // status: deal
  final totalActiveCatalogs = 0.obs;
  final totalInvoices = 0.obs;
  final totalRevenue = 0.0.obs;

  // Activities
  final activities = <ActivityItem>[].obs;
  final isLoadingActivities = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Default ke bulan ini
    selectedMonth.value = DateTime(DateTime.now().year, DateTime.now().month);
    fetchDashboardData();
  }

  /// Fetch all dashboard data
  Future<void> fetchDashboardData() async {
    await Future.wait([
      fetchStats(),
      fetchActivities(),
    ]);
  }

  /// Refresh dashboard
  Future<void> refreshDashboard() async {
    await fetchDashboardData();
    Get.snackbar('Berhasil', 'Data dashboard diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade700);
  }

  /// Fetch statistics for current month
  Future<void> fetchStats() async {
    try {
      isLoadingStats.value = true;

      final month = selectedMonth.value ?? DateTime.now();
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      // Fetch orders for current month
      final ordersResponse = await _supabase
          .from('request_orders')
          .select('id, status')
          .isFilter('deleted_at', null)
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String());

      final orders = List<Map<String, dynamic>>.from(ordersResponse);
      totalOrders.value = orders.length;
      pendingOrders.value = orders.where((o) => 
          o['status'] == 'masuk' || o['status'] == 'negosiasi').length;
      completedOrders.value = orders.where((o) => o['status'] == 'deal').length;

      // Fetch active catalogs (tidak terbatas bulan)
      final catalogsResponse = await _supabase
          .from('catalogs')
          .select('id')
          .isFilter('deleted_at', null)
          .eq('is_active', true);
      totalActiveCatalogs.value = (catalogsResponse as List).length;

      // Fetch invoices for current month
      final invoicesResponse = await _supabase
          .from('invoices')
          .select('id, total_amount, payment_status')
          .isFilter('deleted_at', null)
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String());

      final invoices = List<Map<String, dynamic>>.from(invoicesResponse);
      totalInvoices.value = invoices.length;
      
      // Calculate revenue from paid invoices
      totalRevenue.value = invoices
          .where((i) => i['payment_status'] == 'lunas')
          .fold<double>(0, (sum, i) => sum + ((i['total_amount'] as num?)?.toDouble() ?? 0));

    } catch (e) {
      debugPrint('Error fetching stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Fetch recent activities
  Future<void> fetchActivities() async {
    try {
      isLoadingActivities.value = true;
      final List<ActivityItem> allActivities = [];

      // Fetch recent orders (last 10)
      final ordersResponse = await _supabase
          .from('request_orders')
          .select('id, nama_eo, status, created_at')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(10);

      for (var order in ordersResponse) {
        allActivities.add(ActivityItem(
          id: order['id'],
          type: 'order',
          title: 'Request Order Baru',
          description: '${order['nama_eo']} - ${_getStatusLabel(order['status'])}',
          timestamp: DateTime.parse(order['created_at']),
          status: order['status'],
        ));
      }

      // Fetch recent invoices (last 10)
      final invoicesResponse = await _supabase
          .from('invoices')
          .select('id, invoice_number, nama_eo, payment_status, created_at')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(10);

      for (var invoice in invoicesResponse) {
        allActivities.add(ActivityItem(
          id: invoice['id'],
          type: 'invoice',
          title: 'Invoice ${invoice['invoice_number']}',
          description: '${invoice['nama_eo']} - ${_getPaymentStatusLabel(invoice['payment_status'])}',
          timestamp: DateTime.parse(invoice['created_at']),
          status: invoice['payment_status'],
        ));
      }

      // Sort by timestamp descending and take top 15
      allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      activities.assignAll(allActivities.take(15).toList());

    } catch (e) {
      debugPrint('Error fetching activities: $e');
    } finally {
      isLoadingActivities.value = false;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'masuk': return 'Masuk';
      case 'negosiasi': return 'Negosiasi';
      case 'deal': return 'Deal';
      case 'ditolak': return 'Ditolak';
      default: return status ?? '-';
    }
  }

  String _getPaymentStatusLabel(String? status) {
    switch (status) {
      case 'belum_bayar': return 'Belum Bayar';
      case 'sudah_dp': return 'Sudah DP';
      case 'lunas': return 'Lunas';
      default: return status ?? '-';
    }
  }

  /// Change month filter
  void changeMonth(DateTime? month) {
    selectedMonth.value = month ?? DateTime(DateTime.now().year, DateTime.now().month);
    fetchStats();
  }

  /// Get formatted month label
  String get monthLabel {
    if (selectedMonth.value == null) return 'Bulan Ini';
    return DateFormat('MMMM yyyy').format(selectedMonth.value!);
  }

  void selectMenu(int index) {
    if (menuItems[index] == 'Logout') {
      _showLogoutConfirmation();
      return;
    }
    
    selectedMenuIndex.value = index;
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 36,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Konfirmasi Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin keluar dari akun ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.offAllNamed(AppRoutes.adminLogin);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ya, Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
