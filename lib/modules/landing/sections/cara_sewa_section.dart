import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/responsive_wrapper.dart';
import '../../../widgets/section_title.dart';

class CaraSewaSection extends StatelessWidget {
  const CaraSewaSection({super.key});

  static const List<Map<String, dynamic>> steps = [
    {
      'title': 'Pilih Produk',
      'desc': 'User Request Order produk yang dipilih dari katalog kami',
      'icon': Icons.shopping_cart_outlined,
    },
    {
      'title': 'Isi Form',
      'desc': 'Mengisi form dan mengirimkan catatan keperluan event Anda',
      'icon': Icons.edit_note_outlined,
    },
    {
      'title': 'Negosiasi',
      'desc': 'Negosiasi harga dan detail melalui WhatsApp dengan tim kami',
      'icon': Icons.chat_outlined,
    },
    {
      'title': 'Selesai',
      'desc': 'Kesepakatan dibuat dan orderan siap dikirim ke lokasi',
      'icon': Icons.check_circle_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWrapper.isMobile(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.03),
            Colors.white,
          ],
        ),
      ),
      child: ResponsiveWrapper(
        child: Column(
          children: [
            const SectionTitle(title: 'CARA SEWA'),
            const SizedBox(height: 8),
            Text(
              'Proses pemesanan yang mudah dan cepat',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),
            if (isMobile)
              Column(
                children: List.generate(
                  steps.length,
                  (index) => _StepCard(
                    number: index + 1,
                    title: steps[index]['title'],
                    desc: steps[index]['desc'],
                    icon: steps[index]['icon'],
                    isLast: index == steps.length - 1,
                  ),
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  steps.length,
                  (index) => Expanded(
                    child: _StepCardHorizontal(
                      number: index + 1,
                      title: steps[index]['title'],
                      desc: steps[index]['desc'],
                      icon: steps[index]['icon'],
                      isLast: index == steps.length - 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String desc;
  final IconData icon;
  final bool isLast;

  const _StepCard({
    required this.number,
    required this.title,
    required this.desc,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Step $number',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            height: 30,
            width: 2,
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}

class _StepCardHorizontal extends StatelessWidget {
  final int number;
  final String title;
  final String desc;
  final IconData icon;
  final bool isLast;

  const _StepCardHorizontal({
    required this.number,
    required this.title,
    required this.desc,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: isLast ? 0 : 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: number > 1 ? 1 : 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: isLast ? 0.3 : 1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
