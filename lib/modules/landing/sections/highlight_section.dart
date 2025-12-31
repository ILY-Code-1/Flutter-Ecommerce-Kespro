import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/responsive_wrapper.dart';

class HighlightSection extends StatelessWidget {
  const HighlightSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWrapper.isMobile(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ResponsiveWrapper(
        child: isMobile
            ? Column(
                children: const [
                  _HighlightCard(
                    imagePath: 'assets/images/highlights/highlight_1.webp',
                    title: 'Lengkap & Berkualitas',
                    description: 'Properti event terlengkap dengan kualitas terjamin',
                  ),
                  SizedBox(height: 24),
                  _HighlightCard(
                    imagePath: 'assets/images/highlights/highlight_2.webp',
                    title: 'Harga Terjangkau',
                    description: 'Solusi sewa properti dengan harga kompetitif',
                  ),
                ],
              )
            : Row(
                children: const [
                  Expanded(
                    child: _HighlightCard(
                      imagePath: 'assets/images/highlights/highlight_1.webp',
                      title: 'Lengkap & Berkualitas',
                      description: 'Properti event terlengkap dengan kualitas terjamin',
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: _HighlightCard(
                      imagePath: 'assets/images/highlights/highlight_2.webp',
                      title: 'Harga Terjangkau',
                      description: 'Solusi sewa properti dengan harga kompetitif',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _HighlightCard({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image dengan optimasi
            Expanded(
              flex: 3,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                // Optimasi: cache dengan ukuran tetap
                cacheHeight: 600,
                cacheWidth: 800,
                // Fade in animation
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                // Error fallback - tampilkan placeholder
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not found',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Text content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
