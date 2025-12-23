import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/nav_bar.dart';
import 'landing_controller.dart';
import 'sections/hero_section.dart';
import 'sections/highlight_section.dart';
import 'sections/kategori_section.dart';
import 'sections/cara_sewa_section.dart';
import 'sections/tentang_kami_section.dart';
import 'sections/footer_section.dart';

class LandingPage extends GetView<LandingController> {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: AppDrawer(controller: controller),
      body: Column(
        children: [
          NavBar(controller: controller),
          Expanded(
            child: SingleChildScrollView(
              controller: controller.scrollController,
              child: Column(
                children: [
                  HeroSection(key: controller.heroKey),
                  const HighlightSection(),
                  KategoriSection(key: controller.kategoriKey),
                  CaraSewaSection(key: controller.caraSewaKey),
                  TentangKamiSection(key: controller.tentangKey),
                  const FooterSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
