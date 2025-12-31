import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/app_theme.dart';
import '../routes/app_routes.dart';
import '../modules/landing/landing_controller.dart';

class NavBar extends StatelessWidget {
  final LandingController? controller;
  
  const NavBar({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand
          Flexible(
            child: GestureDetector(
              onTap: () {
                if (controller != null) {
                  controller!.scrollToSection(controller!.heroKey);
                } else {
                  Get.offAllNamed(AppRoutes.landing);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Kespro Event Hub',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Menu
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavItem(
                  title: 'Beranda',
                  onTap: () => controller?.scrollToSection(controller!.heroKey),
                ),
                _NavItem(
                  title: 'Kategori',
                  onTap: () => controller?.scrollToSection(controller!.kategoriKey),
                ),
                _NavItem(
                  title: 'Cara Sewa',
                  onTap: () => controller?.scrollToSection(controller!.caraSewaKey),
                ),
                _NavItem(
                  title: 'Tentang Kami',
                  onTap: () => controller?.scrollToSection(controller!.tentangKey),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _NavItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final LandingController? controller;
  
  const AppDrawer({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Beranda'),
              onTap: () {
                Navigator.pop(context);
                controller?.scrollToSection(controller!.heroKey);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Kategori'),
              onTap: () {
                Navigator.pop(context);
                controller?.scrollToSection(controller!.kategoriKey);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Cara Sewa'),
              onTap: () {
                Navigator.pop(context);
                controller?.scrollToSection(controller!.caraSewaKey);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Kami'),
              onTap: () {
                Navigator.pop(context);
                controller?.scrollToSection(controller!.tentangKey);
              },
            ),
          ],
        ),
      ),
    );
  }
}
