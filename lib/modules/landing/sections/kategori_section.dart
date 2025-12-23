import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/responsive_wrapper.dart';
import '../../../widgets/section_title.dart';

class KategoriSection extends StatelessWidget {
  const KategoriSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWrapper.isMobile(context);
    final isTablet = ResponsiveWrapper.isTablet(context);

    int crossAxisCount = 4;
    if (isMobile) crossAxisCount = 2;
    if (isTablet) crossAxisCount = 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ResponsiveWrapper(
        child: Column(
          children: [
            const SectionTitle(title: 'KATEGORI'),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: 8,
                itemBuilder: (context, index) => const _KategoriItem(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KategoriItem extends StatelessWidget {
  const _KategoriItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_view_rounded,
            size: 36,
            color: AppTheme.primaryColor,
          ),
          SizedBox(height: 8),
          Text(
            'Kategori',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
