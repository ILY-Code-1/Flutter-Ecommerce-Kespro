import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../themes/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../routes/app_routes.dart';
import '../order/order_controller.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  // GANTI DENGAN NOMOR WHATSAPP ADMIN ANDA (format: 62xxx tanpa +)
  static const String adminWhatsApp = '6285178226071';

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWrapper.isMobile(context);
    final orderController = Get.find<OrderController>();
    final orderData = orderController.lastOrderData.value;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ResponsiveWrapper(
              maxWidth: 600,
              child: Container(
                padding: EdgeInsets.all(isMobile ? 24 : 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'TERIMAKASIH!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Request Order Berhasil Dikirim',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Order Summary
                    if (orderData != null)
                      _buildOrderSummary(orderData, isMobile),
                    const SizedBox(height: 24),

                    // Info Text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Untuk mempercepat proses, silahkan hubungi admin kami via WhatsApp',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // WhatsApp Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'CHAT WHATSAPP',
                        backgroundColor: const Color(0xFF25D366),
                        onPressed: () => _openWhatsApp(orderController),
                        height: 56,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Back to Home
                    TextButton.icon(
                      onPressed: () => Get.offAllNamed(AppRoutes.landing),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.primaryColor,
                      ),
                      label: const Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(Map<String, dynamic> orderData, bool isMobile) {
    final catalogs = orderData['catalogs'] as List? ?? [];
    final tanggal = orderData['tanggal_mulai'] as DateTime?;
    final formattedDate = tanggal != null
        ? '${tanggal.day}/${tanggal.month}/${tanggal.year}'
        : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Order',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),

          // Customer Info
          _buildSummaryRow('Nama', orderData['nama_eo'] ?? '-'),
          _buildSummaryRow('Email', orderData['email'] ?? '-'),
          _buildSummaryRow('WhatsApp', orderData['whatsapp'] ?? '-'),

          const Divider(height: 24),

          // Event Info
          _buildSummaryRow('Tanggal', formattedDate),
          _buildSummaryRow('Lokasi', orderData['lokasi'] ?? '-'),
          _buildSummaryRow('Durasi', orderData['durasi'] ?? '-'),

          const Divider(height: 24),

          // Products
          const Text(
            'Produk:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 8),
          ...catalogs.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        c['name'] ?? '',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    c['price'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 24),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Estimasi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                orderData['total'] ?? 'Rp 0',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(OrderController controller) async {
    final url = controller.getWhatsAppUrl(adminWhatsApp);
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Tidak dapat membuka WhatsApp',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade700,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka WhatsApp: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
    }
  }
}
