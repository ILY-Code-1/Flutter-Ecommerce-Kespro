import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../themes/app_theme.dart';
import '../admin_dashboard_controller.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah di-register, jika belum maka register
    final controller = Get.isRegistered<AdminDashboardController>()
        ? Get.find<AdminDashboardController>()
        : Get.put(AdminDashboardController(), permanent: true);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          // Logo section with gradient background
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  const Color(0xFF667eea).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF667eea),
                        AppTheme.primaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.event_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kespro',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'Event Hub',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Menu label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MENU UTAMA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.menuItems.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  final isActive = controller.selectedMenuIndex.value == index;
                  final isLogout = controller.menuItems[index] == 'Logout';

                  if (isLogout) {
                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        Divider(color: Colors.grey.shade200, height: 1),
                        const SizedBox(height: 8),
                        _buildMenuItem(
                          controller: controller,
                          index: index,
                          isActive: isActive,
                          isLogout: true,
                        ),
                      ],
                    );
                  }

                  return _buildMenuItem(
                    controller: controller,
                    index: index,
                    isActive: isActive,
                    isLogout: false,
                  );
                });
              },
            ),
          ),
          // Footer
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                        const Color(0xFF667eea),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.headset_mic_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Butuh Bantuan?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        'Hubungi support',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required AdminDashboardController controller,
    required int index,
    required bool isActive,
    required bool isLogout,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectMenu(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF667eea),
                        AppTheme.primaryColor,
                      ],
                    )
                  : null,
              color: isLogout && !isActive
                  ? Colors.red.withValues(alpha: 0.05)
                  : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.2)
                        : isLogout
                            ? Colors.red.withValues(alpha: 0.1)
                            : AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconForMenu(controller.menuItems[index]),
                    color: isActive
                        ? Colors.white
                        : isLogout
                            ? Colors.red.shade400
                            : AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.menuItems[index],
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : isLogout
                              ? Colors.red.shade400
                              : const Color(0xFF4A5568),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForMenu(String menu) {
    switch (menu) {
      case 'Beranda':
        return Icons.dashboard_rounded;
      case 'Katalog':
        return Icons.inventory_2_rounded;
      case 'Request Order':
        return Icons.shopping_cart_rounded;
      case 'Invoice':
        return Icons.receipt_long_rounded;
      case 'Jadwal Sewa':
        return Icons.calendar_month_rounded;
      case 'Logout':
        return Icons.logout_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}
