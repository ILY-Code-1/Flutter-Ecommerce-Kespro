import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/responsive_wrapper.dart';
import '../../../routes/app_routes.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWrapper.isMobile(context);
    final isTablet = ResponsiveWrapper.isTablet(context);
    
    // Pilih gambar berdasarkan device
    String getHeroImage() {
      if (isMobile) return 'assets/images/hero/hero_mobile.webp';
      if (isTablet) return 'assets/images/hero/hero_tablet.webp';
      return 'assets/images/hero/hero_desktop.webp';
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      decoration: BoxDecoration(
        // Gradient sebagai fallback jika gambar belum ada
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Image dengan optimasi
          Positioned.fill(
            child: Image.asset(
              getHeroImage(),
              fit: BoxFit.cover,
              // Optimasi: gunakan cache
              cacheHeight: isMobile ? 1334 : (isTablet ? 720 : 1080),
              cacheWidth: isMobile ? 750 : (isTablet ? 1280 : 1920),
              // Placeholder saat loading
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              // Error handler - tampilkan gradient jika gambar gagal load
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Dark overlay untuk readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          // Content
          ResponsiveWrapper(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Kespro Event Hub',
                  style: TextStyle(
                    fontSize: isMobile ? 36 : 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Solusi Properti Event Terbaik untuk Event Organizer',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    color: Colors.white.withValues(alpha: 0.95),
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'ORDER NOW',
                  backgroundColor: AppTheme.accentColor,
                  onPressed: () => Get.toNamed(AppRoutes.order),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
