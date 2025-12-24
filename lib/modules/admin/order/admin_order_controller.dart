import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

/// Controller untuk mengelola state Order di Admin Dashboard
/// 
/// Access Control:
/// - READ: Admin only
/// - UPDATE/DELETE: Admin only
/// - CREATE: Handled by public OrderController (landing page)
class AdminOrderController extends GetxController {
  final OrderRepository _repository = OrderRepository();

  // State management
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final selectedOrder = Rxn<OrderModel>();

  // Filter state
  final selectedStatusFilter = Rxn<OrderStatus>();

  // Statistics
  final statistics = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    fetchStatistics();
  }

  /// Fetch semua orders dari Supabase (Admin only)
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      List<OrderModel> items;
      if (selectedStatusFilter.value != null) {
        items = await _repository.fetchByStatus(selectedStatusFilter.value!);
      } else {
        items = await _repository.fetchAll();
      }
      orders.assignAll(items);
    } catch (e) {
      errorMessage.value = e.toString();
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch statistik order (Admin only)
  Future<void> fetchStatistics() async {
    try {
      final stats = await _repository.getStatistics();
      statistics.assignAll(stats);
    } catch (e) {
      // Silent fail for statistics
    }
  }

  /// Filter orders berdasarkan status
  void filterByStatus(OrderStatus? status) {
    selectedStatusFilter.value = status;
    fetchOrders();
  }

  /// View order detail
  void viewOrderDetail(OrderModel order) {
    selectedOrder.value = order;
    // Navigate to detail page or show dialog
  }

  /// Update status order (Admin only)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      isLoading.value = true;
      final updatedOrder = await _repository.updateStatus(
        id: orderId,
        status: newStatus,
      );

      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = updatedOrder;
      }

      // Update statistics
      fetchStatistics();

      _showSuccessSnackbar('Status order berhasil diupdate');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete order dengan konfirmasi (Admin only)
  void deleteOrder(OrderModel order) {
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
                  Icons.delete_outline_rounded,
                  size: 36,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hapus Order',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus order dari "${order.customerName}"?',
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
                      onPressed: () => _confirmDelete(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ya, Hapus',
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

  /// Execute delete after confirmation
  Future<void> _confirmDelete(OrderModel order) async {
    try {
      Get.back(); // Close dialog
      isLoading.value = true;
      await _repository.delete(order.id);
      orders.removeWhere((o) => o.id == order.id);
      fetchStatistics();
      _showSuccessSnackbar('Order berhasil dihapus');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Get orders count by status
  int getOrderCountByStatus(OrderStatus status) {
    return statistics[status.value] ?? 0;
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Sukses',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade700,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade700,
    );
  }
}
