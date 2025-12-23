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
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
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
      child: ResponsiveWrapper(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'HERO SECTION',
              style: TextStyle(
                fontSize: ResponsiveWrapper.isMobile(context) ? 36 : 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Solusi Properti Event Terbaik untuk Event Organizer',
              style: TextStyle(
                fontSize: ResponsiveWrapper.isMobile(context) ? 16 : 20,
                color: Colors.white.withValues(alpha: 0.9),
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
    );
  }
}
