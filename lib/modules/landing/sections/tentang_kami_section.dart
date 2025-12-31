import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/responsive_wrapper.dart';
import '../../../widgets/section_title.dart';

class TentangKamiSection extends StatelessWidget {
  const TentangKamiSection({super.key});

  static const List<Map<String, dynamic>> features = [
    {
      'icon': Icons.verified_outlined,
      'title': 'Terpercaya',
      'desc': 'Mitra terpercaya untuk Event Organizer',
    },
    {
      'icon': Icons.speed_outlined,
      'title': 'Responsif',
      'desc': 'Layanan cepat dan koordinasi efisien',
    },
    {
      'icon': Icons.tune_outlined,
      'title': 'Fleksibel',
      'desc': 'Disesuaikan dengan kebutuhan event',
    },
    {
      'icon': Icons.workspace_premium_outlined,
      'title': 'Berkualitas',
      'desc': 'Properti event berkualitas tinggi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWrapper.isMobile(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ResponsiveWrapper(
        child: Column(
          children: [
            const SectionTitle(title: 'TENTANG KAMI'),
            const SizedBox(height: 16),
            if (isMobile)
              Column(
                children: [
                  _buildInfoCard(context),
                  const SizedBox(height: 24),
                  _buildFeaturesGrid(context, isMobile),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildInfoCard(context),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: _buildFeaturesGrid(context, isMobile),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KESPRO',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Produksi Event',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Kespro adalah mitra penyedia properti event terpercaya untuk Event Organizer. Kami menghadirkan berbagai perlengkapan event berkualitas, mulai dari backdrop, sound system, lighting, hingga properti pendukung lainnya.',
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dengan pengalaman di bidang produksi event, kami memahami pentingnya ketepatan, fleksibilitas, dan kualitas properti untuk menunjang kesuksesan setiap acara.',
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.handshake_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Partner Andal Anda',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: features.map((feature) {
        return SizedBox(
          width: isMobile
              ? (MediaQuery.of(context).size.width - 64) / 2
              : double.infinity,
          child: _FeatureCard(
            icon: feature['icon'],
            title: feature['title'],
            desc: feature['desc'],
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
