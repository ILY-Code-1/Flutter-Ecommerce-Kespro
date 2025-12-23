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
                  _HighlightCard(),
                  SizedBox(height: 24),
                  _HighlightCard(),
                ],
              )
            : Row(
                children: const [
                  Expanded(child: _HighlightCard()),
                  SizedBox(width: 24),
                  Expanded(child: _HighlightCard()),
                ],
              ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'Highlight Content',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
